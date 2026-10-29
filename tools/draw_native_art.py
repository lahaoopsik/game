"""Original native-resolution pixel assets. No input images, resampling or AA.
All coordinates are source pixels. Pillow only places palette pixels/shapes.
Run from repository root; output is deterministic and editable here.
"""
from PIL import Image, ImageDraw
from pathlib import Path
import random, math, json
OUT=Path('assets/art/native'); OUT.mkdir(parents=True,exist_ok=True)
P={'ink':'#29372e','deep':'#234e38','shade':'#32613c','green':'#448342','leaf':'#63a549','lime':'#8cbd55','sun':'#bad675','bark':'#69452f','wood':'#95613c','tan':'#bb874d','gold':'#dab267','cream':'#f1d49a','paper':'#f5dfac','rock':'#697575','rocklit':'#9ca49a','rockdark':'#485958','blue':'#367b95','water':'#4f9db1','foam':'#a8d3c4','teal':'#3c847f','aqua':'#85d5bd','white':'#e1f1cf','red':'#a84e42','rose':'#dd8363','purple':'#78628b','night':'#444f69'}
def c(k):return P.get(k,k)
def canvas(w,h):return Image.new('RGBA',(w,h))
def rect(im,box,k):ImageDraw.Draw(im).rectangle(tuple(map(int,box)),fill=c(k))
def poly(im,pts,k):ImageDraw.Draw(im).polygon(pts,fill=c(k))
def line(im,pts,k,w=1):ImageDraw.Draw(im).line(pts,fill=c(k),width=w)
def oval(im,box,k):ImageDraw.Draw(im).ellipse(box,fill=c(k))
def save(im,name):im.save(OUT/(name+'.png'))
def sheet(name,w,h,cols,rows,fn):
 im=canvas(w*cols,h*rows)
 for r in range(rows):
  for f in range(cols):im.paste(fn(f,r),(f*w,r*h))
 save(im,name)
