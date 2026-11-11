"""Original Vesper props, executed in Blender through BlendRelay. Units map to studs."""
import bpy, math, json
from mathutils import Vector
from pathlib import Path
OUT=Path(r'C:\Users\BOSS\Desktop\egg\src\models')
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
for m in list(bpy.data.materials): bpy.data.materials.remove(m)
bpy.context.preferences.filepaths.save_version=0
def material(name,color,metal,rough):
    m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*color,1); p.inputs['Metallic'].default_value=metal; p.inputs['Roughness'].default_value=rough
    return m
steel=material('Brushed titanium',(.42,.52,.55),.85,.28)
edge=material('Ground cutting edges',(.73,.8,.8),.9,.22)
dark=material('Graphite rubber',(.025,.043,.05),.03,.76)
teal=material('Petrol enamel',(.035,.21,.22),.5,.32)
amber=material('Safety ochre',(.92,.43,.055),.35,.37)
inside=material('Bucket interior',(.14,.2,.21),.75,.38)
groups={'Bucket':[]}; group='Bucket'
def finish(o,name,mat,bevel=0,smooth=True):
    o.name=name; o.data.materials.append(mat); groups[group].append(o)
    if bevel:
        b=o.modifiers.new('Machined edge bevel','BEVEL'); b.width=bevel; b.segments=3
        b.affect='EDGES'
    if smooth:
        for p in o.data.polygons:p.use_smooth=True
        n=o.modifiers.new('Weighted surface normals','WEIGHTED_NORMAL'); n.keep_sharp=True
    return o
def cube(name,loc,scale,mat,bevel=.04):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.scale=scale;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    return finish(o,name,mat,bevel)
def cyl(name,a,b,r,mat,vertices=20):
    a,b=Vector(a),Vector(b); d=b-a
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=d.length,location=(a+b)/2)
    o=bpy.context.object;o.rotation_euler=d.to_track_quat('Z','Y').to_euler()
    return finish(o,name,mat,.015)
def torus(name,loc,major,minor,mat,rotation=None):
    bpy.ops.mesh.primitive_torus_add(major_segments=32,minor_segments=8,location=loc,major_radius=major,minor_radius=minor)
    o=bpy.context.object
    if rotation:o.rotation_euler=rotation
    return finish(o,name,mat)
def profile(name,points,thickness,mat):
    # XY extrusion of a silhouette drawn in XZ.
    vs=[(x,y,z) for y in (-thickness/2,thickness/2) for x,z in points]; n=len(points)
    fs=[tuple(reversed(range(n))),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(vs,[],fs);mesh.update();o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o)
    return finish(o,name,mat,.035)
# Phase 4 pickaxe uses the finished sourced mesh; its obsolete generator was removed.
# Bucket origin is the carrying grip, with contents below the hand.
group='Bucket'
segments=32; vs=[]; faces=[]; matids=[]
rings=[(.65,-2.27),(.69,-2.27),(.91,-.77),(.91,-.69),(.83,-.69),(.83,-.80),(.62,-2.16)]
for r,z in rings:
    for i in range(segments):a=i*2*math.pi/segments;vs.append((r*math.cos(a),r*math.sin(a),z))
for j in range(len(rings)-1):
    for i in range(segments):k=(i+1)%segments;faces.append((j*segments+i,j*segments+k,(j+1)*segments+k,(j+1)*segments+i));matids.append(1 if j>=4 else 0)
