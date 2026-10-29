# Native pixel art — current revision

All currently used raster art is now in assets/art/native/ (55 PNG assets/sheets).
These are original coordinate-drawn assets, created directly at native resolution
by tools/draw_native_art.py using palette pixels and integer shapes. No input
images, downsampling, antialiasing or image generation is used in this revision.
They are a new complete prototype set, not a claim of finished Stardew-level art.

World surface tile: 24x24 source pixels / 48x48 game units.
Hero: 32x32 cells, 6 columns x 4 directions.
Creatures: 28x28 cells, 4 animation frames x 4 species.
Trees: 64x80. Axe: 24x28 cells. Small props: 14–48 source pixels wide.
Chief tent: 96x80. Interior shell: 480x320. Display generally uses integer 2x.
HUD uses native ninepatch panels and the existing pixel font.

The code draws directly on small canvases. Art and DirectionalArt retain and
crop source textures with AtlasTexture; they no longer resize or recrop alpha.
Native source sheets are independent of Godot and can be used in Unity later.
Original generated assets are retained as historical files, with no runtime PNG
references from scripts to those old sheets. The two existing rendering shaders
remain for ground transitions and soft foliage lighting, not pixel conversion.

Coverage: ground grass/sand/gravel/dirt/soil/stone/clay/water, cliffs and ramps,
bridge, crops, flowers, berry bush, trees, natural props, all portable furniture,
lanterns, torches, fences, campfire frames, supplies, tents, interior, hero walk
and casting poses, spectral axe phases, creatures, inventory and HUD panels.
Iron/coal sprites are drawn but resource gathering is still not implemented.
Nature particles and small UI glyphs remain native coordinate drawings.

Symmetric prop views intentionally share shapes; bench/fence profiles vary.
The existing game rules, map layout, storage and controls are unchanged.
Run the generator with Python + Pillow from the project root. Source palettes
and every silhouette can be edited in tools/draw_native_art.py or PNG pixel editor.
Verification: tests/native_art_test.gd plus all ten prior gameplay tests.
