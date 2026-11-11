#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""发布包闭包探针：实际导出 PCK，并交给 Godot 校验保留与排除路径。

源目录闭包与 export_presets.cfg 声明覆盖都不等于发布包完整；本探针检查
FrameSequence、关卡预载依赖，并可验证排除资源不可达。

不使用自写的 PCK 二进制解析器；在最小空工程中挂载 PCK，用引擎检查路径。

退出码：
- 0 已验证：必需路径存在、指定排除路径不可达，探针标记与退出码一致；
- 1 验证失败：缺少依赖、意外包含排除资源或 Godot 非零退出；
- 2 无法验证：缺少 Godot、素材、导出预设、探针结果或结果协议无效。
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
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
	var excluded: Array[String] = []
	var excluded_items: Variant = manifest.get("excluded", [])
	if not excluded_items is Array:
		print("PACK_PROBE_ERROR=manifest.excluded is not an array")
		quit(2)
		return
	for item in excluded_items:
		excluded.append(str(item))
	if not ProjectSettings.load_resource_pack(pck_path, true):
		print(
			RESULT_PREFIX
			+ JSON.stringify(
				{
					"ok": required.is_empty(),
					"required": required.size(),
					"imported": 0,
					"missing": required,
					"excluded": excluded.size(),
					"unexpected": [],
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
	var unexpected: Array[String] = []
	for path in excluded:
		if (
			FileAccess.file_exists(path)
			or FileAccess.file_exists(path + ".remap")
			or FileAccess.file_exists(path + ".import")
			or ResourceLoader.exists(path)
		):
			unexpected.append(path)
	print(
		RESULT_PREFIX
		+ JSON.stringify(
			{
				"ok": missing.is_empty() and unexpected.is_empty(),
				"required": required.size(),
				"imported": imported,
				"missing": missing,
				"excluded": excluded.size(),
				"unexpected": unexpected,
			}
		)
	)
	quit(0 if missing.is_empty() and unexpected.is_empty() else 1)
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


def check_export_result(output: Path, returncode: int, log: str) -> tuple[int, str]:
    """导出文件存在不足以证明成功；报告引擎错误和非零退出。"""
    diagnostics = [
        line.strip() for line in log.splitlines()
        if line.lstrip().startswith(("SCRIPT ERROR:", "ERROR:", "WARNING:"))
    ]
    detail = " | ".join(diagnostics[:5])
    if returncode != 0:
        return 1, f"导出退出码 {returncode}" + (f"；{detail}" if detail else "")
    if diagnostics:
        return 1, detail
    if not output.is_file():
        return 2, "未生成导出文件"
    return 0, ""


def run_export(godot: str, preset: str, output: Path, timeout: int) -> tuple[int, str]:
    """导出 PCK 并校验退出码、产物和引擎日志。"""
    command = [godot, "--headless", "--path", str(SOURCE), "--export-pack", preset, str(output)]
    try:
        result = subprocess.run(
            command, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout
        )
    except subprocess.TimeoutExpired:
        return 2, f"导出在 {timeout}s 内未完成"
    except OSError as error:
        return 2, f"无法启动导出: {error}"
    return check_export_result(output, result.returncode, (result.stdout or "") + "\n" + (result.stderr or ""))


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
    excluded = payload.get("excluded", 0)
    unexpected = payload.get("unexpected", [])
    if not isinstance(ok, bool):
        return 2, {}, "探针结果 ok 不是布尔值"
    if type(required) is not int or type(imported) is not int:
        return 2, {}, "探针结果 required/imported 不是整数"
    if not isinstance(missing, list) or any(not isinstance(path, str) for path in missing):
        return 2, {}, "探针结果 missing 不是字符串数组"
    if type(excluded) is not int or not isinstance(unexpected, list) or any(
        not isinstance(path, str) for path in unexpected
    ):
        return 2, {}, "探针结果 excluded/unexpected 类型无效"
    if "error" in payload and not isinstance(payload["error"], str):
        return 2, {}, "探针结果 error 不是字符串"
    if required != expected_count:
        return 2, {}, f"探针 required 数量不匹配: 收到 {required}, 预期 {expected_count}"
    if required < 0 or imported < 0 or imported > required or len(missing) > required:
        return 2, {}, "探针结果 required/imported/missing 数量无效"
    if excluded < 0 or len(unexpected) > excluded:
        return 2, {}, "探针结果 excluded/unexpected 数量无效"
    if ok != (not missing and not unexpected):
        return 2, {}, "探针结果 ok 与 missing/unexpected 列表不一致"

    declared_error = payload.get("error", "")
    if returncode != 0:
        detail = f"Godot 退出码 {returncode}"
        if declared_error:
            detail += f": {declared_error}"
        return 1, payload, detail
    if not ok or declared_error:
        detail = declared_error or f"探针报告缺少 {len(missing)} 条路径，意外保留 {len(unexpected)} 条"
        return 1, payload, detail
    return 0, payload, ""


def run_probe(
    godot: str,
    pck: Path,
    manifest_copy: Path,
    timeout: int,
    expected_count: int,
    expected_excluded: int = 0,
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
        status, payload, error = _interpret_probe_result(
            result.stdout or "", result.returncode, expected_count, result.stderr or ""
        )
        if payload and expected_excluded and (
            payload.get("excluded") != expected_excluded or "unexpected" not in payload
        ):
            return 2, {}, "探针 excluded/unexpected 与请求不一致"
        return status, payload, error
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
    unexpected = {**success, "ok": False, "excluded": 1, "unexpected": ["res://excluded.png"]}
    cases = (
        ("good result", marked(success), 0, 0),
        ("ok=false with exit 0", marked(declared_miss), 0, 1),
        ("exit 1 despite ok=true", marked(success), 1, 1),
        ("unexpected exported resource", marked(unexpected), 1, 1),
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
    parser.add_argument("--check-exclusions", action="store_true", help="同时验证预设排除资源未进入 PCK")
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
    excluded: list[str] = []
    if args.check_exclusions:
        from export_asset_exclusions import run_check

        audit = run_check(SOURCE, EXPORT_PRESETS_PATH)
        if not audit["ok"]:
            print(f"[{audit['status']}] 资源排除策略未通过，无法校验发布包", file=sys.stderr)
            return 2 if audit["status"] == "BLOCKED" else 1
        if not any(item["name"] == preset and item["export_filter"] == "all_resources" for item in audit["presets"]):
            print(f"[FAIL] 预设未纳入 all_resources 排除策略: {preset}", file=sys.stderr)
            return 1
        excluded = audit["excluded_resources"]

        imported_targets: set[str] = set()
        for path in excluded:
            descriptor = SOURCE / (path.removeprefix("res://") + ".import")
            if descriptor.is_file():
                imported_targets.update(
                    re.findall(
                        r'res://\.godot/imported/[^"\]\s,]+',
                        descriptor.read_text(encoding="utf-8", errors="replace"),
                    )
                )
        excluded = list(dict.fromkeys(excluded + sorted(imported_targets)))

    workdir = Path(tempfile.mkdtemp(prefix="bhyh_pack_probe_"))
    pck_path = workdir / "publish_probe.pck"
    manifest_copy = workdir / "manifest.json"
    manifest_copy.write_text(
        json.dumps({"required": expected, "excluded": excluded}, ensure_ascii=False), encoding="utf-8"
    )
    try:
        export_status, failure = run_export(godot, preset, pck_path, max(args.export_timeout, 1))
        if export_status:
            print(f"[{'FAIL' if export_status == 1 else 'BLOCKED'}] PCK 导出未通过: {failure}", file=sys.stderr)
            return export_status
        status, payload, error = run_probe(
            godot,
            pck_path.resolve(),
            manifest_copy.resolve(),
            max(args.probe_timeout, 1),
            len(expected),
            len(excluded),
        )
        if status == 2:
            print(f"[BLOCKED] 包内校验未取得有效结果: {error}", file=sys.stderr)
            return 2
        missing = payload["missing"]
        unexpected = payload["unexpected"]
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
            "excluded_paths": len(excluded),
            "unexpected": unexpected[:50],
            "unexpected_count": len(unexpected),
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
            if unexpected:
                print(
                    f"[FAIL] PCK 意外保留 {len(unexpected)}/{len(excluded)} 条排除资源，例如: "
                    + ", ".join(unexpected[:5]),
                    file=sys.stderr,
                )
            if not missing and not unexpected:
                print(f"[FAIL] 包内校验未通过: {error}", file=sys.stderr)
            return 1
        print(
            f"[OK] PCK 闭包验证通过: {len(expected)} 条发布依赖在包内，{len(excluded)} 条排除资源不在包内，"
            f"PCK {report['pck_bytes']} 字节，sha256 {report['pck_sha256'][:12]}"
        )
        return 0
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
