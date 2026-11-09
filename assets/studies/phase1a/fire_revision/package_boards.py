"""Compose exactly two static boards from the five required component views."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
OUT=Path(__file__).resolve().parent
TEMP=OUT.parents[3]/'Backups'/'Phase1A_FireRevision_20261109'/'static_views'
BG='#f1eee5';INK='#173b41';SUB='#5a6768'
def font(size,bold=False):return ImageFont.truetype('C:/Windows/Fonts/'+('segoeuib.ttf' if bold else 'segoeui.ttf'),size)
def panel(im,filename,rect):
    p=Image.open(TEMP/filename).convert('RGB');p.thumbnail((rect[2],rect[3]))
    im.paste(p,(rect[0]+(rect[2]-p.width)//2,rect[1]+(rect[3]-p.height)//2))

im=Image.new('RGB',(1500,620),BG);d=ImageDraw.Draw(im)
d.text((28,18),'FIRE PICKAXE  /  one proposed replacement',font=font(30,True),fill=INK)
d.text((28,61),'Accepted starter at left in every pair. Reflective materials only; no glow, particles or fire mechanic.',font=font(19),fill=SUB)
for i,(filename,title) in enumerate([('front.png','FRONT'),('side.png','SIDE / HEAD DEPTH'),('three_quarter.png','THREE-QUARTER')]):
    panel(im,filename,(i*500,102,500,438))
    d.text((i*500+24,552),title,font=font(22,True),fill=INK)
    d.text((i*500+24,586),'STARTER                     FIRE PROPOSAL',font=font(17),fill=SUB)
im.save(OUT/'01_starter_and_fire.png')

im=Image.new('RGB',(1280,670),BG);d=ImageDraw.Draw(im)
d.text((28,18),'HELD SCALE  /  fire pickaxe',font=font(30,True),fill=INK)
d.text((28,61),'Existing 5.5-stud mannequin. Static Blender study; not a Roblox screenshot or final grip fit.',font=font(18),fill=SUB)
for i,(filename,title,detail) in enumerate([
    ('held_close.png','CLOSE VIEW','Head-to-shaft connection, palm grip and pommel.'),
    ('held_distance.png','GAMEPLAY-DISTANCE APPROXIMATION','Silhouette and warm edge remain readable without effects.')]):
    panel(im,filename,(i*640,108,640,480))
    d.text((i*640+24,604),title,font=font(21,True),fill=INK)
    d.text((i*640+24,638),detail,font=font(16),fill=SUB)
im.save(OUT/'02_held_scale.png')
print('Saved exactly two static preview boards.')
