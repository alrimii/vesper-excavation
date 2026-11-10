import bpy,json,os,collections
from pathlib import Path
p=Path(__file__).resolve().parents[3]/'Backups/BlendkitInspection'
s=bpy.context.scene
report={'blender':bpy.app.version_string,'file_version':list(bpy.data.version),'scene':s.name,'engine':s.render.engine,'camera':s.camera.name if s.camera else None,'frame':s.frame_current,'resolution':[s.render.resolution_x,s.render.resolution_y,s.render.resolution_percentage],'world':s.world.name if s.world else None,'view_transform':s.view_settings.view_transform,'look':s.view_settings.look,'exposure':s.view_settings.exposure,'gamma':s.view_settings.gamma,'cycles_samples':s.cycles.samples,'use_nodes':s.use_nodes,'objects':[],'images':[],'materials':[],'libraries':[],'texts':[]}
for o in bpy.data.objects:
 d={'name':o.name,'type':o.type,'location':list(o.location),'dimensions':list(o.dimensions),'hide_render':o.hide_render,'library':o.library.filepath if o.library else None,'modifiers':[(m.name,m.type) for m in o.modifiers]}
 if o.type=='MESH':d.update(vertices=len(o.data.vertices),faces=len(o.data.polygons),materials=[m.name if m else None for m in o.data.materials])
 if o.type=='CAMERA':d.update(lens=o.data.lens,rotation=list(o.rotation_euler),camera_type=o.data.type)
 report['objects'].append(d)
for im in bpy.data.images:
 report['images'].append({'name':im.name,'filepath':im.filepath,'size':list(im.size),'packed':bool(im.packed_file),'source':im.source,'exists':os.path.exists(bpy.path.abspath(im.filepath))})
for mat in bpy.data.materials:
 report['materials'].append({'name':mat.name,'nodes':[{'name':n.name,'type':n.type,'image':n.image.name if hasattr(n,'image') and n.image else None} for n in mat.node_tree.nodes] if mat.use_nodes else []})
for lib in bpy.data.libraries:report['libraries'].append({'path':lib.filepath,'exists':os.path.exists(bpy.path.abspath(lib.filepath))})
for t in bpy.data.texts:report['texts'].append({'name':t.name,'use_module':t.use_module})
report['compositor']=[{'name':n.name,'type':n.type} for n in s.compositing_node_group.nodes] if s.use_nodes else []
report['world_nodes']=[{'name':n.name,'type':n.type} for n in s.world.node_tree.nodes] if s.world and s.world.use_nodes else []
(p/'inspection.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print('Inspection saved privately:', p/'inspection.json')
