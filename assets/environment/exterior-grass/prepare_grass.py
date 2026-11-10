"""Static source adaptation, not a runtime vegetation system. Run with Blender 5.2.3.
Reuses v182 geometry and CC0 Quaternius Grass_Wispy_Short; originals stay untouched.
"""
import bpy, json, math, random, copy
import numpy as np
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT = Path('C:/Users/BOSS/Desktop/egg')
OUT = ROOT/'Backups/ExteriorGrass_20261110'
EXP = OUT/'exports'; EXP.mkdir(exist_ok=True)
PUBLIC = ROOT/'assets/environment/exterior-grass'
old = json.loads((ROOT/'assets/environment/exterior-integration/layout.json').read_text())
data = copy.deepcopy(old)
# Keep the same distant silhouette angle, but put its actual geometry within the
# runtime-visible landscape. Runtime A/B compares this with the exact v182 transform.
data['peaks'][4] = [55, 2900, -15, .68087, .47283, .59261, 204]
data['grading'] += [[1580,300,32,440,300],[-600,1370,30,430,340],
                    [-1450,-1270,28,450,340],[1420,2140,30,530,400]]

def ground(x,z):
    r=np.sqrt(x*x+z*z);t=np.clip((r-350)/500,0,1);t=t*t*(3-2*t)
    y=-8+t*(8+13*np.sin(x/430)*np.cos(z/520)+9*np.sin(z/310))
    for cx,cz,h,wx,wz in data['grading']:
        y+=t*h*np.exp(-(((x-cx)/wx)**2+((z-cz)/wz)**2)*1.7)
    a=math.radians(55);u=x*math.cos(a)+z*math.sin(a);v=-x*math.sin(a)+z*math.cos(a)
    y-=np.clip((u-800)/900,0,1)*np.exp(-((v-110*np.sin(u/650))/360)**2)*18
    return y

def triangle_ground(x,z):
    # Match the actual grade triangles, rather than floating on an analytic curve.
    step=1500/16;xx=math.floor((x+6000)/step)*step-6000;zz=math.floor((z+6000)/step)*step-6000
    fx=(x-xx)/step;fz=(z-zz)/step
    a=float(ground(xx,zz));b=float(ground(xx+step,zz));c=float(ground(xx,zz+step));d=float(ground(xx+step,zz+step))
    return a+fx*(b-a)+fz*(c-a) if fx+fz<=1 else d+(1-fx)*(c-d)+(1-fz)*(b-d)

bpy.ops.wm.open_mainfile(filepath=str(ROOT/'Backups/ExteriorComposition_20261110/exterior-adapted.blend'))
alpine=bpy.data.objects['AlpineRange'];faces=[tuple(p.vertices)for p in alpine.data.polygons]
massifs=[]
for deg,r,base,sx,sy,sz,yaw in data['peaks']:
    a=math.radians(deg);q=math.radians(yaw);px,pz=math.cos(a)*r,math.sin(a)*r;c,s=math.cos(q),math.sin(q)
    verts=[]
    for v in alpine.data.vertices:
        lx,ly,lz=-v.co.x*sx,v.co.z*sy,v.co.y*sz
        verts.append((px+c*lx+s*lz,pz-s*lx+c*lz,base+ly))
    massifs.append(BVHTree.FromPolygons(verts,faces,all_triangles=False))
def surface(x,z):
    y=triangle_ground(x,z)
    for tree in massifs:
        hit,_,_,_=tree.ray_cast(Vector((x,z,1800)),Vector((0,0,-1)),2200)
        if hit and hit.z>y:y=hit.z
    return y

# Preserve the original good assets. Redistribute only the v182 added route trees
# into asymmetric overlapping lobes; remove 28 redundant added placements.
rng=random.Random(182183)
centers=[(1190,480),(-480,1100),(-1090,-100),(-1160,-1050),(620,-1340),
         (1500,-400),(600,1470),(1460,1130),(1500,2600)]
