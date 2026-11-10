import bpy,json,math
from pathlib import Path
from mathutils import Vector
root=Path(__file__).resolve().parents[3];private=root/'Backups/BlendkitInspection';out=root/'docs/reviews/blendkit-gazebo';out.mkdir(parents=True,exist_ok=True)
s=bpy.context.scene
exec((Path(__file__).with_name('inspect_scene.py')).read_text(encoding='utf-8-sig'))
def sockets(n):
 result={}
 for a in n.inputs:
  if hasattr(a,'default_value'):
   v=a.default_value
   try:v=list(v)
   except:pass
   if isinstance(v,(str,int,float,bool,list,type(None))):result[a.name]=v
 return result
def tree(t):
 return {'nodes':[{'name':n.name,'type':n.bl_idname,'inputs':sockets(n),'group':n.node_tree.name if hasattr(n,'node_tree') and n.node_tree else None} for n in t.nodes], 'links':[(l.from_node.name,l.from_socket.name,l.to_node.name,l.to_socket.name) for l in t.links]}
d={'node_groups':{g.name:tree(g) for g in bpy.data.node_groups},'materials':{m.name:tree(m.node_tree) for m in bpy.data.materials if m.use_nodes},'world':tree(s.world.node_tree),'compositor':tree(s.compositing_node_group) if s.use_nodes else None,'lights':[{'name':o.name,'type':o.data.type,'energy':o.data.energy,'color':list(o.data.color)} for o in s.objects if o.type=='LIGHT'],'mesh_unique':len(bpy.data.meshes),'unique_faces':sum(len(m.polygons) for m in bpy.data.meshes),'scene_objects':len(s.objects),'active_camera':s.camera.name,'drivers':[(o.name,len(o.animation_data.drivers)) for o in bpy.data.objects if o.animation_data and len(o.animation_data.drivers)],'camera_constraints':[(c.name,c.type) for c in s.camera.constraints]}
(private/'deep-inspection.json').write_text(json.dumps(d,indent=2),encoding='utf8')
print('RUNNING_VERSION',bpy.app.version_string,'ENGINE',s.render.engine,'COLOR',s.view_settings.view_transform,flush=True)
cam=s.camera;original=cam.matrix_world.copy();right=original.to_quaternion()@Vector((1,0,0));right.z=0;right.normalize()
positions=[]
s.render.resolution_percentage=100;s.render.resolution_x=768;s.render.resolution_y=768;s.render.image_settings.file_format='PNG'
if hasattr(s,'eevee') and hasattr(s.eevee,'taa_render_samples'):s.eevee.taa_render_samples=32
for name,offset in [('original-camera',0),('offset-left',-3),('offset-right',3)]:
 cam.matrix_world=original.copy();cam.location+=right*offset;positions.append({'name':name,'offset_scene_units':offset,'position':list(cam.location),'rotation':list(cam.rotation_euler),'lens':cam.data.lens});s.render.filepath=str(out/(name+'.png'));print('RENDER_START',name,flush=True);bpy.ops.render.render(write_still=True);print('RENDER_DONE',name,flush=True)
(private/'camera-positions.json').write_text(json.dumps(positions,indent=2));cam.matrix_world=original
# Solid Workbench overview of source geometry; beauty material and fog are deliberately disabled only here.
s.render.engine='BLENDER_WORKBENCH';s.render.use_compositing=False;s.render.resolution_x=1100;s.render.resolution_y=850
s.view_settings.view_transform='Standard';s.view_settings.look='None';s.view_settings.exposure=0;s.view_settings.gamma=1
sh=s.display.shading;sh.light='STUDIO';sh.color_type='OBJECT';sh.show_shadows=True;sh.show_cavity=True;sh.cavity_type='BOTH';sh.background_type='WORLD';s.world.color=(0.12,0.14,0.16)
for o in s.objects:
 o.color=(0.55,0.59,0.59,1)
 if o.type=='MESH' and any(m and m.use_nodes and any(n.type=='PRINCIPLED_VOLUME' for n in m.node_tree.nodes) for m in o.data.materials):o.hide_render=True;print('OVERVIEW_ONLY_HIDE_VOLUME',o.name,flush=True)
# Renderable frustum markers at the three real capture transforms.
def line(name,points,color):
 c=bpy.data.curves.new(name,'CURVE');c.dimensions='3D';c.bevel_depth=0.085;c.bevel_resolution=0;spl=c.splines.new('POLY');spl.points.add(len(points)-1)
 for a,b in zip(spl.points,points):a.co=(*b,1)
 ob=bpy.data.objects.new(name,c);s.collection.objects.link(ob);ob.color=(*color,1)
for item,color in zip(positions,[(1,.55,.08),(.1,.7,1),(1,.16,.48)]):
 pos=Vector(item['position']);mat=original.copy();mat.translation=pos
 corners=[mat@Vector((x,y,-3)) for x,y in [(-1.08,-1.08),(1.08,-1.08),(1.08,1.08),(-1.08,1.08)]]
 for i,v in enumerate(corners):line(item['name']+str(i),[pos,v,corners[(i+1)%4]],color)
 data=bpy.data.cameras.new(item['name']);ob=bpy.data.objects.new(item['name'],data);s.collection.objects.link(ob);ob.matrix_world=mat;data.lens=50
ov=bpy.data.objects.new('Inspection overview',bpy.data.cameras.new('Inspection overview'));s.collection.objects.link(ov);ov.location=(48,-65,56);ov.rotation_euler=(Vector((-5,0,3))-ov.location).to_track_quat('-Z','Y').to_euler();ov.data.type='ORTHO';ov.data.ortho_scale=88;s.camera=ov
s.render.filepath=str(out/'solid-overview.png');print('OVERVIEW_START',flush=True);bpy.ops.render.render(write_still=True);print('OVERVIEW_DONE',flush=True)
