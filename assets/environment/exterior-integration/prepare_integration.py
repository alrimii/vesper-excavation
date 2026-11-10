"""Prepare grading/material copies around the existing v180 meshes; no new mountain modeling."""
import bpy, json, math, random
import numpy as np
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT=Path('C:/Users/BOSS/Desktop/egg')
OUT=ROOT/'Backups/ExteriorIntegration_20261110'
EXP=OUT/'exports';EXP.mkdir(exist_ok=True)
CONFIG=json.loads((ROOT/'assets/environment/exterior-integration/composition.json').read_text())
bpy.ops.wm.open_mainfile(filepath=str(OUT/'assets-before.blend'))
alpine=bpy.data.objects['AlpineRange']
faces=[tuple(p.vertices) for p in alpine.data.polygons]
massifs=[]
for deg,r,base,sx,sy,sz,yaw in CONFIG['peaks']:
 a=math.radians(deg);q=math.radians(yaw);px,pz=math.cos(a)*r,math.sin(a)*r;c,s=math.cos(q),math.sin(q)
 verts=[]
 for v in alpine.data.vertices:
  lx,ly,lz=-v.co.x*sx,v.co.z*sy,v.co.y*sz
  verts.append((px+c*lx+s*lz,pz-s*lx+c*lz,base+ly))
 massifs.append(BVHTree.FromPolygons(verts,faces,all_triangles=False))

def ground(x,z):
 r=np.sqrt(x*x+z*z)
 t=np.clip((r-350)/500,0,1);t=t*t*(3-2*t)
 y=-8+t*(8+13*np.sin(x/430)*np.cos(z/520)+9*np.sin(z/310))
 for cx,cz,h,wx,wz in CONFIG['grading']:
  y+=t*h*np.exp(-(((x-cx)/wx)**2+((z-cz)/wz)**2)*1.7)
 a=math.radians(55);u=x*math.cos(a)+z*math.sin(a);v=-x*math.sin(a)+z*math.cos(a)
 valley=np.clip((u-800)/900,0,1)*np.exp(-((v-110*np.sin(u/650))/360)**2)
 y-=valley*18
 return y

def surface(x,z):
 y=float(ground(x,z))
 for tree in massifs:
  hit,normal,_,_=tree.ray_cast(Vector((x,z,1800)),Vector((0,0,-1)),2200)
  if hit and hit.z>y:y=hit.z
 return y

plants=json.loads((OUT/'old-planting.json').read_text())
for p in plants:
 p['y']=round(surface(p['x'],p['z'])-.4,3)
 p['patch']='RetainedTrees' if p['kind']=='tree' else 'RetainedMeadow'
rng=random.Random(180194)
for route_index,route in enumerate(CONFIG['treeRoutes']):
 points=route['points']
 for j in range(route['count']):
  for attempt in range(40):
   u=rng.random()*2;seg=min(1,int(u));f=u-seg
   x=points[seg][0]*(1-f)+points[seg+1][0]*f+rng.gauss(0,85)
   z=points[seg][1]*(1-f)+points[seg+1][1]*f+rng.gauss(0,75)
   y=surface(x,z)
   if y>220 or math.hypot(x,z)<650:continue
   if any(p['kind']=='tree' and (p['x']-x)**2+(p['z']-z)**2<58**2 for p in plants):continue
   break
  else:continue
  s=rng.uniform(2.8,4.5) if route_index<8 else rng.uniform(2.1,3.0)
  name=['CanopyYoung','MountainPine','CanopyYoung','CanopyOak','CanopyTwisted'][j%5]
  plants.append(dict(name=name,kind='tree',x=round(x,3),y=round(y-.4,3),z=round(z,3),yaw=round(rng.uniform(0,math.tau),5),scale=[round(s*.92,4),round(s,4),round(s,4)],color=[239,245,226],retained=False,patch='WoodlandLink%d'%(route_index+1)))

