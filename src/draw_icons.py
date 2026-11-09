"""Original Vesper icons. Editable SVG + transparent PNG; Pillow only."""
from pathlib import Path
from PIL import Image, ImageDraw
import math
OUT=Path(__file__).parent/'art'; OUT.mkdir(exist_ok=True)
steel='#d8e3df'; dark='#25343c'; gold='#e8b65e'; teal='#80c9bc'
shapes={
 'Pickaxe': [('poly',[(57,215),(39,200),(148,57),(165,69)],gold),('poly',[(52,181),(68,194),(50,216),(36,203)],dark),('poly',[(58,55),(100,29),(161,35),(211,69),(230,118),(181,84),(150,68),(108,65)],steel),('poly',[(125,38),(155,43),(164,66),(141,79),(119,62)],teal)],
 'Bucket':[('arc',(65,25,192,174),steel),('poly',[(49,99),(207,99),(190,220),(66,220)],steel),('poly',[(66,114),(190,114),(176,203),(80,203)],dark),('poly',[(76,167),(100,149),(126,164),(151,141),(183,164),(177,201),(80,201)],gold),('ellipse',(45,85,211,117),teal)],
 'Cash':[('poly',[(25,64),(231,64),(231,194),(25,194)],teal),('poly',[(42,82),(214,82),(214,176),(42,176)],dark),('ellipse',(91,91,165,168),gold),('line',[(62,104),(62,152)],steel),('line',[(194,104),(194,152)],steel)],
 'Sell':[('poly',[(32,133),(67,133),(67,202),(189,202),(189,133),(224,133),(224,227),(32,227)],steel),('poly',[(111,28),(145,28),(145,113),(181,113),(128,170),(75,113),(111,113)],gold)],
 'Power':[('poly',[(139,20),(51,142),(112,142),(94,236),(209,101),(145,101),(169,20)],gold)],
 'Speed':[('ellipse',(43,55,213,225),steel),('ellipse',(62,74,194,206),dark),('poly',[(108,23),(150,23),(150,46),(108,46)],gold),('line',[(128,94),(128,139),(164,161)],teal)],
 'Capacity':[('poly',[(32,80),(102,80),(102,209),(32,209)],steel),('poly',[(154,80),(224,80),(224,209),(154,209)],steel),('poly',[(115,20),(141,20),(141,47),(168,47),(168,73),(141,73),(141,100),(115,100),(115,73),(88,73),(88,47),(115,47)],gold),('line',[(63,144),(193,144)],teal)],
}
for name,items in shapes.items():
 im=Image.new('RGBA',(1024,1024)); d=ImageDraw.Draw(im); svg=[]
 for kind,coords,col in items:
  if kind in ('poly','line'):
   p=[(x*4,y*4) for x,y in coords]
   if kind=='poly': d.polygon(p,fill=col); svg.append(f'<polygon points="{" ".join(f"{x},{y}" for x,y in coords)}" fill="{col}"/>')
   else: d.line(p,fill=col,width=36,joint='curve'); svg.append(f'<polyline points="{" ".join(f"{x},{y}" for x,y in coords)}" fill="none" stroke="{col}" stroke-width="9" stroke-linecap="round"/>')
  else:
   box=tuple(v*4 for v in coords); x,y,x2,y2=coords
   if kind=='ellipse': d.ellipse(box,fill=col); svg.append(f'<ellipse cx="{(x+x2)/2}" cy="{(y+y2)/2}" rx="{(x2-x)/2}" ry="{(y2-y)/2}" fill="{col}"/>')
   else: d.arc(box,180,360,fill=col,width=36); svg.append(f'<path d="M{x},{(y+y2)/2} A{(x2-x)/2},{(y2-y)/2} 0 0 1 {x2},{(y+y2)/2}" fill="none" stroke="{col}" stroke-width="9"/>')
 im.resize((256,256),Image.Resampling.LANCZOS).save(OUT/f'{name}.png')
 (OUT/f'{name}.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">'+''.join(svg)+'</svg>',encoding='utf-8')
print('Rendered seven original transparent icons.')
