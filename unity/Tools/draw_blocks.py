"""Starter blocks: drawn at 24 source pixels / 48 world pixels, no image inputs.
Seeded tiny brush clusters are surface detail, not procedural world generation.
"""
from PIL import Image,ImageDraw
from pathlib import Path
import random,json
out=Path('unity/Assets/Resources/Blocks');out.mkdir(parents=True,exist_ok=True)
palettes=[['#326340','#3e7945','#508c49','#619d50','#77ac56'],['#b38b59','#c69c66','#d8b37a','#e2c58b','#ad8254'],['#737a70','#858b7a','#9a9c86','#aeb19b','#606d66'],['#88613e','#976e45','#a87e51','#b58d5c','#7c583b'],['#593f30','#6a4b35','#78583d','#876743','#4c392d'],['#5a6465','#69777a','#7c8988','#929a91','#4d5a60'],['#9e6651','#b37c5b','#c68e66','#d59e73','#8d5c4c'],['#294d70','#315d80','#3d7192','#4c86a2','#6aa0b5']]
def floor(kind,v):
 rng=random.Random(811+kind*91+v*331);im=Image.new('RGBA',(24,24),palettes[kind][1]);d=ImageDraw.Draw(im)
 # Separate, asymmetric 2–5 pixel clusters, each with an upper lit pixel.
 for n in range(34 if kind==0 else 23):
  x=rng.randrange(24);y=rng.randrange(24);p=palettes[kind];shade=p[0] if n%3 else p[4]
  pts=[(x,y),(x+2,y),(x+3,y+1),(x+2,y+2),(x,y+1)]
  d.polygon(pts,fill=shade);d.line([(x,y),(x+1,y)],fill=p[2])
  if kind==0:
   d.point((x+1,y-1),fill=p[3]);d.point((x+2,y),fill=p[2])
  elif kind in [2,5] and n%4==0:
   d.line([(x,y+1),(x+1,y+2)],fill=p[4]);d.point((x+1,y),fill=p[3])
 if kind==4:
  for y in range(2,24,6):d.line([(0,y),(23,y)],fill=palettes[kind][0]);d.line([(0,y+1),(23,y+1)],fill=palettes[kind][2])
 return im
atlas=Image.new('RGBA',(96,192))
for k in range(8):
 for v in range(4):atlas.paste(floor(k,v),(v*24,k*24))
atlas.save(out/'floors.png')
# Wall blocks: irregular fitted stone/earth, grass roots, lit ridges, dark base.
def face(mat,v):
 rng=random.Random(441+mat*43+v*141);p=palettes[[3,5,6,0][mat]];im=Image.new('RGBA',(24,16),p[4]);d=ImageDraw.Draw(im)
 for row in range(3):
  y=row*5+1
  for col in range(4):
   x=col*8-(row%2)*4
   d.polygon([(x,y+1),(x+2,y-1),(x+6,y),(x+8,y+3),(x+5,y+5),(x+1,y+4)],fill=p[0])
   d.polygon([(x+1,y),(x+5,y),(x+7,y+2),(x+4,y+3),(x+1,y+2)],fill=p[1])
   d.line([(x+2,y),(x+5,y)],fill=p[2]);d.point((x+2,y-1),fill=p[3])
 for x in range(24):
  d.line([(x,0),(x,(x*7+v)%3)],fill='#345c39');d.point((x,0),fill='#6e9c4f')
 for x in range(3,24,9):d.line([(x,3),(x+1,6),(x,8)],fill='#706044')
 d.line([(0,15),(23,15)],fill=p[4]);return im
wall=Image.new('RGBA',(96,160))
for k in range(4):
 for v in range(4):
  top=floor([3,5,6,0][k],v);wall.paste(top,(v*24,k*40));wall.paste(face(k,v),(v*24,k*40+24))
wall.save(out/'walls.png')
# Natural bank lip is alpha, for neighbour-connected edges over all base floors.
edge=Image.new('RGBA',(96,8));d=ImageDraw.Draw(edge)
for v in range(4):
 for x in range(24):
  depth=2+(x*11+v*3)%3;xx=v*24+x;d.line([(xx,0),(xx,depth)],fill='#466a3f');d.point((xx,0),fill='#96b866')
  if x%5==0:d.point((xx,depth+1),fill='#6a8146')
edge.save(out/'grass-edge.png')
wood=Image.new('RGBA',(96,24));d=ImageDraw.Draw(wood)
for v in range(4):
 for y in range(0,24,6):
  d.rectangle((v*24,y,v*24+23,y+5),fill='#64462f');d.rectangle((v*24,y,v*24+23,y+3),fill='#a47845');d.line([(v*24,y),(v*24+23,y)],fill='#c69a5c')
  for x in [4+v,13-v]:d.line([(v*24+x,y+2),(v*24+x+5,y+2)],fill='#805934')
wood.save(out/'wood.png')
(out/'catalogue.json').write_text(json.dumps({'tilePixels':24,'worldTile':48,'floorKinds':['grass','sand','gravel','dirt','tilled soil','stone','clay','water'],'variants':4,'wallMaterials':['earth','stone','clay','moss'],'wallTopPixels':24,'wallFacePixels':16},indent=2))
print('PASS: 32 floor variants, 16 wall tops and faces, 4 grass rims, 4 wood floors; native size')
