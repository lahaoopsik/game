"""Convert authored pixel-art atlases into native-size Unity point-filtered sheets.

The atlas inputs are kept under ArtDirection/source-atlases. Each object is
cropped independently, fitted by nearest-neighbour sampling, and packed into
integer sprite frames; whole concept images are never used as game textures.
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "ArtDirection" / "source-atlases"
ART = ROOT / "Assets" / "Resources" / "Art"
BLOCKS = ROOT / "Assets" / "Resources" / "Blocks"


def grid(source_name, output, columns, rows, cell_w, cell_h, pad=2, crop_alpha=False):
    image = Image.open(SOURCE / source_name).convert("RGBA")
    atlas = Image.new("RGBA", (columns * cell_w, rows * cell_h), (0, 0, 0, 0))
    sw, sh = image.size
    for row in range(rows):
        for col in range(columns):
            x0, x1 = round(col * sw / columns) + pad, round((col + 1) * sw / columns) - pad
            y0, y1 = round(row * sh / rows) + pad, round((row + 1) * sh / rows) - pad
            tile = image.crop((x0, y0, x1, y1))
            if crop_alpha:
                alpha = tile.getchannel("A").point(lambda a: 255 if a >= 96 else 0)
                bounds = alpha.getbbox()
                if bounds:
                    tile = tile.crop(bounds)
                    ratio = min((cell_w - 8) / tile.width, (cell_h - 8) / tile.height)
                    size = (max(1, round(tile.width * ratio)), max(1, round(tile.height * ratio)))
                    tile = tile.resize(size, Image.Resampling.NEAREST)
                    x, y = (cell_w - size[0]) // 2, cell_h - size[1] - 3
                    atlas.alpha_composite(tile, (col * cell_w + x, row * cell_h + y))
            else:
                tile = tile.resize((cell_w, cell_h), Image.Resampling.NEAREST)
                atlas.alpha_composite(tile, (col * cell_w, row * cell_h))
    atlas.save(output)


def hero_sheet(source_name, output):
    image = Image.open(SOURCE / source_name).convert("RGBA")
    columns, rows, fw, fh = 6, 4, 24, 32
    atlas = Image.new("RGBA", (columns * fw, rows * fh), (0, 0, 0, 0))
    sw, sh = image.size
    for row in range(rows):
        for col in range(columns):
            tile = image.crop((round(col * sw / columns) + 3,
                               round(row * sh / rows) + 3,
                               round((col + 1) * sw / columns) - 3,
                               round((row + 1) * sh / rows) - 3))
            alpha = tile.getchannel("A").point(lambda a: 255 if a >= 96 else 0)
            bounds = alpha.getbbox()
            if not bounds:
                continue
            tile = tile.crop(bounds)
            ratio = min((fw - 4) / tile.width, (fh - 3) / tile.height)
            size = (max(1, round(tile.width * ratio)), max(1, round(tile.height * ratio)))
            tile = tile.resize(size, Image.Resampling.NEAREST)
            atlas.alpha_composite(tile, (col * fw + (fw - size[0]) // 2,
                                         row * fh + fh - size[1]))
    atlas.save(output)


def bridge_sprite(source_name, output):
    image = Image.open(SOURCE / source_name).convert("RGBA")
    alpha = image.getchannel("A").point(lambda a: 255 if a >= 96 else 0)
    bounds = alpha.getbbox()
    image = image.crop(bounds)
    image = image.resize((192, 96), Image.Resampling.NEAREST)
    image.save(output)


def axe_sheet(source_name, output):
    grid(source_name, output, 4, 4, 36, 36, pad=2, crop_alpha=True)


def grass_rim():
    floors = Image.open(BLOCKS / "floors-v2.png").convert("RGBA")
    rim = Image.new("RGBA", (96, 8), (0, 0, 0, 0))
    for variant in range(4):
        grass = floors.crop((variant * 24, 0, variant * 24 + 24, 24))
        soil = floors.crop((variant * 24, 3 * 24, variant * 24 + 24, 4 * 24))
        tile = Image.new("RGBA", (24, 8))
        tile.alpha_composite(grass.crop((0, 0, 24, 2)), (0, 0))
        tile.alpha_composite(soil.crop((0, 0, 24, 6)), (0, 2))
        rim.alpha_composite(tile, (variant * 24, 0))
    rim.save(BLOCKS / "grass-rim-v2.png")


if __name__ == "__main__":
    BLOCKS.mkdir(parents=True, exist_ok=True)
    ART.mkdir(parents=True, exist_ok=True)
    grid("terrain-atlas.png", BLOCKS / "floors-v2.png", 4, 8, 24, 24, pad=2)
    grid("nature-atlas.png", ART / "nature-v2.png", 4, 4, 96, 96, pad=1, crop_alpha=True)
    grid("village-atlas.png", ART / "village-v2.png", 4, 4, 96, 96, pad=1, crop_alpha=True)
    grid("item-atlas.png", ART / "item-icons-v2.png", 4, 4, 24, 24, pad=2, crop_alpha=True)
    grid("flowers-stumps-atlas.png", ART / "flowers-stumps-v1.png", 4, 4, 96, 96, pad=2, crop_alpha=True)
    grid("crop-sprites.png", ART / "crops-v2.png", 4, 4, 96, 96, pad=2, crop_alpha=True)
    grid("garden-beds.png", BLOCKS / "beds-v1.png", 4, 2, 24, 24, pad=2)
    grid("goblin-atlas.png", ART / "goblins-v2.png", 4, 4, 96, 96, pad=2, crop_alpha=True)
    axe_sheet("axe-atlas.png", ART / "axe-v4.png")
    grass_rim()
    hero_sheet("hero-atlas.png", ART / "hero-v4.png")
    bridge_sprite("bridge-atlas.png", ART / "bridge-v2.png")
    print("Wrote 32 native 24x24 ground tiles, 16 96px nature sprites, 16 village sprites, 16 native item icons, a 192x96 bridge, and 24 native 24x32 character frames.")
