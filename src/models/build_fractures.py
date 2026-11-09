import bpy,bmesh,math,json
from mathutils import Vector
from pathlib import Path
out=Path(r'C:\Users\BOSS\Desktop\egg\src\models')
original=[bpy.data.objects[f'L{li}_R{row:02d}'] for li in range(1,4) for row in range(24)]
for o in bpy.data.objects:o.hide_render=True
pieces=[];manifest=[]
for source in original:
 row=int(source.name[-2:]);phi=(row+.5)*math.pi/24
 center=sum((v.co for v in source.data.vertices),Vector())/len(source.data.vertices)
 tangent=Vector((math.cos(phi),0,math.sin(phi))).normalized()
 plane0=Vector((.035,1,.14)).normalized();plane1=(tangent+Vector((0,.22,0))).normalized()
 for index in range(3):
  bm=bmesh.new();bm.from_mesh(source.data);uv=bm.loops.layers.uv.active
  capUV=(.5,.5)
  for f in bm.faces:
   if f.material_index==1 and uv:
    capUV=tuple(sum((loop[uv].uv for loop in f.loops),Vector((0,0)))/len(f.loops));break
  cuts=[(plane0,index!=0)]
  if index>0:cuts.append((plane1,index==2))
  for normal,positive in cuts:
   result=bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.000001,plane_co=center,plane_no=normal,clear_inner=positive,clear_outer=not positive)
   edges=[e for e in result['geom_cut'] if isinstance(e,bmesh.types.BMEdge) and e.is_valid and e.is_boundary]
   if edges:
    filled=bmesh.ops.holes_fill(bm,edges=edges,sides=0)
    for f in filled['faces']:
     f.material_index=1;f.smooth=False
     if uv:
      for loop in f.loops:loop[uv].uv=capUV
  bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
  name=source.name+f'_F{index+1}'
  mesh=bpy.data.meshes.new(name);bm.to_mesh(mesh);bm.free();mesh.update()
  if len(mesh.polygons)==0:raise RuntimeError('Empty fragment '+name)
  for material in source.data.materials:mesh.materials.append(material)
  normals=[None]*len(mesh.loops)
  for polygon in mesh.polygons:
   polygon.use_smooth=polygon.material_index==0
   for loop_index in polygon.loop_indices:
    if polygon.material_index==0:
     v=mesh.vertices[mesh.loops[loop_index].vertex_index].co
     phi=math.acos(max(-1,min(1,1-2*v.z/68)));theta=math.atan2(v.y,v.x)
     dz=34*math.sin(phi);dr=24*(math.cos(phi)*(1+.18*math.cos(phi))-.18*math.sin(phi)**2)
     n=Vector((dz*math.cos(theta),dz*math.sin(theta),-dr)).normalized()
     normals[loop_index]=tuple(n)
    else:normals[loop_index]=tuple(polygon.normal)
  mesh.normals_split_custom_set(normals)
  obj=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(obj);obj.hide_render=False
  coords=[v.co for v in mesh.vertices];lo=Vector(tuple(min(v[i] for v in coords) for i in range(3)));hi=Vector(tuple(max(v[i] for v in coords) for i in range(3)))
  c=(lo+hi)/2;manifest.append({'name':name,'template':source.name,'piece':index+1,'center':[c.x,c.z,-c.y],'size':[hi.x-lo.x,hi.z-lo.z,hi.y-lo.y]})
  pieces.append(obj)
bpy.ops.object.select_all(action='DESELECT')
for o in pieces:o.select_set(True)
bpy.context.view_layer.objects.active=pieces[0]
bpy.ops.export_scene.fbx(filepath=str(out/'shell-fractures.fbx'),use_selection=True,add_leaf_bones=False,axis_forward='-Z',axis_up='Y')
(out/'fracture-manifest.json').write_text(json.dumps(manifest,indent=2))
bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(out/'shell-fractures.blend'))
print('FRACTURES_READY',len(pieces),flush=True)
