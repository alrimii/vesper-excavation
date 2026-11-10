import bpy
from pathlib import Path
root=Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(root/'living-lab-assets.blend'))
bpy.ops.object.select_all(action='DESELECT')
for o in bpy.data.objects:
 if o.type=='MESH': o.hide_render=False;o.hide_set(False);o.select_set(True)
bpy.ops.export_scene.fbx(filepath=str(root/'exports/living-lab-assets.fbx'),use_selection=True,object_types={'MESH'},apply_unit_scale=True,bake_space_transform=True,axis_forward='-Z',axis_up='Y',path_mode='AUTO',use_mesh_modifiers=True)
