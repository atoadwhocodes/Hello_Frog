import json
from collections import deque
from pathlib import Path

from PIL import Image

BASE_DIR = Path(__file__).resolve().parent
ASSETS_DIR = BASE_DIR / "frog assets"
SPRITESHEETS_DIR = ASSETS_DIR / "frog_spritesheets"
STYLE_SHEETS = [
    {"id": "green", "label": "GREEN TOAD", "path": SPRITESHEETS_DIR / "frog_green_spritesheet.png"},
    {"id": "tophat", "label": "TOP HAT TOAD", "path": SPRITESHEETS_DIR / "frog_tophat_spritesheet.png"},
    {"id": "cowboy", "label": "COWBOY TOAD", "path": SPRITESHEETS_DIR / "frog_cowboy_spritesheet.png"},
    {"id": "viking", "label": "VIKING TOAD", "path": SPRITESHEETS_DIR / "frog_viking_spritesheet.png"},
    {"id": "pirate", "label": "PIRATE TOAD", "path": SPRITESHEETS_DIR / "frog_pirate_spritesheet.png"},
    {"id": "clown", "label": "CLOWN TOAD", "path": SPRITESHEETS_DIR / "frog_clown_spritesheet.png"},
    {
        "id": "glasses",
        "label": "GLASSES TOAD",
        "path": SPRITESHEETS_DIR / "frog_funnyglasses_spritesheet.png",
    },
]
BACKGROUND_ASSET_FILES = {
    "ground_top": "frog assets/landscape/FreeCuteTileset/Tileset.png",
    "ground_fill": "frog assets/landscape/FreeCuteTileset/Tileset.png",
}
ANIMATION_MANIFEST_OUT = BASE_DIR / "frog_animation_manifest.json"
SCENE_CHR_SOURCE = ASSETS_DIR / "frog.chr"
POND_FONT_OUT = BASE_DIR / "pond-font.chr"
SCENE_CHR_OUT = BASE_DIR / "frog_scene.chr"
CHR_ROM_BYTES = 0x8000
CHR_PAGE_BYTES = 0x1000
CHR_PAGE_TILES = CHR_PAGE_BYTES // 16
SPRITE_STYLE_START_PAGE = 1
SPRITE_SOURCE_CELL_SIZE = 32
SPRITE_CANVAS_SIZE = (24, 32)
SPRITE_TILES_WIDE = 3
SPRITE_TILES_HIGH = 4
SPRITE_FRAME_TILE_COUNT = SPRITE_TILES_WIDE * SPRITE_TILES_HIGH
SPRITE_STYLE_PAGE_CAPACITY = CHR_PAGE_TILES // SPRITE_FRAME_TILE_COUNT

BG_TILE_SLICES = {
    # Keep the imported shore art in a fixed tile range so the ASM room data stays simple.
    0x07: ("ground_top", (0, 0, 8, 8)),
    0x08: ("ground_top", (8, 0, 16, 8)),
    0x09: ("ground_fill", (0, 8, 8, 16)),
    0x0A: ("ground_fill", (8, 8, 16, 16)),
}

