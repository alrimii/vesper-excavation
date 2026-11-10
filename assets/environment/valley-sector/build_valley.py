"""Original exterior-sector geometry authoring in Blender; no gameplay simulation."""
import bpy, math, json, random
from pathlib import Path
from mathutils import Vector
R=Path(__file__).resolve().parent
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
palette=[(99,125,80),(112,138,86),(125,145,94),(89,119,78),(119,135,101), # ground
 (126,137,133),(135,144,138),(144,151,142),(116,130,129),(151,155,143), # cliff
 (90,117,132),(109,137,149),(124,151,157),(137,161,161), # far
 (53,122,132),(72,151,158),(116,188,190),(185,224,215),(222,239,222)] # water
mats=[]
for i,c in enumerate(palette):
 m=bpy.data.materials.new('ValleyTone%02d'%i);m.diffuse_color=tuple((v/255)**2.2 for v in c)+(1,);mats.append(m)
objects=[]
def obj(name,verts,faces,indices,smooth=False):
 me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.update()
 o=bpy.data.objects.new(name,me);bpy.context.collection.objects.link(o)
 for m in mats:me.materials.append(m)
 uv=me.uv_layers.new(name='UVMap')
 for p,mi in zip(me.polygons,indices):
  p.material_index=mi;p.use_smooth=smooth
  for li in p.loop_indices:uv.data[li].uv=((mi+.5)/32,.5)
 objects.append(o);return o
def lerp(a,b,t):return a+(b-a)*t
def interp(points,v):
 for i in range(len(points)-1):
  if v<=points[i+1][0]:
   a,b=points[i],points[i+1];t=max(0,min(1,(v-a[0])/(b[0]-a[0])));t=t*t*(3-2*t)
   return lerp(a[1],b[1],t)
 return points[-1][1]
def top(x,z):
 # Broad connected plateau, with a shallow river cleft rather than floating source water.
 base=229+8*math.sin(x/87)+5*math.cos(z/71)+4*math.sin(x/145+z/93)
 shoulders=54*math.exp(-((x+195)/62)**2)+82*math.exp(-((x-155)/67)**2)
 return base+shoulders+8*(1-math.exp(-((x+30)/30)**2))
def ground(x,z):
 base=interp([(350,-4),(395,18),(445,48),(480,74),(565,74),(610,88),(675,212),(755,222),(870,150),(1100,92)],z)
 sides=(1-math.exp(-(x/125)**2))*(28+14*math.sin(z/105+x/280))
 broad=9*math.sin(x/170+z/143)+5*math.cos(x/81-z/123)
 h=base+sides+broad
 # Broad water basin cut into the valley floor; banks merge continuously with the slopes.
 pool=math.exp(-(((x-40)/95)**6+((z-519)/65)**6))
 h=lerp(h,73.7,pool)
 if 650<z<825 and abs(x)<240:
  blend=min(1,(z-650)/25,(825-z)/25,(240-abs(x))/30)
  h=lerp(h,top(x,z)-1,max(0,blend))
 # Continuous outflow trough from the pool toward the valley mouth.
 if 400<z<520:
  center=40+24*math.sin((520-z)/90)
  weight=math.exp(-((x-center)/45)**4)
  river=interp([(400,25),(435,43),(475,65),(520,76)],z)-1
  h=lerp(h,min(h,river),weight)
 # Fade side boundaries into existing low outer scenery instead of sheer mesh edges.
 edge=max(0,(abs(x)-390)/90);h=lerp(h,-3,min(1,edge*edge))
 t=max(0,min(1,(z-350)/110));h+=40*t*t*(3-2*t)
 return h

# One continuous, gently faceted terrain skin with planted shoulders and a cut basin.
vs=[];fs=[];ids=[];nx=64;nz=72
for j in range(nz+1):
 z=350+j*750/nz
 for i in range(nx+1):
  x=-480+i*960/nx;vs.append((x,z,ground(x,z)))
for j in range(nz):
 for i in range(nx):
  a=j*(nx+1)+i;x=-480+(i+.5)*15;z=350+(j+.5)*750/nz
  if abs(x)<270 and 570<z<810:continue
  fs.append((a,a+1,a+nx+2,a+nx+1))
  slope=abs(ground(x+6,z)-ground(x-6,z))+abs(ground(x,z+6)-ground(x,z-6))
  ids.append(6 if slope>20 else 1)
terrain=obj('ConnectedValley',vs,fs,ids,True)
for p in terrain.data.polygons:
 for li in p.loop_indices:
  co=terrain.data.vertices[terrain.data.loops[li].vertex_index].co;terrain.data.uv_layers.active.data[li].uv=((co.x+480)/960,(co.y-350)/750)