plants=[];removed=[];changed_species=0
for i,p in enumerate(data['planting']):
    if p['kind']=='tree' and not p['retained']:
        index=int(p['patch'].replace('WoodlandLink',''))-1
        if len(removed)<28 and i%3==0:
            removed.append(p);continue
        cx,cz=centers[index];lobe=(-1 if i%3 else 1)
        for attempt in range(50):
            x=cx+lobe*85+rng.gauss(0,66);z=cz+lobe*30+rng.gauss(0,83)
            if math.hypot(x,z)<660 or surface(x,z)>220:continue
            if any(q['kind']=='tree'and(q['x']-x)**2+(q['z']-z)**2<44**2 for q in plants):continue
            break
        p['x'],p['z']=round(x,3),round(z,3)
        if p['name']=='CanopyTwisted':p['name']='CanopyYoung';changed_species+=1
        p['patch']=p['patch'].replace('WoodlandLink','WoodlandPatch')
    p['y']=round(surface(p['x'],p['z'])-.35,3);plants.append(p)
data['planting']=plants

# Irregular low grass fields nearest the glass, then selected woodland toes.
# Short blades remain 1.0..1.9 studs high; distant views rely on surface masses.
patch_centers=[(390,185,52,34),(250,365,48,32),(420,315,60,34),(-180,395,52,30),
 (-330,335,62,38),(-420,90,54,34),(-415,-145,60,38),(-290,-365,64,36),
 (-80,-445,55,35),(240,-385,56,38),(410,-265,64,40),(480,-80,58,36),
 (570,520,72,44),(-635,350,72,44),(-585,-550,70,42),(570,-615,76,45)]
data['grassPatches']=[]
data['grassCoverage']={'approach':'static simplified source clumps combined into terrain-fitted patches',
 'source':'Quaternius Standard Grass_Wispy_Short / existing SoftGrass',
 'animation':False,'minRootRadius':375,'heightRange':[1.0,1.9]}

# Save new material derivatives without reducing original rock resolution or blur.
def save_pixels(name,pixels,size):
    im=bpy.data.images.new(name,width=size,height=size,alpha=False);im.colorspace_settings.name='Non-Color'
    im.pixels.foreach_set(pixels.astype(np.float32).ravel());im.file_format='PNG';im.filepath_raw=str(EXP/(name+'.png'));im.save();return im
for name,source in [('AlpineReadableColor','AlpineRange_Alpine_range_rock,_snow,_scree,_turf_and_forest_color.png'),('ButtressReadableColor','RockButtress_rock_face_02_color.png')]:
    im=bpy.data.images.load(str(ROOT/'Backups/ExteriorComposition_20261110/exports'/source),check_existing=False)
    w,h=im.size;arr=np.empty(w*h*4,dtype=np.float32);im.pixels.foreach_get(arr);arr=arr.reshape(h,w,4)
    grey=arr[:,:,:3].mean(axis=2,keepdims=True)
    arr[:,:,:3]=np.clip((arr[:,:,:3]*.94+grey*.06)*.92+np.array([.43,.45,.37])*.08,0,1)
    im.pixels.foreach_set(arr.ravel());im.filepath_raw=str(EXP/(name+'.png'));im.file_format='PNG';im.save()

n=2048;axis=np.linspace(-6000,6000,n);x,z=np.meshgrid(axis,axis);h=ground(x,z)
nrng=np.random.default_rng(183);wave=np.zeros_like(x)
for count,amount in [(19,.035),(60,.025),(220,.018),(560,.010)]:
    lattice=nrng.uniform(-1,1,(count,count));coarse=np.linspace(0,n-1,count);fine=np.arange(n)
    rows=np.array([np.interp(fine,coarse,row)for row in lattice]);noise=np.array([np.interp(fine,coarse,rows[:,i])for i in range(n)]).T
    wave+=noise*amount
base=np.array([.43,.50,.305])[None,None,:]+wave[:,:,None]
wood=np.zeros_like(x)
for p in plants:
    if p['kind']=='tree':wood=np.maximum(wood,np.exp(-(((x-p['x'])/140)**2+((z-p['z'])/150)**2)))
