"""Blender authoring/export recipe; no Roblox runtime code or player data."""
import bpy, math, json
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parent
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
assets=[]
def material(name,color):
    m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);return m
ivory=material('Fossil ivory',(.72,.64,.46));stone=material('Mineral limestone',(.66,.65,.58));dark=material('Socket interior',(.15,.19,.19))
def finish(name,objects):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0];bpy.ops.object.join();o=bpy.context.object;o.name=name
    bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
    # Ground pivot and centered footprint for reusable placements.
    coords=[o.matrix_world@v.co for v in o.data.vertices];lo=Vector(tuple(min(p[i] for p in coords) for i in range(3)));hi=Vector(tuple(max(p[i] for p in coords) for i in range(3)))
    offset=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z))
    for v in o.data.vertices:v.co=o.matrix_world@v.co-offset
    o.matrix_world.identity();assets.append(o);return o
for filename,name,height in [('plant_bush.glb','PlantBush',3.6),('plant_flatTall.glb','PlantLeaves',3.8),('tree_default.glb','ScenicTree',22),('rock_largeA.glb','ScenicRock',15)]:
    before=set(bpy.data.objects);bpy.ops.import_scene.gltf(filepath=str(ROOT/'source/kenney'/filename));objects=[o for o in set(bpy.data.objects)-before if o.type=='MESH']
    coords=[o.matrix_world@v.co for o in objects for v in o.data.vertices];span=max(p.z for p in coords)-min(p.z for p in coords);factor=height/span
    for o in objects:
        o.location*=factor;o.scale*=factor
        for m in o.data.materials:
            if m:
                c=m.diffuse_color
                if c[1]>c[0]*1.08 and c[1]>c[2]*1.05:m.diffuse_color=(.24,.39,.22,1)
    finish(name,objects)
def ellipsoid(name,loc,scale,mat):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,location=loc);o=bpy.context.object;o.name=name;o.scale=scale;o.data.materials.append(mat);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);return o
# Original broad-snouted fossil: real inset eye sockets, jaw separation and readable cheek arches.
cranium=ellipsoid('Cranium',(0,0,1.35),(1.25,1.55,1.25),ivory)
snout=ellipsoid('Snout',(0,-1.45,.75),(.86,1.35,.6),ivory)
for x in [-1,1]:
    cut=ellipsoid('EyeSocketCutter',(x*.96,-.1,1.55),(.65,.62,.56),ivory)
    bpy.context.view_layer.objects.active=cranium;mod=cranium.modifiers.new('Eye socket','BOOLEAN');mod.operation='DIFFERENCE';mod.object=cut;bpy.ops.object.modifier_apply(modifier=mod.name);bpy.data.objects.remove(cut,do_unlink=True)
jaw=ellipsoid('Lower jaw',(0,-.9,.18),(.83,1.8,.18),ivory)
objects=[cranium,snout,jaw]
for x in [-.62,.62]:
    for y in [-1.9,-1.35,-.8]:objects.append(ellipsoid('Broad tooth',(x,y,.39),(.17,.2,.21),ivory))
finish('FossilSkull',objects)
objects=[ellipsoid('Shaft',(0,0,.45),(.34,1.7,.33),ivory)]
for y in [-1.7,1.7]:
    for x in [-.3,.3]:objects.append(ellipsoid('Condyle',(x,y,.45),(.44,.5,.43),ivory))
finish('FossilBone',objects)
curve=bpy.data.curves.new('Ammonite spiral','CURVE');curve.dimensions='3D';curve.bevel_depth=.18;curve.bevel_resolution=1;curve.resolution_u=1
sp=curve.splines.new('POLY');sp.points.add(79)
for i,p in enumerate(sp.points):
    a=i/79*math.pi*4.4;r=.12+i/79*1.6;p.co=(r*math.cos(a),r*math.sin(a),.22,1)
