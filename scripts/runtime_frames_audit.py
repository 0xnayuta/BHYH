#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""运行时 SpriteFrames 建帧允许清单门禁。

Phase 13-2 的目标是把运行时 `SpriteFrames.new()` 收敛到已评审例外。
本脚本只做集合守恒：

- 扫描 `source/Script/**/*.gd` 中出现 `SpriteFrames.new()` 的文件；
- 与 `scripts/runtime_frames_allowlist.json` 登记清单逐项比较；
- 新增未登记文件、失效条目或空理由均失败。

迁移完成后必须同步删除清单条目；禁止只加不减。
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source"
ALLOWLIST = ROOT / "scripts/runtime_frames_allowlist.json"
MARKER = "SpriteFrames.new()"


def collect_runtime_frames() -> set[str]:
    found: set[str] = set()
    for path in SOURCE.rglob("*.gd"):
        try:
            text = path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        if MARKER in text:
            found.add(path.relative_to(ROOT).as_posix())
    return found


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="运行时 SpriteFrames 建帧允许清单门禁")
    parser.add_argument("--fail-on-error", action="store_true", help="存在未登记/失效条目时返回 1")
    args = parser.parse_args(argv)

    if not ALLOWLIST.is_file():
        print(f"FAIL 允许清单不存在: {ALLOWLIST.relative_to(ROOT)}", file=sys.stderr)
        return 1
    data = json.loads(ALLOWLIST.read_text(encoding="utf-8"))
    allowed: dict[str, str] = data.get("allowed", {})
    current = collect_runtime_frames()

    added = sorted(current - set(allowed))
    stale = sorted(set(allowed) - current)
    empty_reason = sorted(path for path, reason in allowed.items() if not str(reason).strip())

    print(f"运行时建帧文件: {len(current)}；允许清单: {len(allowed)}")
    for path in added:
        print(f"FAIL 未登记运行时建帧: {path}", file=sys.stderr)
    for path in stale:
        print(f"FAIL 已失效清单条目（文件已无 SpriteFrames.new()）: {path}", file=sys.stderr)
    for path in empty_reason:
        print(f"FAIL 清单条目缺少理由: {path}", file=sys.stderr)

    if added or stale or empty_reason:
        return 1
    print("PASS 运行时建帧集合与允许清单一致")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
