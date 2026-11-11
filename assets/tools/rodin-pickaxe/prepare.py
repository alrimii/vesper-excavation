"""Selective reduction and material-preserving export of the owner's exact FBX."""
import bpy,json,math
from pathlib import Path
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'Backups/RodinPickaxe_20261111'
UPLOAD=ROOT/'assets/environment/compact-interior/exports'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'source-inspected.blend'))
scene=bpy.context.scene
meshes=[o for o in scene.objects if o.type=='MESH']
materials=sorted({m for o in meshes for m in o.data.materials if m},key=lambda m:m.name)
def points(objects): return [o.matrix_world @ v.co for o in objects for v in o.data.vertices]
vv=points(meshes)
lo=Vector(tuple(min(v[i] for v in vv) for i in range(3)));hi=Vector(tuple(max(v[i] for v in vv) for i in range(3)))
center=(lo+hi)/2
scene.render.engine='CYCLES';scene.cycles.samples=48
scene.world=bpy.data.worlds.new('Neutral studio');scene.world.use_nodes=True
scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.17,.20,.24,1)
for pos,power,size in [((2,-4,5),550,4),((-3,-2,2),300,3),((1,3,3),650,3)]:
    bpy.ops.object.light_add(type='AREA',location=pos);l=bpy.context.object;l.data.energy=power;l.data.shape='DISK';l.data.size=size
    l.rotation_euler=(center-l.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=center+Vector((.35,-4,.3)));cam=bpy.context.object
cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=max(hi.z-lo.z,hi.x-lo.x)*1.13;scene.camera=cam
scene.render.resolution_x=900;scene.render.resolution_y=900;scene.render.resolution_percentage=100;scene.render.film_transparent=True
scene.view_settings.view_transform='AgX'
scene.render.filepath=str(OUT/'source-render.png')
if not (OUT/'source-render.png').exists():bpy.ops.render.render(write_still=True)
reductions=[]
for o in meshes:
    if o.name.startswith('Raised strap edge'):
        before=sum(len(f.vertices)-2 for f in o.data.polygons)
        bpy.context.view_layer.objects.active=o
        mod=o.modifiers.new('Selective dense grip edge reduction','DECIMATE');mod.ratio=.12
        bpy.ops.object.modifier_apply(modifier=mod.name)
        reductions.append({'name':o.name,'before':before,'after':sum(len(f.vertices)-2 for f in o.data.polygons)})
scene.render.filepath=str(OUT/'optimized-render.png')
if not (OUT/'optimized-render.png').exists():bpy.ops.render.render(write_still=True)
# Apply a uniform scale and hand origin only. Original silhouette and proportions remain intact.
height=3.85;scale=height/(hi.z-lo.z);origin=Vector((0,0,.65))
for o in meshes:
    world=o.matrix_world.copy();o.parent=None
    o.data.transform(Matrix.Scale(scale,4) @ Matrix.Translation(-origin) @ world)
    o.matrix_world=Matrix.Identity(4)
# Separate source material regions, then consolidate equal materials without changing geometry.
for o in list(scene.objects):
    if o.type!='MESH':continue
    if len(set(f.material_index for f in o.data.polygons))>1:
        bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
        bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.separate(type='MATERIAL');bpy.ops.object.mode_set(mode='OBJECT')
for o in scene.objects:
    if o.type!='MESH':continue
    used=set(f.material_index for f in o.data.polygons);assert len(used)==1
    mat=o.data.materials[next(iter(used))];o.data.materials.clear();o.data.materials.append(mat)
    for face in o.data.polygons:face.material_index=0
# Merge compatible objects into one material group; preserve every surviving vertex and normal.
parts=[]
for index,mat in enumerate(materials):
    group=[o for o in scene.objects if o.type=='MESH' and mat in list(o.data.materials)]
    assert all(len(o.data.materials)==1 for o in group),'Unexpected mixed-material source'
    bpy.ops.object.select_all(action='DESELECT')
    for o in group:o.select_set(True)
    bpy.context.view_layer.objects.active=group[0];bpy.ops.object.join();o=bpy.context.object
    o.name='Rodin_'+mat.name.replace(' ','_');o.data.name=o.name
    # Flat source materials need only a padded palette tile; source has no image textures.
    uv=o.data.uv_layers.active or o.data.uv_layers.new(name='MaterialPalette')
    for loop in uv.data:loop.uv=((index+.5)/8,.5)
    vv=points([o]);low=Vector(tuple(min(v[j] for v in vv) for j in range(3)));high=Vector(tuple(max(v[j] for v in vv) for j in range(3)))
    c=(low+high)/2;sz=high-low;n=mat.node_tree.nodes['Principled BSDF']
    parts.append({'name':o.name,'center':[c.x,c.z,-c.y],'size':[sz.x,sz.z,sz.y],'triangles':sum(len(f.vertices)-2 for f in o.data.polygons),'material':mat.name,'linearColor':list(n.inputs['Base Color'].default_value),'metallic':n.inputs['Metallic'].default_value,'roughness':n.inputs['Roughness'].default_value})
game_meshes=[o for o in scene.objects if o.type=='MESH']
crystals=[o for o in game_meshes if 'crystal' in o.name.lower()]
tip=min(points(crystals),key=lambda v:v.x)
data={'originalObjects':217,'originalTriangles':63928,'finalObjects':len(game_meshes),'finalTriangles':sum(p['triangles'] for p in parts),'reducedOnly':reductions,'scale':scale,'sourceGripOrigin':list(origin),'strikeTip':[tip.x,tip.z,-tip.y],'parts':parts}
(Path(__file__).parent/'geometry.json').write_text(json.dumps(data,indent=2),encoding='utf8')
bpy.ops.object.select_all(action='DESELECT')
for o in game_meshes:o.select_set(True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'RodinPickaxe-Game.blend'))
bpy.ops.export_scene.gltf(filepath=str(UPLOAD/'RodinPickaxe.glb'),export_format='GLB',use_selection=True,export_yup=True)
print(json.dumps(data,indent=2))
