"""
Remove near-white background from a JPG/PNG image using flood fill from the 4 corners.

Preserves interior white regions (e.g., bird belly) because they are not reachable
from the corners — they are enclosed by non-background pixels (the bird's outline).

Usage:
    python remove_bg.py <input> <output.png> [--tolerance N] [--preview-violet <path>]

Tweaks:
    --tolerance N : color distance threshold (0-255). Default 22.
                    Increase to remove more (risk: eats the belly).
                    Decrease to be safer (risk: leaves halos).
"""

import argparse
import sys
from collections import deque
from PIL import Image


def remove_background(input_path: str, output_path: str, tolerance: int = 22) -> int:
    img = Image.open(input_path).convert("RGBA")
    w, h = img.size
    pixels = img.load()

    samples = [
        pixels[0, 0],
        pixels[w - 1, 0],
        pixels[0, h - 1],
        pixels[w - 1, h - 1],
    ]
    bg_r = sum(s[0] for s in samples) / 4
    bg_g = sum(s[1] for s in samples) / 4
    bg_b = sum(s[2] for s in samples) / 4
    print(f"  Sampled background color: ({bg_r:.0f}, {bg_g:.0f}, {bg_b:.0f})")
    print(f"  Tolerance: {tolerance}")
    print(f"  Image size: {w}x{h}")

    visited = bytearray(w * h)
    queue = deque()
    for x, y in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        queue.append((x, y))

    tol = tolerance
    transparent_count = 0
    while queue:
        x, y = queue.popleft()
        if x < 0 or x >= w or y < 0 or y >= h:
            continue
        idx = y * w + x
        if visited[idx]:
            continue
        visited[idx] = 1
        p = pixels[x, y]
        if (
            abs(p[0] - bg_r) <= tol
            and abs(p[1] - bg_g) <= tol
            and abs(p[2] - bg_b) <= tol
        ):
            pixels[x, y] = (0, 0, 0, 0)
            transparent_count += 1
            queue.append((x + 1, y))
            queue.append((x - 1, y))
            queue.append((x, y + 1))
            queue.append((x, y - 1))

    total = w * h
    pct = 100.0 * transparent_count / total
    print(f"  Transparent pixels: {transparent_count} / {total} ({pct:.1f}%)")

    if pct > 60:
        print(
            f"  WARNING: more than 60% removed — tolerance may be too high. "
            f"Check if the bird's white belly was eaten.",
            file=sys.stderr,
        )
    elif pct < 5:
        print(
            f"  WARNING: less than 5% removed — tolerance may be too low. "
            f"Background may not have been fully cleared.",
            file=sys.stderr,
        )

    img.save(output_path, "PNG")
    print(f"  Saved: {output_path}")
    return pct


def make_preview(input_png: str, output_path: str, bg_r: int, bg_g: int, bg_b: int) -> None:
    img = Image.open(input_png).convert("RGBA")
    bg = Image.new("RGBA", img.size, (bg_r, bg_g, bg_b, 255))
    bg.paste(img, (0, 0), img)
    bg.save(output_path, "PNG")
    print(f"  Preview saved: {output_path}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("input", help="Source image (JPG or PNG)")
    parser.add_argument("output", help="Output PNG with transparency")
    parser.add_argument(
        "--tolerance", type=int, default=22, help="Color distance threshold (0-255)"
    )
    parser.add_argument(
        "--preview-violet",
        metavar="PATH",
        help="Also write a preview composited on the brand violet #7C3AED",
    )
    args = parser.parse_args()

    print("Removing background...")
    pct = remove_background(args.input, args.output, args.tolerance)
    if args.preview_violet:
        print("Generating violet preview...")
        make_preview(args.output, args.preview_violet, 0x7C, 0x3A, 0xED)
    print("Done.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