# Broad continuous eroded cliff; ledges cut back through a solid mass, not separate towers.
vs=[];fs=[];ids=[];nx=56
profile=[(55,546),(78,568),(111,580),(138,590),(145,614),(162,622),(190,635),(215,645),(230,657)]
for row,(height,depth) in enumerate(profile):
 for i in range(nx+1):
  x=-275+i*550/nx
  flank=max(0,1-(abs(x)/290)**3)
  # Broad buttresses and shallow vertical fractures continue through adjacent ledges.
  push=12*math.sin(x/45)+6*math.sin(x/17+.5)+9*math.cos(x/93)
  z=depth+push+(1-flank)*45
  y=55+(height-55)*(.55+.45*flank)+4*math.sin(x/69+row*.25)
  if row==len(profile)-1:y=top(x,z)
  vs.append((x,z,y))
for row in range(len(profile)-1):
 for i in range(nx):
  a=row*(nx+1)+i;fs.append((a,a+1,a+nx+2,a+nx+1));ids.append(5+row%3)
# Top surface merges into the upper valley, plus buried back and side closure.
front=len(vs)-(nx+1)
for row in range(1,9):
 for i in range(nx+1):
  x=-275+i*550/nx;prev=vs[front+i];z=lerp(prev[1],820,row/8);vs.append((x,z,top(x,z)-.15))
for row in range(8):
 for i in range(nx):
  a=front+row*(nx+1)+i;fs.append((a,a+1,a+nx+2,a+nx+1));ids.append(1)
for side in [0,nx]:
 line=[r*(nx+1)+side for r in range(9)]+[front+r*(nx+1)+side for r in range(1,9)]
 for a,b in zip(line,line[1:]):
  low=len(vs);vs.extend([(vs[a][0],vs[a][1],35),(vs[b][0],vs[b][1],35)]);fs.append((a,b,low+1,low));ids.append(8)
cliff=obj('RiverCliffMass',vs,fs,ids,False)
for p in cliff.data.polygons:
 pts=[cliff.data.vertices[cliff.data.loops[li].vertex_index].co for li in p.loop_indices]
 lx=min(v.x for v in pts);hx=max(v.x for v in pts);lh=min(v.z for v in pts);hh=max(v.z for v in pts)
 for li in p.loop_indices:
  co=cliff.data.vertices[cliff.data.loops[li].vertex_index].co
  cliff.data.uv_layers.active.data[li].uv=(.95,.5) if p.material_index<5 else (.02+.82*(co.x-lx)/max(.01,hx-lx),.02+.96*(co.z-lh)/max(.01,hh-lh))

# Unequal long ridgelines with shoulders, saddles and asymmetric buttresses.
def ridge(name,baseZ,scale,offset,tone):
 profile=[(-650,85),(-570,135),(-500,164),(-435,156),(-370,238),(-315,251),(-250,210),(-180,197),(-105,245),(-50,262),(25,230),(100,308),(150,321),(205,279),(270,266),(340,201),(420,209),(490,156),(565,148),(650,78)]
 verts=[];faces=[];mi=[];cols=104;rows=14
 for j in range(rows+1):
  t=j/rows;shape=math.sin(math.pi*t)**.73
  for i in range(cols+1):
   x=-650+i*1300/cols;crest=interp(profile,x)*scale
   z=baseZ+t*260+34*math.sin(x/123)+15*math.cos(x/52)
   h=32+crest*shape+16*math.sin(x/52+t*5)*shape+offset
   verts.append((x,z,h))
 for j in range(rows):
  for i in range(cols):
   a=j*(cols+1)+i;faces.append((a,a+1,a+cols+2,a+cols+1));mi.append(tone+(1 if j>7 else 0))
 return obj(name,verts,faces,mi,False)
ridge('ValleyRidgeNear',880,.80,0,10);ridge('ValleyRidgeFar',1120,1.0,36,12)

# Curved upstream channel, two offset falls and a shelf transition.
water=[(-39,785,top(-39,785)+.6,15),(-43,752,top(-43,752)+.6,17),(-37,715,top(-37,715)+.6,19),(-25,681,top(-25,681)+.6,20),(-22,655,top(-22,655)+.7,23),(-20,646,221,25),(-17,640,209,26),(-12,630,183,27),(-8,622,154,29),(0,613,146,33),(10,600,144,35),(22,588,136,31),(25,583,118,33),(28,577,95,35),(33,568,79,39),(40,550,77,48)]
vs=[];fs=[];ids=[];cols=12
for j,(cx,z,h,w) in enumerate(water):
 for i in range(cols+1):
  u=i/cols;vs.append((cx+(u-.5)*w,z+.4*math.cos(u*9+j),h+.18*math.sin(u*12+j)))
