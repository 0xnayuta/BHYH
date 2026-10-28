#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/convert_atlas_metadata.py

把运行时 atlas manifest.json 转换为 Godot 文本资源 metadata.tres（构建期中间产物）。

设计约定
--------
- 每个 manifest.json 在**同目录**生成 metadata.tres，运行时通过
  `AtlasMetadataStore.view_for()` 读取，不再解析 JSON；
- manifest.json 保留为构建期源数据，不参与运行时加载；
- 输出为 `AtlasMetadata` 自定义 Resource，`data` 字段完整保留原 JSON 结构。

用法
----
    python scripts/convert_atlas_metadata.py
    python scripts/convert_atlas_metadata.py --check
    python scripts/convert_atlas_metadata.py --project-dir source
"""

import argparse
import json
import math
import os
import sys
from typing import Any, List

SCRIPT_RES_PATH = "res://Script/atlas/atlas_metadata.gd"


def gd_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def gd_value(value: Any, level: int = 0) -> str:
    indent = "\t" * level
    child_indent = "\t" * (level + 1)
    if isinstance(value, dict):
        if not value:
            return "{}"
        items = [
            f"{child_indent}{gd_string(str(key))}: {gd_value(item, level + 1)}"
            for key, item in value.items()
        ]
        return "{\n" + ",\n".join(items) + "\n" + indent + "}"
    if isinstance(value, list):
        if not value:
            return "[]"
        items = [f"{child_indent}{gd_value(item, level + 1)}" for item in value]
        return "[\n" + ",\n".join(items) + "\n" + indent + "]"
    if isinstance(value, str):
        return gd_string(value)
    if isinstance(value, bool):
        return "true" if value else "false"
    if value is None:
        return "null"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        if math.isnan(value) or math.isinf(value):
            return "0.0"
        return repr(value)
    raise TypeError(f"不支持的 JSON 值类型: {type(value)!r}")


def normalize_payload(data: Any) -> dict:
    """字典原样保留；少数数组型 manifest 包装为可检索的稳定结构。"""
    if isinstance(data, dict):
        return data
    if isinstance(data, list):
        return {"__top_level": "array", "items": data}
    raise TypeError(f"不支持的 manifest 顶层类型: {type(data)!r}")


def render_tres(data: dict) -> str:
    lines = [
        '[gd_resource type="Resource" script_class="AtlasMetadata" load_steps=2 format=3]',
        "",
        f'[ext_resource type="Script" path="{SCRIPT_RES_PATH}" id="1_atlas_metadata"]',
        "",
        "[resource]",
        'script = ExtResource("1_atlas_metadata")',
        'schema_id = "atlas_metadata"',
        "schema_version = 1",
        f"data = {gd_value(data)}",
        "",
    ]
    return "\n".join(lines)


def manifest_frame_count(data: dict):
	"""返回 manifest 的源帧数；无法判定时返回 None。"""
	sequences = data.get("sequences")
	if isinstance(sequences, dict) and sequences:
		total = 0
		for value in sequences.values():
			if not isinstance(value, dict):
				return None
			frames = value.get("frames")
			if not isinstance(frames, list):
				return None
			total += len(frames)
		return total
	files = data.get("files")
	if isinstance(files, dict):
		return len(files)
	return None


def validate_frame_count(data: dict):
	"""校验 source_frames 声明；返回错误文本或 None。"""
	if not isinstance(data, dict):
		return None
	declared = data.get("source_frames")
	actual = manifest_frame_count(data)
	if declared is None or actual is None:
		return None
	try:
		declared_int = int(declared)
	except (TypeError, ValueError):
		return f"source_frames 不是整数: {declared!r}"
	if declared_int != actual:
		return f"source_frames={declared_int} 与实际帧数={actual} 不一致"
	return None


def run_frame_count_self_test() -> bool:
	"""帧数校验负向自测：坏样本必须报错，好样本必须放行。"""
	samples = [
		("sequence 少声明", {"source_frames": 1, "sequences": {"a": {"frames": [[0, 0, 0, 1, 1, 1, 0, 0, 0, 0]] * 2}}}, True),
		("sequence 正确", {"source_frames": 2, "sequences": {"a": {"frames": [[0, 0, 0, 1, 1, 1, 0, 0, 0, 0]] * 2}}}, False),
		("files 少声明", {"source_frames": 1, "files": {"a.png": [], "b.png": []}}, True),
		("files 正确", {"source_frames": 2, "files": {"a.png": [], "b.png": []}}, False),
	]
	failed = 0
	for label, payload, should_fail in samples:
		error = validate_frame_count(payload)
		if bool(error) != should_fail:
			failed += 1
			print(f"[FAIL] {label}: {error or '未报错'}")
		else:
			print(f"[OK] {label}: {error or '放行'}")
	if failed:
		print(f"[FAIL] 帧数校验负向自测失败 {failed}/{len(samples)}", file=sys.stderr)
		return False
	print(f"[SUCCESS] 帧数校验负向自测通过 ({len(samples)} 样本)")
	return True


def collect_manifests(project_dir: str) -> List[str]:
    manifests: List[str] = []
    art_dir = os.path.join(project_dir, "Art")
    for root, dirs, files in os.walk(art_dir):
        dirs.sort()
        for name in sorted(files):
            if name == "manifest.json":
                manifests.append(os.path.join(root, name))
    return manifests


def main() -> int:
    parser = argparse.ArgumentParser(description="atlas manifest.json -> metadata.tres 构建期转换器")
    parser.add_argument("--project-dir", default="source", help="Godot 工程根目录")
    parser.add_argument("--check", action="store_true", help="只校验 metadata.tres 是否与 manifest 同步，不写文件")
    parser.add_argument("--quiet", action="store_true", help="仅输出汇总")
    parser.add_argument("--self-test", action="store_true", help="只运行 source_frames 帧数校验负向自测")
    args = parser.parse_args()

    if args.self_test:
        return 0 if run_frame_count_self_test() else 1

    project_dir = os.path.abspath(args.project_dir)
    manifests = collect_manifests(project_dir)
    if not manifests:
        print(f"[!] 未找到 manifest.json: {project_dir}", file=sys.stderr)
        return 1

    written = 0
    unchanged = 0
    stale: List[str] = []
    for manifest_path in manifests:
        with open(manifest_path, "r", encoding="utf-8-sig") as f:
            data = json.load(f)
        try:
            payload = normalize_payload(data)
        except TypeError as exc:
            print(f"[!] {manifest_path}: {exc}", file=sys.stderr)
            return 1
        frame_error = validate_frame_count(data)
        if frame_error is not None:
            print(f"[!] {manifest_path}: {frame_error}", file=sys.stderr)
            return 1
        output_path = os.path.join(os.path.dirname(manifest_path), "metadata.tres")
        content = render_tres(payload)
        if args.check:
            if os.path.exists(output_path):
                with open(output_path, "r", encoding="utf-8", newline="") as f:
                    current = f.read()
                if current == content:
                    unchanged += 1
                    continue
            stale.append(output_path)
            continue
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(content)
        written += 1

    rel_root = os.path.relpath(project_dir)
    if args.check:
        print(f"[*] 校验 manifest: {len(manifests)} 个，已同步 {unchanged} 个，待更新 {len(stale)} 个")
        for path in stale[:20]:
            print(f"    [!] {os.path.relpath(path, project_dir)}")
        if stale:
            print("[FAIL] metadata.tres 与 manifest.json 不同步，请运行转换器。", file=sys.stderr)
            return 1
        print("[SUCCESS] 全部 metadata.tres 与 manifest.json 同步")
        return 0

    print(f"[*] 工程根目录: {rel_root}")
    print(f"[*] 已生成 metadata.tres: {written} 个（manifest 总数 {len(manifests)}）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
