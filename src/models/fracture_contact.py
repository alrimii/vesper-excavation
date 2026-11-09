import bpy,json,math
from pathlib import Path
from mathutils import Vector
out=Path(r'C:\Users\BOSS\Desktop\egg\src\models')
data=[]
for o in bpy.data.objects:
 if '_F' not in o.name or not o.name.startswith('L') or o.type!='MESH':continue
 coords=[v.co for v in o.data.vertices]
 lo=Vector(tuple(min(v[i] for v in coords) for i in range(3)));hi=Vector(tuple(max(v[i] for v in coords) for i in range(3)))
 c=(lo+hi)/2
 phi=math.acos(max(-1,min(1,1-2*c.z/68)))
 dz=34*math.sin(phi);dr=24*(math.cos(phi)*(1+.18*math.cos(phi))-.18*math.sin(phi)**2)
 n=Vector((dz,0,-dr)).normalized()
 localn=Vector((-n.x,n.z,n.y))
 depth=max(-(v-c).dot(n) for v in coords)
 data.append({'name':o.name,'normal':list(localn),'height':depth})
(out/'fracture-contact.json').write_text(json.dumps(data))
print('CONTACTS',len(data))