for j in range(len(water)-1):
 for i in range(cols):
  a=j*(cols+1)+i;fs.append((a,a+1,a+cols+2,a+cols+1));ids.append(15 if i in [0,1,11] else 16 if i%4 else 17)
fall=obj('TwinCascade',vs,[tuple(reversed(f)) for f in fs],ids,True)
for p in fall.data.polygons:
 for li in p.loop_indices:
  vi=fall.data.loops[li].vertex_index;fall.data.uv_layers.active.data[li].uv=((vi%(cols+1))/cols,1-(vi//(cols+1))/(len(water)-1))
# Pool edge follows an asymmetric shore; lower stream is visibly connected.
vs=[(40,515,76.8)];fs=[];ids=[]
for i in range(65):
 a=i*math.tau/64;r=1+.06*math.sin(a*5)+.04*math.cos(a*7);vs.append((40+76*r*math.cos(a),515+52*r*math.sin(a),76.8))
for i in range(64):fs.append((0,i+1,i+2));ids.append(14)
obj('ReceivingBasin',vs,fs,ids,True)
out=[]
for z in range(520,399,-10):out.append((40+24*math.sin((520-z)/90),z,interp([(400,25),(435,43),(475,65),(520,76)],z)+.2,15+(z-400)/15))
vs=[];fs=[];ids=[]
for x,z,h,w in out:vs.extend([(x-w/2,z,h),(x+w/2,z,h)])
for j in range(len(out)-1):a=j*2;fs.append((a,a+1,a+3,a+2));ids.append(14+j%2)
obj('ValleyOutflow',vs,[tuple(reversed(f)) for f in fs],ids,True)
# Discontinuous curved foam tongues at the impact basin, no particle fog.
vs=[];fs=[];ids=[]
for k in range(5):
 for i in range(14):
  a=-.45+i/13*2.4;r=12+k*6;w=1.1 if k<2 else .65
  base=len(vs)
  for rr in [r-w,r+w]:vs.append((33+rr*math.cos(a),564-rr*.55*math.sin(a),77.2))
  if i:fs.append((base-2,base-1,base+1,base));ids.append(17 if k>1 else 18)
obj('BasinFoam',vs,fs,ids,False)

records=[]
for o in objects:
 o.data.calc_loop_triangles();pts=[v.co for v in o.data.vertices];lo=[min(v[i]for v in pts)for i in range(3)];hi=[max(v[i]for v in pts)for i in range(3)]
 records.append(dict(name=o.name,triangles=len(o.data.loop_triangles),boundsMin=lo,boundsMax=hi))
(R/'geometry.json').write_text(json.dumps(records,indent=2))
(R/'water-path.json').write_text(json.dumps(water,indent=2))
# Store source materials and an atlas runtime counterpart; real geometry remains editable.
bpy.ops.wm.save_as_mainfile(filepath=str(R/'valley-master.blend'),compress=True)
im=bpy.data.images.load(str(R/'exports/valley-palette.png'))
m=bpy.data.materials.new('ValleySharedPalette');m.use_nodes=True;n=m.node_tree.nodes;tex=n.new('ShaderNodeTexImage');tex.image=im
m.node_tree.links.new(tex.outputs['Color'],n.get('Principled BSDF').inputs['Base Color']);n.get('Principled BSDF').inputs['Roughness'].default_value=.9
for o in objects:
 for p in o.data.polygons:p.material_index=0
 o.data.materials.clear();o.data.materials.append(m)
 if o.name in ['RiverCliffMass','ConnectedValley','TwinCascade']:
  cm=m.copy();cm.name=o.name+'Material';ct=next(n for n in cm.node_tree.nodes if n.type=='TEX_IMAGE');ct.image=bpy.data.images.load(str(R/'exports'/({'RiverCliffMass':'cliff-stone.png','ConnectedValley':'valley-ground.png','TwinCascade':'cascade-color.png'}[o.name])));o.data.materials.clear();o.data.materials.append(cm)
bpy.ops.wm.save_as_mainfile(filepath=str(R/'valley-runtime.blend'),compress=True)
bpy.ops.export_scene.fbx(filepath=str(R/'exports/valley.fbx'),object_types={'MESH'},apply_unit_scale=True,bake_space_transform=True,axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
print('VALLEY_AUTHORING_COMPLETE',len(records),sum(r['triangles']for r in records))

bpy.ops.object.select_all(action='DESELECT')
for name in ['ConnectedValley','TwinCascade']:bpy.data.objects[name].select_set(True)
bpy.ops.export_scene.fbx(filepath=str(R/'exports/valley-materials.fbx'),use_selection=True,object_types={'MESH'},apply_unit_scale=True,bake_space_transform=True,axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
