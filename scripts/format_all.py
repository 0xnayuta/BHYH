#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BHYH 全工程 GDScript 自动化格式化流水线工具 (Format All Pipeline)
====================================================================
基于官方推荐的 gdtoolkit (gdformat 4.5.0)，提供工程级代码规范格式化与门禁校验。
对标现代大型工程中的 clang-format 流水线。

性能优化版：
- 多核高并发批处理（ThreadPoolExecutor 调度外部 gdformat 进程）
- mtime/size 增量状态缓存（增量毫秒级响应，避免无改动文件重复解析）
- 支持 --no-cache 强制全量校验
"""

import os
import sys
import json
import shutil
import argparse
import subprocess
import concurrent.futures
from pathlib import Path
from typing import List, Tuple, Dict, Set

# 排除目录
EXCLUDE_DIRS = {
    ".git", ".godot", "godot", "extracted", "binaries"
}

DEFAULT_CACHE_REL_PATH = Path(".godot") / "format_cache.json"

def resolve_gdformat_cmd() -> List[str]:
    """解析并定位 gdformat 可执行命令，优先使用本地独立可执行文件"""
    gdformat_bin = shutil.which("gdformat")
    if gdformat_bin:
        return [gdformat_bin]
    
    # 尝试 uv tool 方式
    uv_bin = shutil.which("uv")
    if uv_bin:
        return [uv_bin, "tool", "run", "--from", "gdtoolkit", "gdformat"]
    
    print("[ERROR] 未找到 gdformat 或 uv 工具！请先运行: uv tool install gdtoolkit", file=sys.stderr)
    sys.exit(1)

def collect_gd_files(target_path: str) -> List[str]:
    """安全递归收集目标路径下的所有有效 .gd 脚本"""
    p = Path(target_path)
    if not p.exists():
        print(f"[ERROR] 目标路径不存在: {target_path}", file=sys.stderr)
        return []

    if p.is_file():
        if p.suffix == ".gd":
            return [str(p.resolve())]
        return []

    collected: List[str] = []
    norm_target = str(p.resolve())

    for root, dirs, files in os.walk(norm_target):
        # 排除只读基线与缓存目录
        dirs[:] = [
            d for d in dirs
            if not any(ex in os.path.join(root, d).replace("\\", "/") for ex in EXCLUDE_DIRS)
        ]

        for f in sorted(files):
            if f.endswith(".gd"):
                full_path = os.path.join(root, f)
                collected.append(full_path)

    return collected

def run_batch(
    cmd_base: List[str],
    batch: List[str],
    line_length: int,
    mode: str
) -> Tuple[int, List[str], List[str]]:
    """执行单个批次的格式化，返回 (退出码, 需要格式化/已格式化列表, 错误列表)"""
    if not batch:
        return 0, [], []

    args = list(cmd_base)
    args.extend(["-l", str(line_length)])

    if mode == "check":
        args.append("--check")
    elif mode == "diff":
        args.append("--diff")

    args.extend(batch)

    res = subprocess.run(args, capture_output=True, text=True, errors="ignore")
    
    reformatted = []
    errors = []

    output = (res.stderr + "\n" + res.stdout).strip()
    for line in output.splitlines():
        line_clean = line.strip()
        if line_clean.startswith("would reformat "):
            fp = line_clean[len("would reformat "):].strip()
            reformatted.append(fp)
        elif line_clean.startswith("reformatted "):
            fp = line_clean[len("reformatted "):].strip()
            reformatted.append(fp)
        elif "could not parse" in line_clean.lower() or "syntaxerror" in line_clean.lower():
            errors.append(line_clean)

    if mode == "diff" and output:
        print(output + "\n")
    return res.returncode, reformatted, errors

def load_cache(cache_path: Path) -> Dict[str, List[float]]:
    """加载已通过校验的文件 mtime 和 size 缓存"""
    if cache_path.exists():
        try:
            with open(cache_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {}

def save_cache(cache_path: Path, cache_data: Dict[str, List[float]]) -> None:
    """持久化保存缓存"""
    try:
        cache_path.parent.mkdir(parents=True, exist_ok=True)
        with open(cache_path, "w", encoding="utf-8") as f:
            json.dump(cache_data, f, ensure_ascii=False)
    except Exception:
        pass

def main():
    parser = argparse.ArgumentParser(
        description="BHYH GDScript 代码格式化流水线 (对标 clang-format，多核加速与增量版)"
    )
    parser.add_argument(
        "target",
        nargs="?",
        default="source",
        help="目标文件或目录路径 (默认: source)"
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="校验模式：不修改文件，仅检查是否符合规范 (CI 门禁模式)"
    )
    parser.add_argument(
        "--diff",
        action="store_true",
        help="差异模式：打印建议修改的代码 diff，不直接写回文件"
    )
    parser.add_argument(
        "--line-length",
        "-l",
        type=int,
        default=120,
        help="最大允许单行字符宽度 (默认: 120)"
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=100,
        help="批处理文件上限 (默认: 100)"
    )
    parser.add_argument(
        "-j", "--jobs",
        type=int,
        default=min(8, os.cpu_count() or 4),
        help="并发执行任务数 (默认: min(8, CPU核心数))"
    )
    parser.add_argument(
        "--no-cache",
        action="store_true",
        help="禁用增量缓存，强制执行全量检查"
    )

    args = parser.parse_args()

    mode = "write"
    if args.diff:
        mode = "diff"
    elif args.check:
        mode = "check"

    cmd_base = resolve_gdformat_cmd()
    all_files = collect_gd_files(args.target)

    if not all_files:
        print(f"[ERROR] 在目标路径 '{args.target}' 下未发现任何可处理的 .gd 脚本。", file=sys.stderr)
        sys.exit(2)

    # 确定缓存路径
    target_p = Path(args.target)
    cache_root = target_p if target_p.is_dir() else target_p.parent
    cache_file = cache_root / DEFAULT_CACHE_REL_PATH
    if not cache_file.parent.exists():
        cache_file = Path(".cache") / "format_cache.json"

    cache_data = {} if args.no_cache else load_cache(cache_file)

    # 增量筛选：仅对未在缓存中、或 mtime/size 改变的文件执行 gdformat
    files_to_process: List[str] = []
    cached_clean_count = 0

    for fp in all_files:
        try:
            stat = os.stat(fp)
            rec = cache_data.get(fp)
            if rec and len(rec) >= 2 and rec[0] == stat.st_mtime and rec[1] == stat.st_size:
                cached_clean_count += 1
            else:
                files_to_process.append(fp)
        except OSError:
            files_to_process.append(fp)

    print("=" * 72)
    print(" BHYH GDScript 代码格式化流水线 (gdformat 4.5.0 · 多核增量加速版)")
    print("=" * 72)
    print(f"[*] 执行模式: {'校验 (Check)' if mode == 'check' else ('差异 (Diff)' if mode == 'diff' else '覆写格式化 (Write)')}")
    print(f"[*] 目标路径: {args.target}")
    print(f"[*] 全量脚本: {len(all_files)} 个 | 缓存命中: {cached_clean_count} 个 | 待处理: {len(files_to_process)} 个")
    print(f"[*] 单行宽度: {args.line_length} 字符 | 并发线程: {args.jobs} | 批次容量: {args.batch_size}")
    print("-" * 72)

    total_reformatted = []
    total_errors = []
    overall_exit_code = 0

    if files_to_process:
        batches = [
            files_to_process[i:i + args.batch_size]
            for i in range(0, len(files_to_process), args.batch_size)
        ]
        total_batches = len(batches)

        # 多线程并发拉起批次
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as executor:
            future_to_batch = {
                executor.submit(run_batch, cmd_base, b, args.line_length, mode): idx
                for idx, b in enumerate(batches)
            }
            completed_batches = 0
            for future in concurrent.futures.as_completed(future_to_batch):
                ret, reformatted, errors = future.result()
                total_reformatted.extend(reformatted)
                total_errors.extend(errors)
                if ret != 0:
                    overall_exit_code = ret
                completed_batches += 1
                processed_count = min(completed_batches * args.batch_size, len(files_to_process))
                print(f" -> 处理进度: 批次 [{completed_batches}/{total_batches}] (已处理 {processed_count}/{len(files_to_process)} 文件)...")

        # 若为写模式，自动确保所有文件统一维持标准 Unix LF 行尾
        if mode == "write" and files_to_process:
            for fp in files_to_process:
                try:
                    with open(fp, "rb") as bf:
                        data = bf.read()
                    if b"\r" in data:
                        norm = data.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
                        with open(fp, "wb") as bf:
                            bf.write(norm)
                except Exception:
                    pass

        # 更新通过检查的文件缓存
        problem_files: Set[str] = set()
        for rf in total_reformatted:
            problem_files.add(os.path.normpath(rf))
        for ef in total_errors:
            problem_files.add(os.path.normpath(ef))

        for fp in files_to_process:
            norm_fp = os.path.normpath(fp)
            if norm_fp not in problem_files:
                try:
                    st = os.stat(fp)
                    cache_data[fp] = [st.st_mtime, st.st_size]
                except OSError:
                    pass
        save_cache(cache_file, cache_data)
    else:
        print(" -> [缓存命中] 所有目标文件均未变动且符合规范，直接通过！")

    print("=" * 72)
    print(" 格式化流水线执行结果报告")
    print("=" * 72)
    print(f"[+] 总扫描脚本数: {len(all_files)}")
    print(f"[+] 需规范化/已格式化文件数: {len(total_reformatted)}")
    print(f"[+] 已经符合规范文件数: {len(all_files) - len(total_reformatted)}")
    print(f"[+] 语法解析错误数: {len(total_errors)}")

    if total_errors:
        print("\n[!] 语法解析异常列表:")
        for err in total_errors:
            print(f"    * {err}")

    if mode == "check" and total_reformatted:
        print("\n[FAIL] 门禁校验失败：以上文件未遵守官方代码格式规范，请运行格式化！")
        sys.exit(1)
    elif mode == "check":
        print("\n[SUCCESS] 门禁校验通过：所有代码完全符合代码格式规范！")
        sys.exit(0)
    else:
        print("\n[SUCCESS] 代码格式化操作完成！")
        sys.exit(0 if not total_errors else 1)

if __name__ == "__main__":
    main()
