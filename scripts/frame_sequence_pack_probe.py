#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FrameSequence 发布包闭包探针：实际导出 PCK，并交给 Godot 自己校验包内路径。

源目录闭包与 export_presets.cfg 声明覆盖都不等于发布包完整；本探针必须看到
真实 PCK 中的 Catalog、每个序列资源与全部延迟纹理路径。

不使用自写的 PCK 二进制解析器：PCK 头格式随引擎版本变化，误判会制造假通过或
假失败。改为在最小空工程中挂载 PCK，用引擎的 FileAccess 判定路径是否存在。

退出码：
- 0 已验证：PCK 内包含全部依赖，探针标记与 Godot 退出码一致；
- 1 验证失败：有效探针报告缺少依赖/错误，或 Godot 非零退出；
- 2 无法验证：缺少 Godot、导出预设、探针结果或结果协议无效。
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from tool_common import ROOT, SOURCE, resolve_godot, write_json

MANIFEST_PATHS = (
    SOURCE / "Art/frame_sequences/frame_sequence_export_dependencies.json",
    SOURCE / "Script/data/level_preload_export_dependencies.json",
)
EXPORT_PRESETS_PATH = SOURCE / "export_presets.cfg"
RESULT_PREFIX = "PACK_PROBE_RESULT="

PROBE_PROJECT = """config_version=5

[application]
config/name="bhyh_pack_probe"
"""

PROBE_SCRIPT = """extends SceneTree

const RESULT_PREFIX := "%s"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		print("PACK_PROBE_ERROR=usage: <pck> <manifest>")
		quit(2)
		return
	var pck_path := args[0]
	var manifest_path := args[1]
	var manifest_file := FileAccess.open(manifest_path, FileAccess.READ)
	if manifest_file == null:
		print("PACK_PROBE_ERROR=manifest unreadable")
		quit(2)
		return
	var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
	manifest_file.close()
	if not parsed is Dictionary:
		print("PACK_PROBE_ERROR=manifest not an object")
		quit(2)
		return
	var manifest: Dictionary = parsed
	var required: Array[String] = []
	var items: Variant = manifest.get("required", [])
	if not items is Array:
		print("PACK_PROBE_ERROR=manifest.required is not an array")
		quit(2)
		return
	for item in items:
		required.append(str(item))
	if not ProjectSettings.load_resource_pack(pck_path, true):
		print(
			RESULT_PREFIX
			+ JSON.stringify(
				{
					"ok": required.is_empty(),
					"required": required.size(),
					"imported": 0,
					"missing": required,
					"error": "load_resource_pack failed",
				}
			)
		)
		quit(1)
		return
	# 导出会把源文件重写为 *.remap、*.import 或导入容器（.ctex）；
	# 判定“资源可加载”必须走引擎的 ResourceLoader，而不是 FileAccess 的原始路径。
	var missing: Array[String] = []
	var imported: int = 0
	for path in required:
		if FileAccess.file_exists(path):
			continue
		if FileAccess.file_exists(path + ".remap") or FileAccess.file_exists(path + ".import"):
			imported += 1
			continue
		if ResourceLoader.exists(path):
			imported += 1
			continue
		missing.append(path)
	print(
		RESULT_PREFIX
		+ JSON.stringify(
			{"ok": missing.is_empty(), "required": required.size(), "imported": imported, "missing": missing}
		)
	)
	quit(0 if missing.is_empty() else 1)
""" % RESULT_PREFIX


def normalize(path: str) -> str:
    return path.replace("\\", "/")


def required_paths(manifest: dict[str, object]) -> list[str]:
    paths: list[str] = []
    catalog = str(manifest.get("catalog", ""))
    if catalog:
        paths.append(catalog)
    layout_catalog = str(manifest.get("layout_catalog", ""))
    if layout_catalog:
        paths.append(layout_catalog)
    equipment_catalog = str(manifest.get("equipment_catalog", ""))
    if equipment_catalog:
        paths.append(equipment_catalog)
    for key in (
        "sequences",
        "deferred_textures",
        "monster_scenes",
        "dynamic_monster_scenes",
        "bullet_scenes",
        "dynamic_textures",
        "layouts",
    ):
        items = manifest.get(key, [])
        if isinstance(items, list):
            paths.extend(str(item) for item in items)
    return paths