CUSTOM_BG_TILES = {
    0x01: (
        "00110011",
        "01100110",
        "12211221",
        "21122112",
        "12211221",
        "21122112",
        "01100110",
        "00110011",
    ),
    0x02: (
        "11001100",
        "01100110",
        "22112211",
        "12211221",
        "21122112",
        "22112211",
        "01100110",
        "11001100",
    ),
    0x03: (
        "00000000",
        "00011110",
        "00122220",
        "01222330",
        "12233330",
        "12233330",
        "01222330",
        "00111110",
    ),
    0x04: (
        "00000000",
        "01111000",
        "02222200",
        "03332210",
        "03333221",
        "03333221",
        "03332210",
        "01111100",
    ),
    0x05: (
        "00111110",
        "01222330",
        "12233330",
        "22333330",
        "22333330",
        "12233330",
        "01222210",
        "00111100",
    ),
    0x06: (
        "01111100",
        "03332210",
        "03333221",
        "03333322",
        "03333322",
        "03333221",
        "01222210",
        "00111100",
    ),
    0x0B: (
        "30000000",
        "33000000",
        "33300000",
        "33330000",
        "33333000",
        "33333300",
        "33333330",
        "33333333",
    ),
    0x0C: (
        "00000111",
        "00012333",
        "00123333",
        "01233333",
        "12333333",
        "12333333",
        "12333333",
        "01233333",
    ),
    0x0D: (
        "11100000",
        "33332100",
        "33333210",
        "33333321",
        "33333332",
        "33333332",
        "33333332",
        "33333321",
    ),
    0x0E: (
        "12333333",
        "23333333",
        "33333333",
        "33333333",
        "33333333",
        "33333333",
        "23333333",
        "11222222",
    ),
    0x0F: (
        "33333321",
        "33333332",
        "33333333",
        "33333333",
        "33333333",
        "33333333",
        "33333332",
        "22222211",
    ),
    0x10: (
        "00022000",
        "00022000",
        "00022000",
        "00022000",
        "00022000",
        "00022000",
        "00022000",
        "00022000",
    ),
    0x11: (
        "00002200",
        "00002200",
        "00002200",
        "00002200",
        "00002200",
        "00002200",
        "00002200",
        "00002200",
    ),
    0x12: (
        "00001110",
        "00123333",
        "01233333",
        "12333333",
        "23333333",
        "23333333",
        "12333333",
        "01222221",
    ),
    0x13: (
        "01110000",
        "33332100",
        "33333210",
        "33333321",
        "33333332",
        "33333332",
        "33333321",
        "12222210",
    ),
    0x14: (
        "12333333",
        "23333333",
        "33333333",
        "33333333",
        "33333333",
        "33333333",
        "23333333",
        "12222221",
    ),
    0x15: (
        "33333321",
        "33333332",
        "33332333",
        "33323333",
        "33233333",
        "32333333",
        "33333332",
        "12222221",
    ),
    0x16: (
        "33333333",
        "13131313",
        "22222222",
        "22222222",
        "21222122",
        "22122212",
        "21222122",
        "22122212",
    ),
    0x17: (
        "00000000",
        "01111110",
        "02222220",
        "03333330",
        "33333333",
        "33333333",
        "03333330",
        "01111110",
    ),
    0x18: (
        "01111110",
        "03333330",
        "33333333",
        "33333333",
        "33333333",
        "33333333",
        "02222220",
        "00111100",
    ),
}

chr_data = bytearray(CHR_ROM_BYTES)

