"""Original UV-matched shell finish; no external textures or paid generation."""
from pathlib import Path
import json,random
from PIL import Image,ImageDraw,ImageFilter
root=Path(__file__).parent
data=json.loads((root/'egg-uv.json').read_text())
for name,triangles in data.items():
    mask=Image.new('L',(512,512),0);draw=ImageDraw.Draw(mask)
    for t in triangles:
        xy=[(round(u*511),round((1-v)*511)) for u,v in t['uv']]
        draw.polygon(xy,fill=255 if t['inner'] else 0)
        draw.line(xy+[xy[0]],fill=255 if t['inner'] else 0,width=3)
    rng=random.Random(912+int(name[-2:]));coarse=Image.new('L',(32,32));coarse.putdata([rng.randint(90,165) for _ in range(1024)])
    coarse=coarse.resize((512,512),Image.Resampling.BICUBIC).filter(ImageFilter.GaussianBlur(4))
    pixels=[]
    for inner,noise in zip(mask.getdata(),coarse.getdata()):
        base=(148,130,101) if inner>127 else (211,202,180)
        variation=(noise-128)*.10+rng.gauss(0,.75)
        if rng.random()<.006:variation-=rng.uniform(3,12)
        pixels.append(tuple(max(0,min(255,round(v+variation))) for v in base))
    image=Image.new('RGB',(512,512));image.putdata(pixels);image.save(root/(name+'-shell.png'))
Image.new('RGB',(32,32),(214,214,214)).save(root/'egg-roughness.png')
print('24 original shell maps and one shared roughness map created.')
