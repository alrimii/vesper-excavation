"""Adapt selected licensed meshes and author enclosure panes for the compact court.
Fresh background scene only; originals are never overwritten.
"""
import bpy, json, math, bmesh
from pathlib import Path
from mathutils import Vector, Matrix
ROOT=Path(__file__).parent; EXPORT=ROOT/'exports';EXPORT.mkdir(exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
def select(objects):
 bpy.ops.object.select_all(action='DESELECT')
 for o in objects:o.select_set(True)
 if objects:bpy.context.view_layer.objects.active=objects[0]
def apply(o):
 bpy.context.view_layer.update();select([o]);bpy.ops.object.transform_apply(location=False,rotation=True,scale=True);bpy.context.view_layer.update()
def bounds(objects):
 pts=[o.matrix_world@v.co for o in objects for v in o.data.vertices]
 return Vector([min(p[i] for p in pts) for i in range(3)]),Vector([max(p[i] for p in pts) for i in range(3)])
def import_source(name):
 before=set(bpy.context.scene.objects);bpy.ops.import_scene.gltf(filepath=str(ROOT/'source'/f'{name}.glb'))
 bpy.context.view_layer.update()
 obs=[o for o in set(bpy.context.scene.objects)-before if o.type=='MESH']
 for o in obs:
  world=o.matrix_world.copy();o.data.transform(world);o.parent=None;o.matrix_world=Matrix.Identity(4)
 bpy.context.view_layer.update()
 return obs
def material(name,c):
 m=bpy.data.materials.new(name);m.diffuse_color=(*c,1);m.use_nodes=True;m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(*c,1);m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=0.82;return m
bone=material('WarmFossil',(0.50,0.39,0.24))
objects=import_source('triceratops');o=objects[0]
# This published scan has its height along X. Stand it upright; head/tail along Y.
o.data.transform(Matrix.Rotation(-math.pi/2,4,'Y'));apply(o)
lo,hi=bounds([o]);o.scale*=38/max(hi-lo);apply(o);lo,hi=bounds([o]);o.location-=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z));apply(o)
o.data.materials.clear();o.data.materials.append(bone)
for p in o.data.polygons:p.material_index=0;p.use_smooth=True
select([o]);mod=o.modifiers.new('SilhouettePreservingReduction','DECIMATE');mod.ratio=.30;bpy.ops.object.modifier_apply(modifier=mod.name)
# Spatial partition preserves the entire selected scan under Roblox's per-mesh limit.
mesh=o.data; lo,hi=bounds([o]); bins=[[] for _ in range(4)]
for p in mesh.polygons:
 y=sum((o.matrix_world@mesh.vertices[i].co).y for i in p.vertices)/len(p.vertices)
 bins[min(3,int((y-lo.y)/(hi.y-lo.y)*4))].append(p)
fossils=[]
for i,faces in enumerate(bins):
 used=sorted({v for f in faces for v in f.vertices});remap={v:j for j,v in enumerate(used)}
 data=bpy.data.meshes.new(f'FossilScan{i+1}');data.from_pydata([o.matrix_world@mesh.vertices[v].co for v in used],[],[[remap[v] for v in f.vertices] for f in faces]);data.materials.append(bone)
 ob=bpy.data.objects.new(data.name,data);bpy.context.collection.objects.link(ob)
 for p in data.polygons:p.use_smooth=True
 fossils.append(ob)
bpy.data.objects.remove(o,do_unlink=True)
micros=import_source('microscope')
for o in micros:apply(o)
lo,hi=bounds(micros)
print('MICROSCOPE_BOUNDS',list(lo),list(hi))
rank=[]
for o in micros:
 l,h=bounds([o]);rank.append((math.prod(h-l),o.name,list(l),list(h)))
print('LARGEST',sorted(rank,reverse=True)[:8])
# Remove the source presentation cube and its loose trailing cable below the instrument.
table_name=max(rank)[1]; table=next(o for o in micros if o.name==table_name);tl,th=bounds([table]);floor=th.z
for o in list(micros):
 l,h=bounds([o])
 if o==table or h.z<floor+0.0001:micros.remove(o);bpy.data.objects.remove(o,do_unlink=True)