BITMAP_FONT = {
    " ": (),
    "!": ("..#..", "..#..", "..#..", "..#..", "..#..", ".....", "..#.."),
    '"': (".#.#.", ".#.#.", ".#.#.", ".....", ".....", ".....", "....."),
    "#": (".#.#.", "#####", ".#.#.", ".#.#.", "#####", ".#.#.", ".#.#."),
    "$": ("..#..", ".####", "#.#..", ".###.", "..#.#", "####.", "..#.."),
    "%": ("##..#", "##.#.", "...#.", "..#..", ".#...", ".#.##", "#..##"),
    "&": (".##..", "#..#.", "#.#..", ".##..", "#.#.#", "#..#.", ".##.#"),
    "'": ("..#..", "..#..", "..#..", ".....", ".....", ".....", "....."),
    "(": ("...#.", "..#..", ".#...", ".#...", ".#...", "..#..", "...#."),
    ")": (".#...", "..#..", "...#.", "...#.", "...#.", "..#..", ".#..."),
    "*": (".....", "#.#.#", ".###.", "#####", ".###.", "#.#.#", "....."),
    "+": (".....", "..#..", "..#..", "#####", "..#..", "..#..", "....."),
    ",": (".....", ".....", ".....", ".....", "..#..", "..#..", ".#..."),
    "-": (".....", ".....", ".....", "#####", ".....", ".....", "....."),
    ".": (".....", ".....", ".....", ".....", ".....", "..#..", "..#.."),
    "/": ("....#", "...#.", "..#..", ".#...", "#....", ".....", "....."),
    "0": (".###.", "#...#", "#..##", "#.#.#", "##..#", "#...#", ".###."),
    "1": ("..#..", ".##..", "..#..", "..#..", "..#..", "..#..", ".###."),
    "2": (".###.", "#...#", "....#", "...#.", "..#..", ".#...", "#####"),
    "3": ("#####", "....#", "...#.", "..##.", "....#", "#...#", ".###."),
    "4": ("...#.", "..##.", ".#.#.", "#..#.", "#####", "...#.", "...#."),
    "5": ("#####", "#....", "####.", "....#", "....#", "#...#", ".###."),
    "6": (".###.", "#....", "#....", "####.", "#...#", "#...#", ".###."),
    "7": ("#####", "....#", "...#.", "..#..", ".#...", ".#...", ".#..."),
    "8": (".###.", "#...#", "#...#", ".###.", "#...#", "#...#", ".###."),
    "9": (".###.", "#...#", "#...#", ".####", "....#", "....#", ".###."),
    ":": (".....", "..#..", "..#..", ".....", "..#..", "..#..", "....."),
    ";": (".....", "..#..", "..#..", ".....", "..#..", "..#..", ".#..."),
    "<": ("...#.", "..#..", ".#...", "#....", ".#...", "..#..", "...#."),
    "=": (".....", "#####", ".....", "#####", ".....", ".....", "....."),
    ">": (".#...", "..#..", "...#.", "....#", "...#.", "..#..", ".#..."),
    "?": (".###.", "#...#", "....#", "...#.", "..#..", ".....", "..#.."),
    "@": (".###.", "#...#", "#.###", "#.#.#", "#.###", "#....", ".####"),
    "A": (".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"),
    "B": ("####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."),
    "C": (".###.", "#...#", "#....", "#....", "#....", "#...#", ".###."),
    "D": ("####.", "#...#", "#...#", "#...#", "#...#", "#...#", "####."),
    "E": ("#####", "#....", "#....", "####.", "#....", "#....", "#####"),
    "F": ("#####", "#....", "#....", "####.", "#....", "#....", "#...."),
    "G": (".###.", "#...#", "#....", "#.###", "#...#", "#...#", ".###."),
    "H": ("#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"),
    "I": ("#####", "..#..", "..#..", "..#..", "..#..", "..#..", "#####"),
    "J": ("..###", "...#.", "...#.", "...#.", "...#.", "#..#.", ".##.."),
    "K": ("#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"),
    "L": ("#....", "#....", "#....", "#....", "#....", "#....", "#####"),
    "M": ("#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"),
    "N": ("#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"),
    "O": (".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."),
    "P": ("####.", "#...#", "#...#", "####.", "#....", "#....", "#...."),
    "Q": (".###.", "#...#", "#...#", "#...#", "#.#.#", "#..#.", ".##.#"),
    "R": ("####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"),
    "S": (".####", "#....", "#....", ".###.", "....#", "....#", "####."),
    "T": ("#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."),
    "U": ("#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."),
    "V": ("#...#", "#...#", "#...#", "#...#", "#...#", ".#.#.", "..#.."),
    "W": ("#...#", "#...#", "#...#", "#.#.#", "#.#.#", "##.##", "#...#"),
    "X": ("#...#", "#...#", ".#.#.", "..#..", ".#.#.", "#...#", "#...#"),
    "Y": ("#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."),
    "Z": ("#####", "....#", "...#.", "..#..", ".#...", "#....", "#####"),
    "[": (".###.", ".#...", ".#...", ".#...", ".#...", ".#...", ".###."),
    "\\": ("#....", ".#...", "..#..", "...#.", "....#", ".....", "....."),
    "]": (".###.", "...#.", "...#.", "...#.", "...#.", "...#.", ".###."),
    "^": ("..#..", ".#.#.", "#...#", ".....", ".....", ".....", "....."),
    "_": (".....", ".....", ".....", ".....", ".....", ".....", "#####"),
    "`": (".#...", "..#..", "...#.", ".....", ".....", ".....", "....."),
    "{": ("...#.", "..#..", "..#..", ".#...", "..#..", "..#..", "...#."),
    "|": ("..#..", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."),
    "}": (".#...", "..#..", "..#..", "...#.", "..#..", "..#..", ".#..."),
    "~": (".....", ".##..", "#..#.", ".....", ".....", ".....", "....."),
}


def write_tile(chr_buffer, tile_index, rows):
    offset = tile_index * 16
    for i, row in enumerate(rows):
        chr_buffer[offset + i] = row
        chr_buffer[offset + 8 + i] = 0x00


def write_shaded_tile(chr_buffer, tile_index, pattern):
    if len(pattern) != 8 or any(len(row) != 8 for row in pattern):
        raise ValueError(f"Shaded tile {tile_index:#04x} must be 8x8.")

    offset = tile_index * 16
    for y, row in enumerate(pattern):
        plane0 = 0
        plane1 = 0
        for x, shade_char in enumerate(row):
            shade = int(shade_char)
            bit = 7 - x
            if shade & 1:
                plane0 |= 1 << bit
            if shade & 2:
                plane1 |= 1 << bit
        chr_buffer[offset + y] = plane0
        chr_buffer[offset + 8 + y] = plane1


def pixel_to_shade(pixel):
    if pixel[3] == 0:
        return 0

    r, g, b = pixel[:3]
    luma = int(0.299 * r + 0.587 * g + 0.114 * b)
    if luma < 80:
        return 1
    if luma < 180:
        return 2
    return 3


def image_to_tile_planes(image):
    image = image.convert("RGBA")
    if image.size != (8, 8):
        raise ValueError(f"Expected an 8x8 tile image, got {image.size}.")

    plane0 = []
    plane1 = []
    for y in range(8):
        b0 = 0
        b1 = 0
        for x in range(8):
            shade = pixel_to_shade(image.getpixel((x, y)))
            bit = 7 - x
            if shade & 1:
                b0 |= 1 << bit
            if shade & 2:
                b1 |= 1 << bit
        plane0.append(b0)
        plane1.append(b1)
    return plane0, plane1


def write_image_tile(chr_buffer, tile_index, image):
    plane0, plane1 = image_to_tile_planes(image)
    offset = tile_index * 16
    for i in range(8):
        chr_buffer[offset + i] = plane0[i]
        chr_buffer[offset + 8 + i] = plane1[i]


def pattern_to_rows(pattern):
    rows = [0] * 8
    if not pattern:
        return rows

    width = max(len(row) for row in pattern)
    if width > 8 or len(pattern) > 8:
        raise ValueError(f"Bitmap glyph is too large for an 8x8 tile: {pattern}")

    x_offset = (8 - width) // 2
    y_offset = 0

    for y, row in enumerate(pattern):
        bits = 0
        for x, pixel in enumerate(row):
            if pixel != ".":
                bits |= 1 << (7 - (x + x_offset))
        rows[y + y_offset] = bits

    return rows


def glyph_to_rows(ch):
    pattern = BITMAP_FONT.get(ch)
    if pattern is None and "a" <= ch <= "z":
        pattern = BITMAP_FONT.get(ch.upper())
    if pattern is None:
        pattern = BITMAP_FONT["?"]
    return pattern_to_rows(pattern)


def build_font_map():
    glyphs = {0x00: [0] * 8}
    for code in range(0x20, 0x7F):
        glyphs[code] = glyph_to_rows(chr(code))
    return glyphs


def load_background_sources():
    sources = {}
    for asset_name, relative_path in BACKGROUND_ASSET_FILES.items():
        path = BASE_DIR / relative_path
        if not path.exists():
            raise FileNotFoundError(f"Missing background source asset: {path}")
        with Image.open(path) as image:
            sources[asset_name] = image.convert("RGBA")
    return sources


def write_background_tiles(chr_buffer):
    sources = load_background_sources()
    for tile_index, (asset_name, crop_box) in BG_TILE_SLICES.items():
        tile = sources[asset_name].crop(crop_box)
        write_image_tile(chr_buffer, tile_index, tile)


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


def extract_sheet_frames(sheet_path):
    if not sheet_path.exists():
        raise FileNotFoundError(f"Missing sprite sheet: {sheet_path}")

    frames = []
    with Image.open(sheet_path) as source:
        image = source.convert("RGBA")

    for grid_y in range(image.height // SPRITE_SOURCE_CELL_SIZE):
        for grid_x in range(image.width // SPRITE_SOURCE_CELL_SIZE):
            crop = image.crop(
                (
                    grid_x * SPRITE_SOURCE_CELL_SIZE,
                    grid_y * SPRITE_SOURCE_CELL_SIZE,
                    (grid_x + 1) * SPRITE_SOURCE_CELL_SIZE,
                    (grid_y + 1) * SPRITE_SOURCE_CELL_SIZE,
                )
            )
            bbox = crop.getbbox()
            if not bbox:
                continue
            frames.append(
                {
                    "index": len(frames),
                    "grid": [grid_x, grid_y],
                    "bbox": list(bbox),
                    "image": crop,
                }
            )

    return frames


def fit_sprite_to_canvas(sprite, canvas_size=SPRITE_CANVAS_SIZE):
    sprite = sprite.convert("RGBA")
    bbox = sprite.getbbox()
    if bbox:
        sprite = sprite.crop(bbox)
    else:
        return Image.new("RGBA", canvas_size, (0, 0, 0, 0))

    canvas_w, canvas_h = canvas_size
    if sprite.width > canvas_w or sprite.height > canvas_h:
        scale = min(canvas_w / sprite.width, canvas_h / sprite.height)
        sprite = sprite.resize(
            (
                max(1, int(sprite.width * scale)),
                max(1, int(sprite.height * scale)),
            ),
            Image.Resampling.NEAREST,
        )

    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    paste_x = (canvas_w - sprite.width) // 2
    paste_y = canvas_h - sprite.height
    canvas.alpha_composite(sprite, (paste_x, paste_y))
    return canvas


def pack_sprite(
    sprite,
    tiles_wide=SPRITE_TILES_WIDE,
    tiles_high=SPRITE_TILES_HIGH,
    canvas_size=SPRITE_CANVAS_SIZE,
):
    sprite = fit_sprite_to_canvas(sprite, canvas_size=canvas_size)
    plane0 = []
    plane1 = []

    for tile_y in range(tiles_high):
        for tile_x in range(tiles_wide):
            tx = tile_x * 8
            ty = tile_y * 8
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


def pack_sprite_at_base(
    chr_buffer,
    base_tile,
    sprite,
    tiles_wide=SPRITE_TILES_WIDE,
    tiles_high=SPRITE_TILES_HIGH,
    canvas_size=SPRITE_CANVAS_SIZE,
):
    plane0, plane1 = pack_sprite(
        sprite,
        tiles_wide=tiles_wide,
        tiles_high=tiles_high,
        canvas_size=canvas_size,
    )
    tile_count = tiles_wide * tiles_high
    for tile_index in range(tile_count):
        base_offset = (base_tile + tile_index) * 16
        plane_offset = tile_index * 8
        for row in range(8):
            chr_buffer[base_offset + row] = plane0[plane_offset + row]
            chr_buffer[base_offset + 8 + row] = plane1[plane_offset + row]


def main():
    if len(STYLE_SHEETS) > (CHR_ROM_BYTES // CHR_PAGE_BYTES) - SPRITE_STYLE_START_PAGE:
        raise ValueError("Not enough CHR pages to store every configured hat style.")

    font = build_font_map()

    for idx, pat in font.items():
        offset = idx * 16
        for i in range(8):
            chr_data[offset + i] = pat[i]
            chr_data[offset + 8 + i] = 0x00

    for tile_index, pattern in CUSTOM_BG_TILES.items():
        write_shaded_tile(chr_data, tile_index, pattern)
    write_background_tiles(chr_data)

    POND_FONT_OUT.write_bytes(chr_data)

    if not SCENE_CHR_SOURCE.exists():
        raise FileNotFoundError(f"Missing scene CHR source: {SCENE_CHR_SOURCE}")

    scene_chr = bytearray(SCENE_CHR_SOURCE.read_bytes())
    if len(scene_chr) == 4096:
        scene_chr.extend(b"\x00" * (CHR_ROM_BYTES - 4096))
    elif len(scene_chr) == 8192:
        scene_chr.extend(b"\x00" * (CHR_ROM_BYTES - 8192))
    elif len(scene_chr) != CHR_ROM_BYTES:
        raise ValueError(
            f"{SCENE_CHR_SOURCE} must be 4096, 8192, or {CHR_ROM_BYTES} bytes, got {len(scene_chr)}"
        )

    for tile_index in sorted(font.keys()):
        src = tile_index * 16
        scene_chr[src:src + 16] = chr_data[src:src + 16]

    for tile_index in range(0x01, 0x19):
        src = tile_index * 16
        scene_chr[src:src + 16] = chr_data[src:src + 16]

    manifest = {
        "sprite_canvas": list(SPRITE_CANVAS_SIZE),
        "frame_tile_count": SPRITE_FRAME_TILE_COUNT,
        "styles": [],
    }

    for style_index, style in enumerate(STYLE_SHEETS):
        frames = extract_sheet_frames(style["path"])
        if len(frames) > SPRITE_STYLE_PAGE_CAPACITY:
            raise ValueError(
                f"{style['path'].name} has {len(frames)} frames; only {SPRITE_STYLE_PAGE_CAPACITY} fit in one sprite page."
            )

        page_index = SPRITE_STYLE_START_PAGE + style_index
        page_tile_start = page_index * CHR_PAGE_TILES
        bank_base = page_index * 4
        style_manifest = {
            "id": style["id"],
            "label": style["label"],
            "source": style["path"].name,
            "style_index": style_index,
            "chr_page": page_index,
            "chr_bank_base": bank_base,
            "frame_count": len(frames),
            "frames": [],
        }

        for frame in frames:
            tile_base = frame["index"] * SPRITE_FRAME_TILE_COUNT
            pack_sprite_at_base(scene_chr, page_tile_start + tile_base, frame["image"])
            style_manifest["frames"].append(
                {
                    "index": frame["index"],
                    "grid": frame["grid"],
                    "bbox": frame["bbox"],
                    "tile_base": tile_base,
                }
            )

        manifest["styles"].append(style_manifest)

    ANIMATION_MANIFEST_OUT.write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    SCENE_CHR_OUT.write_bytes(scene_chr)

    print(f"Created {POND_FONT_OUT.name}!")
    print(f"Created {SCENE_CHR_OUT.name}!")


if __name__ == "__main__":
    main()
