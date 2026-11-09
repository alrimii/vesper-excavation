import bpy, math
from mathutils import Vector
from pathlib import Path
ROOT=Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'VesperExpansionV3.blend'))
for obj in bpy.data.objects: obj.hide_render=True
m=bpy.data.materials.new('Default egg mineral porcelain');m.use_nodes=True
n=m.node_tree.nodes;l=m.node_tree.links;p=n.get('Principled BSDF')
for kind,socket in [('color','Base Color'),('rough','Roughness'),('normal','Normal')]:
    filename='mineral-micro-normal.png' if kind=='normal' else f'L1_R20_{kind}.png'
    t=n.new('ShaderNodeTexImage');t.image=bpy.data.images.load(str(ROOT/'default-finish'/filename))
    if kind!='color':t.image.colorspace_settings.name='Non-Color'
    if kind=='normal':
        normal=n.new('ShaderNodeNormalMap'); l.new(t.outputs['Color'],normal.inputs['Color']);l.new(normal.outputs['Normal'],p.inputs[socket])
    else:l.new(t.outputs['Color'],p.inputs[socket])
for name in ['L1_R20','L1_R20_F1','L1_R20_F2','L1_R20_F3']:
    obj=bpy.data.objects[name];obj.hide_render=False
    obj.data.materials.clear();obj.data.materials.append(m)
    for poly in obj.data.polygons:poly.material_index=0
    if name=='L1_R20':obj.location.y=-3
    else:
        center=sum((v.co for v in obj.data.vertices),Vector())/len(obj.data.vertices)
        whole=bpy.data.objects['L1_R20'];origin=sum((v.co for v in whole.data.vertices),Vector())/len(whole.data.vertices)
        delta=(center-origin).normalized()*.12
        obj.location=Vector((0,3,0))+delta
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=24
scene.world.color=(.18,.18,.18)
for loc,power,size in [((52,-6,65),2400,9),((47,8,57),1100,7)]:
    bpy.ops.object.light_add(type='AREA',location=loc);light=bpy.context.object;light.data.energy=power;light.data.shape='DISK';light.data.size=size;light.rotation_euler=(Vector((40,0,54))-light.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(61,0,55));cam=bpy.context.object;cam.rotation_euler=(Vector((40,0,54))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=13
scene.camera=cam;scene.render.resolution_x=1200;scene.render.resolution_y=700;scene.render.resolution_percentage=100
scene.render.filepath=str(ROOT/'default-finish'/'material-preview.png');scene.view_settings.view_transform='AgX'
bpy.ops.render.render(write_still=True)