base=base*(1-wood[:,:,None]*.64)+np.array([.30,.385,.21])*wood[:,:,None]*.64
# Meadow/soil transitions support actual grass shapes; no overlaid alpha panels.
cover=np.zeros_like(x)
for cx,cz,wx,wz in patch_centers:
    v=np.exp(-(((x-cx)/(wx*1.3))**2+((z-cz)/(wz*1.4))**2)*1.2)
    cover=np.maximum(cover,v)
base=base*(1-cover[:,:,None]*.60)+np.array([.34,.465,.215])*cover[:,:,None]*.60
soil=np.clip((np.sin(x/143+np.sin(z/235))*.45+np.sin(z/96+x/260)*.25+wave*8-.24)*.55,0,.25)
slope=np.clip((abs(np.gradient(h,axis,axis)[0])+abs(np.gradient(h,axis,axis)[1]))*.9,0,.42)
mix=np.maximum(soil,slope)
base=base*(1-mix[:,:,None])+np.array([.49,.455,.32])*mix[:,:,None]
rgba=np.concatenate([np.clip(base,0,1),np.ones((n,n,1))],axis=2)
ground_image=save_pixels('MeadowMosaicColor',rgba,n)

for o in list(bpy.data.objects):bpy.data.objects.remove(o,do_unlink=True)
mat=bpy.data.materials.new('MeadowMosaic');mat.use_nodes=True
bs=mat.node_tree.nodes.get('Principled BSDF');tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=ground_image
mat.node_tree.links.new(tex.outputs['Color'],bs.inputs['Base Color']);bs.inputs['Roughness'].default_value=1
records=[];n=16;w=1500
for gx in range(-4,4):
 for gz in range(-4,4):
    cx,cz=(gx+.5)*w,(gz+.5)*w;verts=[];faces=[];uvs=[]
    for j in range(n+1):
     for i in range(n+1):
        xx=cx+(i/n-.5)*w;zz=cz+(j/n-.5)*w;yy=float(ground(xx,zz))
        verts.append((-(xx-cx),zz-cz,yy));uvs.append(((xx+6000)/12000,(zz+6000)/12000))
    for j in range(n):
     for i in range(n):
        a=j*(n+1)+i;b=a+1;c=a+n+1;d=c+1;faces.extend([(a,c,b),(b,c,d)])
    name='Grade_%d_%d'%(gx+4,gz+4);me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.update();uv=me.uv_layers.new(name='WorldColor')
    for poly in me.polygons:
        poly.use_smooth=True
        for li in poly.loop_indices:uv.data[li].uv=uvs[me.loops[li].vertex_index]
    normals=[]
    for vx,vz,vy in verts:
        xx=cx-vx;zz=cz+vz;dx=float(ground(xx+1,zz)-ground(xx-1,zz))/2;dz=float(ground(xx,zz+1)-ground(xx,zz-1))/2
        normals.append(Vector((dx,-dz,1)).normalized())
    me.normals_split_custom_set_from_vertices(normals)
    ob=bpy.data.objects.new(name,me);bpy.context.collection.objects.link(ob);ob.location=(-cx,cz,0);me.materials.append(mat)
    low=min(v[2]for v in verts);high=max(v[2]for v in verts)
    records.append(dict(name=name,triangles=len(faces),size=[w,high-low,w],center=[cx,(high+low)/2,cz]))
data['ground']=records

