"""Inspect each supplied PBR FBX without changing source geometry or images."""
import bpy,json,hashlib
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[3];OUT=ROOT/'Backups/CreatureBatchTimer_20261111'
for species in ['frost-spirit-mammoth','volcanic-sabertooth','fossil-tortoise']:
 SOURCE=OUT/'source-original'/species;DEST=OUT/species;DEST.mkdir(exist_ok=True)
 bpy.ops.wm.read_factory_settings(use_empty=True);bpy.ops.import_scene.fbx(filepath=str(SOURCE/'base_basic_pbr.fbx'))
 for im in bpy.data.images:
  p=SOURCE/Path(im.filepath.replace('\\','/')).name
  if p.exists():im.filepath=str(p);im.reload()
 meshes=[o for o in bpy.context.scene.objects if o.type=='MESH'];report=[]
 for o in meshes:
  vs=[o.matrix_world@v.co for v in o.data.vertices]
  report.append(dict(name=o.name,vertices=len(vs),triangles=sum(len(p.vertices)-2 for p in o.data.polygons),low=[min(v[i] for v in vs)for i in range(3)],high=[max(v[i]for v in vs)for i in range(3)],uvs=[x.name for x in o.data.uv_layers]))
 mats=[dict(name=m.name,nodes=[dict(type=n.type,image=n.image.filepath if n.type=='TEX_IMAGE' and n.image else None)for n in m.node_tree.nodes],links=[(l.from_node.name,l.from_socket.name,l.to_node.name,l.to_socket.name)for l in m.node_tree.links])for m in bpy.data.materials if m.use_nodes]
 (DEST/'inspection.json').write_text(json.dumps(dict(source=species,files={p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in SOURCE.iterdir()if p.is_file()},meshes=report,materials=mats,rigs=[o.name for o in bpy.context.scene.objects if o.type=='ARMATURE']),indent=2))
 scene=bpy.context.scene;vs=[o.matrix_world@v.co for o in meshes for v in o.data.vertices];lo=Vector([min(v[i]for v in vs)for i in range(3)]);hi=Vector([max(v[i]for v in vs)for i in range(3)]);center=(lo+hi)/2;extent=max(hi-lo)
 scene.render.engine='CYCLES';scene.cycles.samples=20;scene.world=bpy.data.worlds.new('Inspection');scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.25,.25,.25,1)
 for delta,power in [((2,-3,4),500),((-3,-1,2),350),((1,3,3),650)]:
  bpy.ops.object.light_add(type='AREA',location=center+Vector(delta)*extent);l=bpy.context.object;l.data.energy=power*extent**2;l.data.size=extent*3;l.rotation_euler=(center-l.location).to_track_quat('-Z','Y').to_euler()
 bpy.ops.object.camera_add(location=center+Vector((2,-4,2))*extent);cam=bpy.context.object;cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=extent*1.4;scene.camera=cam
 scene.render.resolution_x=900;scene.render.resolution_y=750;scene.render.resolution_percentage=100;scene.render.film_transparent=True;scene.render.filepath=str(DEST/'source-render.png');bpy.ops.render.render(write_still=True)
 bpy.ops.wm.save_as_mainfile(filepath=str(DEST/'inspected.blend'))
 print(species,json.dumps(report))
