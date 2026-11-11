"""Fit the complete Baziliq PK-001 sample. No mesh reconstruction or simplification."""
from pathlib import Path
import bpy, json, math
from mathutils import Vector, Matrix
ROOT = Path(__file__).resolve().parents[3]
PRIVATE = ROOT / 'Backups/IdentitySlice_20261111'
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(PRIVATE / 'baziliq-sample/Models/PK-001.glb'))
meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
points = [o.matrix_world @ v.co for o in meshes for v in o.data.vertices]
lo = Vector(tuple(min(v[i] for v in points) for i in range(3)))
hi = Vector(tuple(max(v[i] for v in points) for i in range(3)))
scale = 3.85 / (hi.z-lo.z)
origin = Vector(((lo.x+hi.x)/2, (lo.y+hi.y)/2, lo.z+(hi.z-lo.z)*.34))
records=[]
primitives=[]
def srgb(c): return 12.92*c if c<=.0031308 else 1.055*c**(1/2.4)-.055
for i,o in enumerate(meshes):
    matrix=o.matrix_world.copy();o.parent=None
    o.data.transform(Matrix.Scale(scale,4) @ Matrix.Translation(-origin) @ matrix)
    o.matrix_world=Matrix.Identity(4)
    o.name='Authored_'+str(i)+'_'+o.name.replace('.','_')
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True);bpy.context.view_layer.objects.active=o
    bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY',center='BOUNDS')
    vv=[o.matrix_world @ v.co for v in o.data.vertices]
    low=Vector(tuple(min(v[j] for v in vv) for j in range(3)))
    high=Vector(tuple(max(v[j] for v in vv) for j in range(3)))
    c=(low+high)/2;sz=high-low
    records.append({'name':o.name,'center':[c.x,c.z,-c.y],'size':[sz.x,sz.z,sz.y]})
    for index,mi in enumerate(sorted(set(f.material_index for f in o.data.polygons))):
        vertices=set(v for f in o.data.polygons if f.material_index==mi for v in f.vertices)
        pp=[o.matrix_world @ o.data.vertices[v].co for v in vertices]
        low=Vector(tuple(min(v[j] for v in pp) for j in range(3)));high=Vector(tuple(max(v[j] for v in pp) for j in range(3)))
        c=(low+high)/2;sz=high-low;m=o.data.materials[mi]
        color=m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value
        primitives.append({'name':o.data.name+(str(index+1) if index else ''),'center':[c.x,c.z,-c.y],'size':[sz.x,sz.z,sz.y],'material':m.name,'color':[round(srgb(v)*255) for v in color[:3]]})
points=[o.matrix_world @ v.co for o in meshes for v in o.data.vertices]
tip=min(points,key=lambda v:v.x)
out=ROOT/'assets/tools/identity'
(out/'geometry.json').write_text(json.dumps({'parts':records,'primitives':primitives,'strikeTip':[tip.x,tip.z,-tip.y],'triangles':sum(len(p.vertices)-2 for o in meshes for p in o.data.polygons)},indent=2))
bpy.ops.object.select_all(action='DESELECT')
for o in meshes:o.select_set(True)
bpy.ops.wm.save_as_mainfile(filepath=str(PRIVATE/'AuthoredPickaxe.blend'))
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/environment/compact-interior/exports/AuthoredPickaxe.glb'),export_format='GLB',use_selection=True,export_yup=True)
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=32
world=bpy.data.worlds.new('Studio');scene.world=world;world.use_nodes=True;world.node_tree.nodes['Background'].inputs[0].default_value=(.12,.16,.22,1)
for pos,power,size in [((1,-4,6),700,5),((-4,-1,3),450,4),((2,4,4),650,3)]:
    bpy.ops.object.light_add(type='AREA',location=pos);l=bpy.context.object;l.data.energy=power;l.data.shape='DISK';l.data.size=size;l.rotation_euler=(Vector((0,0,.6))-l.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(1.4,-7,2.6));cam=bpy.context.object;cam.rotation_euler=(Vector((0,0,.65))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=4.8;scene.camera=cam
scene.render.resolution_x=800;scene.render.resolution_y=800;scene.render.resolution_percentage=100;scene.render.film_transparent=True
scene.render.filepath=str(PRIVATE/'authored-pickaxe.png');bpy.ops.render.render(write_still=True)