def find_preset_name() -> str:
    if not EXPORT_PRESETS_PATH.is_file():
        raise FileNotFoundError(f"缺少导出预设: {EXPORT_PRESETS_PATH.relative_to(ROOT)}")
    text = EXPORT_PRESETS_PATH.read_text(encoding="utf-8-sig")
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("name="):
            return stripped.split("=", 1)[1].strip().strip('"')
    raise ValueError("export_presets.cfg 未找到预设名称")


def run_export(godot: str, preset: str, output: Path, timeout: int) -> str | None:
    """返回失败原因；None 表示导出产生了 PCK。"""
    command = [godot, "--headless", "--path", str(SOURCE), "--export-pack", preset, str(output)]
    try:
        result = subprocess.run(
            command, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout
        )
    except subprocess.TimeoutExpired:
        return f"导出在 {timeout}s 内未完成"
    if output.is_file():
        return None
    detail = (result.stderr or result.stdout or "").strip().splitlines()
    return detail[-1] if detail else f"退出码 {result.returncode}"


def _interpret_probe_result(
    output: str,
    returncode: int,
    expected_count: int,
    stderr: str = "",
) -> tuple[int, dict[str, object], str]:
    marker_lines = [line[len(RESULT_PREFIX) :] for line in output.splitlines() if line.startswith(RESULT_PREFIX)]
    if not marker_lines:
        details = (stderr or output).strip().splitlines()
        return 2, {}, details[-1] if details else "探针未输出结果"
    if len(marker_lines) != 1:
        return 2, {}, "探针输出多个结果标记"
    try:
        payload = json.loads(marker_lines[0])
    except json.JSONDecodeError as error:
        return 2, {}, f"探针结果 JSON 无效: {error.msg}"
    if not isinstance(payload, dict):
        return 2, {}, "探针结果不是 JSON 对象"

    ok = payload.get("ok")
    required = payload.get("required")
    imported = payload.get("imported")
    missing = payload.get("missing")
    if not isinstance(ok, bool):
        return 2, {}, "探针结果 ok 不是布尔值"
    if type(required) is not int or type(imported) is not int:
        return 2, {}, "探针结果 required/imported 不是整数"
    if not isinstance(missing, list) or any(not isinstance(path, str) for path in missing):
        return 2, {}, "探针结果 missing 不是字符串数组"
    if "error" in payload and not isinstance(payload["error"], str):
        return 2, {}, "探针结果 error 不是字符串"
    if required != expected_count:
        return 2, {}, f"探针 required 数量不匹配: 收到 {required}, 预期 {expected_count}"
    if required < 0 or imported < 0 or imported > required or len(missing) > required:
        return 2, {}, "探针结果 required/imported/missing 数量无效"
    if ok != (len(missing) == 0):
        return 2, {}, "探针结果 ok 与 missing 列表不一致"

    declared_error = payload.get("error", "")
    if returncode != 0:
        detail = f"Godot 退出码 {returncode}"
        if declared_error:
            detail += f": {declared_error}"
        return 1, payload, detail
    if not ok or declared_error:
        detail = declared_error or f"探针报告缺少 {len(missing)} 条路径"
        return 1, payload, detail
    return 0, payload, ""


def run_probe(
    godot: str,
    pck: Path,
    manifest_copy: Path,
    timeout: int,
    expected_count: int,
) -> tuple[int, dict[str, object], str]:
    workdir = Path(tempfile.mkdtemp(prefix="bhyh_pack_probe_proj_"))
    try:
        try:
            (workdir / "project.godot").write_text(PROBE_PROJECT, encoding="utf-8", newline="\n")
            (workdir / "pack_probe.gd").write_text(PROBE_SCRIPT, encoding="utf-8", newline="\n")
            command = [
                godot,
                "--headless",
                "--path",
                str(workdir),
                "--script",
                "res://pack_probe.gd",
                "--",
                str(pck),
                str(manifest_copy),
            ]
            result = subprocess.run(
                command, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout
            )
        except subprocess.TimeoutExpired:
            return 2, {}, f"包内校验在 {timeout}s 内未完成"
        except OSError as error:
            return 2, {}, f"无法启动包内校验探针: {error}"
        return _interpret_probe_result(result.stdout or "", result.returncode, expected_count, result.stderr or "")
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


