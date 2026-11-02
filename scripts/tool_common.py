#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Runner 共用的路径、Godot 解析与 JSON 报告写入工具。

只被 scripts/ 下的运行器导入，不进入 Godot 工程或生产运行时。
"""

from __future__ import annotations

import json
import os
import shutil
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source"
REPORT_DIR = ROOT / "docs" / "reports"
GODOT_CANDIDATES = ("godot", "godot4")


def resolve_godot(explicit: str | None = None) -> str | None:
    """按显式参数、GODOT_BIN、PATH 顺序解析 Godot；找不到返回 None。"""
    candidates = [explicit, os.environ.get("GODOT_BIN"), *GODOT_CANDIDATES]
    for candidate in candidates:
        if not candidate:
            continue
        path = Path(candidate)
        if path.is_file():
            return str(path)
        found = shutil.which(candidate)
        if found:
            return found
    return None


def write_json(path: Path, payload: Any, indent: int = 2) -> None:
    """写入 UTF-8 JSON 报告；调用方负责只写 docs/reports 或明确的输出路径。"""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=indent) + "\n", encoding="utf-8")
