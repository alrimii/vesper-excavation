"""Adapt actual Grab3D meshes: remove brown display supports, retain connected plant geometry."""
import bpy, bmesh, json, numpy as np
from pathlib import Path
from mathutils import Vector
ROOT=Path(r'C:/Users/BOSS/Desktop/egg')
PRIVATE=ROOT/'Backups/InteriorPhase3_20261111/source'
EXPORT=ROOT/'assets/environment/compact-interior/exports'
manifest={}
for source,name in [('ivy-vine','ArchitecturalIvy'),('hanging-vine','TrailingVine')]:
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.gltf(filepath=str(PRIVATE/(source+'.glb')))
    o=next(o for o in bpy.context.selected_objects if o.type=='MESH')
    bpy.context.view_layer.objects.active=o
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    mat=o.data.materials[0]
    bsdf=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    tex=bsdf.inputs['Base Color'].links[0].from_node.image
    w,h=tex.size;pixels=np.array(tex.pixels[:]).reshape(h,w,4)
    uv=o.data.uv_layers.active.data
    remove=[]
    for p in o.data.polygons:
        coords=np.array([uv[i].uv[:]for i in p.loop_indices]);u,v=coords.mean(axis=0)
        r,g,b,a=pixels[min(h-1,int(v*h)),min(w-1,int(u*w))]
        if r>g*1.15 and r>b*1.4:remove.append(p.index)
    bm=bmesh.new();bm.from_mesh(o.data);bm.faces.ensure_lookup_table();bmesh.ops.delete(bm,geom=[bm.faces[i]for i in remove],context='FACES');bm.to_mesh(o.data);bm.free()
    # Source textures are 2K; repeated architectural foliage uses a 1K base-colour map.
    for node in list(mat.node_tree.nodes):
        if node.type=='TEX_IMAGE'and node.image==tex:continue
        if node.type in {'TEX_IMAGE','NORMAL_MAP','SEPARATE_COLOR','SEPRGB'}:mat.node_tree.nodes.remove(node)
    bsdf.inputs['Roughness'].default_value=.82;bsdf.inputs['Metallic'].default_value=0
    tex.scale(1024,1024);tex.pack()
    o.name=name;o.data.name=name
    # Convert source metres to studs in the GLB itself, verified again on insertion.
    for v in o.data.vertices:v.co*=1/.28
    points=[v.co for v in o.data.vertices]
    lo=Vector(tuple(min(v[k]for v in points)for k in range(3)));hi=Vector(tuple(max(v[k]for v in points)for k in range(3)))
    # Origin at soil for ivy, at attachment head for hanging sections.
    anchor=Vector((0,0,lo.z if name=='ArchitecturalIvy'else hi.z))
    for v in o.data.vertices:v.co-=anchor
    lo-=anchor;hi-=anchor
    # glTF axis: x,z,-y. This is also the canonical Studio template frame.
    center=(lo+hi)/2;size=hi-lo
    manifest[name]={'source':source,'triangles':sum(len(p.vertices)-2 for p in o.data.polygons),'removedSupportFaces':len(remove),'size':[size.x,size.z,size.y],'center':[center.x,center.z,-center.y],'meshes':1,'textureSize':[1024,1024],'orientation':'leaf faces toward +Z; ivy roots at Y0, trailing head at Y0'}
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True)
    bpy.ops.wm.save_as_mainfile(filepath=str(PRIVATE/(name+'.blend')))
    bpy.ops.export_scene.gltf(filepath=str(EXPORT/(name+'.glb')),export_format='GLB',use_selection=True,export_yup=True,export_materials='EXPORT')
(ROOT/'assets/environment/phase-3/export-manifest.json').write_text(json.dumps(manifest,indent=2))
print(json.dumps(manifest))
