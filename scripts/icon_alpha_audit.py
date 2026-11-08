#!/usr/bin/env python3
"""Report-only icon alpha audit for BHYH consumer assets.

Scans source/Art/hero_picture/role_*/equipment.json referenced equipment icons
and reports PNGs that contain an opaque near-black background plate. Run from
the repository root; the default --root is source/. In a public clone without
private assets the scan reports zero icons and still succeeds.
"""

from __future__ import annotations

import argparse
import glob
import json
import struct
import sys
import zlib
from collections import deque
from pathlib import Path

DEFAULT_ICON_DIR = "Art/backpack/all_items"
DEFAULT_ROLE_GLOB = "Art/hero_picture/role_*/equipment.json"
BLACK_THRESHOLD = 24
ALPHA_OPAQUE = 200
ALPHA_TRANSPARENT = 16


def _chunks(data: bytes):
    pos = 8
    while pos + 12 <= len(data):
        length = struct.unpack_from(">I", data, pos)[0]
        kind = data[pos + 4:pos + 8]
        yield kind, data[pos + 8:pos + 8 + length]
        pos += 12 + length


def _unfilter(raw: bytes, width: int, height: int, channels: int) -> bytes:
    stride = width * channels
    out = bytearray()
    previous = bytearray(stride)
    pos = 0
    for _y in range(height):
        filter_kind = raw[pos]
        pos += 1
        line = bytearray(raw[pos:pos + stride])
        pos += stride
        for x in range(stride):
            left = line[x - channels] if x >= channels else 0
            above = previous[x]
            upper_left = previous[x - channels] if x >= channels else 0
            if filter_kind == 1:
                line[x] = (line[x] + left) & 0xFF
            elif filter_kind == 2:
                line[x] = (line[x] + above) & 0xFF
            elif filter_kind == 3:
                line[x] = (line[x] + ((left + above) >> 1)) & 0xFF
            elif filter_kind == 4:
                predictor = left + above - upper_left
                pa = abs(predictor - left)
                pb = abs(predictor - above)
                pc = abs(predictor - upper_left)
                if pa <= pb and pa <= pc:
                    paeth = left
                elif pb <= pc:
                    paeth = above
                else:
                    paeth = upper_left
                line[x] = (line[x] + paeth) & 0xFF
        out += line
        previous = line
    return bytes(out)


def read_png(path: Path):
    """Return decoded RGBA pixels for bit-depth-8, non-interlaced PNGs."""
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        return None, "not_png"
    width = height = bit_depth = color_type = interlace = None
    palette = b""
    transparency = None
    compressed = bytearray()
    for kind, payload in _chunks(data):
        if kind == b"IHDR":
            width, height, bit_depth, color_type, _comp, _filt, interlace = struct.unpack(
                ">IIBBBBB", payload
            )
        elif kind == b"PLTE":
            palette = payload
        elif kind == b"tRNS":
            transparency = payload
        elif kind == b"IDAT":
            compressed += payload
        elif kind == b"IEND":
            break
    if None in (width, height, bit_depth, color_type, interlace):
        return None, "bad_ihdr"
    if bit_depth != 8:
        return None, f"unsupported_bit_depth_{bit_depth}"
    if interlace != 0:
        return None, "interlaced"
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}.get(color_type)
    if channels is None:
        return None, f"unsupported_color_type_{color_type}"
    raw = zlib.decompress(bytes(compressed))
    pixels = _unfilter(raw, width, height, channels)
    rgba = []
    for y in range(height):
        row = []
        for x in range(width):
            index = (y * width + x) * channels
            if color_type == 6:
                r, g, b, a = pixels[index:index + 4]
            elif color_type == 2:
                r, g, b = pixels[index:index + 3]
                a = 255
                if transparency is not None and len(transparency) >= 6:
                    tr, tg, tb = struct.unpack(">HHH", transparency[:6])
                    if tr == r and tg == g and tb == b:
                        a = 0
            elif color_type == 3:
                palette_index = pixels[index]
                if palette_index * 3 + 2 >= len(palette):
                    return None, "bad_palette"
                r, g, b = palette[palette_index * 3:palette_index * 3 + 3]
                a = 255
                if transparency is not None and palette_index < len(transparency):
                    a = transparency[palette_index]
            elif color_type == 0:
                r = g = b = pixels[index]
                a = 255
            else:  # 4: grayscale + alpha
                r = g = b = pixels[index]
                a = pixels[index + 1]
            row.append((r, g, b, a))
        rgba.append(row)
    return (width, height, color_type, rgba), ""


