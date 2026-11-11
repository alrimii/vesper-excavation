"""UV/topology-preserving fits, original PBR uploads and exact-model icons."""
import bpy,json,math,shutil
from pathlib import Path
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[3];OUT=ROOT/'Backups/CreatureBatchTimer_20261111';UPLOAD=ROOT/'assets/environment/compact-interior/exports'
SPECS=[('frost-spirit-mammoth','frost_spirit_mammoth','BatchMammoth',(.9,.3,-1)),('volcanic-sabertooth','volcanic_sabertooth','BatchSabertooth',(.65,.25,-1)),('fossil-tortoise','fossil_tortoise','BatchTortoise',(.75,.4,-1))]
def hull(points):
 ordered=sorted((x,y,i)for i,(x,y)in enumerate(points))
 def cross(a,b,c):return (b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
 lower=[];upper=[]
 for p in ordered:
  while len(lower)>1 and cross(lower[-2],lower[-1],p)<=0:lower.pop()
  lower.append(p)
 for p in reversed(ordered):
  while len(upper)>1 and cross(upper[-2],upper[-1],p)<=0:upper.pop()
  upper.append(p)
 return {p[2]for p in lower+upper}
records=[]
for folder,id,name,direction in SPECS:
 dest=OUT/folder;source=OUT/'source-original'/folder;bpy.ops.wm.open_mainfile(filepath=str(dest/'inspected.blend'))
 meshes=[o for o in bpy.context.scene.objects if o.type=='MESH'];assert len(meshes)==1
 o=meshes[0];vs=[o.matrix_world@v.co for v in o.data.vertices];lo=Vector([min(v[i]for v in vs)for i in range(3)]);hi=Vector([max(v[i]for v in vs)for i in range(3)])
 origin=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z));scale=4.8/(hi.z-lo.z)
 transform=Matrix.Scale(scale,4)@Matrix.Rotation(math.pi,4,'Z')@Matrix.Translation(-origin)
 o.data.transform(transform@o.matrix_world);o.matrix_world=Matrix.Identity(4);o.name=name;o.data.name=name
 for mat in o.data.materials:
  for n in mat.node_tree.nodes:
   if n.type=='TEX_IMAGE'and n.image:n.image.colorspace_settings.name='sRGB' if 'diffuse' in n.image.filepath else 'Non-Color'
 bpy.ops.wm.save_as_mainfile(filepath=str(dest/(name+'-Game.blend')))
 mats=list(o.data.materials);o.data.materials.clear();bpy.ops.object.select_all(action='DESELECT');o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(UPLOAD/(name+'.glb')),export_format='GLB',use_selection=True,export_yup=True,export_tangents=True)
 for m in mats:o.data.materials.append(m)
 for old,suffix in [('texture_diffuse.png','Color'),('texture_metallic.png','Metalness'),('texture_roughness.png','Roughness'),('texture_normal.png','Normal')]:shutil.copy2(source/old,UPLOAD/(name+suffix+'.png'))
 vs=[v.co for v in o.data.vertices];lo=Vector([min(v[i]for v in vs)for i in range(3)]);hi=Vector([max(v[i]for v in vs)for i in range(3)]);center=(lo+hi)/2
 # Exact support silhouettes for this fixed preview direction; no mesh changes.
 rv=[Vector((v.x,v.z,-v.y))for v in vs];rc=Vector((center.x,center.z,-center.y));d=Vector(direction).normalized();r=Vector((0,1,0)).cross(d).normalized();u=d.cross(r).normalized();cv=[Vector((r.dot(v-rc),u.dot(v-rc),d.dot(v-rc)))for v in rv]
 ids=hull([(v.x,v.z)for v in cv])|hull([(v.y,v.z)for v in cv])
 points=[[round(x,6)for x in rv[i]]for i in sorted(ids)]
 scene=bpy.context.scene;cam=scene.camera;cam.location=center+Vector((direction[0],-direction[2],direction[1]))*8;cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();bpy.context.view_layer.update()
 local=[cam.matrix_world.inverted()@v for v in vs];xl,xh=min(v.x for v in local),max(v.x for v in local);yl,yh=min(v.y for v in local),max(v.y for v in local)
 cam.location+=cam.matrix_world.to_quaternion()@Vector(((xl+xh)/2,(yl+yh)/2,0));cam.data.ortho_scale=max(xh-xl,yh-yl)*1.10
 for light in [x for x in scene.objects if x.type=='LIGHT']:
  light.location=transform@light.location;light.data.energy*=scale**2;light.data.size*=scale;light.rotation_euler=(center-light.location).to_track_quat('-Z','Y').to_euler()
 scene.render.resolution_x=768;scene.render.resolution_y=768;scene.cycles.samples=24;scene.render.filepath=str(UPLOAD/(name+'Icon.png'));bpy.ops.render.render(write_still=True)
 bpy.ops.wm.save_as_mainfile(filepath=str(dest/(name+'-Icon.blend')))
 record=dict(folder=folder,id=id,uploadName=name,meshes=1,vertices=len(o.data.vertices),triangles=sum(len(p.vertices)-2 for p in o.data.polygons),uniformScale=scale,sourceOrigin=list(origin),robloxSize=[hi.x-lo.x,hi.z-lo.z,hi.y-lo.y],forward='-Z',pivot='floor center',rigged=False,decimated=False,textureEdits=False,previewDirection=direction,previewHull=points)
 records.append(record);print(json.dumps({k:v for k,v in record.items()if k!='previewHull'}))
(Path(__file__).parent/'geometry.json').write_text(json.dumps(records,indent=2))
