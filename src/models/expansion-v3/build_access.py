import bpy,bmesh,math,json
from mathutils import Vector
from pathlib import Path
out=Path(r'C:\Users\BOSS\Desktop\egg\src\models\expansion-v3')
bpy.ops.wm.open_mainfile(filepath=str(out/'VesperExpansionV3.blend'))
contacts={}
for o in bpy.data.objects:
 if '_F' not in o.name or o.type!='MESH':continue
 vs=[v.co for v in o.data.vertices];c=Vector([(min(v[i] for v in vs)+max(v[i] for v in vs))/2 for i in range(3)])
 phi=math.acos(max(-1,min(1,1-2*c.z/104.04)))
 dz=52.02*math.sin(phi);dr=40.8*(math.cos(phi)*(1+.18*math.cos(phi))-.18*math.sin(phi)**2)
 n=Vector((dz,0,-dr)).normalized()
 contacts[o.name]={'normal':[n.x,n.z,-n.y],'restHeight':max(-(v-c).dot(n) for v in vs)}
(out/'fracture-contact.json').write_text(json.dumps(contacts))
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
def path(t,offset=0):
 y=3.495+91.55*t;phi=math.acos(max(-1,min(1,1-2*(y+10.2)/104.04)))
 r=max(18,40.8*math.sin(phi)*(1+.18*math.cos(phi))+12)+offset;a=t*math.pi*10
 return Vector((math.cos(a)*r,y,math.sin(a)*r))
def rb_to_bl(v):return (v.x,-v.z,v.y)
manifest=[]
for turn in range(5):
 for kind in ['Deck','Trim']:
  verts=[];faces=[]
  def box(a,b,width,height):
   forward=(b-a).normalized();right=forward.cross(Vector((0,1,0))).normalized();up=right.cross(forward).normalized();c=(a+b)/2;length=(b-a).length+.12
   start=len(verts)
   for x,y,z in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]:verts.append(rb_to_bl(c+right*x*width/2+up*y*height/2+forward*z*length/2))
   for f in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(3,7,6,2),(0,4,7,3),(1,2,6,5)]:faces.append(tuple(start+i for i in f))
  for i in range(turn*96,(turn+1)*96):
   t,u=i/480,(i+1)/480
   if kind=='Deck':box(path(t),path(u),12,.3)
   else:
    box(path(t,6)+Vector((0,2.95,0)),path(u,6)+Vector((0,2.95,0)),.12,.12)
    box(path(t,6)+Vector((0,.18,0)),path(u,6)+Vector((0,.18,0)),.1,.1)
    if i%8==0:
     a=path(t,6)+Vector((0,.15,0));b=a+Vector((0,2.8,0))
     # Vertical posts use a tiny horizontal tilt to keep basis defined.
     b.x+=.0001;box(a,b,.14,.14)
  name=f'Access_{turn}_{kind}'
  mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update()
  bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
  ob=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(ob)
  material=bpy.data.materials.get(kind) or bpy.data.materials.new(kind);material.diffuse_color=(.12,.17,.21,1) if kind=='Deck' else (.65,.43,.16,1);mesh.materials.append(material)
  bpy.context.view_layer.objects.active=ob;ob.select_set(True)
  bevel=ob.modifiers.new('Machined edge','BEVEL');bevel.width=.025;bevel.segments=1
  bpy.ops.object.modifier_apply(modifier=bevel.name)
  vs=[v.co for v in ob.data.vertices];lo=Vector([min(v[i] for v in vs) for i in range(3)]);hi=Vector([max(v[i] for v in vs) for i in range(3)]);c=(lo+hi)/2
  manifest.append({'name':name,'center':[c.x,c.z,-c.y],'size':[hi.x-lo.x,hi.z-lo.z,hi.y-lo.y]})
  ob.select_set(False)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.fbx(filepath=str(out/'VesperAccessV3Final.fbx'),use_selection=True,axis_forward='-Z',axis_up='Y',add_leaf_bones=False)
bpy.ops.wm.save_as_mainfile(filepath=str(out/'VesperAccessV3.blend'))
(out/'access-manifest.json').write_text(json.dumps(manifest))
print('ACCESS_READY',flush=True)
