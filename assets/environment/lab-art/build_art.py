"""Offline Blender asset authoring, not a game simulation. Free-source glTF adaptation."""
import bpy, math, json, random
from pathlib import Path
from mathutils import Vector
R=Path(__file__).resolve().parent
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
objects=[]; records=[]
def mat(name,color):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);return m
stone=[mat('Mineral%02d'%i,c) for i,c in enumerate([(.47,.49,.46),(.51,.52,.49),(.45,.48,.47),(.54,.53,.48),(.49,.50,.48)])]
edge=mat('Dressed limestone',(.69,.67,.56));soil=mat('Living soil',(.19,.25,.15));bone=mat('Fossil ivory',(.77,.69,.50));mount=mat('Scientific bronze',(.28,.35,.32));water=mat('Water',(.30,.62,.65));foam=mat('Water crest',(.77,.90,.85))
def mesh(name,verts,faces,materials,indices=None):
 me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.update();o=bpy.data.objects.new(name,me);bpy.context.collection.objects.link(o)
 for m in materials:me.materials.append(m)
 if indices:
  for p,i in zip(me.polygons,indices):p.material_index=i
 return o
def finish(name,obs,height=None,source='Original project geometry',ground=True):
 bpy.ops.object.select_all(action='DESELECT')
 for o in obs:o.select_set(True)
 bpy.context.view_layer.objects.active=obs[0];bpy.ops.object.join();o=bpy.context.object;o.name=name
 bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
 coords=[v.co.copy() for v in o.data.vertices];lo=Vector(tuple(min(v[i]for v in coords)for i in range(3)));hi=Vector(tuple(max(v[i]for v in coords)for i in range(3)))
 if ground:
  center=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z))
  for v in o.data.vertices:v.co-=center
 if height:
  factor=height/max(.01,hi.z-lo.z)
  for v in o.data.vertices:v.co*=factor
 o.data.update();objects.append(o);records.append({'name':name,'source':source});return o
selected=[('CommonTree_1','CanopyOak',28),('CommonTree_3','CanopyYoung',22),('TwistedTree_2','CanopyTwisted',26),('Pine_2','MountainPine',32),('Bush_Common','LeafShrub',4.4),('Fern_1','ForestFern',4.2),('Plant_1_Big','Broadleaf',5.8),('Plant_7_Big','LanceLeaf',6.2),('Grass_Wispy_Short','SoftGrass',2),('Clover_2','Clover',1),('Flower_3_Group','FlowerAccent',2.2),('Rock_Medium_1','RockLedge',8),('Rock_Medium_2','RockShoulder',9),('Rock_Medium_3','RockRound',5)]
for original,name,h in selected:
 before=set(bpy.data.objects);bpy.ops.import_scene.gltf(filepath=str(R/'source/quaternius'/f'{original}.gltf'))
 obs=[o for o in set(bpy.data.objects)-before if o.type=='MESH'];finish(name,obs,h,'Quaternius Standard / '+original)
for original,name,h in [('Bush_2_D_Color1','GroundShrub',3.5),('Rock_1_J_Color1','LowBoulder',4.5)]:
 before=set(bpy.data.objects);bpy.ops.import_scene.gltf(filepath=str(R/'source/kaykit'/f'{original}.gltf'))
 finish(name,[o for o in set(bpy.data.objects)-before if o.type=='MESH'],h,'KayKit Forest Free / '+original)

# Radial dressed paving: compact roughly 10x8-stud stones, aligned apron/outer edges.
random.seed(704)
verts=[];faces=[];indices=[]
def prism(poly,z0,z1,mi):
 start=len(verts);n=len(poly);verts.extend([(x,y,z0)for x,y in poly]);verts.extend([(x,y,z1)for x,y in poly])
 faces.append(tuple(start+n+i for i in range(n)));indices.append(mi)
 for i in range(n):faces.append((start+i,start+(i+1)%n,start+n+(i+1)%n,start+n+i));indices.append(mi)
for band in range(24):
 r0=75+band*8;r1=r0+8;count=max(12,round((r0+r1)*math.pi/4/10));off=.5 if band%2 else 0
 for j in range(count+1):
  a0=max(0,(j-off)/count*math.pi/2)+.00042;a1=min(math.pi/2,(j+1-off)/count*math.pi/2)-.00042
  if a1<=a0:continue
  # Chamfered corners with closed deliberate joints; no raised collision facets.
  rr0=r0+.055;rr1=r1-.055;aa=.002
  poly=[(rr0*math.cos(a0+aa),rr0*math.sin(a0+aa)),((rr0+.18)*math.cos(a0),(rr0+.18)*math.sin(a0)),((rr1-.18)*math.cos(a0),(rr1-.18)*math.sin(a0)),(rr1*math.cos(a0+aa),rr1*math.sin(a0+aa)),(rr1*math.cos(a1-aa),rr1*math.sin(a1-aa)),((rr1-.18)*math.cos(a1),(rr1-.18)*math.sin(a1)),((rr0+.18)*math.cos(a1),(rr0+.18)*math.sin(a1)),(rr0*math.cos(a1-aa),rr0*math.sin(a1-aa))]
  mi=(band+j)%5 if band not in [5,6,20,21] else 2
  prism(poly,0,.075,mi)
floor=mesh('PavingQuarter',verts,faces,stone,indices);finish('PavingQuarter',[floor],ground=False)

