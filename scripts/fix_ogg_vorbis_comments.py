#!/usr/bin/env python3
"""修复 Ogg Vorbis comment 头中缺少 '=' 的条目。

Godot 加载 Ogg Vorbis 时会检查 comment 列表，对不含 '=' 的条目发出警告：
    Invalid comment in Ogg Vorbis file "...", should contain '=': "..."
Sony 等编码器会把编码器标识写成裸字符串。本脚本在等长约束下把该条目
改写为 ENCODER=<原值前缀>，只修改 comment 文本并重算所属 Ogg 页的 CRC。
音频包、页数、页序号、granule 与页布局全部保持不变。

这是本地素材预处理工具，不进入 check_all：公开仓库不包含 Music 素材。
修复后需要让 Godot 重新导入对应 .ogg。命令示例：
    python scripts/fix_ogg_vorbis_comments.py --check
    python scripts/fix_ogg_vorbis_comments.py
    python scripts/fix_ogg_vorbis_comments.py --root source/Music --dry-run

退出码：0 通过/修复完成；1 发现无效条目（--check）或修复失败；2 路径错误。
"""
from __future__ import annotations

import argparse
import os
import struct
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_ROOT = ROOT / "source" / "Music"
ENCODER_PREFIX = b"ENCODER="
VORBIS_IDENT = b"\x01vorbis"
VORBIS_COMMENT = b"\x03vorbis"
CRC_POLY = 0x04C11DB7
CRC_OFFSET = 22
CRC_SIZE = 4


@dataclass(frozen=True)
class Page:
    """一个 Ogg 页在文件中的位置与分页信息。"""

    offset: int
    total: int
    seq: int
    granule: int
    segments: tuple[int, ...]
    body_offset: int


@dataclass(frozen=True)
class Packet:
    """一个 Ogg 包及其在文件中的连续字节片段。"""

    data: bytes
    spans: tuple[tuple[int, int], ...]


def read_u32(data: bytes, offset: int) -> int:
    return struct.unpack_from("<I", data, offset)[0]


def read_i64(data: bytes, offset: int) -> int:
    return struct.unpack_from("<q", data, offset)[0]


def ogg_crc(data: bytes) -> int:
    """Ogg 页 CRC：多项式 0x04C11DB7，非反射，初值 0。"""
    crc = 0
    for byte in data:
        crc ^= byte << 24
        for _ in range(8):
            if crc & 0x80000000:
                crc = ((crc << 1) ^ CRC_POLY) & 0xFFFFFFFF
            else:
                crc = (crc << 1) & 0xFFFFFFFF
    return crc


def parse_pages(data: bytes) -> list[Page]:
    """按页头解析整个 Ogg 文件；页外数据视为损坏。"""
    pages: list[Page] = []
    offset = 0
    while offset < len(data):
        if offset + 27 > len(data) or data[offset:offset + 4] != b"OggS":
            raise ValueError(f"invalid Ogg page header at byte {offset}")
        if data[offset + 4] != 0:
            raise ValueError(f"unsupported Ogg version {data[offset + 4]} at byte {offset}")
        segment_count = data[offset + 26]
        header_end = offset + 27 + segment_count
        if header_end > len(data):
            raise ValueError(f"truncated Ogg segment table at byte {offset}")
        segments = tuple(data[offset + 27:header_end])
        total = 27 + segment_count + sum(segments)
        if offset + total > len(data):
            raise ValueError(f"truncated Ogg page at byte {offset}")
        pages.append(
            Page(
                offset=offset,
                total=total,
                seq=read_u32(data, offset + 18),
                granule=read_i64(data, offset + 6),
                segments=segments,
                body_offset=header_end,
            )
        )
        offset += total
    if not pages:
        raise ValueError("empty file")
    return pages


def locate_packets(data: bytes, pages: list[Page]) -> list[Packet]:
    """按 lacing 规则切包，并记录每个包在文件中的字节片段。"""
    packets: list[Packet] = []
    current = bytearray()
    spans: list[tuple[int, int]] = []
    for page in pages:
        position = page.body_offset
        for length in page.segments:
            current += data[position:position + length]
            spans.append((position, length))
            position += length
            if length < 255:
                packets.append(Packet(data=bytes(current), spans=tuple(spans)))
                current = bytearray()
                spans = []
    if current:
        raise ValueError("truncated Ogg packet at end of file")
    return packets