def analyze(path: Path):
    decoded, error = read_png(path)
    if decoded is None:
        return None, error
    width, height, color_type, pixels = decoded
    opaque = 0
    transparent = 0
    black = 0
    for row in pixels:
        for r, g, b, a in row:
            if a > ALPHA_OPAQUE:
                opaque += 1
                if max(r, g, b) < BLACK_THRESHOLD:
                    black += 1
            elif a < ALPHA_TRANSPARENT:
                transparent += 1
    ratio = black / opaque if opaque else 0.0
    return {
        "width": width,
        "height": height,
        "color_type": color_type,
        "opaque": opaque,
        "transparent": transparent,
        "black": black,
        "ratio": ratio,
    }, ""


def role_icon_paths(root: Path, role_glob: str, icon_dir: str, allowed_roles=None):
    role_files = sorted(root.glob(role_glob))
    if allowed_roles:
        allowed = set(allowed_roles)
        role_files = [path for path in role_files if path.parent.name in allowed]
    paths = []
    missing = []
    for role_file in role_files:
        try:
            entries = json.loads(role_file.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            print(f"[SKIP] {role_file}: {exc}")
            continue
        if not isinstance(entries, list):
            print(f"[SKIP] {role_file}: expected a JSON list")
            continue
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            item_id = str(entry.get("id", "")).strip()
            if not item_id:
                continue
            icon = root / icon_dir / f"{item_id}.png"
            if icon.exists():
                paths.append(icon)
            else:
                missing.append((role_file, item_id, icon))
    return paths, missing


def expand_paths(root: Path, patterns):
    paths = []
    for pattern in patterns:
        candidate = Path(pattern)
        if not candidate.is_absolute():
            candidate = root / candidate
        matched = sorted(glob.glob(str(candidate), recursive=True))
        for match in matched:
            match_path = Path(match)
            if match_path.is_dir():
                paths.extend(sorted(match_path.rglob("*.png")))
            else:
                paths.append(match_path)
    return paths


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default="source", help="project root (default: source)")
    parser.add_argument("--icon-dir", default=DEFAULT_ICON_DIR, help="icon directory relative to root")
    parser.add_argument("--role-glob", default=DEFAULT_ROLE_GLOB, help="role equipment JSON glob")
    parser.add_argument("--role", action="append", default=[], help="restrict to one role name, repeatable")
    parser.add_argument("--paths", action="append", default=[], help="explicit file/dir/glob to audit")
    parser.add_argument("--threshold-ratio", type=float, default=0.30, help="black/opaque ratio threshold")
    parser.add_argument("--threshold-black", type=int, default=150, help="minimum opaque black pixels")
    parser.add_argument("--verbose", action="store_true", help="print every scanned icon")
    parser.add_argument("--strict", action="store_true", help="exit 1 when suspects are reported")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    if args.paths:
        icons = expand_paths(root, args.paths)
        missing = []
    else:
        role_glob = args.role_glob
        icons, missing = role_icon_paths(root, role_glob, args.icon_dir, args.role)

    suspects = []
    skipped = []
    seen = set()
    for icon in icons:
        icon = icon.resolve()
        if icon in seen:
            continue
        seen.add(icon)
        result, error = analyze(icon)
        if result is None:
            skipped.append((icon, error))
            continue
        ratio = result["ratio"]
        suspicious = (
            result["black"] >= args.threshold_black
            and ratio >= args.threshold_ratio
            and (result["transparent"] > 0 or ratio >= 0.90)
        )
        if suspicious:
            suspects.append((icon, result))
        elif args.verbose:
            print(f"[OK] {icon.relative_to(root) if icon.is_relative_to(root) else icon}")

    for icon, result in suspects:
        name = icon.relative_to(root) if icon.is_relative_to(root) else icon
        print(
            f"[SUSPECT] {name} {result['width']}x{result['height']} "
            f"color_type={result['color_type']} transparent={result['transparent']} "
            f"opaque={result['opaque']} black={result['black']} "
            f"ratio={result['ratio']:.1%}"
        )
    for role_file, item_id, icon in missing:
        print(f"[MISSING] {role_file}: id={item_id} -> {icon}")
    for icon, error in skipped:
        print(f"[SKIP] {icon}: {error}")

    print(
        f"SUMMARY scanned={len(seen)} suspects={len(suspects)} "
        f"missing={len(missing)} skipped={len(skipped)}"
    )
    if args.strict and suspects:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
