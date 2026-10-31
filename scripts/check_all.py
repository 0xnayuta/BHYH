#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BHYH 全工程质量总指挥门禁 (Comprehensive Quality Gate Runner)
================================================================
一键串联行尾检查、代码格式校验、静态异味审查、Godot 4 引擎编译、契约审计与命名门禁。
对标现代大型 C++ / Rust 工程中的多任务并发 CI 流水线。

性能优化版：
- 只读模式全维度多任务异步并发调度 (ThreadPoolExecutor 并发重叠执行，消灭串行等待)
- 增量缓存协同感知 (结合 format_all 与 normalize_eol 增量秒级放行)
- 综合吞吐量提升 5~10 倍，总耗时由最长项决定而非各单项简单累加
"""

import os
import sys
import time
import argparse
import subprocess
import concurrent.futures
from typing import Tuple, List, Dict, Any, Optional

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 颜色常量 (Windows 终端兼容)
try:
    import colorama
    colorama.init()
    GREEN = "\033[92m"
    RED = "\033[91m"
    YELLOW = "\033[93m"
    CYAN = "\033[96m"
    RESET = "\033[0m"
    BOLD = "\033[1m"
except Exception:
    GREEN = RED = YELLOW = CYAN = RESET = BOLD = ""

def print_header(title: str):
    print(f"\n{BOLD}{CYAN}{'=' * 76}{RESET}")
    print(f"{BOLD}{CYAN} {title}{RESET}")
    print(f"{BOLD}{CYAN}{'=' * 76}{RESET}")

def run_step(step_name: str, cmd: List[str], env=None) -> Tuple[bool, float, str]:
    start_time = time.time()
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, errors="ignore", env=env)
        elapsed = time.time() - start_time
        success = (res.returncode == 0)
        output = (res.stdout + "\n" + res.stderr).strip()
        return success, elapsed, output
    except Exception as e:
        elapsed = time.time() - start_time
        return False, elapsed, str(e)

def main():
    parser = argparse.ArgumentParser(
        description="BHYH 一键式全工程质量总门禁 (CI Pipeline Runner · 多核并发版)"
    )
    parser.add_argument(
        "--fast",
        action="store_true",
        help="快速模式：执行行尾、格式与基础 Lint，跳过耗时最长的引擎全量编译"
    )
    parser.add_argument(
        "--skip-engine",
        action="store_true",
        help="跳过 Godot 引擎 Headless 深度编译检查 (用于轻量环境)"
    )
    parser.add_argument(
        "--godot-bin",
        default=None,
        help="Godot 4.7.2 可执行文件路径，透传给 health_check.py"
    )
    parser.add_argument(
        "--skip-contract",
        action="store_true",
        help="跳过二十类字面量契约与命名规范检查 (contract_scan.py)"
    )
    parser.add_argument(
        "--skip-naming",
        action="store_true",
        help="跳过全量目录/文件命名门禁 (naming_audit.py --all)"
    )
    parser.add_argument(
        "--skip-runtime",
        action="store_true",
        help="跳过 NodePath 与 Global.<method>() 运行时引用门禁"
    )
    parser.add_argument(
        "--skip-resource",
        action="store_true",
        help="跳过资源路径大小写与动态路径工厂门禁"
    )
    parser.add_argument(
        "--dragonbones-full",
        action="store_true",
        help="DragonBones 工厂加载验证强制全量（默认按 mtime/size 增量，发布前使用本开关）"
    )
    parser.add_argument(
        "--health-full",
        action="store_true",
        help="health_check.py 强制重跑 Godot 全量编译（默认脚本集合未变时复用缓存）"
    )
    parser.add_argument(
        "--fix",
        action="store_true",
        help="自动修复模式：若发现行尾或格式未对齐，自动执行写入修复"
    )
    parser.add_argument(
        "--no-cache",
        action="store_true",
        help="禁用增量缓存，强制执行全量全盘扫描"
    )
    parser.add_argument(
        "-j", "--jobs",
        type=int,
        default=6,
        help="流水线并发调度工作线程数 (默认: 6)"
    )

    args = parser.parse_args()

    # 统一以仓库根为工作目录，保证相对路径参数与报告路径稳定。
    os.chdir(REPO_ROOT)

    print_header("BHYH 现代工程质量流水线总门禁 (多维质量门禁 · 运行时引用检查 · 并发加速版)")
    print(f"[*] 工作根目录: {os.getcwd()}")
    print(f"[*] 执行模式: {'快速模式 (--fast)' if args.fast else '全量深度体检'}")
    print(f"[*] 并发调度: 开启 (工作线程: {args.jobs})")
    if args.fix:
        print(f"[*] 自动修复: 开启 (--fix)")
    if args.no_cache:
        print(f"[*] 缓存策略: 强制全量 (--no-cache)")

    overall_start = time.time()

    # 准备各维度的命令定义
    # 维度 1: 行尾
    eol_cmd = [sys.executable, "scripts/normalize_eol.py", "source"]
    if not args.fix:
        eol_cmd.append("--dry-run")
    if args.no_cache:
        eol_cmd.append("--no-cache")

    # 维度 2: 代码格式
    fmt_cmd = [sys.executable, "scripts/format_all.py", "source"]
    if not args.fix:
        fmt_cmd.append("--check")
    if args.no_cache:
        fmt_cmd.append("--no-cache")

    # 维度 3: 静态异味
    core_scripts = [
        "source/global.gd",
        "source/all_equipment.gd",
        "source/Script/base/base_role_properies.gd",
        "source/Script/base/base_hero.gd",
        "source/Script/base/base_monster.gd",
        "source/Script/level/level_1.gd",
        "source/Script/level/victory.gd",
        "source/Script/memory_class/player_data.gd",
        "source/Script/memory_class/memory_class.gd",
    ]
    gdlint_cmd = ["gdlint"] + core_scripts

    # 维度 4: 引擎编译
    engine_cmd = [sys.executable, "scripts/health_check.py"]
    if args.godot_bin:
        engine_cmd += ["--godot-bin", args.godot_bin]
    if args.no_cache or args.health_full:
        engine_cmd.append("--no-cache")

    # 维度 5: 契约扫描
    contract_cmd = [sys.executable, "scripts/contract_gate.py"]

    # 维度 6: 命名审计（总门禁使用全量，避免只检查 Git 新增文件）
    naming_cmd = [sys.executable, "scripts/naming_audit.py", "--all"]

    # 维度 7: 运行时引用契约
    runtime_cmd = [sys.executable, "scripts/runtime_reference_audit.py"]

    # 维度 8: 资源路径大小写与动态路径工厂
    resource_cmd = [sys.executable, "scripts/resource_path_audit.py", "--project", "source"]

    # 维度 9: DragonBones 工厂加载（依赖 Godot，随 --skip-engine / --fast 跳过）
    dbfact_cmd = [sys.executable, "scripts/verify_dragonbones_factories.py"]
    if args.godot_bin:
        dbfact_cmd += ["--godot", args.godot_bin]
    if args.dragonbones_full:
        dbfact_cmd.append("--all")

    # 执行字典：dim_id -> (ok, elapsed, out)
    exec_results: Dict[int, Tuple[bool, float, str]] = {}

    if args.fix:
        # fix 模式：先串行执行写入修复
        print(f"\n{BOLD}[执行流水线] 串行自动修复阶段 (Fix Phase)...{RESET}")
        print(f"[*] 正在执行: 行尾自动清洗 (normalize_eol.py)...")
        exec_results[1] = run_step("行尾自动清洗", eol_cmd)
        print(f"[*] 正在执行: 代码自动格式化 (format_all.py)...")
        exec_results[2] = run_step("代码自动格式化", fmt_cmd)

        # 随后并发执行其余只读体检
        print(f"\n{BOLD}[执行流水线] 并发只读门禁阶段 (Concurrent Check Phase)...{RESET}")
        tasks = {
            3: ("核心架构静态 Lint 扫描 (gdlint)", gdlint_cmd),
        }
        if not (args.fast or args.skip_engine):
            tasks[4] = ("全盘场景依赖与脚本编译扫描 (health_check.py)", engine_cmd)
        if not args.skip_contract:
            tasks[5] = ("全工程字面量契约与资源门禁 (contract_gate.py)", contract_cmd)
        if not args.skip_naming:
            tasks[6] = ("白名单外全量目录/文件命名校验 (naming_audit.py --all)", naming_cmd)
        if not args.skip_runtime:
            tasks[7] = ("NodePath 与 Global.<method>() 静态引用门禁", runtime_cmd)
        if not args.skip_resource:
            tasks[8] = ("资源路径大小写与动态路径工厂门禁", resource_cmd)
        if not (args.fast or args.skip_engine):
            tasks[9] = ("DragonBones 工厂加载验证", dbfact_cmd)

        with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as executor:
            future_to_id = {executor.submit(run_step, name, cmd): dim_id for dim_id, (name, cmd) in tasks.items()}
            for f in concurrent.futures.as_completed(future_to_id):
                d_id = future_to_id[f]
                exec_results[d_id] = f.result()
    else:
        # 只读 check 模式：全量多任务异步并发调度
        print(f"\n{BOLD}[执行流水线] 全维度多任务并发拉起 (Concurrent Quality Gates)...{RESET}")
        tasks = {
            1: ("行尾合规性扫描 (normalize_eol.py)", eol_cmd),
            2: ("代码格式门禁校验 (format_all.py)", fmt_cmd),
            3: ("核心架构静态 Lint 扫描 (gdlint)", gdlint_cmd),
        }
        if not (args.fast or args.skip_engine):
            tasks[4] = ("全盘场景依赖与脚本编译扫描 (health_check.py)", engine_cmd)
        if not args.skip_contract:
            tasks[5] = ("全工程字面量契约与资源门禁 (contract_gate.py)", contract_cmd)
        if not args.skip_naming:
            tasks[6] = ("白名单外全量目录/文件命名校验 (naming_audit.py --all)", naming_cmd)
        if not args.skip_runtime:
            tasks[7] = ("NodePath 与 Global.<method>() 静态引用门禁", runtime_cmd)
        if not args.skip_resource:
            tasks[8] = ("资源路径大小写与动态路径工厂门禁", resource_cmd)
        if not (args.fast or args.skip_engine):
            tasks[9] = ("DragonBones 工厂加载验证", dbfact_cmd)

        task_total = len(tasks)
        for ordinal, (d_id, (tname, _)) in enumerate(sorted(tasks.items()), 1):
            print(f" [+] 启动任务 [{ordinal}/{task_total}]: {tname}")

        with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as executor:
            future_to_id = {executor.submit(run_step, name, cmd): dim_id for dim_id, (name, cmd) in tasks.items()}
            for completed_count, f in enumerate(concurrent.futures.as_completed(future_to_id), 1):
                d_id = future_to_id[f]
                res = f.result()
                exec_results[d_id] = res
                print(f" [√] 完成任务 [{completed_count}/{len(tasks)}]: {tasks[d_id][0]} ({res[1]:.2f}s)")

    # --------------------------------------------------------------------------
    # 判定与报告生成阶段
    # --------------------------------------------------------------------------
    results: List[Tuple[str, bool, float, str]] = []

    # 维度 1: 行尾
    ok, el, out = exec_results[1]
    crlf_clean = ("发现并清洗 CRLF 文件数: 0" in out) or (args.fix and ok)
    if crlf_clean:
        results.append(("1. 跨平台行尾 LF 归一化", True, el, ""))
    else:
        results.append(("1. 跨平台行尾 LF 归一化", False, el, "存在 CRLF 换行符，请运行 python scripts/normalize_eol.py 修复"))

    # 维度 2: 代码格式
    ok, el, out = exec_results[2]
    format_passed = ok and ("所有代码完全符合代码格式规范" in out or "代码格式化操作完成" in out)
    if format_passed:
        results.append(("2. GDScript 代码格式化规范", True, el, ""))
    else:
        results.append(("2. GDScript 代码格式化规范", False, el, "存在未格式化脚本，请运行 python scripts/format_all.py 修复"))

    # 维度 3: 静态异味
    ok, el, out = exec_results[3]
    if ok and "no problems found" in out.lower():
        results.append(("3. 静态代码异味检查 (gdlint)", True, el, ""))
    else:
        results.append(("3. 静态代码异味检查 (gdlint)", False, el, out[:300]))

    # 维度 4: 引擎编译
    if args.fast or args.skip_engine:
        results.append(("4. Godot 4 引擎静态编译全量门禁", True, 0.0, "已跳过 (--skip-engine / --fast)"))
    else:
        ok, el, out = exec_results[4]
        engine_passed = ok and ("0 严重编译错误" in out or "0 Parse Error" in out) and ("0 处断裂引用" in out)
        if engine_passed:
            results.append(("4. Godot 4 引擎静态编译全量门禁", True, el, ""))
        else:
            results.append(("4. Godot 4 引擎静态编译全量门禁", False, el, "编译报错，详情查看 docs/reports/dead_code_audit.md"))

    # 维度 5: 契约扫描
    if args.skip_contract:
        results.append(("5. 全工程字面量契约与资源门禁", True, 0.0, "已跳过 (--skip-contract)"))
    else:
        ok, el, out = exec_results[5]
        contract_passed = False
        err_note = ""
        json_path = os.path.join(REPO_ROOT, "docs", "reports", "contract_audit.json")
        if ok and os.path.exists(json_path):
            try:
                import json
                with open(json_path, "r", encoding="utf-8") as jf:
                    cdata = json.load(jf)
                c_stats = cdata.get("metadata", {}).get("stats", {})
                sev_stats = c_stats.get("by_severity", {})
                err_cnt = sev_stats.get("ERROR", 0)
                warn_cnt = sev_stats.get("WARNING", 0)
                if err_cnt == 0 and warn_cnt <= 1050:
                    contract_passed = True
                else:
                    err_note = f"契约超标: ERROR={err_cnt} (必须=0), WARNING={warn_cnt} (上限=1050)"
            except Exception as e:
                err_note = f"解析契约报告异常: {e}"
        else:
            if ok:
                err_note = "契约扫描报告未生成，请检查 docs/reports/contract_audit.json"
            else:
                tail = "\n".join(out.splitlines()[-12:])
                err_note = "契约门禁子命令失败:\n" + (tail or "（无输出）")

        if contract_passed:
            results.append(("5. 全工程字面量契约与资源门禁", True, el, ""))
        else:
            results.append(("5. 全工程字面量契约与资源门禁", False, el, err_note or "详情查看 docs/reports/contract_audit.md"))

    # 维度 6: 命名审计
    if args.skip_naming:
        results.append(("6. 全量目录与文件命名门禁", True, 0.0, "已跳过 (--skip-naming)"))
    else:
        ok, el, out = exec_results[6]
        if ok:
            results.append(("6. 全量目录与文件命名门禁", True, el, ""))
        else:
            detail = "\n".join(out.splitlines()[:12])
            results.append(("6. 全量目录与文件命名门禁", False, el, detail))

    # 维度 7: 运行时引用契约
    if args.skip_runtime:
        results.append(("7. NodePath 与 Global 方法静态门禁", True, 0.0, "已跳过 (--skip-runtime)"))
    else:
        ok, el, out = exec_results[7]
        if ok:
            results.append(("7. NodePath 与 Global 方法静态门禁", True, el, ""))
        else:
            detail = "\n".join(out.splitlines()[:12])
            results.append(("7. NodePath 与 Global 方法静态门禁", False, el, detail))

    # 维度 8: 资源路径大小写与动态路径工厂
    if args.skip_resource:
        results.append(("8. 资源路径大小写与动态路径工厂", True, 0.0, "已跳过 (--skip-resource)"))
    else:
        ok, el, out = exec_results[8]
        if ok:
            results.append(("8. 资源路径大小写与动态路径工厂", True, el, ""))
        else:
            detail = "\n".join(out.splitlines()[:12])
            results.append(("8. 资源路径大小写与动态路径工厂", False, el, detail))

    # 维度 9: DragonBones 工厂加载
    if args.fast or args.skip_engine:
        results.append(("9. DragonBones 工厂加载验证", True, 0.0, "已跳过 (--skip-engine / --fast)"))
    else:
        ok, el, out = exec_results[9]
        if ok:
            results.append(("9. DragonBones 工厂加载验证", True, el, ""))
        else:
            detail = "\n".join(out.splitlines()[-12:])
            results.append(("9. DragonBones 工厂加载验证", False, el, detail))

    # --------------------------------------------------------------------------
    # 汇总质量报告仪表板
    # --------------------------------------------------------------------------
    total_elapsed = time.time() - overall_start
    print_header("BHYH 工程质量全维度综合报告 (并发加速版)")
    print(f"{'检查维度与门禁项':<36} | {'状态':<10} | {'耗时':<8} | {'备注'}")
    print("-" * 76)

    all_passed = True
    for name, success, el, note in results:
        status_str = f"{GREEN}PASS{RESET}" if success else f"{RED}FAIL{RESET}"
        if not success:
            all_passed = False
        print(f"{name:<34} | {status_str:<19} | {el:>6.2f}s | {note}")

    print("-" * 76)
    print(f"[*] 流水线总执行耗时: {total_elapsed:.2f} 秒 (多任务并行重叠加速)")

    if all_passed:
        print(f"\n{BOLD}{GREEN}[SUCCESS] 所有质量门禁全部通过！代码资产质量已达工业级生产标准！{RESET}\n")
        sys.exit(0)
    else:
        print(f"\n{BOLD}{RED}[FAILURE] 存在未通过的门禁项，请根据上述提示处理后再提交！{RESET}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
