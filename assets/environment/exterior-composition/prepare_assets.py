import bpy,bmesh,json,math
from pathlib import Path
from mathutils import Vector
ROOT=Path('C:/Users/BOSS/Desktop/egg');P=ROOT/'Backups/ExteriorComposition_20261110';OUT=P/'exports';OUT.mkdir(exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
records=[]
def prepare(name,path,target,width):
 before=set(bpy.data.objects);bpy.ops.import_scene.gltf(filepath=str(path));objs=[o for o in set(bpy.data.objects)-before if o.type=='MESH'];bpy.ops.object.select_all(action='DESELECT')
 for o in objs:o.select_set(True)
 bpy.context.view_layer.objects.active=objs[0];bpy.ops.object.join();o=bpy.context.object;o.name=name;bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
 verts=[o.matrix_world@v.co for v in o.data.vertices];lo=Vector([min(v[k]for v in verts)for k in range(3)]);hi=Vector([max(v[k]for v in verts)for k in range(3)]);center=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z));scale=width/(hi.x-lo.x)
 for v in o.data.vertices:v.co=(o.matrix_world@v.co-center)*scale
 o.location=(0,0,0);o.rotation_euler=(0,0,0);o.scale=(1,1,1)
 oldtri=sum(len(f.vertices)-2 for f in o.data.polygons);m=o.modifiers.new('ScenicLOD','DECIMATE');m.ratio=min(1,target/oldtri);bpy.ops.object.modifier_apply(modifier=m.name)
 for f in o.data.polygons:f.use_smooth=True
 # Keep supplied UVs and base-color images, suppress normal microdetail for distant stylization.
 for mat in o.data.materials:
  if not mat or not mat.use_nodes:continue
  nodes=mat.node_tree.nodes;bs=nodes.get('Principled BSDF')
  if not bs:continue
  colorlinks=list(bs.inputs['Base Color'].links)
  im=colorlinks[0].from_node.image if colorlinks and colorlinks[0].from_node.type=='TEX_IMAGE' else None
  if im:
   im.scale(1024,1024);im.filepath_raw=str(OUT/(name+'_'+mat.name.replace(' ','_')+'_color.png'));im.file_format='PNG';im.save()
  for link in list(bs.inputs['Normal'].links):mat.node_tree.links.remove(link)
  bs.inputs['Roughness'].default_value=.88
  for link in list(bs.inputs['Roughness'].links):mat.node_tree.links.remove(link)
  bs.inputs['Metallic'].default_value=0
 lo=Vector([min(v.co[k]for v in o.data.vertices)for k in range(3)]);hi=Vector([max(v.co[k]for v in o.data.vertices)for k in range(3)])
 records.append({'name':name,'source':str(path.relative_to(ROOT)),'originalTriangles':oldtri,'triangles':sum(len(f.vertices)-2 for f in o.data.polygons),'size':[hi.x-lo.x,hi.z-lo.z,hi.y-lo.y],'center':[(hi.x+lo.x)/2,(hi.z+lo.z)/2,(hi.y+lo.y)/2]})
 o.location.x=len(records)*2000
 return o
prepare('AlpineRange',P/'source/mountain-range.glb',14000,1800)
prepare('StrataCliff',P/'source/mountainside/mountainside_1k.gltf',9000,200)
prepare('RockButtress',P/'source/rock_face_02/rock_face_02_1k.gltf',5000,130)
# A low connected ground apron only, not authored mountains. It stays below the lab floor.
def height(x,y):
 r=math.hypot(x,y);t=max(0,min(1,(r-400)/650));return -9+t*(10*math.sin(x/420)*math.cos(y/530)+9*math.sin(y/370)-5)
mat=bpy.data.materials.new('GroundSage');mat.diffuse_color=(.26,.32,.21,1);mat.use_nodes=True;mat.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=(.26,.32,.21,1)
for gx in range(-4,4):
 for gy in range(-4,4):
  verts=[];faces=[];n=8;cx=(gx+.5)*1500;cy=(gy+.5)*1500
  for j in range(n+1):
   for i in range(n+1):
    x=(i/n-.5)*1500;y=(j/n-.5)*1500;verts.append((x,y,height(x+cx,y+cy)))
  for j in range(n):
   for i in range(n):
    a=j*(n+1)+i;b=a+1;c=a+n+1;d=c+1;faces.extend([(a,b,c),(b,d,c)])
  name='Ground_%d_%d'%(gx+4,gy+4);mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update();ob=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(ob);mesh.materials.append(mat)
  for f in mesh.polygons:f.use_smooth=True
  low=min(v[2]for v in verts);high=max(v[2]for v in verts)
  records.append({'name':name,'source':'Original low relief ground only','triangles':len(faces),'size':[1500,high-low,1500],'center':[cx,(high+low)/2,cy]})
  ob.location=(cx,cy,0)
bpy.ops.wm.save_as_mainfile(filepath=str(P/'exterior-adapted.blend'),compress=True)
bpy.ops.export_scene.fbx(filepath=str(OUT/'scenic-assets.fbx'),use_selection=False,object_types={'MESH'},apply_unit_scale=True,bake_space_transform=True,axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True,use_mesh_modifiers=True)
(P/'geometry.json').write_text(json.dumps(records,indent=2));print('EXPORT_COMPLETE',records,flush=True)
