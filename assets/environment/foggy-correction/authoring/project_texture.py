from PIL import Image
import numpy as np,math
from pathlib import Path
p=Path('Backups/FoggyCorrection_20261110/exports');W,H=3072,1024
a=np.linspace(-math.pi/2,math.pi/2,W)[None,:];y=np.linspace(1150,-350,H)[:,None]
seg=np.minimum(2,np.floor((a+math.pi/2)/(math.pi/3)).astype(int));center=-math.pi/3+seg*math.pi/3;d=a-center
u=.5+np.tan(d)/(2*math.tan(math.pi/6));h=1450*np.cos(d)
v=.5+(y-110-h*math.sin(.04537944))/(2*h*math.cos(.04537944)*math.tan(math.pi/6))
rgba=np.zeros((H,W,4),dtype=np.uint8)
for i,label in enumerate(['left','center','right']):
 im=np.array(Image.open(p/('forest-'+label+'-clean.png')).convert('RGB'))
 xx=np.clip(np.rint(u*1023).astype(int),0,1023);yy=np.clip(np.rint((1-v)*1023).astype(int),0,1023)
 values=im[yy,xx];mask=np.broadcast_to(seg==i,(H,W));rgba[:,:,:3][mask]=values[mask]
# Through Glass, soft alpha is culled. Use a source-derived forest silhouette with
# the mist already in its colors; reject the baked sky, not a geometric panel edge.
sky=np.median(np.concatenate([np.array(Image.open(p/('forest-'+q+'-clean.png')).convert('RGB'))[:160].reshape(-1,3) for q in ['left','center','right']]),axis=0)
difference=np.maximum(0,sky-rgba[:,:,:3].astype(float))
subject=np.maximum(difference[:,:,0],difference[:,:,1])
alpha=np.clip((subject-7)/7,0,1)
rgba[:,:,3]=np.rint(alpha*255).astype('uint8')
Image.fromarray(rgba).save(p/'forest-silhouettes.png')
print('SOURCE_FOREST_SILHOUETTES',W,H,sky.tolist())
