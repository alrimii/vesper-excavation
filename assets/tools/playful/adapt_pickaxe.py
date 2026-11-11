"""Adapt Kay Lousberg's finished CC0 pickaxe: proportions and palette only."""
import bpy,json,math
from pathlib import Path
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[3]
P=ROOT/'Backups/PlayfulInterface_20261111'
OUT=Path(__file__).parent
bpy.ops.wm.open_mainfile(filepath=str(P/'kaykit-inspected.blend'))
o=bpy.data.objects['pickaxe'];o.data.transform(o.matrix_world);o.matrix_world=Matrix.Identity(4)
groups=json.loads((P/'pick-islands.json').read_text())
palette=[('AquaHead',(0.025,0.62,0.78,1)),('GoldenSocket',(1,.51,.035,1)),('PlumShaft',(.13,.035,.26,1)),('VioletWrap',(.42,.09,.61,1)),('GoldenCaps',(1,.61,.07,1))]
o.data.materials.clear()
for name,color in palette:
 m=bpy.data.materials.new(name);m.diffuse_color=color;m.use_nodes=True
 bs=m.node_tree.nodes['Principled BSDF'];bs.inputs['Base Color'].default_value=color;bs.inputs['Roughness'].default_value=.36;bs.inputs['Metallic'].default_value=.15
 o.data.materials.append(m)
vertexm={}
for i,g in enumerate(groups):
 mat=0 if 16<=i<=31 else 1 if i>=32 else 3 if 5<=i<=9 else 4 if i in [0,1,3,4] or 10<=i<=15 else 2
 for vi in g['vertices']:
  v=o.data.vertices[vi]
  if mat in [0,1]:v.co.y*=1.8;v.co.z=.99+(v.co.z-.99)*1.4
  v.co*=2.7
  vertexm[vi]=mat
for f in o.data.polygons:f.material_index=vertexm[f.vertices[0]]
bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o
bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.separate(type='MATERIAL');bpy.ops.object.mode_set(mode='OBJECT')
meshes=[x for x in bpy.context.scene.objects if x.type=='MESH']
records=[]
for x in meshes:
 name=x.data.materials[x.data.polygons[0].material_index].name
 x.name=name;x.data.name=name
 bpy.context.view_layer.objects.active=x;bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY',center='BOUNDS')
 vv=[x.matrix_world@v.co for v in x.data.vertices];lo=Vector(tuple(min(v[i] for v in vv) for i in range(3)));hi=Vector(tuple(max(v[i] for v in vv) for i in range(3)));c=(lo+hi)/2;sz=hi-lo
 records.append({'name':name,'center':[c.x,c.z,-c.y],'size':[sz.x,sz.z,sz.y],'linearColor':list(x.data.materials[x.data.polygons[0].material_index].diffuse_color)})
head=next(x for x in meshes if x.name=='AquaHead');vv=[head.matrix_world@v.co for v in head.data.vertices];tip=min(vv,key=lambda v:v.x)
(OUT/'geometry.json').write_text(json.dumps({'parts':records,'strikeTip':[tip.x,tip.z,-tip.y]},indent=2))
bpy.ops.object.select_all(action='DESELECT')
for x in meshes:x.select_set(True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'TreasurePickaxe.blend'))
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/environment/compact-interior/exports/TreasurePickaxe.glb'),export_format='GLB',use_selection=True,export_yup=True)
scene=bpy.context.scene;center=Vector((0,0,1.25));cam=scene.camera;cam.location=center+Vector((2,-7,2));cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.ortho_scale=4.8
scene.render.filepath=str(P/'references/treasure-pickaxe.png');bpy.ops.render.render(write_still=True)
