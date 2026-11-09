"""Cut the original shell, retaining exterior normals and exact reassembly coordinates."""
import bpy, bmesh, math, json
from mathutils import Vector
from pathlib import Path
OUT=Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(OUT.parent/'expansion-v3'/'VesperExpansionV3.blend'))
records=[]
def export(obj,kind,template=None):
    mesh=obj.data;mesh.calc_loop_triangles()
    def rb(v):return [round(v.x,7),round(v.z,7),round(-v.y,7)]
    coords=[Vector(rb(v.co)) for v in mesh.vertices]
    low=Vector([min(v[i] for v in coords) for i in range(3)])
    high=Vector([max(v[i] for v in coords) for i in range(3)])
    center=(low+high)/2
    triangles=[]
    for tri in mesh.loop_triangles:
        triangles.append({'v':list(tri.vertices),'n':[rb(mesh.corner_normals[i].vector) for i in tri.loops],
            'uv':[list(mesh.uv_layers.active.data[i].uv) if mesh.uv_layers.active else [0,0] for i in tri.loops]})
    record={'name':obj.name,'kind':kind,'template':template,'center':list(center),'size':list(high-low),
        'vertices':[list(v-center) for v in coords],'triangles':triangles}
    records.append(record)
    return record
for row in range(10,40):
    source=bpy.data.objects[f'L1_R{row:02d}']
    vs=[v.co for v in source.data.vertices]
    center=Vector([(min(v[i] for v in vs)+max(v[i] for v in vs))/2 for i in range(3)])
    phi=(row+.5)*math.pi/40
    side=Vector((0,1,0));up=Vector((-math.cos(phi),0,math.sin(phi))).normalized()
    w=max(abs((v-center).dot(side)) for v in vs);h=max(abs((v-center).dot(up)) for v in vs)
    sites=[center+side*w*.08+up*h*.07]
    for i in range(4):
        theta=i*math.pi/2+.35+row*.07
        sites.append(center+side*math.cos(theta)*w*.67+up*math.sin(theta)*h*.67)
    for index,site in enumerate(sites):
        bm=bmesh.new();bm.from_mesh(source.data)
        uv=bm.loops.layers.uv.active
        for other in sites:
            if (site-other).length<1e-6:continue
            result=bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=1e-7,
                plane_co=(site+other)/2,plane_no=(other-site).normalized(),clear_outer=True,clear_inner=False)
            edges=[e for e in result['geom_cut'] if isinstance(e,bmesh.types.BMEdge) and e.is_valid and e.is_boundary]
            if edges:
                for f in bmesh.ops.holes_fill(bm,edges=edges,sides=0)['faces']:
                    f.material_index=1
                    if uv:
                        for loop in f.loops:loop[uv].uv=(.5,.5)
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        name=f'L1_R{row:02d}_B{index+1}'
        mesh=bpy.data.meshes.new(name);bm.to_mesh(mesh);bm.free();mesh.update()
        if not mesh.polygons:raise RuntimeError('Empty piece '+name)
        normals=[None]*len(mesh.loops)
        for face in mesh.polygons:
            face.use_smooth=face.material_index==0
            for li in face.loop_indices:
                if face.material_index==0:
                    v=mesh.vertices[mesh.loops[li].vertex_index].co
                    p=math.acos(max(-1,min(1,1-2*v.z/104.04)))
                    theta=math.atan2(v.y,v.x)
                    dz=52.02*math.sin(p);dr=40.8*(math.cos(p)*(1+.18*math.cos(p))-.18*math.sin(p)**2)
                    normals[li]=tuple(Vector((dz*math.cos(theta),dz*math.sin(theta),-dr)).normalized())
                else:normals[li]=tuple(face.normal)
        mesh.normals_split_custom_set(normals)
        obj=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(obj)
        export(obj,'fracture',source.name)
# Closed final lining follows the same egg profile, just inside the third layer.
verts=[];faces=[];cols=96;rows=64;depth=1.72
for j in range(rows+1):
    phi=max(.00001,min(math.pi-.00001,j*math.pi/rows))
    rad=40.8*math.sin(phi)*(1+.18*math.cos(phi))
    dz=52.02*math.sin(phi);dr=40.8*(math.cos(phi)*(1+.18*math.cos(phi))-.18*math.sin(phi)**2)
    for i in range(cols):
        t=i*2*math.pi/cols;n=Vector((dz*math.cos(t),dz*math.sin(t),-dr)).normalized()
        verts.append(tuple(Vector((rad*math.cos(t),rad*math.sin(t),52.02*(1-math.cos(phi))))-n*depth))
for j in range(rows):
    for i in range(cols):
        a=j*cols+i;b=j*cols+(i+1)%cols;c=(j+1)*cols+(i+1)%cols;d=(j+1)*cols+i
        faces.append((a,b,c,d))
faces.extend([tuple(reversed(range(cols))),tuple(rows*cols+i for i in range(cols))])
mesh=bpy.data.meshes.new('FinalLining');mesh.from_pydata(verts,[],faces);mesh.update()
for f in mesh.polygons:f.use_smooth=True
obj=bpy.data.objects.new('FinalLining',mesh);bpy.context.collection.objects.link(obj);export(obj,'lining')
(OUT/'geometry.json').write_text(json.dumps(records,separators=(',',':')))
bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'CoherentShell.blend'))
print('AUTHORED',len(records),'MESHES',flush=True)
