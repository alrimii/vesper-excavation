"""Neutralize only baked screen digits on private explicit PBR-map derivatives."""
from pathlib import Path
from PIL import Image,ImageFilter
import numpy as np,json,shutil
ROOT=Path(__file__).resolve().parents[3];SRC=ROOT/'Backups/RodinCharge_20261111/source-original';OUT=ROOT/'assets/environment/compact-interior/exports'
color=np.array(Image.open(SRC/'texture_diffuse.png').convert('RGB'))
emissive=np.array(Image.open(SRC/'texture_emissive.png').convert('RGB'))
mask=Image.fromarray((emissive.max(2)>1).astype('uint8')*255).filter(ImageFilter.MaxFilter(17))
mask=np.array(mask)>0
ys,xs=np.where(mask);box=[int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1)]
for y in range(box[1],box[3]):
 row=color[y,box[0]:box[2]];dark=row[(row.max(1)<45)&(row[:,0]<15)&(~mask[y,box[0]:box[2]])]
 background=np.median(dark,axis=0).astype('uint8') if len(dark) else np.array([3,16,23],dtype='uint8')
 color[y,mask[y]]=background
Image.fromarray(color).save(OUT/'ChargeColor.png')
for file,target,value in [('texture_metallic.png','ChargeMetalness.png',110),('texture_roughness.png','ChargeRoughness.png',199),('texture_normal.png','ChargeNormal.png',(127,127,254))]:
 im=np.array(Image.open(SRC/file));im[mask]=value;Image.fromarray(im).save(OUT/target)
(Path(__file__).parent/'screen-edit.json').write_text(json.dumps(dict(changedPixels=int(mask.sum()),bounds=box,mask='source emissive nonblack pixels, expanded 8 pixels',changes='digit regions only in color, metalness, roughness and normal; surrounding glass sampled for neutral values',packedPbrUnused=True),indent=2))
