"""Lossless source retention; downsample/pack runtime color+alpha maps, no AI painting."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageOps,ImageFilter
import json,colorsys
R=Path(__file__).resolve().parent
d=json.loads((R/'atlas-layout.json').read_text());atlas=Image.new('RGBA',(2048,2048),(255,255,255,255))
for name,slot in d['images'].items():
 im=Image.open(R/name).convert('RGBA').resize((504,504),Image.Resampling.LANCZOS)
 if Path(name).name=='Leaves_TwistedTree_C.png':
  # Standard pack ships this variant crimson. Harmonize leaf hue, retaining alpha/value.
  pixels=[]
  for rr,gg,bb,aa in im.getdata():
   hh,ss,vv=colorsys.rgb_to_hsv(rr/255,gg/255,bb/255)
   rgb=colorsys.hsv_to_rgb(.255,min(.62,ss),min(.72,vv*.9+.08))
   pixels.append((*[round(c*255)for c in rgb],aa))
  im.putdata(pixels)
 # Edge bleed into four-pixel gutters retains clean leaf cutouts at reduced mip sizes.
 tile=im.resize((512,512),Image.Resampling.NEAREST);tile.paste(im,(4,4));atlas.paste(tile,((slot%4)*512,(slot//4)*512))
slot=len(d['images']);x=(slot%4)*512;y=(slot//4)*512;draw=ImageDraw.Draw(atlas)
for i,c in enumerate(d['colors']):
 # Blender diffuse values are linear; export an sRGB swatch.
 rgb=tuple(round(255*(12.92*v if v<=.0031308 else 1.055*v**(1/2.4)-.055))for v in c[:3])
 cx=x+int((i%8)*63)+4;cy=y+int((7-i//8)*63)+4
 draw.rectangle((cx,cy,cx+63,cy+63),fill=(*rgb,255))
stone=Image.open(R/'source/ambientcg/Rock004_1K-JPG_Color.jpg').convert('L').resize((504,504),Image.Resampling.LANCZOS).filter(ImageFilter.GaussianBlur(.6))
source_normal=Image.open(R/'source/ambientcg/Rock004_1K-JPG_NormalGL.jpg').convert('RGB').resize((504,504),Image.Resampling.LANCZOS)
normal=Image.new('RGB',(2048,2048),(128,128,255));roughness=Image.new('RGB',(2048,2048),(225,225,225))
palette=[(153,148,139),(162,155,144),(145,151,147),(167,160,150),(151,149,144)]
for j,col in enumerate(palette):
 slot=11+j;x=slot%4*512+4;y=slot//4*512+4
 tex=Image.new('RGBA',(504,504));tex.putdata([(*[round(c*(.90+.20*v/255))for c in col],255)for v in stone.getdata()]);atlas.paste(tex,(x,y))
 n=Image.new('RGB',(504,504));n.putdata([(round(128+(rr-128)*.28),round(128+(gg-128)*.28),bb)for rr,gg,bb in source_normal.getdata()]);normal.paste(n,(x,y))
atlas.save(R/'exports/environment-atlas.png');normal.save(R/'exports/stone-normal-atlas.png');roughness.save(R/'exports/roughness-atlas.png')
print('ATLAS_READY',len(d['images']),'source textures')
