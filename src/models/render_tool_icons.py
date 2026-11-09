import bpy
from mathutils import Vector
from pathlib import Path
out=Path(r'C:\Users\BOSS\Desktop\egg\src\models')
s=bpy.context.scene;s.render.film_transparent=True;s.render.resolution_x=512;s.render.resolution_y=512;s.cycles.samples=24
for kind in ['Pickaxe','Bucket']:
 obj=bpy.data.objects['Vesper_'+kind]
 for o in bpy.data.objects:
  if o.type=='MESH':o.hide_render=o!=obj
 center=sum((obj.matrix_world@Vector(v) for v in obj.bound_box),Vector())/8
 s.camera.location=center+Vector((4,-8,3.7));s.camera.rotation_euler=(center-s.camera.location).to_track_quat('-Z','Y').to_euler();s.camera.data.ortho_scale=4.2 if kind=='Pickaxe' else 3.25
 s.render.filepath=str(out/(kind.lower()+'-icon.png'));bpy.ops.render.render(write_still=True)
print('TOOL_ICONS_READY')
