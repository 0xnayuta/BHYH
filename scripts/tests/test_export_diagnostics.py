#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""验证导出日志、退出码与产物的联合判定。"""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from frame_sequence_pack_probe import check_export_result  # noqa: E402


class ExportDiagnosticsTests(unittest.TestCase):
    def test_complete_clean_export_passes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "game.pck"
            output.write_bytes(b"pack")
            self.assertEqual((0, ""), check_export_result(output, 0, "BHYH_RAW_EXPORT files=1"))

    def test_artifact_does_not_hide_script_error(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "game.pck"
            output.write_bytes(b"pack")
            status, detail = check_export_result(output, 0, "SCRIPT ERROR: Parse Error: missing class\n")
            self.assertEqual(1, status)
            self.assertIn("Parse Error", detail)

    def test_artifact_does_not_hide_warning_or_nonzero_exit(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "game.pck"
            output.write_bytes(b"pack")
            for code, log in [(0, " WARNING: bad export"), (0, "ERROR: animation failed"), (1, "")]:
                with self.subTest(code=code, log=log):
                    self.assertEqual(1, check_export_result(output, code, log)[0])

    def test_missing_artifact_is_blocked(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "missing.pck"
            self.assertEqual(2, check_export_result(output, 0, "")[0])
            self.assertEqual(1, check_export_result(output, 1, "ERROR: export failed")[0])
            self.assertEqual(1, check_export_result(output, 0, "SCRIPT ERROR: Parse Error")[0])


if __name__ == "__main__":
    unittest.main()
