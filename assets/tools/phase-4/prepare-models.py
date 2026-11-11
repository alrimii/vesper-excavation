"""Normalize the selected finished Poly Pizza assets; no replacement geometry is authored here."""
import bpy, json, math
from pathlib import Path
from mathutils import Vector, Matrix

ROOT=Path(__file__).resolve().parents[3]
PRIVATE=ROOT/'Backups/InteriorPhase4_20261111'
EXPORT=ROOT/'assets/environment/compact-interior/exports'
OUT=ROOT/'assets/tools/phase-4'
manifest=[]
for name in ['pickaxe','dynamite']:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(PRIVATE/(name+'.glb')))
    objects=[o for o in bpy.context.scene.objects if o.type=='MESH']
    for o in objects:
        o.data.transform(o.matrix_world);o.matrix_world=Matrix.Identity(4)
        if name=='pickaxe':
            transform=Matrix.Rotation(-math.pi/2,4,'Z')
            for v in o.data.vertices:
                v.co=transform@v.co
                v.co.z+=.30
                v.co*=3.8/.836674422
            # Material-only adaptation: readable steel and warm timber, preserving the finished mesh.
            for m in o.data.materials:
                color=(.28,.34,.36,1) if 'Black' in m.name else (.31,.13,.055,1)
                m.diffuse_color=color
                bs=m.node_tree.nodes.get('Principled BSDF')
                bs.inputs['Base Color'].default_value=color
                bs.inputs['Roughness'].default_value=.65
                bs.inputs['Metallic'].default_value=.35 if 'Black' in m.name else 0
            grip=bpy.data.materials.new('CharcoalRubber');grip.use_nodes=True;grip.diffuse_color=(.025,.035,.032,1)
            grip.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=grip.diffuse_color
            grip.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=.85
            o.data.materials.append(grip)
            for f in o.data.polygons:
                if sum(o.data.vertices[i].co.z for i in f.vertices)/len(f.vertices)<.32:f.material_index=len(o.data.materials)-1
        else:
            for v in o.data.vertices: v.co*=.50
        o.name='FieldPickaxe' if name=='pickaxe' else 'SurveyDynamite'
        o.data.name=o.name
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    if name=='pickaxe':
        bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.separate(type='MATERIAL');bpy.ops.object.mode_set(mode='OBJECT')
    objects=[o for o in bpy.context.scene.objects if o.type=='MESH']
    for i,o in enumerate(objects):
        o.name=('PickTimber' if 'Brown' in o.data.materials[0].name else 'PickGrip' if 'Rubber' in o.data.materials[0].name else 'PickSteel') if name=='pickaxe' else 'SurveyDynamite'
        o.data.name=o.name
        bpy.context.view_layer.objects.active=o
        bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY',center='BOUNDS')
    record={'family':name,'parts':[]}
    for o in objects:
        o.data.calc_loop_triangles()
        verts=[o.matrix_world@v.co for v in o.data.vertices]
        lo=Vector(tuple(min(v[i] for v in verts) for i in range(3)));hi=Vector(tuple(max(v[i] for v in verts) for i in range(3)))
        c=(lo+hi)/2;s=hi-lo
        record['parts'].append({'name':o.name,'triangles':len(o.data.loop_triangles),'center':[c.x,c.z,-c.y],'size':[s.x,s.z,s.y],'linearColor':list(o.data.materials[0].diffuse_color)})
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/(name+'.blend')))
    bpy.ops.export_scene.gltf(filepath=str(EXPORT/('Phase4_'+name+'.glb')),export_format='GLB',use_selection=True,export_yup=True)
    # Actual asset inspection, not implementation evidence.
    verts=[o.matrix_world@v.co for o in objects for v in o.data.vertices]
    lo=Vector(tuple(min(v[i] for v in verts) for i in range(3)));hi=Vector(tuple(max(v[i] for v in verts) for i in range(3)))
    center=(lo+hi)/2;span=(hi-lo).length
    bpy.ops.object.camera_add(location=center+Vector((1,-2,.65)).normalized()*span*1.7)
    cam=bpy.context.object;cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=span*1.12
    sc=bpy.context.scene;sc.camera=cam;sc.render.engine='BLENDER_EEVEE';sc.world=bpy.data.worlds.new('Inspection');sc.world.use_nodes=True;sc.world.node_tree.nodes.get('Background').inputs[0].default_value=(.18,.20,.22,1)
    bpy.ops.object.light_add(type='AREA',location=center+Vector((2,-3,5))*span);bpy.context.object.data.energy=1500*span*span;bpy.context.object.data.shape='DISK';bpy.context.object.data.size=span*4
    sc.render.resolution_x=700;sc.render.resolution_y=700;sc.render.resolution_percentage=100;sc.render.filepath=str(PRIVATE/(name+'-finished.png'));bpy.ops.render.render(write_still=True)
    manifest.append(record)
(OUT/'geometry.json').write_text(json.dumps(manifest,indent=2))
