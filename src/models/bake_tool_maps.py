import json,math
from pathlib import Path
from PIL import Image,ImageDraw
root=Path('src/models')
for name in ['pickaxe','bucket']:
 d=json.loads((root/(name+'.mesh.json')).read_text())
 bounds=[(min(v[i] for v in d['vertices']),max(v[i] for v in d['vertices'])) for i in range(3)]
 print(name,'bounds',bounds,'center',[(a+b)/2 for a,b in bounds])
 images={k:Image.new('RGB',(1024,1024),(100,100,100)) for k in ['color','roughness','metalness']}
 draws={k:ImageDraw.Draw(v) for k,v in images.items()}
 for t in d['triangles']:
  c=t['c']; xy=[(round(u*1023),round((1-v)*1023)) for u,v in t['uv']]
  gamma=lambda x:12.92*x if x<=.0031308 else 1.055*x**(1/2.4)-.055
  rgb=tuple(round(255*gamma(x)) for x in c)
  if max(c)<.1: rough,metal=.76,.03
  elif c[0]>.85: rough,metal=.37,.35
  elif c[0]<.06: rough,metal=.32,.5
  elif c[0]>.6: rough,metal=.22,.9
  else: rough,metal=.30,.8
  for kind,value in [('color',rgb),('roughness',(round(rough*255),)*3),('metalness',(round(metal*255),)*3)]:
   draws[kind].polygon(xy,fill=value);draws[kind].line(xy+[xy[0]],fill=value,width=3)
 for k,im in images.items():im.save(root/(name+'-'+k+'.png'))