for o in micros:
 bm=bmesh.new();bm.from_mesh(o.data)
 bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.00001,plane_co=(0,0,floor),plane_no=(0,0,1),clear_inner=True)
 bm.to_mesh(o.data);bm.free()
lo,hi=bounds(micros);sc=6.5/(hi.z-lo.z);center=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z))
for o in micros:
 o.matrix_world=Matrix.Scale(sc,4)@Matrix.Translation(-center)@o.matrix_world
 apply(o)
select(micros);bpy.ops.object.join();scope=bpy.context.object;scope.name='Microscope';apply(scope)
select([scope]);m=scope.modifiers.new('RetainInstrumentSilhouette','DECIMATE');m.ratio=.55;bpy.ops.object.modifier_apply(modifier=m.name)
charge=import_source('charge');lo,hi=bounds(charge);sc=2.1/max(hi-lo);center=(lo+hi)/2
for o in charge:o.matrix_world=Matrix.Scale(sc,4)@Matrix.Translation(-center)@o.matrix_world;apply(o)
select(charge);bpy.ops.object.join();charge=bpy.context.object;charge.name='ChargeBundle'
# Keep authored material colors; all source meshes remain genuine 3D geometry.
allmesh=fossils+[scope,charge]
report={}
for o in allmesh:
 # Ensure export origin is world zero and geometry records exact Roblox-space extents.
 select([o]);bpy.context.scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
 lo,hi=bounds([o]);tris=sum(len(p.vertices)-2 for p in o.data.polygons)
 assert tris<=20000,(o.name,tris)
 report[o.name]={'triangles':tris,'size':[hi.x-lo.x,hi.z-lo.z,hi.y-lo.y],'center':[(lo.x+hi.x)/2,(lo.z+hi.z)/2,-(lo.y+hi.y)/2]}
 select([o]);bpy.ops.export_scene.gltf(filepath=str(EXPORT/(o.name+'.glb')),export_format='GLB',use_selection=True)
# Build each roof pane as a closed thin shell between matching old crown and fitted base.
def base(a):
 s,c=math.sin(a),math.cos(a);rad=min(214/max(abs(s),abs(c)),356/(abs(s)+abs(c)))
 return (s*rad,c*rad)
levels=[(52,1.0),(109,.88),(170,.64),(218,.34),(247,0.0)]
for i in range(24):
 a0=math.radians(i*15-7.5);a1=math.radians(i*15+7.5)
 for j in range(4):
  verts=[]
  for y,t in [levels[j],levels[j+1]]:
   for a in [a0,a1]:
    x,z=base(a);verts.append((x*t+math.sin(a)*88*(1-t),-(z*t+math.cos(a)*88*(1-t)),y))
  # source z is up, source -y is Roblox +z
  data=bpy.data.meshes.new(f'Pane_{i+1:02}_{j+1}');data.from_pydata(verts,[],[(0,1,3,2)]);ob=bpy.data.objects.new(data.name,data);bpy.context.collection.objects.link(ob)
  select([ob]);solid=ob.modifiers.new('SealedThinPane','SOLIDIFY');solid.thickness=.18;bpy.ops.object.modifier_apply(modifier=solid.name)
  lo,hi=bounds([ob]);report[ob.name]={'triangles':sum(len(p.vertices)-2 for p in ob.data.polygons),'size':[hi.x-lo.x,hi.z-lo.z,hi.y-lo.y],'center':[(lo.x+hi.x)/2,(lo.z+hi.z)/2,-(lo.y+hi.y)/2]}
  allmesh.append(ob)
# One model upload for the enclosure mesh library.
panes=[o for o in allmesh if o.name.startswith('Pane_')];select(panes)
bpy.ops.export_scene.gltf(filepath=str(EXPORT/'EnclosurePanes.glb'),export_format='GLB',use_selection=True)
select(allmesh);bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'compact-interior-assets.blend'))
(ROOT/'geometry.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print('EXPORT_COMPLETE',len(report))
