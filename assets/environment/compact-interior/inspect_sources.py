"""Inspect downloaded source geometry in a fresh background Blender process."""
import bpy, json, math
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).parent
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
report={}
for name in ['triceratops','microscope','charge']:
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
 bpy.ops.import_scene.gltf(filepath=str(ROOT/'source'/f'{name}.glb'))
 objects=[o for o in bpy.context.scene.objects if o.type=='MESH']
 points=[o.matrix_world@v.co for o in objects for v in o.data.vertices]
 lo=Vector([min(p[i] for p in points) for i in range(3)]);hi=Vector([max(p[i] for p in points) for i in range(3)])
 report[name]={'bounds':[list(lo),list(hi)],'meshes':[{'name':o.name,'vertices':len(o.data.vertices),'triangles':sum(len(p.vertices)-2 for p in o.data.polygons),'materials':[m.name if m else None for m in o.data.materials]} for o in objects]}
 center=(lo+hi)/2; span=max(hi-lo)
 bpy.ops.object.camera_add(location=center+Vector((1.3,-1.7,0.85))*span)
 cam=bpy.context.object;cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=span*1.4;bpy.context.scene.camera=cam
 scene=bpy.context.scene;scene.render.engine='BLENDER_WORKBENCH';scene.display.shading.light='STUDIO';scene.display.shading.color_type='MATERIAL';scene.display.shading.show_shadows=True;scene.display.shading.show_cavity=True;scene.display.shading.background_type='WORLD';scene.world.color=(0.13,0.15,0.17)
 scene.render.resolution_x=1100;scene.render.resolution_y=800;scene.render.resolution_percentage=100;scene.render.image_settings.file_format='PNG';scene.render.filepath=str(ROOT/f'source-{name}.png')
 bpy.ops.render.render(write_still=True)
(ROOT/'source-inspection.json').write_text(json.dumps(report,indent=2),encoding='utf8')
