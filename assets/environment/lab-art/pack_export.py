"""Pack source base-color/alpha UVs into one 2048 atlas and export native-import FBX."""
import bpy,json,math
from pathlib import Path
R=Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(R/'lab-art-master.blend'))
images={};materials={};colors=[]
for o in bpy.data.objects:
 if o.type!='MESH':continue
 for m in o.data.materials:
  if not m or m.name in materials:continue
  node=next((n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED'),None) if m.use_nodes else None
  img=None
  if node and node.inputs['Base Color'].is_linked:
   # glTF includes a vertex-color multiplication between texture and Principled.
   img=next((n.image for n in m.node_tree.nodes if n.type=='TEX_IMAGE' and n.image and not n.image.filepath.endswith('_Normal.png')),None)
  if img:
   path=Path(bpy.path.abspath(img.filepath)).resolve().relative_to(R).as_posix();images.setdefault(path,len(images));materials[m.name]={'image':path}
  else:
   color=list(node.inputs['Base Color'].default_value if node else m.diffuse_color);colors.append(color);materials[m.name]={'color':len(colors)-1}
meta={'images':images,'materials':materials,'colors':colors}
(R/'atlas-layout.json').write_text(json.dumps(meta,indent=2))
# Atlas assembled by the adjacent plain-Python packing step before export.
if not (R/'exports/environment-atlas.png').exists():print('ATLAS_METADATA_READY');raise SystemExit(0)
image=bpy.data.images.load(str(R/'exports/environment-atlas.png'))
atlas=bpy.data.materials.new('LivingLabNatureAtlas');atlas.use_nodes=True
nodes=atlas.node_tree.nodes;principled=nodes.get('Principled BSDF');tex=nodes.new('ShaderNodeTexImage');tex.image=image
atlas.node_tree.links.new(tex.outputs['Color'],principled.inputs['Base Color']);atlas.node_tree.links.new(tex.outputs['Alpha'],principled.inputs['Alpha']);principled.inputs['Roughness'].default_value=.82
atlas.surface_render_method='DITHERED';atlas.use_backface_culling=False
uv_issues=[];palette_slot=len(images)
def tile_uv(slot,u,v):
 # 4-pixel inset prevents sampling an adjacent atlas tile at small mip levels.
 return ((slot%4*512+4+u*504)/2048,(3-slot//4)*.25+(4+v*504)/2048)
for o in bpy.data.objects:
 if o.type!='MESH':continue
 uv=o.data.uv_layers.active or o.data.uv_layers.new(name='UVMap')
 old=list(o.data.materials);bounds={}
 for p in o.data.polygons:
  key=p.material_index
  for li in p.loop_indices:
   u,v=uv.data[li].uv;b=bounds.setdefault(key,[u,v,u,v]);b[0]=min(b[0],u);b[1]=min(b[1],v);b[2]=max(b[2],u);b[3]=max(b[3],v)
 for p in o.data.polygons:
  m=old[p.material_index];info=materials[m.name]
  points=[o.data.vertices[o.data.loops[li].vertex_index].co for li in p.loop_indices]
  lowx=min(v.x for v in points);highx=max(v.x for v in points);lowy=min(v.y for v in points);highy=max(v.y for v in points)
  for li in p.loop_indices:
   if o.name=='PavingQuarter':
    co=o.data.vertices[o.data.loops[li].vertex_index].co
    uv.data[li].uv=tile_uv(11+int(m.name[-2:]),(co.x-lowx)/max(.01,highx-lowx),(co.y-lowy)/max(.01,highy-lowy))
   elif 'image'in info:
    u,v=uv.data[li].uv
    b=bounds[p.material_index]
    if b[0]<-.001 or b[2]>1.001:u=(u-b[0])/max(.001,b[2]-b[0]);uv_issues.append(o.name)
    if b[1]<-.001 or b[3]>1.001:v=(v-b[1])/max(.001,b[3]-b[1]);uv_issues.append(o.name)
    uv.data[li].uv=tile_uv(images[info['image']],min(1,max(0,u)),min(1,max(0,v)))
   else:
    ci=info['color'];uv.data[li].uv=tile_uv(palette_slot,(ci%8+.5)/8,(ci//8+.5)/8)
  p.material_index=0
 o.data.materials.clear();o.data.materials.append(atlas)
 # Native importer maps Blender +Y into Roblox +Z. Bounds are retained in geometry.json.
 o.select_set(True)
bpy.ops.wm.save_as_mainfile(filepath=str(R/'lab-art-runtime.blend'),compress=True)
bpy.ops.export_scene.fbx(filepath=str(R/'exports/lab-art.fbx'),use_selection=False,object_types={'MESH'},apply_unit_scale=True,bake_space_transform=True,axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True,use_mesh_modifiers=True)
bpy.ops.object.select_all(action='DESELECT');bpy.data.objects['PavingQuarter'].select_set(True)
bpy.ops.export_scene.fbx(filepath=str(R/'exports/paving.fbx'),use_selection=True,object_types={'MESH'},apply_unit_scale=True,bake_space_transform=True,axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
print('ATLAS_EXPORT_COMPLETE',len(images),'images',len(colors),'colors','REPEATED_UV_NORMALIZED',sorted(set(uv_issues)))