o=bpy.data.objects.new('Ammonite',curve);bpy.context.collection.objects.link(o);o.data.materials.append(ivory);bpy.ops.object.select_all(action='DESELECT');o.select_set(True);bpy.context.view_layer.objects.active=o;bpy.ops.object.convert(target='MESH');finish('Ammonite',[bpy.context.object])
# Three subtly different clipped-corner slabs, broad bevels, no texture noise.
for n,cuts in enumerate([(1.2,1.8,1.1,1.5),(2,1,1.6,1.2),(.9,1.4,2,1.1)]):
    a,b,c,d=cuts;outline=[(-12+a,-9),(12-b,-9),(12,-9+b),(12,9-c),(12-c,9),(-12+d,9),(-12,9-d),(-12,-9+a)]
    verts=[(x,y,z) for z in [0,.32] for x,y in outline];faces=[tuple(range(7,-1,-1)),tuple(range(8,16))]+[(i,(i+1)%8,(i+1)%8+8,i+8) for i in range(8)]
    me=bpy.data.meshes.new('Cut stone');me.from_pydata(verts,[],faces);me.update();o=bpy.data.objects.new('Slab',me);bpy.context.collection.objects.link(o);o.data.materials.append(stone)
    bevel=o.modifiers.new('Dressed edge','BEVEL');bevel.width=.13;bevel.segments=1;bpy.context.view_layer.objects.active=o;bpy.ops.object.modifier_apply(modifier=bevel.name);finish('StoneSlab'+str(n+1),[o])
# Single-shell fitted dome sectors. Adjacent sectors share edges; no overlapping pane stack.
profiles=[(350,52),(326,109),(264,170),(179,218),(88,247),(0,258)]
for i,((r0,y0),(r1,y1)) in enumerate(zip(profiles,profiles[1:])):
    a=math.pi/24;verts=[(-math.sin(a)*r0,math.cos(a)*r0,y0),(math.sin(a)*r0,math.cos(a)*r0,y0),(math.sin(a)*r1,math.cos(a)*r1,y1),(-math.sin(a)*r1,math.cos(a)*r1,y1)]
    if r1==0:verts=verts[:3];faces=[(0,1,2)]
    else:faces=[(0,1,2),(0,2,3)]
    me=bpy.data.meshes.new('Fitted glass');me.from_pydata(verts,[],faces);me.update();o=bpy.data.objects.new('DomePane'+str(i+1),me);bpy.context.collection.objects.link(o);assets.append(o)
(ROOT/'exports').mkdir(exist_ok=True)
manifest=[]
for o in assets:
    # Data export in Roblox coordinates (X,Z,-Y), flat per-face normals and vertex colors.
    me=o.data;me.calc_loop_triangles();verts=[[round(v.co.x,6),round(v.co.z,6),round(-v.co.y,6)] for v in me.vertices];tris=[]
    for t in me.loop_triangles:
        mat=me.materials[t.material_index] if len(me.materials)>t.material_index else None;c=list(mat.diffuse_color[:3]) if mat else [1,1,1]
        # Convert Blender linear material RGB into display-space vertex colors.
        c=[round(min(1,max(0,x))**(1/2.2),5) for x in c]
        normal=t.normal;tris.append({'v':list(t.vertices),'n':[[normal.x,normal.z,-normal.y]]*3,'uv':[[0,0],[1,0],[0,1]],'c':c})
    data={'vertices':verts,'triangles':tris};(ROOT/'exports'/(o.name+'.mesh.json')).write_text(json.dumps(data,separators=(',',':')))
    manifest.append({'name':o.name,'triangles':len(tris),'vertices':len(verts),'source':'Kenney Nature Kit, CC0' if o.name in ['PlantBush','PlantLeaves','ScenicTree','ScenicRock'] else 'Original project geometry'})
    o.hide_render=True
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'living-lab-assets.blend'))
(ROOT/'geometry-manifest.json').write_text(json.dumps(manifest,indent=2))
print('LIVING_LAB_EXPORTS',json.dumps(manifest))
