from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

BASE_DIR = Path(__file__).resolve().parent
ASSETS_DIR = BASE_DIR / "frog assets"
SOURCE_SHEET = BASE_DIR / "frog_green_spritesheet.png"
SCENE_CHR_SOURCE = ASSETS_DIR / "frog.chr"
POND_FONT_OUT = BASE_DIR / "pond-font.chr"
SCENE_CHR_OUT = BASE_DIR / "frog_scene.chr"

chr_data = bytearray(8192)

FONT_CANDIDATES = [
    Path(r"C:/Windows/Fonts/consola.ttf"),
    Path(r"C:/Windows/Fonts/lucon.ttf"),
    BASE_DIR / "Fonts/Telluride.otf",
    BASE_DIR / "Fonts/telluride-webfont.ttf",
]

GLYPH_THRESHOLD = 92


def write_tile(chr_buffer, tile_index, rows):
    offset = tile_index * 16
    for i, row in enumerate(rows):
        chr_buffer[offset + i] = row
        chr_buffer[offset + 8 + i] = 0x00


def pick_font_path():
    for path in FONT_CANDIDATES:
        if path.exists():
            return path
    raise FileNotFoundError("No Telluride font file found in Fonts/")


def glyph_to_rows(ch, font):
    canvas = Image.new("L", (32, 32), 0)
    draw = ImageDraw.Draw(canvas)
    bbox = draw.textbbox((0, 0), ch, font=font)
    if bbox is None:
        return [0] * 8

    draw.text((-bbox[0], -bbox[1]), ch, font=font, fill=255)
    ink = canvas.getbbox()
    if ink is None:
        return [0] * 8

    glyph = canvas.crop(ink)
    scale = min(8 / glyph.width, 8 / glyph.height, 1.0)
    new_w = max(1, int(round(glyph.width * scale)))
    new_h = max(1, int(round(glyph.height * scale)))
    glyph = glyph.resize((new_w, new_h), Image.Resampling.LANCZOS)

    tile = Image.new("L", (8, 8), 0)
    tile.paste(glyph, ((8 - new_w) // 2, (8 - new_h) // 2))

    rows = []
    for y in range(8):
        bits = 0
        for x in range(8):
            if tile.getpixel((x, y)) >= GLYPH_THRESHOLD:
                bits |= 1 << (7 - x)
        rows.append(bits)
    return rows


def build_font_map():
    font_path = pick_font_path()
    font = ImageFont.truetype(str(font_path), 18)
    glyphs = {0x00: [0] * 8}
    for code in range(0x20, 0x7F):
        glyphs[code] = glyph_to_rows(chr(code), font)
    return glyphs


def detect_components(image):
    pix = image.load()
    width, height = image.size
    seen = [[False] * width for _ in range(height)]
    components = []

    for y in range(height):
        for x in range(width):
            if seen[y][x] or pix[x, y][3] == 0:
                continue

            queue = deque([(x, y)])
            seen[y][x] = True
            minx = maxx = x
            miny = maxy = y

            while queue:
                cx, cy = queue.popleft()
                if cx < minx:
                    minx = cx
                if cx > maxx:
                    maxx = cx
                if cy < miny:
                    miny = cy
                if cy > maxy:
                    maxy = cy

                for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
                    if 0 <= nx < width and 0 <= ny < height:
                        if not seen[ny][nx] and pix[nx, ny][3] != 0:
                            seen[ny][nx] = True
                            queue.append((nx, ny))

            components.append(((miny, minx), image.crop((minx, miny, maxx + 1, maxy + 1))))

    components.sort(key=lambda item: item[0])
    return [crop for _, crop in components]


def fit_sprite_to_16x16(sprite):
    sprite = sprite.convert("RGBA")

    if sprite.width > 16 or sprite.height > 16:
        left = max(0, (sprite.width - 16) // 2)
        top = max(0, (sprite.height - 16) // 2)
        sprite = sprite.crop((left, top, left + min(16, sprite.width), top + min(16, sprite.height)))

    canvas = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    paste_x = (16 - sprite.width) // 2
    paste_y = (16 - sprite.height) // 2
    canvas.alpha_composite(sprite, (paste_x, paste_y))
    return canvas


def pack_sprite(sprite):
    sprite = fit_sprite_to_16x16(sprite)
    plane0 = []
    plane1 = []

    for ty in (0, 8):
        for tx in (0, 8):
            for y in range(8):
                b0 = 0
                b1 = 0
                for x in range(8):
                    pixel = sprite.getpixel((tx + x, ty + y))
                    if pixel[3] == 0:
                        continue
                    r, g, b = pixel[:3]
                    luma = int(0.299 * r + 0.587 * g + 0.114 * b)
                    if luma < 80:
                        shade = 1
                    elif luma < 180:
                        shade = 2
                    else:
                        shade = 3
                    bit = 7 - x
                    if shade & 1:
                        b0 |= 1 << bit
                    if shade & 2:
                        b1 |= 1 << bit
                plane0.append(b0)
                plane1.append(b1)

    return plane0, plane1


def main():
    font = build_font_map()

    for idx, pat in font.items():
        offset = idx * 16
        for i in range(8):
            chr_data[offset + i] = pat[i]
            chr_data[offset + 8 + i] = 0x00

    write_tile(chr_data, 0xE0, [0x00, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x04])
    write_tile(chr_data, 0xE1, [0x00, 0x00, 0x08, 0x00, 0x00, 0x08, 0x00, 0x00])
    write_tile(chr_data, 0xE2, [0x00, 0x10, 0x00, 0x10, 0x00, 0x10, 0x00, 0x10])
    write_tile(chr_data, 0xE3, [0x00, 0x00, 0x18, 0x00, 0x00, 0x18, 0x00, 0x00])
    write_tile(chr_data, 0xE4, [0x18, 0x00, 0x18, 0x00, 0x18, 0x00, 0x18, 0x00])
    write_tile(chr_data, 0xE5, [0x3C, 0x00, 0x3C, 0x00, 0x3C, 0x00, 0x3C, 0x00])
    write_tile(chr_data, 0xE6, [0x00, 0x24, 0x42, 0x00, 0x24, 0x42, 0x00, 0x00])
    write_tile(chr_data, 0xE7, [0x00, 0x42, 0x24, 0x00, 0x42, 0x24, 0x00, 0x00])
    write_tile(chr_data, 0xE8, [0x00, 0x18, 0x24, 0x42, 0x24, 0x18, 0x00, 0x00])
    write_tile(chr_data, 0xE9, [0x7E, 0x42, 0x5A, 0x42, 0x5A, 0x42, 0x7E, 0x00])
    write_tile(chr_data, 0xEA, [0x18, 0x18, 0x18, 0x18, 0x7E, 0x18, 0x18, 0x18])

    if not SOURCE_SHEET.exists():
        raise FileNotFoundError(f"Missing sprite sheet: {SOURCE_SHEET}")

    with Image.open(SOURCE_SHEET) as source_sheet:
        sheet = source_sheet.convert("RGBA")

    components = detect_components(sheet)

    selected_frames = [0, 1, 2, 3, 4, 6, 11, 16]
    if max(selected_frames) >= len(components):
        raise ValueError(
            f"Sprite sheet only has {len(components)} components; expected at least {max(selected_frames) + 1}."
        )

    for frame_slot, component_index in enumerate(selected_frames):
        base = 0x7F + frame_slot * 4
        plane0, plane1 = pack_sprite(components[component_index])
        for i in range(8):
            chr_data[(base * 16) + i] = plane0[i]
            chr_data[(base * 16) + 8 + i] = plane1[i]
            chr_data[((base + 1) * 16) + i] = plane0[8 + i]
            chr_data[((base + 1) * 16) + 8 + i] = plane1[8 + i]
            chr_data[((base + 2) * 16) + i] = plane0[16 + i]
            chr_data[((base + 2) * 16) + 8 + i] = plane1[16 + i]
            chr_data[((base + 3) * 16) + i] = plane0[24 + i]
            chr_data[((base + 3) * 16) + 8 + i] = plane1[24 + i]

    POND_FONT_OUT.write_bytes(chr_data)

    if not SCENE_CHR_SOURCE.exists():
        raise FileNotFoundError(f"Missing scene CHR source: {SCENE_CHR_SOURCE}")

    scene_chr = bytearray(SCENE_CHR_SOURCE.read_bytes())
    if len(scene_chr) == 4096:
        scene_chr.extend(b"\x00" * 4096)
    elif len(scene_chr) != 8192:
        raise ValueError(f"{SCENE_CHR_SOURCE} must be 4096 or 8192 bytes, got {len(scene_chr)}")

    for tile_index in sorted(font.keys()):
        src = tile_index * 16
        scene_chr[src:src + 16] = chr_data[src:src + 16]

    for tile_index in (0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA):
        src = tile_index * 16
        scene_chr[src:src + 16] = chr_data[src:src + 16]

    for tile_index in range(0x7F, 0x9F):
        src = tile_index * 16
        scene_chr[src:src + 16] = chr_data[src:src + 16]

    SCENE_CHR_OUT.write_bytes(scene_chr)

    print(f"Created {POND_FONT_OUT.name}!")
    print(f"Created {SCENE_CHR_OUT.name}!")


if __name__ == "__main__":
    main()