def _probe_result_contract_self_test() -> int:
    """不依赖 Godot：验证结果标记及退出码的 fail-closed 判定。"""
    expected_count = 3
    success = {"ok": True, "required": expected_count, "imported": 1, "missing": []}
    declared_miss = {
        "ok": False,
        "required": expected_count,
        "imported": 1,
        "missing": ["res://missing.tres"],
        "error": "resource missing",
    }

    def marked(payload: dict[str, object]) -> str:
        return RESULT_PREFIX + json.dumps(payload, ensure_ascii=False, sort_keys=True)

    missing_field = {"ok": True, "required": expected_count, "imported": 1}
    non_list_missing = {**success, "missing": "res://missing.tres"}
    count_mismatch = {**success, "required": expected_count - 1}
    wrong_type = {**success, "ok": 1}
    cases = (
        ("good result", marked(success), 0, 0),
        ("ok=false with exit 0", marked(declared_miss), 0, 1),
        ("exit 1 despite ok=true", marked(success), 1, 1),
        ("missing missing field", marked(missing_field), 0, 2),
        ("non-list missing", marked(non_list_missing), 0, 2),
        ("required count mismatch", marked(count_mismatch), 0, 2),
        ("malformed JSON", RESULT_PREFIX + "{not-json", 0, 2),
        ("malformed type", marked(wrong_type), 0, 2),
        ("no result marker", "", 0, 2),
    )
    failed = 0
    for name, output, returncode, expected_status in cases:
        status, payload, _ = _interpret_probe_result(output, returncode, expected_count)
        if status != expected_status or (status == 2 and payload):
            failed += 1
            print(
                f"[FAIL] 探针结果契约自检 {name}: expected status {expected_status}, got {status}",
                file=sys.stderr,
            )
    if failed:
        return 1
    print(f"[OK] 探针结果契约自检通过: {len(cases)} 个边界")
    return 0


def load_manifests(paths: list[Path]) -> list[dict[str, object]]:
    manifests: list[dict[str, object]] = []
    for path in paths:
        if not path.is_file():
            raise FileNotFoundError(f"缺少发布依赖清单: {path.relative_to(ROOT)}")
        data = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            raise ValueError(f"发布依赖清单不是 JSON 对象: {path.relative_to(ROOT)}")
        manifests.append(data)
    return manifests


def combined_required(manifests: list[dict[str, object]]) -> list[str]:
    paths = [path for manifest in manifests for path in required_paths(manifest)]
    return list(dict.fromkeys(paths))


def self_test(paths: list[Path] | None = None) -> int:
    """不依赖 Godot：验证清单结构与包内探针结果契约。"""
    contract_status = _probe_result_contract_self_test()
    manifest_paths = paths or list(MANIFEST_PATHS)
    try:
        manifests = load_manifests(manifest_paths)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"[FAIL] 发布依赖清单自检失败: {error}", file=sys.stderr)
        return 1
    required = combined_required(manifests)
    problems: list[str] = []
    for manifest in manifests:
        if not str(manifest.get("catalog", "")).startswith("res://"):
            problems.append("catalog 不是 res:// 路径")
        raw = [normalize(path) for path in required_paths(manifest)]
        if len(raw) != len(set(raw)):
            problems.append("单份清单包含重复路径")
    if len(required) < 2:
        problems.append("依赖路径数量不足")
    bad = [path for path in required if not path.startswith("res://")]
    if bad:
        problems.append(f"非 res:// 路径: {bad[:3]}")
    if problems:
        for problem in problems:
            print(f"[FAIL] {problem}", file=sys.stderr)
        return 1
    print(
        f"[OK] 发布依赖清单自检通过: {len(required)} 条路径"
        f"（{len(manifests)} 份清单：FrameSequence + 关卡预载）"
    )
    return contract_status




