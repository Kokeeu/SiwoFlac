"""
Build the final 3 icon files from a transparent PNG (already bg-removed).

Outputs:
  - icon.png                  : 1024x1024, bird centered full canvas
  - icon_android.png          : 1024x1024, identical to icon.png
  - icon_foreground_android.png : 1024x1024, bird in central 68% (safe zone)

All three preserve the transparency from the source.

Usage:
    python build_icons.py <input.png> [--out-dir <dir>]
"""

import argparse
import os
import sys
from PIL import Image


CANVAS = 1024
SAFE_ZONE_PCT = 0.68  # central 68% of 1024 = 696 px
FULL_FILL_PCT = 0.94  # bird occupies 94% of canvas for icon.png


def get_bird_bbox(img: Image.Image) -> tuple[int, int, int, int]:
    """Find tight bounding box of the non-transparent region."""
    alpha = img.split()[-1]
    bbox = alpha.getbbox()
    if bbox is None:
        raise RuntimeError("Source image has no visible (non-transparent) content")
    return bbox


def fit_to_box(src_w: int, src_h: int, target_w: int, target_h: int) -> tuple[int, int]:
    """Compute dest size that fits src aspect ratio inside target box."""
    scale = min(target_w / src_w, target_h / src_h)
    return int(round(src_w * scale)), int(round(src_h * scale))


def composite_on_canvas(
    bird: Image.Image,
    canvas_size: int,
    target_pct: float,
) -> Image.Image:
    """Place the bird centered on a transparent canvas, scaled to target_pct of canvas."""
    bw, bh = bird.size
    target_w = int(round(canvas_size * target_pct))
    target_h = int(round(canvas_size * target_pct))
    new_w, new_h = fit_to_box(bw, bh, target_w, target_h)
    scaled = bird.resize((new_w, new_h), Image.LANCZOS)
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    off_x = (canvas_size - new_w) // 2
    off_y = (canvas_size - new_h) // 2
    canvas.paste(scaled, (off_x, off_y), scaled)
    return canvas


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("input", help="Source PNG (with transparency)")
    parser.add_argument(
        "--out-dir", default=".", help="Output directory (default: current)"
    )
    args = parser.parse_args()

    src = Image.open(args.input).convert("RGBA")
    bbox = get_bird_bbox(src)
    print(f"Source: {args.input}  size={src.size}  bird_bbox={bbox}")
    bird = src.crop(bbox)
    print(f"  Cropped bird: {bird.size}")

    os.makedirs(args.out_dir, exist_ok=True)

    icon_full = composite_on_canvas(bird, CANVAS, FULL_FILL_PCT)
    p1 = os.path.join(args.out_dir, "icon.png")
    icon_full.save(p1, "PNG")
    print(f"  icon.png                  : {p1}  ({CANVAS}x{CANVAS}, bird {FULL_FILL_PCT*100:.0f}%)")

    p2 = os.path.join(args.out_dir, "icon_android.png")
    icon_full.save(p2, "PNG")
    print(f"  icon_android.png          : {p2}  (identical to icon.png)")

    icon_safe = composite_on_canvas(bird, CANVAS, SAFE_ZONE_PCT)
    p3 = os.path.join(args.out_dir, "icon_foreground_android.png")
    icon_safe.save(p3, "PNG")
    print(f"  icon_foreground_android.png: {p3}  ({CANVAS}x{CANVAS}, bird in central {SAFE_ZONE_PCT*100:.0f}%)")

    print("Done.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
