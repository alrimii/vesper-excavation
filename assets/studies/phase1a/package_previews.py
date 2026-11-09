"""Layout only: labels and contact sheets from authored Blender renders.
Requires already-installed Pillow. Does not generate or modify game assets.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import sys
ROOT=Path(__file__).resolve().parent
FONT=Path('C:/Windows/Fonts')
def font(n,bold=False):return ImageFont.truetype(str(FONT/('segoeuib.ttf' if bold else 'segoeui.ttf')),n)
BG='#f1eee5';INK='#173b41';MUTED='#49646a'
def board(name,title,subtitle,items,cols=2,w=1500):
    cellw=w//cols;cellh=650
    im=Image.new('RGB',(w,150+cellh*((len(items)+cols-1)//cols)),BG);d=ImageDraw.Draw(im)
    d.text((40,25),title,fill=INK,font=font(38,True));d.text((40,84),subtitle,fill=MUTED,font=font(21))
    for i,(path,label,detail) in enumerate(items):
        x=(i%cols)*cellw;y=150+(i//cols)*cellh
        pic=Image.open(ROOT/'renders'/path).convert('RGB');pic.thumbnail((cellw-30,540))
        im.paste(pic,(x+(cellw-pic.width)//2,y))
        d.text((x+24,y+550),label,fill=INK,font=font(25,True));d.text((x+24,y+590),detail,fill=MUTED,font=font(18))
    im.save(ROOT/name)
board('01_design_board.png','A brighter discovery workshop','BLENDER GEOMETRY STUDIES  /  Phase 1A proposal  /  Not production-ready',[
 ('tools_three_quarter.png','Starter > reinforced impact','Swept forging, tactile grip; broader head and twin cheek plates.'),
 ('tools_front.png','Front silhouette comparison','Construction changes carry the upgrade, not a flat recolor.'),
 ('tools_side.png','True side / depth profile','A thicker head, captive axle and layered spine.'),
 ('scale_and_grip.png','5.5-stud character reference','Study mannequin only; grip and final avatar fit need production work.')])
board('02_shell_and_distance.png','Warm ceramic. Cool mineral core.','BLENDER GEOMETRY STUDIES  /  Honest neutral lighting  /  No Roblox appearance claim',[
 ('shell_states.png','Intact / damaged / broken','Matched shard edges and a contrasting mineral interior.'),
 ('gameplay_distance.png','Approximate gameplay-distance composition','Silhouette and contact readability; not a Studio screenshot.')])
if '--stills-only' in sys.argv:
    print('Packaged visual boards. Motion packaging deferred until rendering completes.')
    raise SystemExit(0)
def phase(f):
    if f<=8:return '01  Anticipation - readable weight'
    if f<=18:return '02  Ordinary hit - localized chips'
    if f<=35:return '03  Recovery - preserve movement intent'
    if f<=48:return '04  Precise hit - brief stronger accent'
    if f<=60:return '05  Final strike - windup'
    if f<=73:return '06  Break - outward fragment release'
    if f<=94:return '07  Collection - short converging arcs'
    return '08  Upgrade reception - construction reveal'
frames=[]
for f in range(1,121):
    pic=Image.open(ROOT/'frames'/f'{f:04d}.png').convert('RGB')
    im=Image.new('RGB',(720,625),BG);im.paste(pic,(0,55));d=ImageDraw.Draw(im)
    d.text((18,12),phase(f),fill=INK,font=font(22,True))
    d.text((18,598),'AUTHORED BLENDER MOTION STUDY  |  silent  |  not Roblox gameplay',fill=MUTED,font=font(16))
    frames.append(im)
frames[0].save(ROOT/'03_authored_motion.gif',save_all=True,append_images=frames[1:],duration=[90 if (f+1)%3==0 else 80 for f in range(120)],loop=0,optimize=True)
sheet=Image.new('RGB',(1440,4*625),BG)
for i,f in enumerate([8,11,39,61,68,82,94,108]):sheet.paste(frames[f-1],((i%2)*720,(i//2)*625))
sheet.save(ROOT/'04_motion_contact_sheet.png')
print('Packaged two visual boards, 120-frame animated GIF, and motion contact sheet.')