for i,(cx,cz) in enumerate(CONFIG['nearPockets']):
 for j,name in enumerate(['SoftGrass','SoftGrass','ForestFern','GroundShrub','LeafShrub','RockRound']):
  x=cx+rng.uniform(-24,24);z=cz+rng.uniform(-19,19)
  s=rng.uniform(.6,1.1) if name=='RockRound' else rng.uniform(1.3,2.7)
  plants.append(dict(name=name,kind='meadow',x=round(x,3),y=round(surface(x,z)-.2,3),z=round(z,3),yaw=round(rng.uniform(0,math.tau),5),scale=[s,s,s],color=[240,243,223],retained=False,patch='BufferPocket%d'%(i+1)))

# A few low shrubs and rocks at selected woodland feet, not a seam-covering ring.
for i,route in enumerate(CONFIG['treeRoutes'][:8]):
 cx,cz=route['points'][-1]
 for j,name in enumerate(['GroundShrub','ForestFern','RockShoulder','LeafShrub']):
  x=cx+rng.uniform(-55,55);z=cz+rng.uniform(-50,50);s=rng.uniform(1.8,3.3) if name!='RockShoulder' else rng.uniform(1.4,2.4)
  plants.append(dict(name=name,kind='meadow',x=round(x,3),y=round(surface(x,z)-.4,3),z=round(z,3),yaw=rng.uniform(0,math.tau),scale=[s,s,s],color=[235,239,220],retained=False,patch='SlopePocket%d'%(i+1)))

def save_pixels(name,pixels,size):
 im=bpy.data.images.new(name,width=size,height=size,alpha=False)
 im.colorspace_settings.name='Non-Color'
 im.pixels.foreach_set(pixels.astype(np.float32).ravel());im.file_format='PNG';im.filepath_raw=str(EXP/(name+'.png'));im.save();return im

# One continuous world-space color map; identical UV coordinates on shared tile boundaries.
n=1024;axis=np.linspace(-6000,6000,n);x,z=np.meshgrid(axis,axis)
h=ground(x,z)
noise_rng=np.random.default_rng(180)
wave=np.zeros_like(x)
for count,amount in [(19,.034),(43,.014)]:
 lattice=noise_rng.uniform(-1,1,(count,count));coarse=np.linspace(0,n-1,count);fine=np.arange(n)
 rows=np.array([np.interp(fine,coarse,row)for row in lattice])
 noise=np.array([np.interp(fine,coarse,rows[:,i])for i in range(n)]).T
 for _ in range(4):noise=(noise+np.roll(noise,1,0)+np.roll(noise,-1,0)+np.roll(noise,1,1)+np.roll(noise,-1,1))/5
 wave+=noise*amount
base=np.array([.43,.49,.32])[None,None,:]+wave[:,:,None]
wood=np.zeros_like(x)
for p in plants:
 if p['kind']=='tree':wood=np.maximum(wood,np.exp(-(((x-p['x'])/210)**2+((z-p['z'])/210)**2)))
base=base*(1-wood[:,:,None]*.58)+np.array([.29,.37,.235])*wood[:,:,None]*.58
slope=np.clip((abs(np.gradient(h,axis,axis)[0])+abs(np.gradient(h,axis,axis)[1]))*.9,0,.30)
base=base*(1-slope[:,:,None])+np.array([.48,.47,.34])*slope[:,:,None]
rgba=np.concatenate([np.clip(base,0,1),np.ones((n,n,1))],axis=2)
ground_image=save_pixels('GradedMeadowColor',rgba,n)