def main() -> int:
    parser = argparse.ArgumentParser(description="发布包依赖闭包探针（FrameSequence + 关卡预载）")
    parser.add_argument("--godot", default=None, help="Godot 可执行文件路径（或设 GODOT_BIN）")
    parser.add_argument("--preset", default=None, help="导出预设名称；默认取第一个预设")
    parser.add_argument("--manifest", action="append", default=None, help="依赖清单路径；可重复，默认读取两份构建清单")
    parser.add_argument("--self-test", action="store_true", help="校验依赖清单与探针结果契约")
    parser.add_argument("--report", default=None, help="可选 JSON 报告输出路径")
    parser.add_argument("--export-timeout", type=int, default=1800, help="导出子进程墙钟上限（秒）")
    parser.add_argument("--probe-timeout", type=int, default=300, help="包内校验子进程墙钟上限（秒）")
    args = parser.parse_args()
    manifest_paths = [Path(item) for item in args.manifest] if args.manifest else list(MANIFEST_PATHS)

    if args.self_test:
        return self_test(manifest_paths)

    try:
        manifests = load_manifests(manifest_paths)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        print(
            "[FAIL] 先运行 python scripts/convert_frame_sequences.py 与 "
            "python scripts/convert_level_preload_catalog.py 生成清单",
            file=sys.stderr,
        )
        return 1
    expected = [normalize(path) for path in combined_required(manifests)]

    godot = resolve_godot(args.godot)
    if godot is None:
        print("[BLOCKED] 未找到 Godot 可执行文件，无法导出 PCK；本项不得记为通过", file=sys.stderr)
        return 2
    try:
        preset = args.preset or find_preset_name()
    except (OSError, ValueError) as error:
        print(f"[BLOCKED] {error}", file=sys.stderr)
        return 2

    workdir = Path(tempfile.mkdtemp(prefix="bhyh_pack_probe_"))
    pck_path = workdir / "publish_probe.pck"
    manifest_copy = workdir / "manifest.json"
    manifest_copy.write_text(
        json.dumps({"required": expected}, ensure_ascii=False), encoding="utf-8"
    )
    try:
        failure = run_export(godot, preset, pck_path, max(args.export_timeout, 1))
        if failure is not None:
            print(f"[BLOCKED] 导出未产生 PCK，无法验证发布闭包: {failure}", file=sys.stderr)
            print("[BLOCKED] 常见原因：缺少导出模板（编辑器 Install Export Templates）", file=sys.stderr)
            return 2
        status, payload, error = run_probe(
            godot,
            pck_path.resolve(),
            manifest_copy.resolve(),
            max(args.probe_timeout, 1),
            len(expected),
        )
        if status == 2:
            print(f"[BLOCKED] 包内校验未取得有效结果: {error}", file=sys.stderr)
            return 2
        missing = payload["missing"]
        digest_handle = hashlib.sha256()
        with pck_path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1 << 20), b""):
                digest_handle.update(chunk)
        report = {
            "ok": status == 0,
            "probe_ok": payload["ok"],
            "probe_required": payload["required"],
            "probe_imported": payload["imported"],
            "probe_error": error,
            "preset": preset,
            "manifests": [str(path.relative_to(ROOT)) for path in manifest_paths],
            "pck_bytes": pck_path.stat().st_size,
            "pck_sha256": digest_handle.hexdigest(),
            "required_paths": len(expected),
            "missing": missing[:50],
            "missing_count": len(missing),
        }
        if args.report:
            write_json(Path(args.report), report)
        if status == 1:
            if missing:
                print(
                    f"[FAIL] PCK 缺少 {len(missing)}/{len(expected)} 条发布依赖，例如: "
                    + ", ".join(missing[:5]),
                    file=sys.stderr,
                )
            else:
                print(f"[FAIL] 包内校验未通过: {error}", file=sys.stderr)
            return 1
        print(
            f"[OK] PCK 闭包验证通过: {len(expected)} 条发布依赖全部在包内，"
            f"PCK {report['pck_bytes']} 字节，sha256 {report['pck_sha256'][:12]}"
        )
        return 0
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
