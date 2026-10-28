# First dawn — visual direction v1

Original cozy fantasy pixel art. Teal traveler, luminous emerald foliage,
warm wood, pale turquoise conjuration. Images generated with the built-in
ImageGen tool, then connected through atlas regions in Godot.

## Prompt set

- Atlas: "Production sprite atlas for original cozy top-down pixel-art fantasy
  farming RPG Sunny Valley. Transparent PNG, 4 columns x 4 rows. Row 1: two lush
  rounded oak trees, red berry bush, wooden workbench. Rows 2–4: same small
  brown-haired traveler, teal tunic, cream scarf, brown boots; down, up, right;
  idle, left step, idle, right step. Warm luminous pastoral palette, crisp pixel
  clusters, original designs, no labels or scenery."
- Grass: "Seamless repeatable grass ground texture for original cozy top-down
  pixel art farming RPG. Flat meadow, warm moss-sage greens, small grass blades
  and clover, limited palette, calm low-contrast ground, no objects or horizon."
- Spectral axe (final edit): "Transform the solid axe into a SUMMONED SPECTRAL
  AXE made entirely of translucent mint-turquoise magical energy. Preserve
  upright silhouette, right-facing crescent blade, downward shaft. Replace ALL
  wood leather and metal with see-through cyan energy, luminous contours and
  sparse rune accents. Semi-transparent interior, transparent background.
  A levitating magical construct, not a carried weapon."

Original PNGs are retained. The solid axe v1 is a discarded exploration and
is not used by the game. Spectral v2 is rendered with additional opacity and
summon/fade animation. Atlas layout is irregular; art.gd records its measured
regions. Left-facing walking mirrors the right-facing sequence.

## Current scope

Directional four-frame walking, idle breathing, tree sway, grass blade sway,
moving water highlights, summoned floating axe, impact chips and a magical
trail. Y sorting handles passing in front of and behind trees.

Day/night is visual, with a temporary 12-minute complete cycle and F6 preview.
Time is saved alongside world data; old saves default to morning. Gameplay
growth, fatigue, jobs and creature behaviour are unaffected. Lighting currently
uses ambient tint and the axe point light; light occlusion is not implemented.

Shift increases movement and walk animation speed by a temporary factor 1.4;
it does not use bond capacity.

## Expanded pixel pass

Additional ImageGen prompt: "Four columns, two rows transparent scenery atlas,
chunky 32x32 pixel art enlarged nearest neighbor, original cozy fantasy RPG.
Top: oak, birch, pine, orange broadleaf. Bottom: flowering shrub, wildflowers,
stump with mushrooms, mossy rocks. Warm sage/emerald/honey palette, no labels."

Terrain prompt: "Six seamless top-down ground textures, 3 columns and 2 rows,
no borders: pale sand, gray gravel, ochre dirt, dark forest soil, gray cracked
slate, reddish clay. Restrained earthy palette, crisp pixel clusters."

The runtime pixel shader standardizes pixel size on character and props.
Ground materials use an authored cell map, not random distribution.
Height is authored and immutable to the player. Ground overrides store only
surface materials. Current slopes are a 2D shading treatment, not a 3D mesh.
Tree shadows follow the visual sun; point-light occlusion is not implemented.
Butterflies and fireflies are small code-drawn animated pixel particles in
fixed authored zones. Environmental movement does not change gameplay rules.

Fantasy scenery final prompt: "Isolated transparent original fantasy pixel
sprites: luminous seed willow, spiral-trunk jade tree, lavender umbrella tree,
arched emerald tree with cyan hollow; seed-lantern bush, spiral fern, rune stone,
flowering hollow log. Chunky pixel art, brighten into cheerful sunlit spring
greens and warm trunks, no fog, true alpha between all silhouettes."

The bright pass uses fresh spring-green meadow, warmer paths and blue water.
Interface uses the open-source Press Start 2P font; its OFL license is included.
