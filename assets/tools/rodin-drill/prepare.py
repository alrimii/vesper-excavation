"""Split only the shaft for its existing motor; preserve source surfaces and UVs."""
import bpy,bmesh,json,math,shutil
from pathlib import Path
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[3];OUT=ROOT/'Backups/RodinDrill_20261111';UPLOAD=ROOT/'assets/environment/compact-interior/exports'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'source-inspected.blend'))
source=next(o for o in bpy.context.scene.objects if o.type=='MESH')
cut=-.405;scale=1.85;origin=Vector((-.18,.825,.4))
# Roblox mapping after the single assembly yaw: (-x, z, y). In Blender export
# coordinates use (-x,-y,z), then glTF's standard Y-up conversion.
transform=Matrix.Scale(scale,4)@Matrix.Diagonal(Vector((-1,-1,1,1)))@Matrix.Translation(-origin)
parts=[]
for name,front in [('RodinDrillHousing',False),('RodinDrillBit',True)]:
    o=source.copy();o.data=source.data.copy();bpy.context.collection.objects.link(o);o.name=name;o.data.name=name
    bm=bmesh.new();bm.from_mesh(o.data)
    bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.000001,plane_co=(0,cut,0),plane_no=(0,1,0),clear_outer=front,clear_inner=not front)
    # The circular split is internal to the source collar; no visible replacement geometry.
    bmesh.ops.triangulate(bm,faces=list(bm.faces));bm.to_mesh(o.data);bm.free()
    o.data.transform(transform@source.matrix_world);o.matrix_world=Matrix.Identity(4)
    parts.append(dict(name=name,triangles=len(o.data.polygons),vertices=len(o.data.vertices)))
bpy.data.objects.remove(source,do_unlink=True)
scene=bpy.context.scene
# Exact source PBR texture links, with non-color scalar and tangent normal data.
for mat in {m for o in scene.objects if o.type=='MESH' for m in o.data.materials}:
    for n in mat.node_tree.nodes:
        if n.type=='TEX_IMAGE' and n.image and 'diffuse' not in n.image.filepath:n.image.colorspace_settings.name='Non-Color'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'RodinDrill-Game.blend'))
meshes=[o for o in scene.objects if o.type=='MESH']
bpy.ops.object.select_all(action='DESELECT')
for o in meshes:o.select_set(True)
# Geometry-only upload avoids importer-created duplicate texture assets; attach
# explicit separately uploaded maps in Studio, using the preserved source UVs.
materials=[list(o.data.materials) for o in meshes]
for o in meshes:o.data.materials.clear()
bpy.ops.export_scene.gltf(filepath=str(UPLOAD/'RodinDrill.glb'),export_format='GLB',use_selection=True,export_yup=True,export_tangents=True)
for o,ms in zip(meshes,materials):
    for m in ms:o.data.materials.append(m)
def map_point(p):
    v=transform@Vector(p);return [v.x,v.z,-v.y]
data=dict(sourceTriangles=9506,finalTriangles=sum(p['triangles'] for p in parts),decimated=False,splitPlaneSourceY=cut,scale=scale,sourceRearGrip=list(origin),supportGrip=map_point((.25,-.23,.20)),shaftOrigin=map_point((-.18,cut,.455)),workingTip=map_point((-.18,-.949089,.455)),parts=parts)
(Path(__file__).parent/'geometry.json').write_text(json.dumps(data,indent=2))
# A tightly framed render of this same assembled asset becomes the drill icon.
vs=[o.matrix_world@v.co for o in meshes for v in o.data.vertices];lo=Vector([min(v[i] for v in vs) for i in range(3)]);hi=Vector([max(v[i] for v in vs) for i in range(3)]);center=(lo+hi)/2
cam=scene.camera;cam.location=center+Vector((-3,5,2.5));cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();bpy.context.view_layer.update()
local=[cam.matrix_world.inverted()@v for v in vs];xl,xh=min(v.x for v in local),max(v.x for v in local);yl,yh=min(v.y for v in local),max(v.y for v in local)
cam.location+=cam.matrix_world.to_quaternion()@Vector(((xl+xh)/2,(yl+yh)/2,0));cam.data.ortho_scale=max(xh-xl,yh-yl)*1.08
for l in [o for o in scene.objects if o.type=='LIGHT']:
    l.location=transform@l.location;l.data.energy*=scale**2;l.data.size*=scale;l.rotation_euler=(center-l.location).to_track_quat('-Z','Y').to_euler()
scene.render.resolution_x=768;scene.render.resolution_y=768;scene.cycles.samples=48;scene.render.filepath=str(UPLOAD/'RodinDrillIcon.png');bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'RodinDrill-Icon.blend'))
for a,b in [('texture_diffuse.png','DrillColor.png'),('texture_metallic.png','DrillMetalness.png'),('texture_roughness.png','DrillRoughness.png'),('texture_normal.png','DrillNormal.png')]:shutil.copy2(OUT/'source-original'/a,UPLOAD/b)
print(json.dumps(data))
