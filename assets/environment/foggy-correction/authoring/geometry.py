import bpy,json,math
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
p=Path('C:/Users/BOSS/Desktop/egg/Backups/FoggyCorrection_20261110');old=p.parent/'FoggyGazebo_20261110_implementation';s=bpy.context.scene
meta=json.loads((old/'conversion/final-geometry.json').read_text());recs={r['name']:r for r in meta['records']};out=[];records=[]
ground=bpy.data.objects['Source_Landscape_001'];gc=Vector(recs[ground.name]['center']);bv=BVHTree.FromPolygons([v.co+gc for v in ground.data.vertices],[list(f.vertices)for f in ground.data.polygons])
def oldg(x,y):
 hit=bv.ray_cast(Vector((x,y,1000)),Vector((0,0,-1)),2000)[0];return hit.z if hit else 65
gx,gy= -37.256309509,1120.25268555 # Native mirrored X is +37; Blender source center is -37.
gx=recs['Source_Cube_074']['center'][0]
platform=.6*oldg(gx,gy)-20+.04*max(gy-650,0)
def height(x,y,z=None):
 base=.6*(oldg(x,y)if z is None else z)-20+.04*max(y-650,0)
 d=((x-gx)**2+(y-gy)**2)**.5;t=max(0,min(1,(d-155)/65));t=t*t*(3-2*t)
 return platform*(1-t)+base*t
def register(ob,source,center):
 lo=Vector(tuple(min(v.co[k] for v in ob.data.vertices)for k in range(3)));hi=Vector(tuple(max(v.co[k] for v in ob.data.vertices)for k in range(3)));mid=(lo+hi)/2
 for v in ob.data.vertices:v.co-=mid
 records.append({'name':ob.name,'source':source,'center':list(Vector(center)+mid),'size':list(hi-lo),'triangles':sum(len(f.vertices)-2 for f in ob.data.polygons)})
 out.append(ob)
# Restore smooth per-corner source normals when splitting leaf/wood, instead of flat duplicated vertices.
for r in meta['records']:
 if not r['name'].startswith('FrameTree'):continue
 ob=bpy.data.objects[r['name']];me=ob.data;src=bpy.data.objects[r['source']];ev=src.evaluated_get(bpy.context.evaluated_depsgraph_get());tmp=bpy.data.objects.new('tmp',bpy.data.meshes.new_from_object(ev));s.collection.objects.link(tmp);bpy.context.view_layer.objects.active=tmp;mod=tmp.modifiers.new('tri','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=mod.name)
 assert len(me.polygons)==len(tmp.data.polygons)
 for kind in ['leaf','wood']:
  vs=[];fs=[];uvs=[];normals=[]
  for f,orig in zip(me.polygons,tmp.data.polygons):
   leaf=tmp.data.materials[orig.material_index].name=='leaf.8'
   if leaf!=(kind=='leaf'):continue
   fs.append(tuple(range(len(vs),len(vs)+len(f.vertices))));vs.extend(me.vertices[k].co.copy()for k in f.vertices)
   uvs.extend(tmp.data.uv_layers.active.data[k].uv.copy()for k in orig.loop_indices)
   normals.extend(me.corner_normals[k].vector.copy()for k in f.loop_indices)
  name=r['name']+'_'+kind;m=bpy.data.meshes.new(name);m.from_pydata(vs,[],fs);m.update();u=m.uv_layers.new(name='UVMap')
  for a,b in zip(u.data,uvs):a.uv=b
  for f in m.polygons:f.use_smooth=True
  m.normals_split_custom_set(normals)
  no=bpy.data.objects.new(name,m);s.collection.objects.link(no);register(no,r['source'],r['center'])
 bpy.data.objects.remove(tmp,do_unlink=True)
# Ground and wooden approach retain source shape with a modest elevation profile and a seated gazebo footprint.
for name in ['Source_Landscape_001','Source_Cube_077']:
 ob=bpy.data.objects[name];r=recs[name];c=Vector(r['center'])
 for v in ob.data.vertices:
  w=v.co+c;v.co.z=height(w.x,w.y,w.z if 'Landscape' in name else None)+(0 if 'Landscape' in name else 1.0)-c.z
 register(ob,r['source'],r['center'])
# One continuous 180-degree curved projection; no overlapping sky-cap mesh, no cropped v coordinate.
for side in range(2):
 vs=[];fs=[];uvs=[];R=1450
 for j in range(17):
  y=-350+j*1500/16
  for i in range(49):
   n=side*48+i;a=-math.pi/2+n*math.pi/96;vs.append((R*math.sin(a),340+R*math.cos(a),y));uvs.append((n/96,j/16))
 for j in range(16):
  for i in range(48):k=j*49+i;fs.extend([(k,k+1,k+50),(k,k+50,k+49)])
 name='Backdrop_Continuous_'+str(side);m=bpy.data.meshes.new(name);m.from_pydata(vs,[],fs);m.update();u=m.uv_layers.new(name='UVMap')
 for f in m.polygons:
  f.use_smooth=True
  for k in f.loop_indices:u.data[k].uv=uvs[m.loops[k].vertex_index]
 o=bpy.data.objects.new(name,m);s.collection.objects.link(o);register(o,'source far forest corrected perspective projection',(0,0,0))
# Record consistent per-assembly seating; do not independently lift pillars, roof, floor, and path.
placements={}
for r in meta['records']:
 x,y,z=r['center'];placements[r['name']]=height(x,y)-oldg(x,y)
placements['gazebo_delta']=platform+2-recs['Source_Cube_074']['center'][2]
(p/'geometry.json').write_text(json.dumps({'records':records,'placements':placements,'platform':platform},indent=2))
bpy.ops.object.select_all(action='DESELECT')
for o in out:o.select_set(True)
bpy.context.view_layer.objects.active=out[0]
bpy.ops.export_scene.fbx(filepath=str(p/'exports/correction.fbx'),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',use_custom_props=False)
bpy.ops.wm.save_as_mainfile(filepath=str(p/'correction-private.blend'));print('CORRECTION_EXPORTED',len(out),flush=True)
