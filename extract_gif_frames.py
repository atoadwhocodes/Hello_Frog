from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image


def extract_gif_frames(gif_path: Path, output_dir: Path) -> dict:
    with Image.open(gif_path) as gif:
        frame_count = getattr(gif, "n_frames", 1)
        loop = gif.info.get("loop", 0)

        output_dir.mkdir(parents=True, exist_ok=True)

        frames = []
        for index in range(frame_count):
            gif.seek(index)
            frame = gif.convert("RGBA")

            duration = int(gif.info.get("duration", 0))
            filename = f"frame_{index:03d}.png"
            frame_path = output_dir / filename
            frame.save(frame_path)

            frames.append(
                {
                    "index": index,
                    "file": filename,
                    "duration_ms": duration,
                    "size": list(frame.size),
                }
            )

        manifest = {
            "source": gif_path.name,
            "frame_count": frame_count,
            "loop": loop,
            "size": list(gif.size),
            "frames": frames,
        }

        manifest_path = output_dir / "manifest.json"
        manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Extract ordered frames from a GIF and write a frame manifest."
    )
    parser.add_argument("gif", type=Path, help="Input GIF file")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="Output directory for extracted frames",
    )
    args = parser.parse_args()

    gif_path = args.gif
    if not gif_path.exists():
        raise FileNotFoundError(f"Missing GIF file: {gif_path}")

    output_dir = args.output or gif_path.with_name(f"{gif_path.stem}_frames")
    manifest = extract_gif_frames(gif_path, output_dir)

    print(f"Extracted {manifest['frame_count']} frames to {output_dir}")
    print(f"Wrote manifest: {output_dir / 'manifest.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
