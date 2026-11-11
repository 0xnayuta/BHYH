#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""export_asset_exclusions.py 的聚焦回归测试。

覆盖消费者可见缺陷：
- include/exclude 过滤冲突；
- 混合 Art 根压缩 glob 误伤非 DragonBones 目录；
- 保留的生产资源引用被排除；
- 两个 all_resources 预设漂移；
- 公开 clone 缺私有素材时 BLOCKED 而非假 PASS；
- 地图 Catalog 只忽略明确的索引键，不忽略同文件的值。
"""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import export_asset_exclusions as exclusions  # noqa: E402


def write_file(root: Path, relative: str, content: str = "") -> Path:
    path = root / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return path


def write_presets(
    path: Path,
    exclude_a: str,
    exclude_b: str | None = None,
    include: str = "",
) -> None:
    """写两个 all_resources 预设；exclude_b 缺省时与 exclude_a 相同。"""
    second = exclude_a if exclude_b is None else exclude_b
    chunks: list[str] = []
    for index, exclude in enumerate((exclude_a, second)):
        chunks.append(
            "\n".join(
                [
                    f"[preset.{index}]",
                    f'name="Windows Desktop {index}"',
                    'platform="Windows Desktop"',
                    'export_filter="all_resources"',
                    f'include_filter="{include}"',
                    f'exclude_filter="{exclude}"',
                    "",
                    f"[preset.{index}.options]",
                    "",
                ]
            )
        )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(chunks), encoding="utf-8")


def policy_for(path: Path) -> exclusions.PolicyResult:
    return exclusions.select_policy(exclusions.parse_export_presets(path))


class FilterPatternTests(unittest.TestCase):
    def test_question_mark_does_not_match_period(self) -> None:
        pattern = exclusions.FilterPattern.parse("Art/item?png")
        self.assertTrue(pattern.matches("res://Art/item1png"))
        self.assertFalse(pattern.matches("res://Art/item.png"))


class PresetPolicyTests(unittest.TestCase):
    def test_two_preset_drift_fails(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            presets = Path(temporary) / "export_presets.cfg"
            write_presets(presets, "Art/ui/*", "Art/ui/*,Art/diepng/*")
            result = policy_for(presets)
            codes = [issue.code for issue in result.failures]
            self.assertIn("preset_policy_drift", codes)

    def test_include_filter_conflict_fails(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            presets = Path(temporary) / "export_presets.cfg"
            write_presets(presets, "Art/ui/*", include="Art/ui/icon.png")
            result = policy_for(presets)
            codes = [issue.code for issue in result.failures]
            self.assertIn("include_filter_conflict", codes)

    def test_include_is_case_insensitive_and_uses_res_prefix(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            presets = Path(temporary) / "export_presets.cfg"
            write_presets(
                presets,
                "res://ART/UI/*",
                include="art/ui/icon.png",
            )
            result = policy_for(presets)
            codes = [issue.code for issue in result.failures]
            self.assertIn("include_filter_conflict", codes)


class ExclusionCoverageTests(unittest.TestCase):
    def test_mixed_root_prefix_glob_collateral_fails(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "source"
            write_file(source, "Art/monster/db_a/db_a.dbfactory", "factory")
            write_file(source, "Art/monster/db_a/body.png", "png")
            write_file(source, "Art/monster/keep/keep.png", "keep")
            # 新增的非工厂目录仍落在压缩前缀内：必须 fail-closed。
            write_file(source, "Art/monster/db_keep/keep.png", "keep")

            result = exclusions.audit_patterns(
                source,
                ["Art/monster/db*/*"],
                required_dirs=(),
                check_factories=True,
            )
            codes = [issue.code for issue in result.failures]
            self.assertIn("glob_collision", codes)
            collision = next(issue for issue in result.failures if issue.code == "glob_collision")
            self.assertTrue(any("db_keep/keep.png" in sample for sample in collision.samples))

    def test_future_factory_without_pattern_fails(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "source"
            write_file(source, "Art/monster/old/old.dbfactory", "factory")
            write_file(source, "Art/monster/old/body.png", "png")
            write_file(source, "Art/monster/new/new.dbfactory", "factory")
            write_file(source, "Art/monster/new/body.png", "png")

            result = exclusions.audit_patterns(
                source,
                ["Art/monster/old/*"],
                required_dirs=(),
                check_factories=True,
            )
            codes = [issue.code for issue in result.failures]
            self.assertIn("factory_dir_uncovered", codes)
            issue = next(issue for issue in result.failures if issue.code == "factory_dir_uncovered")
            self.assertEqual(issue.path, "Art/monster/new")

    def test_required_domain_without_pattern_fails(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "source"
            write_file(source, "Art/ui/icon.png", "png")

            result = exclusions.audit_patterns(
                source,
                ["Art/zmws_spine/*"],
                required_dirs=("Art/ui",),
                check_factories=False,
            )
            codes = [issue.code for issue in result.failures]
            self.assertIn("required_domain_pattern_missing", codes)
            self.assertIn("required_dir_uncovered", codes)


class ReferenceScanTests(unittest.TestCase):
    def _pattern_result(
        self, source: Path, patterns: list[str], required: tuple[str, ...]
    ) -> exclusions.PatternResult:
        return exclusions.audit_patterns(
            source, patterns, required_dirs=required, check_factories=False
        )

    def test_retained_scene_reference_to_excluded_resource_fails(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "source"
            write_file(source, "Art/ui/icon.png", "png")
            write_file(
                source,
                "Scene/keep.tscn",
                "\n".join(
                    [
                        "[gd_scene load_steps=2 format=3]",
                        '[ext_resource type="Texture2D" path="res://Art/ui/icon.png" id="1"]',
                        "",
                        '[node name="Keep" type="Node2D"]',
                        "",
                    ]
                ),
            )
            patterns = self._pattern_result(source, ["Art/ui/*"], ("Art/ui",))
            references = exclusions.audit_references(
                source, patterns.index, patterns.patterns, check_manifests=False
            )
            codes = [issue.code for issue in references.failures]
            self.assertIn("excluded_reference", codes)

    def test_relative_concat_prefix_under_excluded_dir_fails(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "source"
            write_file(source, "Art/ui/icon.png", "png")
            write_file(
                source,
                "Script/use.gd",
                'func _ready() -> void:\n\tvar path := "Art/ui/" + "icon.png"\n',
            )
            patterns = self._pattern_result(source, ["Art/ui/*"], ("Art/ui",))
            references = exclusions.audit_references(
                source, patterns.index, patterns.patterns, check_manifests=False
            )
            codes = [issue.code for issue in references.failures]
            self.assertIn("excluded_relative_reference", codes)

    def test_uid_reference_to_excluded_resource_fails(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "source"
            write_file(
                source,
                "Art/ui/sheet.tres",
                '[gd_resource type="Resource" format=3 uid="uid://excluded123"]\n',
            )
            write_file(
                source,
                "Script/use.gd",
                'func _ready() -> void:\n\tvar value = load("uid://excluded123")\n',
            )
            patterns = self._pattern_result(source, ["Art/ui/*"], ("Art/ui",))
            references = exclusions.audit_references(
                source, patterns.index, patterns.patterns, check_manifests=False
            )
            codes = [issue.code for issue in references.failures]
            self.assertIn("excluded_uid_reference", codes)

    def test_map_catalog_ignores_only_mapping_keys(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "source"
            write_file(source, "Scene/level/zmws/map.tscn", "scene")
            write_file(source, "Script/data/level_layouts/map.tres", "layout")
            catalog = write_file(
                source,
                "Script/data/level_layout_catalog.tres",
                "\n".join(
                    [
                        '[gd_resource type="Resource" format=3]',
                        "",
                        "[resource]",
                        "layout_paths = {",
                        '\t&"res://Scene/level/zmws/map.tscn": &"res://Script/data/level_layouts/map.tres",',
                        "}",
                        "",
                    ]
                ),
            )
            patterns = self._pattern_result(
                source, ["Scene/level/zmws/*"], ("Scene/level/zmws",)
            )
            references = exclusions.audit_references(
                source, patterns.index, patterns.patterns, check_manifests=False
            )
            self.assertEqual([], references.failures)
            self.assertEqual(1, references.stats["ignored_catalog_keys"])

            # 同一行的值不是索引键，必须继续检查。
            catalog.write_text(
                "\n".join(
                    [
                        '[gd_resource type="Resource" format=3]',
                        "",
                        "[resource]",
                        "layout_paths = {",
                        '\t&"res://Scene/level/zmws/map.tscn": &"res://Scene/level/zmws/other.tscn",',
                        "}",
                        "",
                    ]
                ),
                encoding="utf-8",
            )
            references = exclusions.audit_references(
                source,
                exclusions.build_file_index(source),
                patterns.patterns,
                check_manifests=False,
            )
            codes = [issue.code for issue in references.failures]
            self.assertIn("excluded_reference", codes)

    def test_public_clone_missing_private_assets_blocks_not_passes(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "source"
            write_file(source, "Scene/level/zmws/map.tscn", "scene")
            write_file(source, "Scene/level/zmws_playable/playable.tscn", "scene")
            presets = source / "export_presets.cfg"
            write_presets(
                presets,
                ",".join(f"{directory}/*" for directory in exclusions.REQUIRED_EXCLUSION_DIRS),
            )

            report = exclusions.run_check(source, presets, check_manifests=False)
            self.assertEqual("BLOCKED", report["status"])
            self.assertFalse(report["failures"])
            self.assertTrue(report["blocked"])
            self.assertFalse(report["ok"])


class ExcludedPathApiTests(unittest.TestCase):
    def test_returns_importable_resources_without_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "source"
            write_file(source, "Art/ui/a.png", "png")
            write_file(source, "Art/ui/a.png.import", "import")
            write_file(source, "Art/ui/b.uid", "uid://b")
            write_file(source, "Art/ui/c.json", "{}")
            write_file(source, "Art/ui/sub/d.tres", "resource")

            result = exclusions.excluded_resource_paths(source, ["res://ART/UI/*"])
            self.assertEqual(
                [
                    "res://Art/ui/a.png",
                    "res://Art/ui/c.json",
                    "res://Art/ui/sub/d.tres",
                ],
                result,
            )

    def test_no_patterns_returns_empty(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "source"
            write_file(source, "Art/ui/a.png", "png")
            self.assertEqual([], exclusions.excluded_resource_paths(source, []))


if __name__ == "__main__":
    unittest.main()