def leaf_lobe(im,x,y,r,rng):
 oval(im,(x-r,y-r//2,x+r,y+r),'deep');oval(im,(x-r+1,y-r//2,x+r-1,y+r-2),'shade')
 oval(im,(x-r+1,y-r//2,x+r-2,y+r-5),'green')
 for _ in range(r*4):
  px=x+rng.randint(-r+2,r-2);py=y+rng.randint(-r//2+1,max(-r//2+1,r-5))
  if ((px-x)/r)**2+((py-y)/(r*.85))**2<.8:
   poly(im,[(px-1,py),(px+1,py-1),(px+2,py),(px+1,py+2),(px,py+1)],rng.choice(['leaf','lime','green']) if py<y+2 else rng.choice(['green','leaf','shade']))
def tree(v):
 im=canvas(64,80);rng=random.Random(410+v)
 poly(im,[(29,42),(36,43),(37,69),(43,76),(35,74),(31,77),(25,76),(29,69)],'ink')
 poly(im,[(30,44),(34,44),(35,68),(39,73),(33,71),(30,74)],'wood')
 line(im,[(31,47),(31,66),(29,71)],'tan');line(im,[(35,51),(40,46),(40,39)],'bark',2)
 if v==2:
  for y,width in [(9,9),(19,15),(30,20),(41,25),(51,27)]:
   poly(im,[(32,y-8),(32-width,y+10),(23,y+9),(16,y+15),(46,y+15),(40,y+10),(32+width,y+10)],'deep')
   poly(im,[(31,y-6),(34,y+2),(32+width-3,y+8),(31,y+6),(19,y+11),(32-width+4,y+8)],'green')
   line(im,[(31,y-3),(27,y+4),(22,y+7)],'leaf',2)
 else:
  for x,y,r in [(19,38,14),(44,39,14),(31,45,16),(12,28,10),(51,26,10),(22,20,15),(40,20,15),(31,10,13),(30,30,18)]:leaf_lobe(im,x+(2 if v==1 and y<25 else 0),y,r,rng)
  if v==1:
   rect(im,(29,54,33,70),'cream')
   for y in [57,62,67]:rect(im,(30,y,33,y),'rockdark')
  if v==3:
   for x,y in [(15,39),(45,42),(29,51)]:
    line(im,[(x,y-3),(x,y+3)],'bark');oval(im,(x-2,y+2,x+3,y+8),'gold');rect(im,(x,y+3,x+1,y+6),'cream')
 return im
for v in range(4):save(tree(v),f'tree-{v}')

def rock(w=20,h=12,ore=0):
 im=canvas(w,h);poly(im,[(1,h-4),(4,3),(w//2,1),(w-4,3),(w-1,h-3),(w-5,h-1),(4,h-1)],'rockdark')
 poly(im,[(2,h-5),(5,4),(w//2,2),(w-5,4),(w-3,h-5),(w//2,h-3)],'rock')
 poly(im,[(5,4),(w//2,2),(w-5,4),(w//2,h//2),(3,h-5)],'rocklit')
 line(im,[(w//2,h//2),(w//2+2,h-3)],'rockdark')
 if ore:
  for x,y in [(7,5),(12,7),(15,4)]:rect(im,(x,y,x+2,y+1),'tan' if ore==1 else 'ink')
 return im
save(rock(),'rock');save(rock(24,18,1),'iron');save(rock(24,18,2),'coal')

def tuft(v):
 im=canvas(16,24)
 for i in range(6):
  x=2+i*2;y=10+((i*7+v*3)%9)
  poly(im,[(x,22),(x-2,y),(x+1,y+3),(x+2,13),(x+3,22)],'deep')
  line(im,[(x,21),(x,y+2)],'leaf' if i%2 else 'green')
  rect(im,(x,y+2,x,y+3),'lime')
 return im
sheet('grass',16,24,4,1,lambda f,r:tuft(f))

def flowers(v):
 im=canvas(30,21)
 for i in range(7):
  x=3+(i*11)%24;y=5+(i*7)%13
  line(im,[(x,y+5),(x,y)],'shade');rect(im,(x-2,y+2,x-1,y+2),'leaf')
  for dx,dy in [(-1,0),(1,0),(0,-1),(0,1)]:rect(im,(x+dx,y+dy,x+dx,y+dy),'cream' if v==0 else 'rose')
  rect(im,(x,y,x,y),'gold')
 return im
save(flowers(0),'flowers-0');save(flowers(1),'flowers-1')

def prop(kind,v=0,t=0):
 sizes={'bench':(48,40),'lamp':(32,60) if v==0 else (32,44),'torch':(12,40),'fence':(48,30),'camp':[(36,24),(36,32),(48,30),(28,36)][max(0,min(3,v-4))],'micro':[(16,18),(16,14),(16,16),(20,12),(24,16),(20,20),(24,28),(28,20),(20,12),(28,16),(16,12),(24,18),(16,28),(20,12),(14,18),(16,26)][v]}
 w,h=sizes[kind];im=canvas(w,h);cx=w//2;bottom=h-2;side=t%2;back=t==2
 def box(b,k):rect(im,b,k)
 if kind=='bench':
  left,right=(12,34) if side else (3,44)
  for x in [left+3,right-6]:box((x,23,x+3,37),'bark');box((x,23,x+1,35),'tan')
  poly(im,[(left,14),(right-4,11),(right,17),(right,24),(left,27)],'ink');poly(im,[(left+1,14),(right-4,12),(right-1,17),(left+2,21)],'tan');box((left+2,22,right-1,24),'wood')
  for x in range(left+5,right-3,7):line(im,[(x,14),(x+2,19)],'wood')
  if not back:box((cx-4,12,cx+2,14),'rock');line(im,[(cx+1,12),(cx+6,9)],'bark',2)
 elif kind in ['lamp','torch']:
  box((cx-2,12,cx+1,bottom),'ink');box((cx-1,12,cx,bottom-2),'wood');box((cx-4,bottom-2,cx+3,bottom),'bark')
  if kind=='lamp':
   line(im,[(cx,18),(cx-7,12),(cx-7,6),(cx+1,3),(cx+6,7)],'bark',2)
   if v==0:oval(im,(cx-4,9,cx+5,20),'ink');oval(im,(cx-3,9,cx+4,17),'gold');rect(im,(cx-2,10,cx,14),'cream')
   else:poly(im,[(cx,5),(cx+5,11),(cx+1,20),(cx-5,12)],'aqua');line(im,[(cx,7),(cx-2,12),(cx,16)],'white')
  else:
   box((cx-3,11,cx+2,15),'tan');poly(im,[(cx-3,10),(cx-2,4),(cx,1),(cx+1,6),(cx+3,8),(cx+1,12)],'red');poly(im,[(cx-2,10),(cx,5),(cx+1,9)],'gold');box((cx,8,cx,10),'cream')
 elif kind=='fence' or kind=='camp' and v==6:
  if side:
   for y in [9,17,25]:box((21,y-5,26,y+2),'bark');box((22,y-5,23,y),'tan')
  else:
   for y in [12,21]:box((1,y,46,y+3),'bark');box((1,y,46,y+1),'tan')
   for x in [5,37]:poly(im,[(x,5),(x+3,2),(x+6,5),(x+6,28),(x,28)],'ink');box((x+1,5,x+4,26),'wood');box((x+1,5,x+2,22),'tan')
   if kind=='camp':box((20,10,26,15),(0,0,0,0))
 elif kind=='camp' and v==4:
  for x,y in [(4,20),(12,22),(26,21),(30,17),(27,12),(6,13)]:oval(im,(x-3,y-2,x+3,y+2),'rockdark');line(im,[(x-2,y-1),(x+1,y-1)],'rocklit')
  line(im,[(9,20),(25,14)],'bark',4);line(im,[(11,14),(24,21)],'wood',3)
  poly(im,[(12,17),(10,11),(15,12),(17,3+ t%3),(21,10),(25,8),(24,16),(20,19)],'red');poly(im,[(14,16),(17,8+t%3),(20,13),(23,13),(20,18)],'gold');poly(im,[(16,17),(18,12),(20,17)],'cream')
 elif kind=='camp' and v==5:
  box((3,13,24,28),'bark');box((4,14,23,26),'wood');box((4,15,23,17),'tan');box((4,22,23,23),'tan');line(im,[(8,15),(8,26)],'bark')
  oval(im,(21,11,33,26),'shade');oval(im,(22,10,32,17),'leaf');line(im,[(27,10),(26,23)],'lime')
 elif kind=='camp' and v==7:
  box((13,11,16,34),'bark');box((14,11,14,33),'tan');poly(im,[(2,5),(21,5),(26,10),(21,15),(2,15)],'ink');box((3,6,21,13),'wood');line(im,[(5,8),(17,8)],'tan')
 elif kind=='micro':
  if v==0:
   oval(im,(3,5,13,16),'bark');oval(im,(3,5,11,14),'red');box((5,2,10,5),'tan');oval(im,(5,1,10,3),'ink');line(im,[(12,7),(15,7),(15,11),(12,12)],'wood')
  elif v==1:
   for x in [3,w-5]:box((x,6,x+2,h-1),'bark')
   oval(im,(1,2,w-2,8),'ink');oval(im,(2,2,w-3,6),'tan')
  elif v in [2,14]:
   line(im,[(3,7),(4,1),(w-5,1),(w-3,7)],'bark');poly(im,[(1,6),(w-2,6),(w-4,h-2),(3,h-2)],'wood');oval(im,(1,5,w-2,8),'ink')
   for y in range(9,h-2,3):line(im,[(3,y),(w-4,y)],'tan' if v==2 else 'rocklit')
  elif v==3:
   box((1,4,w-2,h-2),'shade');oval(im,(0,3,6,h-2),'leaf');oval(im,(1,4,5,h-3),'deep');line(im,[(w-6,4),(w-6,h-3)],'tan')
  elif v in [4,9,11]:
   for x,y in [(4,h-5),(10,h-4),(16,h-5),(7,h-9)]:line(im,[(x,y),(min(w-3,x+7),y-4)],'bark',4);oval(im,(x-2,y-2,x+2,y+2),'tan');rect(im,(x,y,x,y),'wood')
  elif v==5:
   oval(im,(3,10,17,19),'bark');oval(im,(3,7,17,14),'tan');line(im,[(8,9),(14,2)],'wood',2);poly(im,[(10,3),(15,1),(18,4),(14,6)],'rocklit')
  elif v in [6,7]:
   for x in [2,w-4]:box((x,4,x+2,h-1),'bark')
   line(im,[(2,5),(w-2,5)],'tan',2)
   if v==7:poly(im,[(3,4),(w-3,4),(w-5,h-5),(w//2,h-7),(4,h-4)],'shade');line(im,[(4,5),(w-5,5)],'leaf')
   else:
    for x in range(6,w-3,5):line(im,[(x,5),(x,13)],'tan');poly(im,[(x,11),(x-3,18),(x,22),(x+3,18)],'leaf')
  elif v==8:return rock(w,h)
  elif v==10:
   for x,y in [(5,3),(11,6)]:box((x,y+3,x+1,h-1),'cream');oval(im,(x-4,y,x+4,y+4),'red');rect(im,(x-2,y+1,x-1,y+1),'cream')
  elif v==12:
   for x in range(2,15,3):line(im,[(x,27),(x-1,6+x%5)],'shade');line(im,[(x,25),(x+2,13)],'leaf');box((x-2,3+x%5,x,9+x%5),'wood')
  elif v==13:
   for x in [5,13]:oval(im,(x-5,3,x+5,10),'deep');oval(im,(x-4,3,x+4,8),'leaf');line(im,[(x,5),(x+4,3)],'water')
  elif v==15:
   line(im,[(2,2),(w-3,2),(w-3,5)],'wood')
   for x in [4,8,12]:line(im,[(x,3),(x,10+x%3)],'tan');poly(im,[(x,8),(x-2,15),(x,20),(x+2,14)],'leaf');rect(im,(x,11,x,16),'lime')
 return im
for k,vs in [('bench',[0]),('lamp',[0,1]),('torch',[0]),('fence',[0,1]),('micro',range(16)),('camp',range(4,8))]:
 for v in vs:
  first=prop(k,v);sheet(f'{k}-{v}',*first.size,4,1,lambda f,r,k=k,v=v:prop(k,v,f))
# Dense berry bush with individual leaf and berry clusters.
im=canvas(30,30);rng=random.Random(81)
for x,y,r in [(9,14,8),(20,13,8),(15,8,9),(16,19,10)]:leaf_lobe(im,x,y,r,rng)
for x,y in [(7,13),(18,10),(23,17),(13,22)]:rect(im,(x,y,x+1,y+2),'red');rect(im,(x,y,x,y),'rose')
save(im,'bush')
# Small crops, two leaf pairs and soil-free alpha.
im=canvas(12,10);line(im,[(6,9),(6,3)],'shade');poly(im,[(6,7),(1,5),(0,2),(4,2),(6,5)],'green');poly(im,[(6,5),(9,0),(11,1),(10,5)],'leaf');rect(im,(2,2,3,2),'lime');save(im,'crop')
# Native surfaces: one world tile = 24 source pixels, 48 game pixels.
def ground(kind):
 im=canvas(24,24);rng=random.Random(kind*103+19)
 base=['green','tan','rock','wood','bark','rockdark','red','water'][kind];rect(im,(0,0,23,23),base)
 for i in range(40 if kind==0 else 25):
  x=rng.randrange(24);y=rng.randrange(24)
  if kind==0:
   col=rng.choice(['#4b8944','#548f46','#3f7d40'])
   rect(im,(x,y,x,y),col)
   if i%3==0:rect(im,(x+1,y-1,x+1,y-1),col)
  elif kind==7:line(im,[(x,y),(x+2,y)],'blue' if i%3 else 'foam')
  else:
   colors={1:['#c59253','#cda05d','#ad7a45'],2:['#858c7e','#727e74','#9da08a'],3:['#a56e41','#9b663e','#895b38'],4:['#765039','#81573c','#62422f'],5:['#64716c','#586861','#7b8377'],6:['#a55c43','#b56d4b','#94533e']}
   col=rng.choice(colors[kind]);rect(im,(x,y,x+1,y),col)

 return im
save(ground(0),'ground-grass');save(ground(7),'water')
atlas=canvas(72,48)
for i,k in enumerate([1,2,3,4,5,6]):atlas.paste(ground(k),((i%3)*24,(i//3)*24))
save(atlas,'terrain')

def cliff(v):
 im=canvas(24,24);rect(im,(0,0,23,23),'bark')
 if v==6:
  rect(im,(0,0,23,23),'wood')
  for y in range(2,24,5):rect(im,(3,y,20,y+2),'tan');line(im,[(4,y),(19,y)],'cream');line(im,[(4,y+3),(20,y+3)],'bark')
  for x in [0,21]:rect(im,(x,0,x+2,23),'shade')
  return im
 rng=random.Random(80+v)
 for row in range(3):
  for col in range(3):
   x=col*10-(row%2)*5;y=row*8+2
   poly(im,[(x+1,y),(x+7,y-1),(x+9,y+3),(x+7,y+7),(x+1,y+6),(x-1,y+3)],'wood')
   poly(im,[(x+1,y),(x+7,y),(x+8,y+2),(x+4,y+4),(x,y+3)],'tan')
   line(im,[(x+1,y),(x+5,y)],'gold')
 for x in range(24):
  h=2+(x*7+v)%3;rect(im,(x,0,x,h),'shade');rect(im,(x,0,x,1),'leaf')
  if x%5==0:rect(im,(x,1,x,2),'lime')
 line(im,[(0,23),(23,23)],'bark')
 return im
sheet('cliffs',24,24,4,2,lambda f,r:cliff(r*4+f))

def hero(f,r):
 im=canvas(32,32);step=[0,1,0,-1,0,0][f];x=16;y=3+(1 if f==1 else 0);side=r>=2
 # Boots retain a stable baseline; alternating two-pixel strides.
 for bx,dy in [(11,step),(18,-step)]:rect(im,(bx,26+dy,bx+4,29+dy),'ink');rect(im,(bx+1,26+dy,bx+3,28+dy),'bark')
 poly(im,[(10,15),(20,15),(23,24),(18,27),(11,26),(8,24)],'ink');rect(im,(11,16,20,24),'teal');rect(im,(11,17,13,23),'aqua');rect(im,(11,24,20,25),'bark');rect(im,(16,24,17,25),'gold')
 # Face and layered hair are deliberately drawn at source size.
 poly(im,[(10,y+3),(12,y),(19,y),(22,y+3),(22,y+10),(19,y+13),(12,y+12),(9,y+9)],'ink')
 rect(im,(11,y+4,20,y+10),'tan');rect(im,(12,y+4,19,y+8),'cream')
 poly(im,[(10,y+4),(11,y+1),(14,y),(20,y+1),(22,y+4),(19,y+5),(17,y+3),(15,y+5),(12,y+3)],'bark')
 line(im,[(12,y+1),(17,y+1),(20,y+3)],'wood')
 if r==1:rect(im,(11,y+4,20,y+9),'bark');line(im,[(12,y+7),(17,y+8)],'wood')
 elif side:rect(im,(19 if r==2 else 12,y+6,19 if r==2 else 12,y+7),'ink')
 else:
  rect(im,(12,y+6,12,y+7),'ink');rect(im,(18,y+6,18,y+7),'ink')
 line(im,[(11,15),(18,16)],'cream',2)
 if f>=4:
  hx=24 if r!=3 else 7;hy=12 if f==4 else 18
  line(im,[(20 if r!=3 else 10,18),(hx,hy)],'teal',3);rect(im,(hx-1,hy-1,hx+1,hy+1),'cream')
 else:
  rect(im,(8,18-step,10,22-step),'teal');rect(im,(9,22-step,10,23-step),'tan');rect(im,(21,18+step,23,22+step),'teal')
 return im
sheet('hero',32,32,6,4,hero)

def beast(f,r):
 im=canvas(28,28);dy=[0,1,0,-1][f]
 if r==0:
  for x,d in [(7,dy),(17,-dy)]:rect(im,(x,21+d,x+3,25+d),'bark');rect(im,(x+1,21+d,x+2,24+d),'tan')
  oval(im,(4,12,22,23),'bark');oval(im,(5,12,21,21),'wood');oval(im,(7,16,19,21),'cream')
  poly(im,[(16,13),(15,7),(18,3),(20,7),(23,8),(25,15),(21,18)],'bark');poly(im,[(17,9),(19,5),(21,10),(24,11),(23,15),(19,16)],'tan');rect(im,(22,10,22,11),'ink');rect(im,(23,9,23,9),'cream')
  line(im,[(18,7),(16,3),(13,3),(13,1)],'wood');rect(im,(13,1,14,1),'leaf');poly(im,[(5,15),(1,12),(2,9),(6,11)],'cream')
 elif r==1:
  sy=1 if f%2 else 0
  poly(im,[(3,23),(2,18+sy),(5,12+sy),(10,9+sy),(19,9+sy),(24,14+sy),(26,23)],'deep');oval(im,(3,10+sy,24,24),'shade');oval(im,(4,10+sy,23,21),'leaf');oval(im,(6,11+sy,11,14+sy),'lime');rect(im,(12,16,12,17),'ink');rect(im,(20,16,20,17),'ink');line(im,[(15,19),(17,20),(18,19)],'deep');poly(im,[(13,10),(9,6),(14,5),(16,8),(20,4),(22,6),(18,10)],'green')
 elif r==2:
  wing=3 if f%2 else 0
  poly(im,[(13,12),(3,3+wing),(1,5+wing),(4,15),(11,18),(4,20),(6,24),(14,19)],'bark');poly(im,[(12,12),(4,5+wing),(3,8+wing),(6,15),(12,17)],'cream');poly(im,[(16,12),(23,4+wing),(26,6+wing),(24,16),(18,18),(23,21),(21,24),(15,19)],'gold');line(im,[(5,9+wing),(9,13)],'teal',2);line(im,[(21,10+wing),(19,14)],'teal',2);rect(im,(14,11,16,21),'cream');line(im,[(14,12),(11,7)],'tan');line(im,[(16,12),(19,7)],'tan')
 else:
  for x,d in [(9,dy),(17,-dy)]:rect(im,(x,22+d,x+3,25+d),'deep')
  poly(im,[(8,16),(20,16),(22,22),(18,24),(7,23)],'bark');rect(im,(10,17,17,21),'wood');rect(im,(9,21,20,22),'tan')
  poly(im,[(8,7),(2,5),(4,12),(8,13),(10,16),(19,15),(22,12),(26,5),(21,7),(19,4),(11,4)],'deep');poly(im,[(9,7),(4,7),(6,10),(10,12),(12,14),(19,13),(21,9),(24,7),(20,8),(18,5),(12,5)],'leaf');rect(im,(18,9,18,10),'ink');rect(im,(11,6,16,6),'lime');line(im,[(9,18),(6,22+dy)],'green',3)
 return im
sheet('creatures',28,28,4,4,beast)
def axe(f,r):
 im=canvas(24,28)
 # Each pose is plotted independently, not image-rotated.
 shafts=[[(8,24),(14,8)],[(6,22),(17,6)],[(5,17),(19,13)],[(9,24),(15,9)]]
 a,b=shafts[f];line(im,[a,b],'teal',3);line(im,[(a[0],a[1]),(b[0],b[1])],'aqua')
 bx,by=b;poly(im,[(bx-2,by-4),(bx+3,by-5),(min(23,bx+6),by-1),(min(23,bx+5),by+5),(bx+1,by+4),(bx,by+1),(bx-3,by)],'aqua');line(im,[(bx+2,by-4),(min(23,bx+5),by-1),(min(23,bx+4),by+3)],'white')
 if r==2:im=im.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
 return im
sheet('axe',24,28,4,4,axe)
sheet('fire',28,28,4,1,lambda f,r: prop('camp',4,f).crop((4,0,32,28)))
# Round chief tent, pitched shelters and collapsed fabric all have own canvases.
def tent(v):
 w,h=[(96,80),(56,52),(56,52),(56,48)][v];im=canvas(w,h);mid=w//2
 if v==3:
  line(im,[(3,h-3),(w-5,h-14)],'bark',3);poly(im,[(8,h-8),(18,12),(29,23),(w-7,h-10),(w-20,h-7),(23,29)],'shade');line(im,[(18,12),(23,29),(w-20,h-7)],'tan');return im
 # Roof is a faceted fabric cone, cylindrical lower wall on the large tent.
 left=5;right=w-6;top=6;rim=int(h*.58)
 poly(im,[(mid,top),(right,rim),(right-2,h-6),(mid,h-1),(left+2,h-6),(left,rim)],'ink')
 poly(im,[(left+1,rim),(right-1,rim),(right-3,h-7),(mid,h-3),(left+3,h-7)],'tan')
 poly(im,[(mid,top+1),(right-1,rim),(mid+12,rim+4),(left+1,rim)],'shade')
 poly(im,[(mid,top+2),(mid-10,rim+2),(left+2,rim)],'green');poly(im,[(mid,top+2),(mid+8,rim+2),(mid-10,rim+2)],'leaf')
 for x in range(12,w-10,12):line(im,[(mid,top+3),(x,rim+1)],'lime' if x<mid else 'deep')
 line(im,[(left+1,rim),(mid,rim+5),(right-1,rim)],'cream')
 for x in range(11,w-9,10):line(im,[(x,rim+5),(x,h-8)],'wood')
 poly(im,[(mid-9,h-4),(mid-7,rim+6),(mid,rim+2),(mid+8,rim+6),(mid+10,h-4)],'ink');poly(im,[(mid-8,h-5),(mid-7,rim+7),(mid-2,rim+5),(mid-3,h-8)],'cream');poly(im,[(mid+2,rim+5),(mid+7,rim+7),(mid+9,h-5),(mid+4,h-8)],'wood')
 line(im,[(mid,1),(mid,top+4)],'bark',2);rect(im,(mid+1,1,mid+6,3),'red')
 for x,y in [(12,rim+5),(w-17,rim+9)]:rect(im,(x,y,x+5,y+4),'shade');line(im,[(x,y),(x+5,y+4)],'cream')
 for x in range(9,w-9,8):
  for y in range(rim+7,h-9,6):
   if abs(x-mid)>10:line(im,[(x,y),(x,y+2)],'gold' if x<mid else 'wood')
 for y in range(top+9,rim-3,5):
  px=int(mid-(mid-left)*(y-top)/(rim-top))
  line(im,[(px+2,y),(px+4,y+1)],'leaf')
 return im
for v in range(4):save(tent(v),f'tent-{v}')
im=canvas(144,72)
for y in range(20,62,5):rect(im,(5,y,138,y+3),'wood');line(im,[(7,y),(136,y)],'tan')
for x in range(5,140,13):
 for y in [14,53]:rect(im,(x,y,x+4,y+15),'bark');rect(im,(x+1,y,x+2,y+12),'tan');rect(im,(x,y,x+4,y+1),'cream')
for y in [19,57]:rect(im,(4,y,140,y+2),'bark');line(im,[(4,y),(140,y)],'tan')
save(im,'bridge')
# Full room drawn at its final 480x320 source resolution, 2x in game.
im=canvas(480,320);d=ImageDraw.Draw(im)
d.ellipse((15,12,465,310),fill=c('ink'));d.ellipse((18,15,462,307),fill=c('bark'));d.ellipse((22,40,458,303),fill=c('wood'))
for y in range(60,302,10):
 for x in range(25,456,28):
  if ((x-240)/214)**2+((y-172)/130)**2<.91:
   rect(im,(x,y,x+26,y+8),'#9f6d43' if (x//28+y//10)%3==0 else '#98653f');line(im,[(x+2,y),(x+23,y)],'#ae7a48')
for x in range(50,450,26):
 y=int(155-133*math.sqrt(max(0,1-((x-240)/220)**2)))
 line(im,[(x,y),(x,y+25)],'shade',7);line(im,[(x-1,y),(x-1,y+22)],'green',3)
line(im,[(48,85),(80,54),(130,34),(190,23),(240,19),(290,23),(350,34),(400,54),(432,85)],'tan',2)
rect(im,(219,292,261,319),'bark');rect(im,(222,293,258,319),'tan')
# Woven central rug with alternating stepped trim.
rect(im,(172,162,307,238),'deep');rect(im,(175,165,304,235),'red');rect(im,(183,173,296,227),'wood')
for x in range(178,303,8):poly(im,[(x,167),(x+3,170),(x,173),(x-3,170)],'cream');poly(im,[(x,228),(x+3,231),(x,234),(x-3,231)],'cream')
save(im,'interior')
# UI is also an explicit native pixel ninepatch.
im=canvas(32,32)
for inset,k in [(0,'ink'),(1,'tan'),(2,'cream'),(3,'wood'),(5,'bark'),(6,'gold'),(7,'paper')]:rect(im,(inset,inset,31-inset,31-inset),k)
for x,y in [(3,3),(27,3),(3,27),(27,27)]:rect(im,(x,y,x+1,y+1),'gold')
save(im,'ui-panel')
for selected in [0,1]:
 im=canvas(16,16)
 for inset,k in [(0,'bark'),(1,'cream' if selected else 'tan'),(2,'red' if selected else 'wood'),(3,'gold' if selected else 'tan')]:rect(im,(inset,inset,15-inset,15-inset),k)
 save(im,'ui-slot-'+str(selected))
# Explicit source coverage manifest for the new asset set.
manifest={p.stem:{'size':list(Image.open(p).size),'colors':len(Image.open(p).getcolors(1000000))} for p in sorted(OUT.glob('*.png'))}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print(f'{len(manifest)} native sheets/assets written; no resize or image input.')