textures={
 'AlpineSoftColor':ROOT/'Backups/ExteriorComposition_20261110/exports/AlpineRange_Alpine_range_rock,_snow,_scree,_turf_and_forest_color.png',
 'CliffSoftColor':ROOT/'Backups/ExteriorComposition_20261110/exports/StrataCliff_mountainside_color.png',
 'ButtressSoftColor':ROOT/'Backups/ExteriorComposition_20261110/exports/RockButtress_rock_face_02_color.png'
}
for name,path in textures.items():
 im=bpy.data.images.load(str(path),check_existing=False);im.scale(256,256);im.scale(512,512)
 arr=np.empty(512*512*4,dtype=np.float32);im.pixels.foreach_get(arr);arr=arr.reshape(512,512,4)
 mean=arr[:,:,:3].mean(axis=2,keepdims=True)
 arr[:,:,:3]=np.clip((arr[:,:,:3]*.91+mean*.09)*.83+np.array([.45,.48,.40])*.17,0,1)
 im.pixels.foreach_set(arr.ravel());im.filepath_raw=str(EXP/(name+'.png'));im.file_format='PNG';im.save()

# Export only new continuous grading; retain all mountain meshes in their original native library.
for o in list(bpy.data.objects):bpy.data.objects.remove(o,do_unlink=True)
mat=bpy.data.materials.new('IntegratedMeadow');mat.use_nodes=True
bs=mat.node_tree.nodes.get('Principled BSDF');tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=ground_image
mat.node_tree.links.new(tex.outputs['Color'],bs.inputs['Base Color']);bs.inputs['Roughness'].default_value=1
records=[];n=CONFIG['tileDivisions'];w=CONFIG['tileWidth']
for gx in range(-4,4):
 for gz in range(-4,4):
  cx,cz=(gx+.5)*w,(gz+.5)*w;verts=[];faces=[];uvs=[]
  for j in range(n+1):
   for i in range(n+1):
    xx=cx+(i/n-.5)*w;zz=cz+(j/n-.5)*w;yy=float(ground(xx,zz))
    # Pre-mirror X so the Studio import yields the intended world-space grade.
    verts.append((-(xx-cx),zz-cz,yy));uvs.append(((xx+6000)/12000,(zz+6000)/12000))
  for j in range(n):
   for i in range(n):
    a=j*(n+1)+i;b=a+1;c=a+n+1;d=c+1;faces.extend([(a,c,b),(b,c,d)])
  name='Grade_%d_%d'%(gx+4,gz+4);me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.update()
  uv=me.uv_layers.new(name='WorldColor')
  for poly in me.polygons:
   poly.use_smooth=True
   for li in poly.loop_indices:uv.data[li].uv=uvs[me.loops[li].vertex_index]
  normals=[]
  for vx,vz,vy in verts:
   xx=cx-vx;zz=cz+vz
   dx=float(ground(xx+1,zz)-ground(xx-1,zz))/2
   dz=float(ground(xx,zz+1)-ground(xx,zz-1))/2
   normals.append(Vector((dx,-dz,1)).normalized())
  me.normals_split_custom_set_from_vertices(normals)
  ob=bpy.data.objects.new(name,me);bpy.context.collection.objects.link(ob);ob.location=(-cx,cz,0);me.materials.append(mat)
  low=min(v[2]for v in verts);high=max(v[2]for v in verts)
  records.append(dict(name=name,triangles=len(faces),size=[w,high-low,w],center=[cx,(high+low)/2,cz]))

data=dict(peaks=CONFIG['peaks'],planting=plants,ground=records,grading=CONFIG['grading'])
(ROOT/'assets/environment/exterior-integration/layout.json').write_text(json.dumps(data,indent=2))
(ROOT/'src/ExteriorIntegrationLayout.luau').write_text('-- Generated from the retained v180 placements and prepare_integration.py. Edit-only data.\nreturn game:GetService("HttpService"):JSONDecode([=['+json.dumps(data,separators=(',',':'))+']=])\n')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'integrated-grading.blend'),compress=True)
bpy.ops.export_scene.fbx(filepath=str(EXP/'integrated-grade-normals.fbx'),use_selection=False,object_types={'MESH'},apply_unit_scale=True,bake_space_transform=True,axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
print('INTEGRATION_COMPLETE',len(records),'ground meshes;',len(plants),'plant placements;',sum(p['kind']=='tree'for p in plants),'trees',flush=True)
