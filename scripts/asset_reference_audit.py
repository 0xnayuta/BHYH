#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts/asset_reference_audit.py

资产引用单遍扫描工具。

设计约束
--------
禁止在 Python 层做“遍历每个文件 × 尝试每个旧基名”的嵌套循环；
统一把全部待查模式写入临时文件，只启动一次 `rg -F -f <patterns>`，
由 ripgrep 在单次多模式扫描中完成引用检索。

用法示例
--------
python scripts/asset_reference_audit.py \
  --patterns old_asset_stems.txt \
  --glob '*.gd' --glob '*.tscn'

python scripts/asset_reference_audit.py \
  --manifest c1.json --manifest c2.json \
  --output docs/asset_reference_audit.json

退出码
------
- 0：扫描完成（默认即使有匹配也返回 0）；
- 1：扫描本身失败；
- 2：参数错误；
- 3：指定 --fail-on-match 且发现匹配。
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Dict, List, Set, Tuple

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_ROOT = os.path.join(REPO_ROOT, "source")
DEFAULT_GLOBS = ("*.gd", "*.tscn", "*.tres", "*.import", "*.json", "*.godot")


def _read_patterns_file(path: str) -> List[str]:
    with open(path, "r", encoding="utf-8", errors="ignore") as fh:
        return [line.strip() for line in fh if line.strip()]


def _patterns_from_manifest(path: str, uppercase_only: bool) -> List[str]:
    with open(path, "r", encoding="utf-8") as fh:
        payload = json.load(fh)
    if isinstance(payload, dict):
        payload = payload.get("pairs", [])
    patterns: List[str] = []
    for item in payload:
        if isinstance(item, dict):
            value = item.get("old", "")
        elif isinstance(item, (list, tuple)) and item:
            value = item[0]
        else:
            continue
        stem = Path(str(value).replace("\\", "/")).stem
        if uppercase_only and not any(ch.isupper() for ch in stem):
            continue
        if stem:
            patterns.append(stem)
    return patterns


def collect_patterns(args: argparse.Namespace) -> List[str]:
    patterns: List[str] = []
    for path in args.patterns:
        patterns.extend(_read_patterns_file(path))
    for path in args.manifest:
        patterns.extend(_patterns_from_manifest(path, args.uppercase_only))
    patterns.extend(args.pattern or [])
    # 保持稳定顺序并去重。
    seen: Set[str] = set()
    unique: List[str] = []
    for pattern in patterns:
        if pattern not in seen:
            seen.add(pattern)
            unique.append(pattern)
    return unique


def resolve_rg(explicit: str = "") -> str:
    """优先 --rg / RG_BIN，再回退 PATH 中的 rg。"""
    if explicit:
        return explicit
    env_bin = os.environ.get("RG_BIN", "").strip()
    if env_bin:
        return env_bin
    return shutil.which("rg") or "rg"


def run_ripgrep(
    patterns: List[str],
    root: str,
    globs: List[str],
    timeout: int,
    rg_exec: str,
) -> Tuple[List[Dict[str, object]], str]:
    """一次 rg 多模式扫描；返回匹配事件和原始 stderr。"""
    fd, pattern_path = tempfile.mkstemp(prefix="asset_ref_patterns_", suffix=".txt", text=True)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as fh:
            fh.write("\n".join(patterns) + "\n")
        command = [rg_exec, "--json", "-F", "-f", pattern_path]
        for glob in globs:
            command.extend(["--glob", glob])
        command.extend(["--", root])
        proc = subprocess.run(
            command,
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="ignore",
            timeout=timeout,
        )
        if proc.returncode not in (0, 1):
            return [], proc.stderr.strip() or f"rg exit {proc.returncode}"
        matches: List[Dict[str, object]] = []
        for line in proc.stdout.splitlines():
            if not line.strip():
                continue
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            if event.get("type") != "match":
                continue
            data = event.get("data", {})
            path = str(data.get("path", {}).get("text", ""))
            line_text = str(data.get("lines", {}).get("text", "")).rstrip("\r\n")
            submatches = data.get("submatches", []) or []
            matched = [str(item.get("match", {}).get("text", "")) for item in submatches]
            matches.append(
                {
                    "path": path,
                    "line": data.get("line_number"),
                    "text": line_text,
                    "matches": matched,
                }
            )
        return matches, proc.stderr.strip()
    finally:
        try:
            os.unlink(pattern_path)
        except OSError:
            pass


def main() -> int:
    parser = argparse.ArgumentParser(description="ripgrep 单遍资产引用扫描")
    parser.add_argument("--patterns", action="append", default=[], help="模式文件（每行一个旧基名）")
    parser.add_argument("--manifest", action="append", default=[], help="旧路径清单 JSON（可重复）")
    parser.add_argument("--pattern", action="append", default=[], help="直接追加一个模式（可重复）")
    parser.add_argument("--uppercase-only", action="store_true", help="仅保留含大写字母的清单基名")
    parser.add_argument("--root", default=DEFAULT_ROOT, help="扫描根目录（默认 source）")
    parser.add_argument("--glob", action="append", default=[], help="ripgrep glob（可重复，默认常用文本扩展名）")
    parser.add_argument("--timeout", type=int, default=120, help="rg 超时秒数（默认 120）")
    parser.add_argument("--rg", default="", help="rg 可执行文件路径（默认读 RG_BIN 或 PATH）")
    parser.add_argument("--output", help="将匹配结果写入 JSON")
    parser.add_argument("--fail-on-match", action="store_true", help="发现匹配时返回退出码 3")
    args = parser.parse_args()

    patterns = collect_patterns(args)
    if not patterns:
        print("[!] 未提供模式：使用 --patterns/--manifest/--pattern", file=sys.stderr)
        return 2
    globs = args.glob or list(DEFAULT_GLOBS)
    if not os.path.isdir(args.root):
        print(f"[!] 扫描根目录不存在: {args.root}", file=sys.stderr)
        return 2

    try:
        matches, stderr = run_ripgrep(
            patterns, args.root, globs, args.timeout, resolve_rg(args.rg)
        )
    except FileNotFoundError:
        print("[!] 未找到 ripgrep（rg）：请安装并加入 PATH，或用 --rg / RG_BIN 指定可执行文件", file=sys.stderr)
        return 1
    except subprocess.TimeoutExpired:
        print(f"[!] ripgrep 扫描超时（{args.timeout}s）", file=sys.stderr)
        return 1

    files = sorted({str(item["path"]) for item in matches})
    payload = {
        "patterns": patterns,
        "glob": globs,
        "root": args.root,
        "file_count": len(files),
        "match_count": len(matches),
        "files": files,
        "matches": matches,
        "stderr": stderr,
    }
    if args.output:
        with open(args.output, "w", encoding="utf-8", newline="\n") as fh:
            json.dump(payload, fh, ensure_ascii=False, indent=2)
    print(f"[*] 单遍扫描：{len(patterns)} 个模式，{len(matches)} 处匹配，{len(files)} 个文件")
    if stderr:
        print(f"[!] rg stderr: {stderr}", file=sys.stderr)
    return 3 if args.fail_on_match and matches else 0


if __name__ == "__main__":
    sys.exit(main())