faces.append(tuple(reversed(range(segments))));matids.append(0)
faces.append(tuple(range(6*segments,7*segments)));matids.append(1)
mesh=bpy.data.meshes.new('Hollow tapered vessel');mesh.from_pydata(vs,[],faces);mesh.update();o=bpy.data.objects.new('Hollow tapered vessel',mesh);bpy.context.collection.objects.link(o);finish(o,o.name,steel,.015);o.data.materials.append(inside)
for p,idx in zip(o.data.polygons,matids):p.material_index=idx
torus('Rolled rim',(0,0,-.70),.87,.065,edge)
torus('Reinforced base',(0,0,-2.22),.67,.045,dark)
torus('Enamel lower stripe',(0,0,-1.90),.744,.025,teal)
torus('Enamel upper stripe',(0,0,-1.13),.853,.024,teal)
# A continuous arched bail, with a horizontal rubber carrying grip.
curve=bpy.data.curves.new('Carry bail curve','CURVE');curve.dimensions='3D';curve.resolution_u=2;curve.bevel_depth=.055;curve.bevel_resolution=3
sp=curve.splines.new('POLY');sp.points.add(32)
for i,p in enumerate(sp.points):a=i*math.pi/32;p.co=(.93*math.cos(a),0,-.86+.98*math.sin(a),1)
o=bpy.data.objects.new('Steel carry bail',curve);bpy.context.collection.objects.link(o);bpy.context.view_layer.objects.active=o;o.select_set(True);bpy.ops.object.convert(target='MESH');finish(bpy.context.object,'Steel carry bail',steel)
cyl('Carry grip',(-.26,0,.095),(.26,0,.095),.102,dark)
for x in [-.91,.91]:cyl('Pivot rivet',(x-.05,0,-.85),(x+.05,0,-.85),.115,amber,16)
cube('Bucket enamel badge',(0,-.848,-1.25),(.48,.045,.36),teal,.055)
cube('Badge bar',(0,-.88,-1.25),(.27,.025,.06),amber,.015)
# Export clean meshes with evaluated normals, UVs and per-face original colors.
report={}
for kind,objects in groups.items():
    bpy.ops.object.select_all(action='DESELECT')
    for obj in objects:
        obj.select_set(True);bpy.context.view_layer.objects.active=obj
        for mod in list(obj.modifiers):bpy.ops.object.modifier_apply(modifier=mod.name)
        obj.select_set(False)
    for obj in objects:obj.select_set(True)
    bpy.context.view_layer.objects.active=objects[0];bpy.ops.object.join();obj=bpy.context.object;obj.name='Vesper_'+kind
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.normals_make_consistent(inside=False);bpy.ops.uv.smart_project(island_margin=.02);bpy.ops.object.mode_set(mode='OBJECT')
    mesh=obj.data;mesh.calc_loop_triangles();matrix=obj.matrix_world
    def xyz(v):return [round(v.x,6),round(v.z,6),round(-v.y,6)]
    verts=[xyz(matrix@v.co) for v in mesh.vertices]
    triangles=[]
    for tri in mesh.loop_triangles:
        mat=mesh.materials[tri.material_index];color=list(mat.diffuse_color[:3])
        normals=[xyz(matrix.to_3x3()@mesh.corner_normals[i].vector) for i in tri.loops]
        uvs=[list(mesh.uv_layers.active.data[i].uv) for i in tri.loops]
        triangles.append({'v':list(tri.vertices),'n':normals,'uv':uvs,'c':color})
    data={'name':kind,'vertices':verts,'triangles':triangles}
    (OUT/(kind.lower()+'.mesh.json')).write_text(json.dumps(data,separators=(',',':')))
    bpy.ops.export_scene.fbx(filepath=str(OUT/(kind.lower()+'.fbx')),use_selection=True,add_leaf_bones=False,axis_forward='-Z',axis_up='Y')
    report[kind]={'vertices':len(verts),'triangles':len(triangles)}
    obj.location+=Vector((2.0,0,2.27))
# Presentation scene, kept separate from exported prop meshes.
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.05));floor=bpy.context.object;floor.name='Presentation floor';floor.data.materials.append(material('Backdrop',(.035,.05,.063),.05,.65))
world=bpy.context.scene.world;world.use_nodes=True;world.node_tree.nodes['Background'].inputs[0].default_value=(.16,.19,.23,1);world.node_tree.nodes['Background'].inputs[1].default_value=.35
def light(name,pos,power,size,color):
    d=bpy.data.lights.new(name,'AREA');d.energy=power;d.shape='DISK';d.size=size;d.color=color;o=bpy.data.objects.new(name,d);bpy.context.collection.objects.link(o);o.location=pos;o.rotation_euler=(Vector((0,0,1.5))-o.location).to_track_quat('-Z','Y').to_euler()
light('Softbox',(1,-5,8),1500,6,(.85,.93,1));light('Warm edge',(-5,2,6),1800,5,(1,.74,.42));light('Fill',(5,3,5),1400,4,(.45,.8,1))
d=bpy.data.cameras.new('Tool preview');cam=bpy.data.objects.new('Tool preview',d);bpy.context.collection.objects.link(cam);cam.location=(7,-12,7);cam.rotation_euler=(Vector((0,0,1.8))-cam.location).to_track_quat('-Z','Y').to_euler();d.type='ORTHO';d.ortho_scale=8.9
s=bpy.context.scene;s.camera=cam;s.render.engine='CYCLES';s.cycles.samples=32;s.cycles.use_denoising=True;s.render.resolution_x=1400;s.render.resolution_y=1000;s.render.resolution_percentage=100;s.render.image_settings.file_format='PNG';s.render.filepath=str(OUT/'tools-preview.png')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'vesper-tools.blend'))
bpy.ops.render.render(write_still=True)
result=report
