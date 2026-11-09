import bpy,bmesh
from mathutils import Vector
from pathlib import Path
out=Path(r'C:\Users\BOSS\Desktop\egg\src\models')
o=bpy.data.objects['Vesper_Pickaxe'];mesh=o.data
indices={i for i,m in enumerate(mesh.materials) if m.name=='Ground cutting edges'}
bm=bmesh.new();bm.from_mesh(mesh);faces=[f for f in bm.faces if f.material_index in indices];print('Removing overlapping tip faces:',len(faces));bmesh.ops.delete(bm,geom=faces,context='FACES');bm.to_mesh(mesh);bm.free();mesh.update()
o.location-=Vector((-2,0,2))
bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
bpy.ops.export_scene.fbx(filepath=str(out/'pickaxe-refined.fbx'),use_selection=True,add_leaf_bones=False,axis_forward='-Z',axis_up='Y')
bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(out/'pickaxe-refined.blend'))