# Load only the known existing source object; no downloaded scripts are executed.
with bpy.data.libraries.load(str(ROOT/'assets/environment/lab-art/lab-art-runtime.blend'),link=False)as(src,dst):dst.objects=['SoftGrass']
source=dst.objects[0];bpy.context.collection.objects.link(source);bpy.context.view_layer.objects.active=source
mod=source.modifiers.new('Distant short grass simplification','DECIMATE');mod.ratio=.285
bpy.ops.object.modifier_apply(modifier=mod.name);source.data.calc_loop_triangles()
sv=[v.co.copy()for v in source.data.vertices];sf=[tuple(p.vertices)for p in source.data.polygons]
suv=[[tuple(source.data.uv_layers.active.data[li].uv)for li in p.loop_indices]for p in source.data.polygons]
triangles=len(source.data.loop_triangles);grassmat=source.data.materials[0]
for index,(cx,cz,wx,wz)in enumerate(patch_centers):
    rng=random.Random(183000+index);verts=[];faces=[];uvs=[];tufts=[]
    for j in range(76):
        for attempt in range(100):
            # Unequal overlapping lobes and a few edge tufts; not a rectangular grid.
            edge=j%6==0;lobe=j%3
            px=rng.gauss([-wx*.22,wx*.16,wx*.03][lobe],wx*(.30 if edge else .16))
            pz=rng.gauss([-wz*.12,wz*.18,-wz*.22][lobe],wz*(.32 if edge else .18))
            if math.hypot(cx+px,cz+pz)<375:continue
            if any((px-a)**2+(pz-b)**2<1.7**2 for a,b in tufts):continue
            break
        tufts.append((px,pz));angle=rng.uniform(0,math.tau);c,s=math.cos(angle),math.sin(angle)
        sx=rng.uniform(.85,1.28);sy=rng.uniform(.50,.95);start=len(verts)
        for v in sv:
            dx=(v.x*c-v.y*s)*sx;dz=(v.x*s+v.y*c)*sx
            xx=cx+px+dx;zz=cz+pz+dz
            verts.append((-xx,zz,triangle_ground(xx,zz)-.08+v.z*sy))
        for f,uv in zip(sf,suv):faces.append(tuple(start+i for i in f));uvs.append(uv)
    name='GrassPatch_%02d'%(index+1);me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.update();uv=me.uv_layers.new(name='NatureAtlas')
    for p,coords in zip(me.polygons,uvs):
        for li,coord in zip(p.loop_indices,coords):uv.data[li].uv=coord
    ob=bpy.data.objects.new(name,me);bpy.context.collection.objects.link(ob);me.materials.append(grassmat)
    lo=[min(v[i]for v in verts)for i in range(3)];hi=[max(v[i]for v in verts)for i in range(3)]
    data['grassPatches'].append(dict(name=name,triangles=triangles*len(tufts),tufts=len(tufts),size=[hi[0]-lo[0],hi[2]-lo[2],hi[1]-lo[1]],center=[-(lo[0]+hi[0])/2,(lo[2]+hi[2])/2,(lo[1]+hi[1])/2]))
bpy.data.objects.remove(source,do_unlink=True)
data['changes']={'removedAddedTrees':len(removed),'changedAddedTwistedToYoung':changed_species,'simplifiedTuftTriangles':triangles,'grassTriangles':sum(p['triangles']for p in data['grassPatches'])}
# Runtime-verified representation overrides only the ridge; preserve the completed
# planting/ground preparation used for the captured state, without a new art pass.
data['ridgeOverride']=json.loads((PUBLIC/'ridge-placement.json').read_text())
(PUBLIC/'layout.json').write_text(json.dumps(data,indent=2))
(PUBLIC/'removed-placements.json').write_text(json.dumps(removed,indent=2))
(ROOT/'src/ExteriorIntegrationLayout.luau').write_text('-- Generated by assets/environment/exterior-grass/prepare_grass.py. Edit-only scenery data.\nreturn game:GetService("HttpService"):JSONDecode([=['+json.dumps(data,separators=(',',':'))+']=])\n')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'grass-ground-adapted.blend'),compress=True)
bpy.ops.export_scene.fbx(filepath=str(EXP/'grass-ground.fbx'),use_selection=False,object_types={'MESH'},apply_unit_scale=True,bake_space_transform=True,axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
print('GRASS_COMPLETE',json.dumps(data['changes']), 'trees',sum(p['kind']=='tree'for p in plants),flush=True)
