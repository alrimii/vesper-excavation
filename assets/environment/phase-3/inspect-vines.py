"""Inspect downloaded meshes privately; source preview is not game evidence."""
import bpy, json, math
from pathlib import Path
from mathutils import Vector
ROOT=Path(r'C:/Users/BOSS/Desktop/egg')
PRIVATE=ROOT/'Backups/InteriorPhase3_20261111/source'
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
report={}
for i,name in enumerate(['ivy-vine','hanging-vine']):
    bpy.ops.import_scene.gltf(filepath=str(PRIVATE/(name+'.glb')))
    meshes=[o for o in bpy.context.selected_objects if o.type=='MESH']
    for o in meshes:
        o.matrix_world.translation.x+=i*1.0
    points=[o.matrix_world@v.co for o in meshes for v in o.data.vertices]
    lo=Vector(tuple(min(v[k]for v in points)for k in range(3)))
    hi=Vector(tuple(max(v[k]for v in points)for k in range(3)))
    report[name]={'bounds':[list(lo),list(hi)],'meshes':[{'name':o.name,'vertices':len(o.data.vertices),'triangles':sum(len(p.vertices)-2 for p in o.data.polygons)}for o in meshes]}
    print(name,report[name])
world=bpy.context.scene.world;world.use_nodes=True;world.node_tree.nodes['Background'].inputs[0].default_value=(.16,.18,.19,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.7
bpy.ops.object.light_add(type='AREA',location=(1,-3,4));bpy.context.object.data.energy=300;bpy.context.object.data.shape='DISK';bpy.context.object.data.size=4
bpy.ops.object.camera_add(location=(1,-3.4,1.7));cam=bpy.context.object;cam.rotation_euler=(Vector((.5,0,.55))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=2.1
s=bpy.context.scene;s.camera=cam;s.render.engine='CYCLES';s.cycles.samples=24;s.render.resolution_x=1200;s.render.resolution_y=900;s.render.resolution_percentage=100;s.render.filepath=str(PRIVATE/'actual-assets.png')
(PRIVATE/'inspection.json').write_text(json.dumps(report,indent=2))
bpy.ops.wm.save_as_mainfile(filepath=str(PRIVATE/'inspection.blend'))
bpy.ops.render.render(write_still=True)
