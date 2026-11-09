"""Original smooth, watertight shell plates. Blender 4.5; no downloaded assets."""
import bpy, math, json
from mathutils import Vector
from pathlib import Path
OUT=Path(r'C:\Users\BOSS\Desktop\egg\src\models')
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
COLS,ROWS,H,R,PITCH=40,24,68,24,.48
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
            a=offsets[side];b=offsets[(side+1)%6];sub=5
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
# Preview intact egg and a deliberate excavation window. Linked geometry matches export.
for o in templates:o.hide_render=True
for row in range(ROWS):
    for col in range(COLS):
        angle=(col+(row%2)*.5)*2*math.pi/COLS
        exposed=1 if 7<=row<=13 and 27<=col<=32 else 0
        if 9<=row<=11 and 29<=col<=30:exposed=2
        template=templates[row*3+exposed];o=template.copy();o.data=template.data;o.hide_render=False;o.name=f'Preview_{row}_{col}';o.rotation_euler.z=angle;bpy.context.collection.objects.link(o)
bpy.ops.mesh.primitive_plane_add(size=1000);floor=bpy.context.object;floor.name='Preview floor';floor.data.materials.append(mat('Backdrop',(.027,.045,.055),.75))
world=bpy.context.scene.world;world.use_nodes=True;world.node_tree.nodes['Background'].inputs[0].default_value=(.18,.23,.3,1);world.node_tree.nodes['Background'].inputs[1].default_value=.45
for name,pos,power,size,color in [('Key',(50,-65,100),140000,60,(1,.86,.67)),('Rim',(-55,25,80),180000,45,(.35,.8,1)),('Fill',(60,30,45),90000,40,(.75,.87,1))]:
    d=bpy.data.lights.new(name,'AREA');d.energy=power;d.shape='DISK';d.size=size;d.color=color;o=bpy.data.objects.new(name,d);bpy.context.collection.objects.link(o);o.location=pos;o.rotation_euler=(Vector((0,0,32))-o.location).to_track_quat('-Z','Y').to_euler()
d=bpy.data.cameras.new('Preview');cam=bpy.data.objects.new('Preview',d);bpy.context.collection.objects.link(cam);cam.location=(95,-145,85);cam.rotation_euler=(Vector((0,0,34))-cam.location).to_track_quat('-Z','Y').to_euler();d.type='ORTHO';d.ortho_scale=90
s=bpy.context.scene;s.camera=cam;s.render.engine='CYCLES';s.cycles.samples=24;s.cycles.use_denoising=True;s.render.resolution_x=1100;s.render.resolution_y=1100;s.render.resolution_percentage=100;s.render.image_settings.file_format='PNG';s.render.filepath=str(OUT/'egg-preview.png')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'vesper-egg.blend'))
bpy.ops.render.render(write_still=True)
print('VESPER_EGG_COMPLETE',flush=True)
