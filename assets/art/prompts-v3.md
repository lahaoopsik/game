# ImageGen — prompt set for visual pass v3

Built-in ImageGen was used. Reference screenshots guide readability and composition;
no screenshot assets are copied. Original PNGs are kept in this folder. Pixel import
normalizes sprites to small native canvases and enlarges by exactly two.

Common specification: original cozy top-down three-quarter fantasy pixel RPG;
deliberate chunky native16×16 to32×40 pixel shapes, nearest-neighbor enlargement,
limited warm earthy palette, readable lit tops and shaded sides, no smooth painting,
labels, borders, ground squares, fog or backdrop. Isolated sprites use true alpha.

Final prompt contents by asset:

- depth-scenery-v3: four trees (round oak, pine, birch, curled jade tree with seed
  lamps); below them a connecting horizontal fence, upright fence, amber seed-glass
  lamp on carved wood and turquoise crystal on mossy pedestal. Upper-left lighting,
  layered foliage volume and dark inner leaves. Artistic screenshot reference only.
- bridge-v1: single left-to-right wooden footbridge, horizontal plank deck, top and
  bottom rails, open middle, leaf carvings and restrained moss. No water or ground.
- terrain-v3: 3×2 quiet materials: pale butter sand, gray gravel, gold dirt, chestnut
  forest soil, broad cracked rock, warm clay. Low noise, seamless within each material.
- grass-clumps-v1: 4×2 separate pointed grass variations, fern, reed, clover and
  flowered tuft; no soil. Independent breakable objects, not baked into ground.
- goblin-camp-v3: four upper objects, main LARGE ROUND patched canvas tent (no house
  walls/windows/door), green triangular tent, faded hide tent, collapsed tent; below,
  stone-ring fire, humble supplies, broken palisade, leaf-symbol sign. Warm poor camp.
- micro-props-v1: 4×4 jug/cup, stool, produce basket, rolled blanket; firewood,
  chopping stump, herb rack, rag banner; pebbles, branch, mushrooms, roots; reeds,
  water lily, bucket, wooden leaf wind chime. Contextual humble details, no luxury.
- torch-v1: three registered frames of a simple planted wood torch, cloth head and
  small swaying amber flame, native12×32 art, no outer glow backdrop.
- rotation-a-v1: rows workbench, seed lamp, crystal pedestal, torch. Four columns
  actual south/front, east/side, north/rear, west/side; camera remains fixed.
- rotation-b-v1: same four real views for jug/cup, stool, basket, rolled blanket.
- rotation-c-v1: same four views for log pile, chopping stump, herb rack, rag banner.
- rotation-d-v1: same four views for bucket, wind chime, campfire, supplies.
- rotation-e-v1: same four views for regular fence, broken palisade, leaf sign;
  rear sign blank, side profiles narrow; do not rotate a flat front cutout.
- hero-v3: brown-haired traveler, teal tunic, cream scarf, brown boots and backpack;
  6×4 poses: idle/step/idle/step/raise palm/extend palm in each direction, consistent
  feet and scale, no held physical axe. Small native canvas, no tiny painted detail.
- axe-directional-v3: 4×4 spectral cyan tool: rows down/up/left/right, columns
  manifestation/windup/strike/recovery; recognizable blade, translucent interior,
  short clear crescent trail, no solid wood/metal/hand or giant glowing rectangle.
- campfire-v2: four registered animation frames of one low campfire, irregular
  stones, charred crossed logs, red embers, small amber flame with pale core; flame
  rises between logs, not a separate detached image behind them.
- tent-interior-v1: empty round chief tent shell and floor only, curved canvas rim,
  humble poles, ropes, woven straw floor edges, open bottom door; central80% free,
  no baked furniture. Movable furnishings are separate world objects.

Symmetric items may share views. Campfire uses a dedicated animation rather than
meaningless directional spinning. Held-tool animation and contact timing are code,
not baked lighting or gameplay effects inside the item image.