def find_comment_packet(packets: list[Packet]) -> int:
    if not packets or packets[0].data[:7] != VORBIS_IDENT:
        raise ValueError("not an Ogg Vorbis stream")
    for index, packet in enumerate(packets):
        if packet.data[:7] == VORBIS_COMMENT:
            return index
    raise ValueError("Vorbis comment packet not found")


def comment_entries(packet: bytes) -> list[tuple[int, int, bytes]]:
    """返回 comment 条目 (包内偏移, 长度, 原始字节)。"""
    if len(packet) < 11 or packet[:7] != VORBIS_COMMENT:
        raise ValueError("not a Vorbis comment packet")
    vendor_length = read_u32(packet, 7)
    position = 11 + vendor_length
    if position + 4 > len(packet):
        raise ValueError("truncated Vorbis comment packet")
    count = read_u32(packet, position)
    position += 4
    entries: list[tuple[int, int, bytes]] = []
    for _ in range(count):
        if position + 4 > len(packet):
            raise ValueError("truncated Vorbis comment length")
        length = read_u32(packet, position)
        position += 4
        if position + length > len(packet):
            raise ValueError("truncated Vorbis comment value")
        entries.append((position, length, packet[position:position + length]))
        position += length
    if position >= len(packet):
        raise ValueError("missing Vorbis comment framing bit")
    return entries


def page_for_offset(pages: list[Page], offset: int) -> Page:
    for page in pages:
        if page.offset <= offset < page.offset + page.total:
            return page
    raise ValueError(f"byte {offset} is outside all Ogg pages")


def page_crc(data: bytes, page: Page) -> int:
    raw = bytearray(data[page.offset:page.offset + page.total])
    raw[CRC_OFFSET:CRC_OFFSET + CRC_SIZE] = b"\x00" * CRC_SIZE
    return ogg_crc(bytes(raw))


def page_crc_valid(data: bytes, page: Page) -> bool:
    return read_u32(data, page.offset + CRC_OFFSET) == page_crc(data, page)


def write_span(
    buffer: bytearray,
    packet: Packet,
    start: int,
    replacement: bytes,
    pages: list[Page],
    changed_pages: set[Page],
) -> None:
    """将包内逻辑区间等长写入文件，并收集受影响的 Ogg 页。"""
    end = start + len(replacement)
    logical = 0
    for file_offset, length in packet.spans:
        span_end = logical + length
        overlap_start = max(start, logical)
        overlap_end = min(end, span_end)
        if overlap_start < overlap_end:
            target = file_offset + (overlap_start - logical)
            buffer[target:target + (overlap_end - overlap_start)] = replacement[
                overlap_start - start:overlap_end - start
            ]
            changed_pages.add(page_for_offset(pages, target))
        logical = span_end
    if logical != len(packet.data):
        raise ValueError("packet span map does not cover the packet")


def geometry(pages: list[Page]) -> list[tuple[int, int, int, int, tuple[int, ...], int]]:
    return [
        (page.offset, page.total, page.seq, page.granule, page.segments, page.body_offset)
        for page in pages
    ]


