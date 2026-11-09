"""Crop original transparent atlases; preserve aspect ratio and alpha in small runtime icons."""
from pathlib import Path
from PIL import Image
import json, hashlib
root = Path(__file__).parent
out = root / 'exports'
out.mkdir(exist_ok=True)
assets = []
for source, cols, rows, names in [
    ('navigation-master.png', 3, 2, ['credits','relic','bucket','skills','equipment','explore']),
    ('eggs-master.png', 3, 1, ['bronze','golden','volcanic']),
]:
    im = Image.open(root / 'source' / source).convert('RGBA')
    for i, name in enumerate(names):
        x,y = i % cols,i // cols
        crop = im.crop((round(x*im.width/cols),round(y*im.height/rows),round((x+1)*im.width/cols),round((y+1)*im.height/rows)))
        bounds=crop.getchannel('A').point(lambda a: 255 if a>24 else 0).getbbox()
        if bounds: crop=crop.crop(bounds)
        crop.thumbnail((232,232),Image.Resampling.LANCZOS)
        icon=Image.new('RGBA',(256,256))
        icon.alpha_composite(crop,((256-crop.width)//2,(256-crop.height)//2))
        path=out/(name+'.png');icon.save(path,optimize=True)
        assets.append({'name':name,'master':'source/'+source,'export':'exports/'+path.name,'size':[256,256],'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
(root/'manifest.json').write_text(json.dumps({'provenance':'Original built-in image generation; flattened RGBA masters, not layered editable artwork. Cropping/resizing only; no replacement background.','assets':assets},indent=2)+'\n')
