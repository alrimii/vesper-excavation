"""Uniform fitting and exact-model icon. Source topology/UVs are not simplified."""
import bpy,json,math
from pathlib import Path
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[3];OUT=ROOT/'Backups/RodinCharge_20261111';UPLOAD=ROOT/'assets/environment/compact-interior/exports'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'source-inspected.blend'))
o=next(o for o in bpy.context.scene.objects if o.type=='MESH');original=o.matrix_world.copy()
# OBJ is Y-up locally. Use the imported world transform when measuring surfaces.
backs=[p for p in o.data.polygons if p.normal.z<-.995 and p.center.z<-.40 and .2<p.center.y<1.5]
assert backs
area=sum(p.area for p in backs);backLocal=sum((p.center*p.area for p in backs),Vector())/area
backWorld=original@backLocal
scale=.85;origin=Vector((.65,0,.60));transform=Matrix.Scale(scale,4)@Matrix.Diagonal(Vector((-1,-1,1,1)))@Matrix.Translation(-origin)
o.data.transform(transform@original);o.matrix_world=Matrix.Identity(4);o.name='RodinStickyCharge';o.data.name=o.name
def point(p):
 v=transform@Vector(p);return [v.x,v.z,-v.y]
screenWorld=(0,-.361,.96)
data=dict(sourceFile='base.obj',sourceTriangles=8620,finalTriangles=sum(len(p.vertices)-2 for p in o.data.polygons),vertices=len(o.data.vertices),meshCount=1,decimated=False,scale=scale,sourceGripOrigin=list(origin),backContact=point(backWorld),backFaceSource=list(backWorld),screenCenter=point(screenWorld),screenSize=[.46*scale,.30*scale,.005],screenFace='Front / -Z')
(Path(__file__).parent/'geometry.json').write_text(json.dumps(data,indent=2))
mat=o.data.materials[0]
for n in mat.node_tree.nodes:
 if n.type=='TEX_IMAGE':
  file={'texture_diffuse.png':'ChargeColor.png','texture_normal.png':'ChargeNormal.png','texture_metallic.png':'ChargeMetalness.png','texture_roughness.png':'ChargeRoughness.png'}[n.label]
  n.image=bpy.data.images.load(str(UPLOAD/file));n.image.colorspace_settings.name='sRGB' if n.label=='texture_diffuse.png' else 'Non-Color'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'RodinCharge-Game.blend'))
bpy.ops.object.select_all(action='DESELECT');o.select_set(True);o.data.materials.clear()
bpy.ops.export_scene.gltf(filepath=str(UPLOAD/'RodinCharge.glb'),export_format='GLB',use_selection=True,export_yup=True,export_tangents=True)
o.data.materials.append(mat)
scene=bpy.context.scene;vs=[o.matrix_world@v.co for v in o.data.vertices];lo=Vector([min(v[i]for v in vs)for i in range(3)]);hi=Vector([max(v[i]for v in vs)for i in range(3)]);center=(lo+hi)/2
cam=scene.camera;cam.location=center+Vector((-2,5,1.7));cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();bpy.context.view_layer.update();local=[cam.matrix_world.inverted()@v for v in vs];xl,xh=min(v.x for v in local),max(v.x for v in local);yl,yh=min(v.y for v in local),max(v.y for v in local);cam.location+=cam.matrix_world.to_quaternion()@Vector(((xl+xh)/2,(yl+yh)/2,0));cam.data.ortho_scale=max(xh-xl,yh-yl)*1.08
for l in [o for o in scene.objects if o.type=='LIGHT']:
 l.location=transform@l.location;l.data.energy*=scale**2;l.data.size*=scale;l.rotation_euler=(center-l.location).to_track_quat('-Z','Y').to_euler()
scene.render.resolution_x=768;scene.render.resolution_y=768;scene.cycles.samples=32;scene.render.filepath=str(UPLOAD/'RodinChargeIcon.png');bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'RodinCharge-Icon.blend'))
print(json.dumps(data))
