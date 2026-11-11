"""Render the exact game mesh/materials at a three-quarter angle with 4% padding."""
from pathlib import Path
import bpy,math
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'Backups/RodinPickaxe_20261111'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'RodinPickaxe-Game.blend'))
scene=bpy.context.scene
meshes=[o for o in scene.objects if o.type=='MESH']
points=[o.matrix_world @ v.co for o in meshes for v in o.data.vertices]
lo=Vector(tuple(min(v[i] for v in points) for i in range(3)));hi=Vector(tuple(max(v[i] for v in points) for i in range(3)));center=(lo+hi)/2
cam=scene.camera;cam.location=center+Vector((2.7,-8,2.2));cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler()
bpy.context.view_layer.update()
local=[cam.matrix_world.inverted()@v for v in points]
xl,xh=min(v.x for v in local),max(v.x for v in local);yl,yh=min(v.y for v in local),max(v.y for v in local)
cam.location+=cam.matrix_world.to_quaternion() @ Vector(((xl+xh)/2,(yl+yh)/2,0))
cam.data.ortho_scale=max(xh-xl,yh-yl)*1.08
for l in [o for o in scene.objects if o.type=='LIGHT']:
    l.location*=2;l.data.energy*=3
    l.rotation_euler=(center-l.location).to_track_quat('-Z','Y').to_euler()
scene.render.resolution_x=768;scene.render.resolution_y=768;scene.render.resolution_percentage=100
scene.cycles.samples=64;scene.render.film_transparent=True
scene.render.filepath=str(ROOT/'assets/environment/compact-interior/exports/RodinPickaxeIcon.png')
bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'RodinPickaxe-Icon.blend'))
