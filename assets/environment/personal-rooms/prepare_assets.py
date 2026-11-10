"""Adapt selected CC0 Kenney furniture, with texture palette baked to materials.
Run with the existing Blender installation. No tool installation or paid assets.
"""
import bpy, json, math, shutil
from pathlib import Path
from mathutils import Vector
ROOT = Path(__file__).resolve().parent
PROJECT = ROOT.parents[2]
PRIVATE = PROJECT / 'Backups/InteriorPhase2_20261111'
EXPORT = PROJECT / 'assets/environment/compact-interior/exports'
SELECTION = [('LabTable', 'space-station-kit', 'table-inset.glb', 6.5),
             ('CareBench', 'furniture-kit', 'benchCushionLow.glb', 6.5),
             ('ArchiveDesk', 'furniture-kit', 'desk.glb', 5.5)]
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
report = {}
for name, pack, filename, width in SELECTION:
    src = next((PRIVATE/pack).rglob(filename))
    out = ROOT/'source'/pack
    out.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, out/filename)
    for license in (PRIVATE/pack).glob('*License*'):
        shutil.copy2(license, out/license.name)
    before=set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=str(src))
    objs=[o for o in bpy.data.objects if o not in before and o.type=='MESH']
    # Convert the original texture's flat palette into actual face materials.
    for obj in objs:
        old=list(obj.data.materials)
        face_colors=[]
        for face in obj.data.polygons:
            mat=old[face.material_index]
            tex=next((n.image for n in mat.node_tree.nodes if n.type=='TEX_IMAGE' and n.image),None) if mat.use_nodes else None
            color=tuple(mat.diffuse_color[:3])
            if tex and obj.data.uv_layers.active:
                uv=sum((obj.data.uv_layers.active.data[i].uv for i in face.loop_indices),Vector((0,0)))/len(face.loop_indices)
                w,h=tex.size; x=min(w-1,max(0,int(uv.x*w)));y=min(h-1,max(0,int(uv.y*h)))
                idx=4*(y*w+x);color=tuple(tex.pixels[idx:idx+3])
            # Muted stone/metal replaces the space kit's blue-violet finish.
            if name=='LabTable':
                value=sum(color)/3
                color=(.12,.155,.15) if value<.32 else ((.36,.39,.35) if max(color)-min(color)>.13 else (.48,.46,.39))
            else:
                color=tuple(c*.63 for c in color)
            face_colors.append(tuple(round(c,4) for c in color))
        obj.data.materials.clear();palette={}
        for face,c in zip(obj.data.polygons,face_colors):
            if c not in palette:
                mat=bpy.data.materials.new(name+str(len(palette)));mat.diffuse_color=(*c,1);mat.use_nodes=True
                bsdf=mat.node_tree.nodes.get('Principled BSDF');bsdf.inputs['Base Color'].default_value=(*c,1);bsdf.inputs['Roughness'].default_value=.8
                palette[c]=len(obj.data.materials);obj.data.materials.append(mat)
            face.material_index=palette[c]
        obj.name=name
    pts=[o.matrix_world@v.co for o in objs for v in o.data.vertices]
    lo=Vector([min(p[i] for p in pts) for i in range(3)]);hi=Vector([max(p[i] for p in pts) for i in range(3)])
    scale=width/(hi.x-lo.x);offset=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z))
    for o in objs:
        for v in o.data.vertices:v.co=(o.matrix_world@v.co-offset)*scale
        o.matrix_world.identity()
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(EXPORT/(name+'.glb')),export_format='GLB',use_selection=True)
    pts=[v.co for o in objs for v in o.data.vertices]
    lo=Vector([min(p[i] for p in pts) for i in range(3)]);hi=Vector([max(p[i] for p in pts) for i in range(3)])
    # Blender Z-up -> glTF Y-up. Import normalization reads this size.
    report[name]={'source':str(src.relative_to(PRIVATE)),'size':[hi.x-lo.x,hi.z-lo.z,hi.y-lo.y], 'center':[0,(hi.z-lo.z)/2,0], 'triangles':sum(len(p.vertices)-2 for o in objs for p in o.data.polygons)}
    # Exact material primitives for Studio's import, which does not retain flat colors.
    import struct
    raw=(EXPORT/(name+'.glb')).read_bytes()
    gltf=json.loads(raw[20:20+struct.unpack_from('<I',raw,12)[0]])
    def srgb(c): return round(255*(12.92*c if c <= .0031308 else 1.055*c**(1/2.4)-.055))
    primitives=[]
    for node in gltf['nodes']:
        if 'mesh' not in node: continue
        for i,p in enumerate(gltf['meshes'][node['mesh']]['primitives']):
            a=gltf['accessors'][p['attributes']['POSITION']];lo=a['min'];hi=a['max']
            c=gltf['materials'][p['material']]['pbrMetallicRoughness']['baseColorFactor'][:3]
            primitives.append({'node':node['name'],'primitive':i,'size':[hi[k]-lo[k] for k in range(3)],'center':[(hi[k]+lo[k])/2 for k in range(3)],'colorSrgb':[srgb(v) for v in c]})
    report[name]['primitives']=primitives
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'personal-room-furniture.blend'))
(ROOT/'export-manifest.json').write_text(json.dumps(report,indent=2))
