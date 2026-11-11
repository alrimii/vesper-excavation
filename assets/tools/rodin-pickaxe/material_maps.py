"""Encode the source FBX's seven constant PBR materials, without changing colors."""
from pathlib import Path
from PIL import Image
import json
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'assets/environment/compact-interior/exports'
data=json.loads((Path(__file__).parent/'geometry.json').read_text(encoding='utf8'))
def srgb(c):return 12.92*c if c<=.0031308 else 1.055*c**(1/2.4)-.055
for channel in ['Color','Metalness','Roughness']:
    image=Image.new('RGB',(256,32),(0,0,0))
    for index,p in enumerate(data['parts']):
        value=tuple(round(srgb(v)*255) for v in p['linearColor'][:3]) if channel=='Color' else (round(p['metallic' if channel=='Metalness' else 'roughness']*255),)*3
        image.paste(value,(index*32,0,(index+1)*32,32))
    image.save(OUT/f'Rodin{channel}.png')
