"""Read the supplied FBX; write inspection and reference renders only to private recovery."""
import bpy, json, hashlib
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'Backups/RodinCrystalTriceratops_20261111'
SOURCE=OUT/'source-original/rodin-crystal-triceratops-source/base_basic_pbr.fbx'
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=str(SOURCE))
meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
report=[]
for o in meshes:
    vs=[o.matrix_world@v.co for v in o.data.vertices]
    report.append(dict(name=o.name,vertices=len(vs),triangles=sum(len(p.vertices)-2 for p in o.data.polygons),low=[min(v[i] for v in vs) for i in range(3)],high=[max(v[i] for v in vs) for i in range(3)],matrix=[list(r) for r in o.matrix_world],uvs=[u.name for u in o.data.uv_layers]))
    # Reconnect supplied files after copying the source package.
for im in bpy.data.images:
    p=SOURCE.parent/Path(im.filepath.replace('\\','/')).name
    if p.exists():im.filepath=str(p);im.reload()
data=dict(files={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in SOURCE.parent.iterdir() if p.is_file()},meshes=report,materials=[dict(name=m.name,nodes=[dict(name=n.name,type=n.type,image=n.image.filepath if n.type=='TEX_IMAGE' and n.image else None) for n in m.node_tree.nodes],links=[(l.from_node.name,l.from_socket.name,l.to_node.name,l.to_socket.name) for l in m.node_tree.links]) for m in bpy.data.materials if m.use_nodes])
(OUT/'source-inspection.json').write_text(json.dumps(data,indent=2))
scene=bpy.context.scene
vs=[o.matrix_world@v.co for o in meshes for v in o.data.vertices]
lo=Vector([min(v[i] for v in vs) for i in range(3)]);hi=Vector([max(v[i] for v in vs) for i in range(3)]);center=(lo+hi)/2;extent=max(hi-lo)
scene.render.engine='CYCLES';scene.cycles.samples=24
scene.world=bpy.data.worlds.new('Inspection studio');scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.25,.25,.25,1)
for delta,power in [((2,-3,4),500),((-3,-1,2),350),((1,3,3),650)]:
    bpy.ops.object.light_add(type='AREA',location=center+Vector(delta)*extent);l=bpy.context.object;l.data.energy=power*extent**2;l.data.shape='DISK';l.data.size=extent*3;l.rotation_euler=(center-l.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=center+Vector((2,-4,2))*extent);cam=bpy.context.object;cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=extent*1.4;scene.camera=cam
scene.render.resolution_x=1000;scene.render.resolution_y=800;scene.render.resolution_percentage=100;scene.render.film_transparent=True
scene.render.filepath=str(OUT/'source-render.png');bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source-inspected.blend'))
print(json.dumps(report))

