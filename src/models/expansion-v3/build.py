"""Original smooth, watertight shell plates. Blender 4.5; no downloaded assets."""
import bpy, math, json
from mathutils import Vector
from pathlib import Path
OUT=Path('C:\\Users\\BOSS\\Desktop\\egg\\src\\models\\expansion-v3')
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
COLS,ROWS,H,R,PITCH=68,40,104.04,40.8,.55
def surface(theta,phi,depth):
    phi=max(0,min(math.pi,phi)); v=-math.cos(phi)
    radius=R*math.sin(phi)*(1-.18*v)
    dr=R*(math.cos(phi)*(1+.18*math.cos(phi))-.18*math.sin(phi)**2)
    dz=H*.5*math.sin(phi)
    normal=Vector((dz*math.cos(theta),dz*math.sin(theta),-dr)).normalized()
    return Vector((radius*math.cos(theta),radius*math.sin(theta),H*.5*(1+v)))-normal*depth
def mat(name,color,rough):
    m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Roughness'].default_value=rough
    return m
mats=[mat('Ivory ceramic shell',(.72,.65,.49),.78),mat('Amber living membrane',(.48,.20,.055),.52),mat('Deep violet matrix',(.21,.14,.28),.67)]
inside=[mat('Shell inner edge',(.46,.39,.27),.85),mat('Membrane inner edge',(.29,.09,.025),.65),mat('Matrix inner edge',(.10,.065,.14),.8)]
templates=[];metadata=[]
offsets=[(0,-2/3),(.5,-1/3),(.5,1/3),(0,2/3),(-.5,1/3),(-.5,-1/3)]
for row in range(ROWS):
    phi=(row+.5)*math.pi/ROWS
    for layer in range(3):
        vertices=[];faces=[];mi=[];cache={};depth=layer*PITCH
        def vertex(u,v,d):
            p=surface(u*2*math.pi/COLS,phi+v*math.pi/ROWS,d)
            key=tuple(round(x,6) for x in p)
            if key not in cache:cache[key]=len(vertices);vertices.append(p)
            return cache[key]
        def tri(a,b,c,material,reverse=False):
            ids=(a,c,b) if reverse else (a,b,c)
            if len(set(ids))==3:faces.append(ids);mi.append(material)
        inset=.996
        for side in range(6):
            a=offsets[side];b=offsets[(side+1)%6];sub=4
            for back in [False,True]:
                d=depth+(PITCH-.012 if back else 0)
                grid={}
                for i in range(sub+1):
                    for j in range(sub+1-i):
                        u=(a[0]*i+b[0]*j)/sub*inset;v=(a[1]*i+b[1]*j)/sub*inset
                        grid[i,j]=vertex(u,v,d)
                for i in range(sub):
                    for j in range(sub-i):
                        tri(grid[i,j],grid[i+1,j],grid[i,j+1],int(back),not back)
                        if j<sub-i-1:tri(grid[i+1,j],grid[i+1,j+1],grid[i,j+1],int(back),not back)
            for k in range(sub):
                u0=(a[0]+(b[0]-a[0])*k/sub)*inset;v0=(a[1]+(b[1]-a[1])*k/sub)*inset
                u1=(a[0]+(b[0]-a[0])*(k+1)/sub)*inset;v1=(a[1]+(b[1]-a[1])*(k+1)/sub)*inset
                x,y,z,w=vertex(u0,v0,depth),vertex(u1,v1,depth),vertex(u1,v1,depth+PITCH-.012),vertex(u0,v0,depth+PITCH-.012)
                tri(x,y,z,1);tri(x,z,w,1)
        name=f'L{layer+1}_R{row:02d}'
        mesh=bpy.data.meshes.new(name);mesh.from_pydata(vertices,[],faces);mesh.update()
        obj=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(obj)
        mesh.materials.append(mats[layer]);mesh.materials.append(inside[layer])
        for p,idx in zip(mesh.polygons,mi):p.material_index=idx;p.use_smooth=True
        bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
        bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.normals_make_consistent(inside=False);bpy.ops.uv.smart_project(island_margin=.015);bpy.ops.object.mode_set(mode='OBJECT')
        # World coordinates preserved in the FBX; importer script normalizes from this manifest.
        coords=[obj.matrix_world@v.co for v in mesh.vertices]
        low=Vector(tuple(min(v[i] for v in coords) for i in range(3)));high=Vector(tuple(max(v[i] for v in coords) for i in range(3)))
        def rb(v):return [v.x,v.z,-v.y]
        metadata.append({'name':name,'center':rb((low+high)/2),'size':[high.x-low.x,high.z-low.z,high.y-low.y],'surfaceCenter':rb(surface(0,phi,depth)),'triangles':len(faces)})
        templates.append(obj)
bpy.ops.object.select_all(action='DESELECT')
for o in templates:o.select_set(True)
bpy.ops.export_scene.fbx(filepath=str(OUT/'vesper-egg-plates.fbx'),use_selection=True,add_leaf_bones=False,axis_forward='-Z',axis_up='Y',use_custom_props=True)
(OUT/'egg-manifest.json').write_text(json.dumps({'columns':COLS,'rows':ROWS,'height':H,'radius':R,'layerPitch':PITCH,'templates':metadata},indent=2))

import bpy,bmesh,math,json
from mathutils import Vector
from pathlib import Path
out=OUT
original=[bpy.data.objects[f'L{li}_R{row:02d}'] for li in range(1,4) for row in range(ROWS)]
for o in bpy.data.objects:o.hide_render=True
pieces=[];manifest=[]
for source in original:
 row=int(source.name[-2:]);phi=(row+.5)*math.pi/ROWS
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
     phi=math.acos(max(-1,min(1,1-2*v.z/H)));theta=math.atan2(v.y,v.x)
     dz=(H*.5)*math.sin(phi);dr=R*(math.cos(phi)*(1+.18*math.cos(phi))-.18*math.sin(phi)**2)
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

bpy.ops.object.select_all(action='DESELECT')
for o in templates+pieces: o.select_set(True)
bpy.ops.export_scene.fbx(filepath=str(OUT/'VesperExpansionV3.fbx'),use_selection=True,add_leaf_bones=False,axis_forward='-Z',axis_up='Y')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'VesperExpansionV3.blend'))
print('EXPANSION_READY',len(templates),len(pieces),flush=True)
