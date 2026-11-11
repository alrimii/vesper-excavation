"""Download attributed Game-icons originals and pack unchanged silhouettes for Roblox."""
from pathlib import Path
import requests, json, hashlib
from PIL import Image, ImageDraw
root = Path(__file__).parent
source = root / 'source'
source.mkdir(exist_ok=True)
icons = {
 'Pickaxe':('lorc','mining'), 'Drill':('delapouite','drill'), 'Explosive':('delapouite','dynamite'),
 'Journal':('lorc','book-cover'), 'Explore':('lorc','compass'), 'Equipment':('lorc','gear-hammer'),
 'Settings':('lorc','gears'), 'Skills':('lorc','crystal-growth'), 'Storage':('lorc','swap-bag'),
 'Research':('lorc','round-bottom-flask'), 'Creatures':('lorc','dinosaur-bones'),
 'Home':('lorc','wooden-door'), 'Sound':('delapouite','speaker'), 'Motion':('lorc','feather'),
 'Results':('lorc','trophy'), 'Credits':('delapouite','coins'), 'Speed':('lorc','stopwatch'),
 'Precision':('skoll','bullseye'), 'Yield':('faithtoken','ore'), 'Value':('lorc','cash'),
}
atlas = Image.new('RGBA',(640,512))
records=[]
for i,(key,(author,slug)) in enumerate(icons.items()):
 url=f'https://game-icons.net/icons/ffffff/transparent/1x1/{author}/{slug}.png'
 dest=source/f'{slug}.png'
 if not dest.exists():
  r=requests.get(url,timeout=45); r.raise_for_status(); dest.write_bytes(r.content)
 im=Image.open(dest).convert('RGBA'); im.thumbnail((112,112),Image.Resampling.LANCZOS)
 atlas.alpha_composite(im,((i%5)*128+8,(i//5)*128+8))
 records.append(dict(key=key,author=author,source=f'https://game-icons.net/1x1/{author}/{slug}.html',license='CC BY 3.0',licenseUrl='https://creativecommons.org/licenses/by/3.0/',file=str(dest.name),sha256=hashlib.sha256(dest.read_bytes()).hexdigest(),rect=[i%5*128,i//5*128,128,128],changes='Resized to 112px with 8px transparent padding; runtime color tint'))
 print(key,im.size)
atlas.save(root/'field-icons.png')
(root/'sources.json').write_text(json.dumps(records,indent=2))
