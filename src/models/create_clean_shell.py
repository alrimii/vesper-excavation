from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import random,math
out=Path('src/models');N=1024;rng=random.Random(4701)
noise=Image.new('L',(40,40));noise.putdata([rng.randint(105,145) for _ in range(1600)]);noise=noise.resize((N,N),Image.Resampling.BICUBIC).filter(ImageFilter.GaussianBlur(8))
img=Image.new('RGB',(N,N)); pixels=[]
for n in noise.getdata():
 v=(n-125)*.12+rng.gauss(0,.38)
 pixels.append(tuple(round(c+v) for c in (228,222,207)))
img.putdata(pixels)
d=ImageDraw.Draw(img)
for _ in range(1300):
 x,y=rng.randrange(N),rng.randrange(N);shade=rng.randint(199,215)
 d.point((x,y),fill=(shade+6,shade+2,shade-8))
img.save(out/'shell-clean.png')
# Original sparse hairline fissures; no plate-sized cells or polygon outlines.
paths=[]
for start,heading in [((400,410),.8),((460,460),-1.1),((465,465),2.3)]:
 x,y=start;pts=[(x,y)]
 for i in range(6):
  heading+=rng.uniform(-.35,.35);length=rng.uniform(13,25)
  x+=math.cos(heading)*length;y+=math.sin(heading)*length;pts.append((x,y))
 paths.append(pts)
for stage in (1,2):
 copy=img.copy();draw=ImageDraw.Draw(copy)
 for pts in paths[:stage+1]:
  sub=pts[:4] if stage==1 else pts
  draw.line(sub,fill=(172,161,142),width=1 if stage==1 else 2)
  if stage==2:
   x,y=sub[3];draw.line([(x,y),(x+15,y-8),(x+25,y-26)],fill=(188,178,158),width=1)
 copy.save(out/f'shell-hairline-{stage}.png')
rough=Image.new('RGB',(64,64),(222,222,222));rough.save(out/'shell-matte.png')
print('Created four original procedural material maps')
