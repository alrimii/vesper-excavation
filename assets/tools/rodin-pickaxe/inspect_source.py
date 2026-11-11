"""Inspect the owner's exact FBX without modifying it."""
import bpy,json,hashlib
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'Backups/RodinPickaxe_20261111'
SOURCE=ROOT/'agentic_0003_pack_fbx_model.fbx'
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=str(SOURCE))
meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
parts=[]
for o in meshes:
    vv=[o.matrix_world @ v.co for v in o.data.vertices]
    low=[min(v[i] for v in vv) for i in range(3)];high=[max(v[i] for v in vv) for i in range(3)]
    parts.append({'name':o.name,'triangles':sum(len(f.vertices)-2 for f in o.data.polygons),'low':low,'high':high,'materials':[m.name for m in o.data.materials if m]})
materials=[]
for m in bpy.data.materials:
    n=m.node_tree.nodes.get('Principled BSDF') if m.use_nodes else None
    materials.append({'name':m.name,'diffuse':list(m.diffuse_color),'base':list(n.inputs['Base Color'].default_value) if n else None,'metallic':n.inputs['Metallic'].default_value if n else None,'roughness':n.inputs['Roughness'].default_value if n else None,'alpha':n.inputs['Alpha'].default_value if n else None,'nodes':[(n.type,n.name) for n in m.node_tree.nodes] if m.use_nodes else []})
data={'sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'objects':len(meshes),'triangles':sum(p['triangles'] for p in parts),'parts':sorted(parts,key=lambda p:-p['triangles']),'materials':materials,'images':[i.filepath for i in bpy.data.images]}
(OUT/'source-inspection.json').write_text(json.dumps(data,indent=2),encoding='utf8')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source-inspected.blend'))
print(json.dumps({k:data[k] for k in ['objects','triangles','materials','images']},indent=2))
print(json.dumps(data['parts'][:8],indent=2))