def sector(name,r0,r1,a0,a1,z0,z1,material,steps=24):
 vs=[]
 for z in [z0,z1]:
  for r in [r0,r1]:
   for i in range(steps+1):
    a=a0+(a1-a0)*i/steps;vs.append((r*math.cos(a),r*math.sin(a),z))
 n=steps+1;fs=[]
 for i in range(steps):fs.extend([(i,i+1,n+i+1,n+i),(2*n+i,3*n+i,3*n+i+1,2*n+i+1),(i,2*n+i,2*n+i+1,i+1),(n+i,n+i+1,3*n+i+1,3*n+i)])
 fs.extend([(0,n,3*n,2*n),(n-1,2*n-1,4*n-1,3*n-1)])
 return mesh(name,vs,fs,[material])
rim=[]
for r0,r1 in [(77,78.1),(95,96.1)]:rim.append(sector('Rim',r0,r1,-.24,.24,0,2.5,edge))
rim.extend([sector('End',78.1,95,-.24,-.226,0,2.5,edge,2),sector('End',78.1,95,.226,.24,0,2.5,edge,2)])
finish('CrescentBed',rim,ground=False);finish('CrescentSoil',[sector('Soil',78.1,95,-.226,.226,.15,2.12,soil)],ground=False)
def tube(name,points,radius,material,sides=8):
 vs=[];fs=[]
 for i,p in enumerate(points):
  direction=Vector(points[min(i+1,len(points)-1)])-Vector(points[max(i-1,0)])
  direction.normalize();axis=direction.cross(Vector((0,0,1)))
  if axis.length<.01:axis=Vector((1,0,0))
  axis.normalize();other=direction.cross(axis)
  for j in range(sides):vs.append(Vector(p)+radius*(axis*math.cos(j*math.tau/sides)+other*math.sin(j*math.tau/sides)))
 for i in range(len(points)-1):
  for j in range(sides):fs.append((i*sides+j,i*sides+(j+1)%sides,(i+1)*sides+(j+1)%sides,(i+1)*sides+j))
 return mesh(name,vs,fs,[material])
rib=[]
rib.append(tube('Spine',[(0,y,7+.7*math.sin(y*.12))for y in range(-10,12,2)],.5,bone))
for i in range(9):
 y=-8+i*2;span=4.3*(.72+.28*math.sin(i/8*math.pi))
 for side in [-1,1]:
  pts=[(side*span*math.sin(t*math.pi*.85),y+.25*math.sin(t*math.pi),7-5.5*t+.6*math.sin(i))for t in [j/10 for j in range(11)]]
  rib.append(tube('Rib',pts,.25,bone))
for y in [-7,6]:rib.append(tube('MuseumSupport',[(0,y,0),(0,y,6.7)],.19,mount))
finish('FossilRibcage',rib)
# Smooth, deliberately asymmetric landscape masses, independent of rock prop scaling.
for index,peaks in enumerate([[(0,0,1),(-.5,.08,.7),(.45,-.1,.58)],[(0,.05,.72),(-.4,0,1),(.55,.22,.65)],[(0,0,.62),(-.55,.2,.48),(.4,-.15,1)]]):
 vs=[];fs=[];cols=25;rows=21
 for iy in range(rows):
  y=(iy/(rows-1)-.5)*2
  for ix in range(cols):
   x=(ix/(cols-1)-.5)*2;z=0
   for px,py,h in peaks:
    # Separate broad summits and lower saddles; avoid a noisy single cone.
    distance=math.sqrt(((x-px)*1.5)**2+((y-py)*1.1)**2)
    z=max(z,h*max(0,1-distance)**1.05)
   z=max(0,z+.018*math.sin(x*4+y*3)*max(0,1-x*x-y*y))
   vs.append((x*90,y*95,z*110))
 for iy in range(rows-1):
  for ix in range(cols-1):
   a=iy*cols+ix;fs.extend([(a,a+1,a+cols+1),(a,a+cols+1,a+cols)])
 mo=mesh('Mountain'+str(index+1),vs,fs,[stone[index]])
 for face in mo.data.polygons:face.use_smooth=True
 finish('Mountain'+str(index+1),[mo])
# Low broad planted terrain for the near and middle groups.
vs=[];fs=[]
for j in range(17):
 for i in range(21):
  x=(i/20-.5)*2;y=(j/16-.5)*2;z=12*max(0,1-x*x-y*y)**1.2+2*max(0,1-abs(x))*math.sin(x*3+y*4)
  vs.append((x*65,y*45,max(0,z)))
for j in range(16):
 for i in range(20):a=j*21+i;fs.extend([(a,a+1,a+22),(a,a+22,a+21)])
finish('PlantedSlope',[mesh('PlantedSlope',vs,fs,[soil])])
# Cascading sheet with outward lip, continuous fall and outward pool transition.
vs=[];fs=[];path=[(0,84),(5,84),(10,82),(14,75),(17,60),(19,40),(22,20),(28,5),(35,1),(47,.5)]
for j,(y,z) in enumerate(path):
 for i in range(9):x=(i/8-.5)*(13+4*j/9);vs.append((x,y,z+.24*math.cos(x*.7+j*.4)))
for j in range(len(path)-1):
 for i in range(8):a=j*9+i;fs.append((a,a+1,a+10,a+9))
finish('CascadeSheet',[mesh('CascadeSheet',vs,fs,[water])],ground=False)

# Every imported object uses one shared packed color/alpha atlas. Source masters retain materials.
info=[]
for o,record in zip(objects,records):
 o.data.calc_loop_triangles();points=[v.co for v in o.data.vertices]
 lo=[min(p[i]for p in points)for i in range(3)];hi=[max(p[i]for p in points)for i in range(3)]
 record.update(triangles=len(o.data.loop_triangles),boundsMin=lo,boundsMax=hi)
 info.append(record)
bpy.ops.wm.save_as_mainfile(filepath=str(R/'lab-art-master.blend'),compress=True)
(R/'geometry.json').write_text(json.dumps(info,indent=2))
print('ART_MASTER_COMPLETE',len(objects))