def repair_file(path: Path, dry_run: bool) -> list[tuple[bytes, bytes]]:
    """修复单个文件；返回 (原条目, 新条目) 列表。dry_run 不写盘。"""
    original = path.read_bytes()
    pages = parse_pages(original)
    packets = locate_packets(original, pages)
    comment_index = find_comment_packet(packets)
    comment_packet = packets[comment_index]
    entries = comment_entries(comment_packet.data)
    invalid = [(offset, length, value) for offset, length, value in entries if b"=" not in value]
    if not invalid:
        return []

    for offset, length, value in invalid:
        if length < len(ENCODER_PREFIX):
            raise ValueError(
                f"comment {value!r} is {length} bytes; too short for an equal-length ENCODER= fix"
            )

    fixes = [(value, (ENCODER_PREFIX + value)[:length]) for _, length, value in invalid]
    if dry_run:
        return fixes

    buffer = bytearray(original)
    changed_pages: set[Page] = set()
    for offset, length, _ in invalid:
        replacement = (ENCODER_PREFIX + comment_packet.data[offset:offset + length])[:length]
        write_span(buffer, comment_packet, offset, replacement, pages, changed_pages)

    for page in changed_pages:
        if not page_crc_valid(original, page):
            raise ValueError(f"page {page.seq} has an invalid CRC; refusing to rewrite")
        raw = bytearray(buffer[page.offset:page.offset + page.total])
        raw[CRC_OFFSET:CRC_OFFSET + CRC_SIZE] = b"\x00" * CRC_SIZE
        struct.pack_into("<I", raw, CRC_OFFSET, ogg_crc(bytes(raw)))
        buffer[page.offset:page.offset + page.total] = raw

    temp_path = path.with_name(path.name + ".tmp")
    temp_path.write_bytes(buffer)
    try:
        repaired = temp_path.read_bytes()
        repaired_pages = parse_pages(repaired)
        repaired_packets = locate_packets(repaired, repaired_pages)
        if geometry(repaired_pages) != geometry(pages):
            raise ValueError("page layout changed during repair")
        if len(repaired_packets) != len(packets):
            raise ValueError("packet count changed during repair")
        for index, (old_packet, new_packet) in enumerate(zip(packets, repaired_packets)):
            if index == comment_index:
                if len(old_packet.data) != len(new_packet.data):
                    raise ValueError("comment packet length changed during repair")
                if any(b"=" not in value for _, _, value in comment_entries(new_packet.data)):
                    raise ValueError("comment repair did not produce valid KEY=VALUE entries")
            elif old_packet.data != new_packet.data:
                raise ValueError(f"packet {index} changed during repair")
        repaired_by_seq = {page.seq: page for page in repaired_pages}
        for page in changed_pages:
            if not page_crc_valid(repaired, repaired_by_seq[page.seq]):
                raise ValueError(f"page {page.seq} CRC verification failed")
        os.replace(temp_path, path)
    finally:
        if temp_path.exists():
            temp_path.unlink()
    return fixes


def display_path(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="修复 Ogg Vorbis comment 中缺少 '=' 的条目。")
    parser.add_argument(
        "--root",
        type=Path,
        default=DEFAULT_ROOT,
        help="Ogg 根目录，默认 source/Music（相对路径按仓库根解析）",
    )
    parser.add_argument("--check", action="store_true", help="只检查，不写文件；存在无效条目时退出 1")
    parser.add_argument("--dry-run", action="store_true", help="打印修复计划但不写文件")
    args = parser.parse_args(argv)

    root = args.root if args.root.is_absolute() else ROOT / args.root
    if not root.is_dir():
        print(f"error: not a directory: {root}", file=sys.stderr)
        return 2
    files = sorted(root.rglob("*.ogg"))
    if not files:
        print(f"error: no .ogg files under {root}", file=sys.stderr)
        return 2

    counts = {"clean": 0, "invalid": 0, "fixed": 0, "would-fix": 0, "error": 0}
    for path in files:
        try:
            if args.check:
                original = path.read_bytes()
                pages = parse_pages(original)
                packets = locate_packets(original, pages)
                comment_index = find_comment_packet(packets)
                entries = comment_entries(packets[comment_index].data)
                invalid = [value for _, _, value in entries if b"=" not in value]
                if invalid:
                    counts["invalid"] += 1
                    print(f"invalid {display_path(path)}: " + ", ".join(repr(value) for value in invalid))
                else:
                    counts["clean"] += 1
                continue

            fixes = repair_file(path, dry_run=args.dry_run)
            if not fixes:
                counts["clean"] += 1
                continue
            if args.dry_run:
                counts["would-fix"] += 1
                for old, new in fixes:
                    print(f"would fix {display_path(path)}: {old!r} -> {new!r}")
            else:
                counts["fixed"] += 1
                for old, new in fixes:
                    print(f"fixed {display_path(path)}: {old!r} -> {new!r}")
        except (OSError, ValueError) as exc:
            counts["error"] += 1
            print(f"error {display_path(path)}: {exc}", file=sys.stderr)

    if args.check:
        print(
            f"checked {len(files)} file(s): {counts['invalid']} invalid, "
            f"{counts['clean']} clean, {counts['error']} error"
        )
    elif args.dry_run:
        print(
            f"checked {len(files)} file(s): {counts['would-fix']} would fix, "
            f"{counts['clean']} clean, {counts['error']} error"
        )
    else:
        print(
            f"checked {len(files)} file(s): {counts['fixed']} fixed, "
            f"{counts['clean']} clean, {counts['error']} error"
        )

    if counts["error"]:
        return 1
    if args.check and counts["invalid"]:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
