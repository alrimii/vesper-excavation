"""Faithful static creature fit, geometry-only upload and exact-model icon."""
import bpy,json,math,shutil
from pathlib import Path
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'Backups/RodinCrystalTriceratops_20261111'
UPLOAD=ROOT/'assets/environment/compact-interior/exports'
SOURCE=OUT/'source-original/rodin-crystal-triceratops-source'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'source-inspected.blend'))
meshes=[o for o in bpy.context.scene.objects if o.type=='MESH'];assert len(meshes)==1
o=meshes[0];vs=[o.matrix_world@v.co for v in o.data.vertices]
lo=Vector([min(v[i] for v in vs) for i in range(3)]);hi=Vector([max(v[i] for v in vs) for i in range(3)])
origin=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z));scale=4.8/(hi.z-lo.z)
transform=Matrix.Scale(scale,4)@Matrix.Rotation(math.pi,4,'Z')@Matrix.Translation(-origin)
o.data.transform(transform@o.matrix_world);o.matrix_world=Matrix.Identity(4)
o.name='CrystalTriceratops';o.data.name=o.name
for mat in o.data.materials:
 for n in mat.node_tree.nodes:
  if n.type=='TEX_IMAGE' and n.image:
   n.image.colorspace_settings.name='sRGB' if 'diffuse' in n.image.filepath else 'Non-Color'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'CrystalTriceratops-Game.blend'))
materials=list(o.data.materials);o.data.materials.clear()
bpy.ops.object.select_all(action='DESELECT');o.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(UPLOAD/'CrystalTriceratops.glb'),export_format='GLB',use_selection=True,export_yup=True,export_tangents=True)
for m in materials:o.data.materials.append(m)
for original,target in [('texture_diffuse.png','TriceratopsColor.png'),('texture_metallic.png','TriceratopsMetalness.png'),('texture_roughness.png','TriceratopsRoughness.png'),('texture_normal.png','TriceratopsNormal.png')]:
 shutil.copy2(SOURCE/original,UPLOAD/target)
vs=[v.co for v in o.data.vertices];lo=Vector([min(v[i] for v in vs) for i in range(3)]);hi=Vector([max(v[i] for v in vs) for i in range(3)]);center=(lo+hi)/2
scene=bpy.context.scene;cam=scene.camera;cam.location=center+Vector((.8,1.6,.8))*8
cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();bpy.context.view_layer.update()
local=[cam.matrix_world.inverted()@v for v in vs];xl,xh=min(v.x for v in local),max(v.x for v in local);yl,yh=min(v.y for v in local),max(v.y for v in local)
cam.location+=cam.matrix_world.to_quaternion()@Vector(((xl+xh)/2,(yl+yh)/2,0));cam.data.ortho_scale=max(xh-xl,yh-yl)*1.12
for light in [x for x in scene.objects if x.type=='LIGHT']:
 light.location=transform@light.location;light.data.energy*=scale**2;light.data.size*=scale;light.rotation_euler=(center-light.location).to_track_quat('-Z','Y').to_euler()
scene.render.resolution_x=768;scene.render.resolution_y=768;scene.cycles.samples=32;scene.render.filepath=str(UPLOAD/'CrystalTriceratopsIcon.png');bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'CrystalTriceratops-Icon.blend'))
data=dict(sourceFile='base_basic_pbr.fbx',meshCount=1,vertices=len(o.data.vertices),triangles=sum(len(p.vertices)-2 for p in o.data.polygons),decimated=False,rigged=False,uniformScale=scale,sourceOrigin=list(origin),robloxSize=[hi.x-lo.x,hi.z-lo.z,hi.y-lo.y],pivot='floor center',forward='-Z',textureModifications=False)
(Path(__file__).parent/'geometry.json').write_text(json.dumps(data,indent=2));print(json.dumps(data))
