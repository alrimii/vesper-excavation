"""Small original material palette and flowing-water accent; not a concept render."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
R=Path(__file__).resolve().parent
colors=[(99,125,80),(112,138,86),(125,145,94),(89,119,78),(119,135,101),(126,137,133),(135,144,138),(144,151,142),(116,130,129),(151,155,143),(90,117,132),(109,137,149),(124,151,157),(137,161,161),(53,122,132),(72,151,158),(116,188,190),(185,224,215),(222,239,222)]
im=Image.new('RGB',(1024,32),colors[0]);d=ImageDraw.Draw(im)
for i,c in enumerate(colors):d.rectangle((i*32,0,i*32+31,31),fill=c)
im.save(R/'exports/valley-palette.png')
# Staggered soft streaks repeat along a native Beam, with ample clear space between them.
im=Image.new('RGBA',(512,128),(255,255,255,0));d=ImageDraw.Draw(im)
for x,y,length,width,alpha in [(12,24,130,5,145),(180,57,155,7,180),(350,89,120,4,150),(65,104,105,4,130),(320,29,100,5,155)]:
 d.rounded_rectangle((x,y,x+length,y+width),radius=width/2,fill=(222,244,234,alpha))
im=im.filter(ImageFilter.GaussianBlur(1.1));im.save(R/'exports/water-flow.png')

# Subdued CC0 Rock004 adaptation: retain broad mineral variation, suppress noise.
source=Image.open(R.parent/'lab-art/source/ambientcg/Rock004_1K-JPG_Color.jpg').convert('L').resize((448,512),Image.Resampling.LANCZOS).filter(ImageFilter.GaussianBlur(1.8))
stone=Image.new('RGB',(512,512),(112,138,86));detail=Image.new('RGB',source.size)
detail.putdata([tuple(round(c*(.92+.16*v/255)) for c in (128,143,135)) for v in source.getdata()]);stone.paste(detail,(0,0));stone.save(R/'exports/cliff-stone.png')
normal=Image.new('RGB',(512,512),(128,128,255));n=Image.open(R.parent/'lab-art/source/ambientcg/Rock004_1K-JPG_NormalGL.jpg').convert('RGB').resize((448,512),Image.Resampling.LANCZOS);n.putdata([(round(128+(r-128)*.18),round(128+(g-128)*.18),b)for r,g,b in n.getdata()]);normal.paste(n,(0,0));normal.save(R/'exports/cliff-normal.png')

# Ground color painting follows actual woodland groups and stream banks, not random noise.
import math
woodlands=[(-230,439),(-152,461),(190,435),(270,479),(-289,565),(255,568),(-165,738),(136,757),(-302,812),(309,835),(-242,936),(248,950),(-105,711),(104,714),(-330,490),(325,505),(40,798)]
ground=Image.new('RGB',(1024,1024));pixels=[]
for py in range(1024):
 z=350+(1-py/1023)*750
 for px in range(1024):
  x=-480+px/1023*960
  woods=min(1,sum(math.exp(-(((x-a)/58)**2+((z-b)/48)**2))for a,b in woodlands))
  broad=math.sin(x/93+z/127)*.025+math.cos(x/57-z/131)*.025
  bank=math.exp(-((x-(40+24*math.sin((520-z)/90)))/43)**4)*max(0,min(1,(540-z)/35))*max(0,min(1,(z-390)/35))
  base=(112,138,86);soil=(94,113,74);sand=(130,135,101)
  col=[(base[i]*(1-woods*.55)+soil[i]*woods*.55)*(1+broad)for i in range(3)]
  col=[round(col[i]*(1-bank*.65)+sand[i]*bank*.65)for i in range(3)]
  pixels.append(tuple(col))
ground.putdata(pixels);ground.save(R/'exports/valley-ground.png')
fall=Image.new('RGB',(256,512));pixels=[]
for y in range(512):
 for x in range(256):
  u=x/255;v=y/511
  streak=math.sin(u*24+v*3)*.055+math.sin(u*53-v*8)*.025
  edge=abs(u-.5)*2
  foam=math.exp(-((v-.59)/.045)**2)*.20+math.exp(-((v-.98)/.035)**2)*.35
  base=(90,169,176);white=(211,235,219);mix=min(.8,edge*.20+foam+max(0,streak))
  pixels.append(tuple(round(base[i]*(1-mix)+white[i]*mix)for i in range(3)))
fall.putdata(pixels);fall.save(R/'exports/cascade-color.png')
