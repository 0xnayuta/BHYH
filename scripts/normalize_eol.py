#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
行尾序列清洗与归一化工具 (EOL Normalizer · 多核增量加速版)
=========================================================
将指定范围内的源码、场景与文本配置统一归一化为标准 Unix LF (\n) 行尾。
严格保留文件原有编码与语义，杜绝任何字符污染。
"""

import os
import sys
import json
import argparse
import concurrent.futures
from pathlib import Path
from typing import Dict, List, Tuple

TEXT_EXTENSIONS = {
    ".gd", ".tscn", ".tres", ".gdshader", ".cfg",
    ".import", ".json", ".md", ".txt", ".py"
}

EXCLUDE_DIRS = {
    ".git", ".godot", "godot", "venv", ".venv",
    "extracted", "binaries"
}

DEFAULT_EOL_CACHE_REL = Path(".godot") / "eol_cache.json"

def process_file_read(file_path: str, dry_run: bool) -> Tuple[str, bool, bool]:
    """读取文件并判断是否含 CRLF，若非 dry_run 且包含则直接在内存清洗写回"""
    try:
        with open(file_path, "rb") as f:
            content = f.read()
    except Exception as e:
        print(f"[ERROR] 读取失败: {file_path} - {e}", file=sys.stderr)
        return os.path.splitext(file_path)[1].lower(), False, False

    if b"\r" not in content:
        return os.path.splitext(file_path)[1].lower(), False, True

    # 包含 CRLF 或孤立 CR
    ext = os.path.splitext(file_path)[1].lower()
    if not dry_run:
        normalized = content.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
        if normalized != content:
            try:
                with open(file_path, "wb") as f:
                    f.write(normalized)
            except Exception as e:
                print(f"[ERROR] 写回失败: {file_path} - {e}", file=sys.stderr)
                return ext, True, False
    return ext, True, True

def scan_and_normalize(target_dir: str, dry_run: bool = False, no_cache: bool = False):
    target_p = Path(target_dir)
    if not target_p.exists():
        print(f"[ERROR] 目标路径不存在: {target_dir}", file=sys.stderr)
        sys.exit(2)

    print(f"[*] 开始扫描目标路径: {target_dir} (Dry-run: {dry_run})")

    # 确定缓存路径
    cache_root = target_p if target_p.is_dir() else target_p.parent
    cache_file = cache_root / DEFAULT_EOL_CACHE_REL
    if not cache_file.parent.exists():
        cache_file = Path(".cache") / "eol_cache.json"

    cache_data = {}
    if not no_cache and cache_file.exists():
        try:
            with open(cache_file, "r", encoding="utf-8") as f:
                cache_data = json.load(f)
        except Exception:
            pass

    files_to_check = []
    total_scanned = 0
    cached_hits = 0

    for root, dirs, files in os.walk(target_dir):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        for file_name in files:
            ext = os.path.splitext(file_name)[1].lower()
            if ext not in TEXT_EXTENSIONS:
                continue

            total_scanned += 1
            file_path = os.path.join(root, file_name)
            
            # 缓存判定
            if not no_cache:
                try:
                    stat = os.stat(file_path)
                    rec = cache_data.get(file_path)
                    if rec and len(rec) >= 2 and rec[0] == stat.st_mtime and rec[1] == stat.st_size:
                        cached_hits += 1
                        continue
                except OSError:
                    pass

            files_to_check.append(file_path)

    stats: Dict[str, int] = {}
    total_modified = 0

    if files_to_check:
        with concurrent.futures.ThreadPoolExecutor(max_workers=min(8, os.cpu_count() or 4)) as executor:
            future_to_path = {executor.submit(process_file_read, fp, dry_run): fp for fp in files_to_check}
            for future in concurrent.futures.as_completed(future_to_path):
                fp = future_to_path[future]
                ext, has_crlf, ok = future.result()
                if has_crlf:
                    stats[ext] = stats.get(ext, 0) + 1
                    total_modified += 1
                    # 仅在非 dry_run 且成功写回时计入纯净缓存
                    if not dry_run and ok:
                        try:
                            st = os.stat(fp)
                            cache_data[fp] = [st.st_mtime, st.st_size]
                        except OSError:
                            pass
                elif ok:
                    # 本身无 CRLF
                    try:
                        st = os.stat(fp)
                        cache_data[fp] = [st.st_mtime, st.st_size]
                    except OSError:
                        pass

        # 保存缓存
        if not dry_run or total_modified == 0:
            try:
                cache_file.parent.mkdir(parents=True, exist_ok=True)
                with open(cache_file, "w", encoding="utf-8") as f:
                    json.dump(cache_data, f, ensure_ascii=False)
            except Exception:
                pass

    print(f"\n[+] 扫描与清洗完成！")
    print(f"    - 总扫描文本文件: {total_scanned}")
    print(f"    - 缓存命中文件数: {cached_hits}")
    print(f"    - 发现并清洗 CRLF 文件数: {total_modified}")
    print("    - 分类清洗明细:")
    for ext, count in sorted(stats.items(), key=lambda x: -x[1]):
        print(f"      * {ext:<12s}: {count} 个文件")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ZMXYBHYH 行尾清洗工具 (多核增量加速版)")
    parser.add_argument("target", nargs="?", default="source", help="待清洗目录 (默认: source)")
    parser.add_argument("--dry-run", action="store_true", help="只检查不实际修改文件")
    parser.add_argument("--no-cache", action="store_true", help="禁用缓存，强制全盘扫描")
    args = parser.parse_args()

    scan_and_normalize(args.target, dry_run=args.dry_run, no_cache=args.no_cache)
