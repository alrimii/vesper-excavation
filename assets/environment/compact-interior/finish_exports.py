import bpy, json, math
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).parent
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'compact-interior-assets.blend'))
fossils=[o for o in bpy.context.scene.objects if o.name.startswith('FossilScan')]
bpy.ops.object.select_all(action='DESELECT')
for o in fossils:o.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(ROOT/'exports/FossilStudy.glb'),export_format='GLB',use_selection=True)
for name,objs in [('fossil',fossils),('microscope',[bpy.data.objects['Microscope']]),('charge',[bpy.data.objects['ChargeBundle']])]:
 for o in bpy.context.scene.objects:o.hide_render=o not in objs
 pts=[o.matrix_world@v.co for o in objs for v in o.data.vertices];lo=Vector([min(p[i] for p in pts) for i in range(3)]);hi=Vector([max(p[i] for p in pts) for i in range(3)]);mid=(lo+hi)/2;span=max(hi-lo)
 bpy.ops.object.camera_add(location=mid+Vector((1.2,-1.9,.65))*span);cam=bpy.context.object;cam.rotation_euler=(mid-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=span*1.5
 s=bpy.context.scene;s.camera=cam;s.render.engine='BLENDER_WORKBENCH';s.display.shading.light='STUDIO';s.display.shading.color_type='MATERIAL';s.display.shading.show_cavity=True;s.display.shading.show_shadows=True;s.display.shading.background_type='WORLD';s.world.color=(.16,.18,.2);s.render.resolution_x=1100;s.render.resolution_y=850;s.render.resolution_percentage=100;s.render.filepath=str(ROOT/f'adapted-{name}.png');bpy.ops.render.render(write_still=True);bpy.data.objects.remove(cam,do_unlink=True)
