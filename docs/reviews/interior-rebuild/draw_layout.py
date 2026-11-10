"""One annotated implementation layout, in the original dome's stud coordinates."""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import math
out=Path(__file__).parent
im=Image.new('RGB',(1400,1050),'#f3f0e6');d=ImageDraw.Draw(im)
fontpath='C:/Windows/Fonts/segoeui.ttf'
f=lambda s:ImageFont.truetype(fontpath,s)
ox,oy,sc=535,530,1.23
def xy(x,z):return (ox+x*sc,oy-z*sc)
def radial(a,r):a=math.radians(a);return math.sin(a)*r,math.cos(a)*r
def circle(r,fill,outline=None,width=1):
 d.ellipse((ox-r*sc,oy-r*sc,ox+r*sc,oy+r*sc),fill=fill,outline=outline,width=width)
def box(a,r,w,h,fill,outline='#4f6662'):
 a=math.radians(a);cx,cz=math.sin(a)*r,math.cos(a)*r
 pts=[xy(cx+x*math.cos(a)+z*math.sin(a),cz-x*math.sin(a)+z*math.cos(a))for x,z in[(-w/2,-h/2),(w/2,-h/2),(w/2,h/2),(-w/2,h/2)]]
 d.polygon(pts,fill=fill,outline=outline)
def txt(x,z,s,size=18,color='#183934'):d.text(xy(x,z),s,font=f(size),fill=color,anchor='mm')
d.text((40,24),'VESPER LAB  /  FIRST INTERIOR REBUILD',font=f(31),fill='#203d3c')
d.text((40,70),'One layout • existing 700-stud dome • twelve personal rooms retained',font=f(19),fill='#536865')
circle(350,'#dce8df','#3c5c59',4);circle(268,'#d9cfba');circle(130,'#9eada3');circle(100,'#d8d0bb');circle(75,'#556b68');circle(43,'#cfb884')
for a in [45,135,225,315]:
 x,z=radial(a,305);d.line([xy(*radial(a,120)),xy(x,z)],fill='#ede6d3',width=27)
 box(a,306,54,82,'#c9e2d9')
for i in range(12):
 a=i*30;box(a,305,86,70,'#7e9390');box(a,264,62,13,['#c0a87f','#d3c6a9','#9caea4'][i%3]);x,z=radial(a,307);txt(x,z,str(i+1).zfill(2),18,'white')
for a in [15,165,255]:box(a,291,53,41,'#4d6565')
box(75,291,53,41,'#d49e56');x,z=radial(75,291);txt(x,z,'W',19)
for a in [15,195,300]:box(a,180 if a!=300 else 190,62,40,'#72935a')
for a in [120,255]:box(a,170,56,30,'#b7976f')
box(90,53,9,14,'#dbc39a');txt(0,0,'EGG',20);txt(0,-112,'CLEAR LOOP',17)
d.line([xy(65,-8),xy(100,-38)],fill='#4b625e',width=2);txt(122,-45,'Ladder',16)
legend=[('STONE LOOP + ROUTES','Continuous original collision floor; flush new finishes.'),('12 PERSONAL ROOMS','Spawns, training, collection and care areas stay put.'),('OPEN VIEWING APPROACHES','Four principal glass views; eight closed bays removed.'),('RECESSED WORKSHOP + 3 LABS','Original workshop tools and interaction bounds retained.'),('PLANTED COMMONS','Three integrated beds and two specimen study islands.'),('CENTRAL CLEARANCE','Egg, access decks, reveal clearance and crown retained.')]
y=160
for title,body in legend:
 d.text((1010,y),title,font=f(17),fill='#214b43');y+=30
 words=body.split();line=''
 for word in words:
  if len(line+' '+word)>35:d.text((1010,y),line,font=f(16),fill='#596863');y+=24;line=word
  else:line=(line+' '+word).strip()
 d.text((1010,y),line,font=f(16),fill='#596863');y+=62
d.text((40,995),'Annotated layout diagram — not a runtime screenshot. North/up = +Z. No gate, road or exterior changes.',font=f(19),fill='#465d58')
im.save(out/'layout.png')
