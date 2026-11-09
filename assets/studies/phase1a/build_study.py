"""Isolated authored Blender design study. Never connects to or edits Roblox.
Run with installed Blender 4.5: blender --background --python build_study.py
All coordinates are study units, intended as Roblox studs. Not an export-ready rig.
"""
import bpy, math, json, random
from pathlib import Path
from mathutils import Vector

OUT=Path(__file__).resolve().parent
(OUT/'renders').mkdir(parents=True,exist_ok=True)
(OUT/'frames').mkdir(exist_ok=True)
random.seed(17)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0

def mat(name,color,metal=0,rough=.4):
    m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*color,1)
    p.inputs['Metallic'].default_value=metal; p.inputs['Roughness'].default_value=rough
    return m
ivory=mat('Warm glazed ceramic',(.83,.70,.43),0,.3)
inside=mat('Fresh mineral interior',(.27,.51,.48),0,.62)
steel=mat('Satin pale steel',(.48,.65,.69),.65,.3)
edge=mat('Honed silver edge',(.78,.87,.88),.75,.24)
teal=mat('Sea green enamel',(.025,.34,.32),.25,.32)
rubber=mat('Soft deep teal grip',(.025,.105,.13),0,.7)
coral=mat('Coral identifier',(.92,.20,.10),.1,.38)
gold=mat('Warm brass fastener',(.9,.52,.12),.55,.3)
dark=mat('Crack interior',(.055,.13,.14),0,.85)
cream=mat('Workshop mannequin',(.65,.76,.74),0,.55)
floor=mat('Warm neutral backdrop',(.72,.76,.72),0,.85)
accent=mat('Impact cream accent',(1,.86,.48),0,.35)

def finish(o,name,m,bevel=0,parent=None):
    o.name=name; o.data.materials.append(m)
    if bevel:
        b=o.modifiers.new('Intentional rounded edges','BEVEL'); b.width=bevel; b.segments=3
        b=o.modifiers.new('Weighted corner normals','WEIGHTED_NORMAL')
    if parent: o.parent=parent
    return o
def empty(name,loc=(0,0,0)):
    o=bpy.data.objects.new(name,None); bpy.context.collection.objects.link(o); o.location=loc; return o
def box(name,pos,scale,m,b=.04,parent=None):
    bpy.ops.mesh.primitive_cube_add(size=1,location=pos); o=bpy.context.object; o.dimensions=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    return finish(o,name,m,b,parent)
def cyl(name,a,b,r,m,parent=None,verts=24):
    a,b=Vector(a),Vector(b); v=b-a
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts,radius=r,depth=v.length,location=(a+b)/2)
    o=bpy.context.object; o.rotation_euler=v.to_track_quat('Z','Y').to_euler()
    return finish(o,name,m,.025,parent)
def profile(name,points,depth,m,parent=None,bevel=.05):
    verts=[(x,y,z) for y in [-depth/2,depth/2] for x,z in points]; n=len(points)
    faces=[tuple(reversed(range(n))),tuple(range(n,2*n))]
    faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    mesh=bpy.data.meshes.new(name); mesh.from_pydata(verts,[],faces); mesh.update()
    o=bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(o)
    return finish(o,name,m,bevel,parent)
def line(name,pts,r,m,parent=None):
    c=bpy.data.curves.new(name,'CURVE'); c.dimensions='3D'; c.bevel_depth=r; c.bevel_resolution=2
    s=c.splines.new('POLY'); s.points.add(len(pts)-1)
    for p,v in zip(s.points,pts): p.co=(*v,1)
    o=bpy.data.objects.new(name,c); bpy.context.collection.objects.link(o); o.data.materials.append(m)
    if parent:o.parent=parent
    return o

def pick(name,upgrade=False,loc=(0,0,0)):
    root=empty(name,loc)
    # Grip origin is the lower-hand anchor; tool extends above and below it.
    profile('Tapered forged shaft',[(-.115,-.58),(.115,-.58),(.16,1.66),(-.16,1.66)],.24,teal,root,.045)
    cyl('Moulded palm grip',(0,0,-.5),(0,0,.34),.195,rubber,root)
    for z in [-.34,-.15,.04,.23]:
        box('Raised grip land',(0,-.185,z),(.28,.035,.075),teal,.024,root)
    cyl('Rounded pommel',(0,0,-.62),(0,0,-.49),.23,coral,root)
    cyl('Grip safety collar',(0,0,.33),(0,0,.43),.205,gold,root)
    box('Shaft identification inset',(0,-.14,.91),(.15,.045,.38),ivory,.035,root)
    if not upgrade:
        pts=[(-1.18,1.23),(-1.05,1.70),(-.55,1.98),(-.12,2.07),(.42,2.02),(.94,1.78),(1.37,1.20),(1.06,1.37),(.65,1.62),(.10,1.72),(-.42,1.66),(-.83,1.44)]
        profile('Swept single-piece starter forging',pts,.38,steel,root,.065)
        profile('Distinct replaceable striking tooth',[(.83,1.82),(1.37,1.2),(1.06,1.37),(.70,1.62)],.405,edge,root,.035)
        box('Coral forged eye socket',(0,0,1.72),(.49,.58,.55),coral,.10,root)
    else:
        pts=[(-1.42,1.23),(-1.35,1.95),(-.8,2.24),(-.20,2.30),(.52,2.20),(1.13,1.85),(1.60,1.15),(1.17,1.31),(.74,1.62),(.08,1.78),(-.58,1.70),(-1.02,1.38)]
        profile('Broader reinforced impact forging',pts,.57,steel,root,.075)
        profile('Layered ceramic spine',[(-1.25,1.96),(-.78,2.22),(-.18,2.28),(.5,2.18),(.83,2.01),(.65,1.85),(.05,1.98),(-.63,1.93),(-1.14,1.76)],.62,ivory,root,.06)
        profile('Wide replaceable chisel tooth',[(1.0,1.96),(1.60,1.15),(1.17,1.31),(.81,1.66)],.61,edge,root,.04)
        box('Twin-lug reinforced eye',(0,0,1.71),(.65,.78,.7),teal,.1,root)
        for z in [.85,1.18]:
            cyl('Double neck compression collar',(0,0,z),(0,0,z+.14),.235,coral,root)
        for x in [-.23,.23]:
            box('Mechanical cheek plate',(x,-.43,1.73),(.12,.10,.49),gold,.035,root)
    cyl('Visible captive axle',(0,-(.43 if upgrade else .34),1.74),(0,.38,1.74),.125,gold,root)
    box('Axle slot',(0,-(.462 if upgrade else .365),1.74),(.12,.02,.025),dark,.008,root)
    grip=empty(name+'_GripAnchor'); grip.parent=root
    contact=empty(name+'_ContactMarker',(1.6 if upgrade else 1.37,0,1.15 if upgrade else 1.2));contact.parent=root
    return root

# Shared matching edges: a tessellated curved patch, with no stacked coplanar overlays.
polys=[ [(-1.65,-1.25),(-.3,-1.35),(.06,-.26),(-.7,.12),(-1.7,-.12)],
 [(-.3,-1.35),(1.44,-1.15),(1.65,-.12),(.06,-.26)],
 [(-1.7,-.12),(-.7,.12),(-.3,1.32),(-1.42,1.18)],
 [(-.7,.12),(.06,-.26),(.72,.3),(.49,1.4),(-.3,1.32)],
 [(.06,-.26),(1.65,-.12),(1.45,1.12),(.49,1.4),(.72,.3)] ]
def surface(x,z):return .08*(x*x+z*z)
def shell(name,state='intact',loc=(0,0,0)):
    root=empty(name,loc); parts=[]
    for i,poly in enumerate(polys):
        cx=sum(p[0] for p in poly)/len(poly); cz=sum(p[1] for p in poly)/len(poly)
        gap=.003 if state=='intact' else .028
        pts=[(x+(cx-x)*gap,z+(cz-z)*gap) for x,z in poly]
        n=len(pts); v=[(x,surface(x,z)+d,z) for d in [0,.22] for x,z in pts]
        f=[tuple(reversed(range(n))),tuple(range(n,2*n))]+[(j,(j+1)%n,(j+1)%n+n,j+n) for j in range(n)]
        mesh=bpy.data.meshes.new('Matched curved ceramic shard'); mesh.from_pydata(v,[],f);mesh.update()
        o=bpy.data.objects.new(name+'_shard_'+str(i),mesh);bpy.context.collection.objects.link(o)
        finish(o,o.name,ivory,.018,root);o.data.materials.append(inside)
        for p in o.data.polygons:
            if p.index>0:p.material_index=1
        if state=='broken':o.location=(cx*.18,-.25-i*.06,cz*.14);o.rotation_euler=(.08*(i-2),.1*(i-2),.04*(i-2))
        parts.append(o)
    # Decorative ancient strata marks stop short of damage seams.
    for j,(x,z) in enumerate([(-1.2,.6),(.98,.7),(-.85,-.72)]):
        pts=[(x+t,surface(x+t,z+.12*math.sin(t*5))-.025,z+.12*math.sin(t*5)) for t in [-.16,-.08,0,.08,.16]]
        line('Intentional mineral stratum',pts,.023,gold,parts[[2,4,0][j]])
    return root,parts

def avatar(loc=(0,0,0),held=False):
    root=empty('5.5-stud stylized scale mannequin',loc)
    for x in [-.49,.49]:
        box('Boot',(x,-.13,.30),(.81,1.13,.55),rubber,.15,root)
        box('Leg',(x,0,1.33),(.78,.78,1.64),teal,.13,root)
    box('Workshop torso',(0,0,3.15),(1.9,.9,1.9),cream,.2,root)
    box('Apron',(0,-.49,3.05),(1.25,.08,1.3),teal,.12,root)
    box('Coral badge',(-.3,-.55,3.5),(.3,.05,.22),coral,.045,root)
    box('Head',(0,0,4.83),(1.4,1.25,1.35),ivory,.24,root)
    for x in [-.25,.25]:box('Simple face eye',(x,-.64,4.90),(.10,.035,.16),dark,.04,root)
    line('Friendly expression',[(-.2,-.65,4.59),(0,-.67,4.53),(.2,-.65,4.59)],.022,dark,root)
    for x in [-1.29,1.29]:
        box('Upper arm',(x,0,3.40),(.57,.70,1.15),cream,.15,root)
        if x<0 or not held:box('Hand',(x,-.04,2.51),(.58,.66,.65),ivory,.14,root)
    if held:
        cyl('Bent right forearm',(1.29,0,2.98),(1.36,-.72,2.78),.27,cream,root)
        box('Closed grip reference',(1.36,-.75,2.78),(.55,.57,.55),ivory,.13,root)
    return root

def newscene(name):
    s=bpy.data.scenes.new(name);bpy.context.window.scene=s
    s.render.engine='CYCLES';s.cycles.samples=20;s.cycles.use_denoising=True
    s.render.resolution_x=1100;s.render.resolution_y=900;s.render.resolution_percentage=100
    s.world=bpy.data.worlds.new(name+' world');s.world.use_nodes=True
    s.world.node_tree.nodes['Background'].inputs[0].default_value=(.65,.75,.8,1)
    s.world.node_tree.nodes['Background'].inputs[1].default_value=.65
    s.view_settings.view_transform='AgX';s.view_settings.exposure=-.55
    s.view_settings.look='AgX - Medium High Contrast'
    box('Neutral presentation floor',(0,0,-.18),(200,200,.2),floor,.0)
    for name,pos,power,size in [('Large key',(-4,-6,10),1600,7),('Soft fill',(6,-2,6),1000,6),('Edge light',(0,5,8),1800,5)]:
        d=bpy.data.lights.new(name,'AREA');d.energy=power;d.shape='DISK';d.size=size
        o=bpy.data.objects.new(name,d);s.collection.objects.link(o);o.location=pos;o.rotation_euler=(Vector((0,0,2))-o.location).to_track_quat('-Z','Y').to_euler()
    d=bpy.data.cameras.new('Honest study camera');c=bpy.data.objects.new('Honest study camera',d);s.collection.objects.link(c);s.camera=c
    return s
def cam(pos,target,scale):
    c=bpy.context.scene.camera;c.location=pos;c.rotation_euler=(Vector(target)-c.location).to_track_quat('-Z','Y').to_euler();c.data.type='ORTHO';c.data.ortho_scale=scale
def render(name):
    s=bpy.context.scene;s.render.image_settings.file_format='PNG';s.render.filepath=str(OUT/'renders'/name);bpy.ops.render.render(write_still=True)

s=newscene('01 Tool construction studies')
pick('Starter',False,(-2.1,0,.9));pick('Reinforced',True,(2.0,0,.9))
cam((6,-12,6),(0,0,1.7),8);render('tools_three_quarter.png')
cam((0,-15,4),(0,0,1.7),8);render('tools_front.png')
s=newscene('01b True side construction view')
for x,up in [(-1.5,False),(1.5,True)]:
    p=pick('Side reinforced' if up else 'Side starter',up,(x,0,.9));p.rotation_euler[2]=math.pi/2
cam((0,-15,4),(0,0,1.7),6);render('tools_side.png')
s=newscene('02 Curved mineral ceramic shell states')
for x,state in [(-4,'intact'),(0,'damaged'),(4,'broken')]:shell(state,state,(x,0,1.65))
cam((4,-15,7),(0,0,1.6),12.8);render('shell_states.png')
s=newscene('03 Scale and grip reference')
avatar((-2.2,0,0),True)
p=pick('Held starter',False,(-.84,-.75,2.78));p.rotation_euler[1]=-.3
pick('Starter beside avatar',False,(2.3,0,.9));pick('Reinforced beside avatar',True,(4.9,0,.9))
cam((8,-16,8),(1,0,2.7),10.5);render('scale_and_grip.png')
s=newscene('04 Gameplay distance composition')
avatar((-2.4,-1,0),True);p=pick('Held starter gameplay',False,(-1.04,-1.75,2.78));p.rotation_euler[1]=-.3
for x in [1,4.3]:
    for z in [1.5,4.2]:shell('Adjacent shell tile','damaged' if x==1 and z==1.5 else 'intact',(x,1.3,z))
cam((10,-19,12),(0,0,2.7),16);render('gameplay_distance.png')

# Authored pose sequence, no physics or player simulation. 120 frames / 12 fps.
s=newscene('05 Authored swing impact break collection')
s.render.resolution_x=720;s.render.resolution_y=540;s.cycles.samples=10;s.render.fps=12;s.frame_start=1;s.frame_end=120
actor=avatar((-2.4,0,0),True)
for o in list(actor.children):
    if o.name.startswith(('Bent right forearm','Closed grip reference')) or (o.name.startswith('Upper arm') and o.location.x>0):
        bpy.data.objects.remove(o,do_unlink=True)
shellroot,shards=shell('Animated ceramic patch','intact',(1.3,.7,3.1))
tool=pick('Animated starter grip',False,(-1.04,-.75,2.78))
cam((8,-16,8),(0,0,2.8),10)
for f,angle,x,y,z in [(1,-.3,-1.04,-.75,2.78),(8,-.95,-1.1,-.6,3.1),(11,.3,-.15,.1,2.2),(13,.42,-.05,.15,2.15),(18,-.2,-.9,-.7,2.78),(28,-.3,-1.04,-.75,2.78),(36,-1.05,-1.1,-.6,3.1),(39,.3,-.15,.1,2.2),(41,.45,-.05,.15,2.15),(48,-.3,-1.04,-.75,2.78),(58,-1.1,-1.1,-.6,3.1),(61,.3,-.15,.1,2.2),(64,.48,-.05,.15,2.1),(72,-.3,-1.04,-.75,2.78),(96,-.3,-1.04,-.75,2.78)]:
    if f in [8,36,58]:angle,x,y,z=-.55,.3,-1,3.15
    tool.location=(x,.7 if f in [11,13,39,41,61,64] else y,z);tool.rotation_euler[1]=angle;tool.keyframe_insert('location',frame=f);tool.keyframe_insert('rotation_euler',frame=f)
upper=cyl('Authored right upper arm',(0,0,0),(0,0,1),.28,cream)
fore=cyl('Authored right forearm',(0,0,0),(0,0,1),.26,cream)
hand=box('Authored hand follows GripAnchor',(0,0,0),(.55,.57,.55),ivory,.13)
shoulder=Vector((-1.11,0,3.6))
for f in range(1,121):
    s.frame_set(f);grip=tool.location.copy();elbow=(shoulder+grip)/2+Vector((.05,.13,-.36))
    for limb,a,b in [(upper,shoulder,elbow),(fore,elbow,grip)]:
        v=b-a;limb.location=(a+b)/2;limb.rotation_euler=v.to_track_quat('Z','Y').to_euler();limb.scale.z=v.length
        for prop in ['location','rotation_euler','scale']:limb.keyframe_insert(prop,frame=f)
    hand.location=grip;hand.rotation_euler=tool.rotation_euler
    hand.keyframe_insert('location',frame=f);hand.keyframe_insert('rotation_euler',frame=f)
for i,o in enumerate(shards):
    for f,v in [(1,(0,0,0)),(12,(0,0,0)),(14,((i-2)*.012,-.025,0)),(38,((i-2)*.012,-.025,0)),(41,((i-2)*.025,-.05,(i%2)*.025)),(60,((i-2)*.025,-.05,(i%2)*.025)),(68,((i-2)*.3,-.6,(i%2)*.4-.5)),(78,((i-2)*.4,-.8,-1.65))]:
        o.location=v;o.keyframe_insert('location',frame=f)
    for f,a in [(60,0),(70,(i-2)*.25),(78,(i-2)*.4)]:o.rotation_euler=(a,a/2,a/3);o.keyframe_insert('rotation_euler',frame=f)
    for f,v in [(1,1),(78,1),(84,0)]:o.scale=(v,v,v);o.keyframe_insert('scale',frame=f)
for hit,count in [(11,5),(39,8),(61,11)]:
    for i in range(count):
        a=i*math.tau/count;pos=Vector((1.1,.1,3.2));v=Vector((math.cos(a),-.3,math.sin(a)))*(.5 if hit==11 else .8)
        chip=box('Localized impact chip',pos,(.11,.10,.18),inside if i%2 else accent,.025)
        for f,scale,at in [(1,0,pos),(hit-1,0,pos),(hit,.8,pos),(hit+3,1,pos+v),(hit+6,0,pos+v*1.5)]:chip.location=at;chip.scale=(scale,)*3;chip.keyframe_insert('location',frame=f);chip.keyframe_insert('scale',frame=f)
for i in range(5):
    gem=box('Collected mineral', (0,0,0),(.22,.18,.27),inside,.055)
    start=Vector((.5+i*.3,-.3,2.2));end=Vector((-2.4,-.55,2.8))
    for f,at,v in [(1,start,0),(71+i,start,0),(74+i,start,1),(80+i,(start+end)/2+Vector((0,-.4,1.0)),1),(86+i,end,.6),(89+i,end,0)]:gem.location=at;gem.scale=(v,)*3;gem.keyframe_insert('location',frame=f);gem.keyframe_insert('scale',frame=f)
for name,f in [('Ready',1),('Anticipation',8),('Ordinary contact',11),('Recoil',14),('Precision contact',39),('Final break',61),('Fragment release',68),('Collection',82),('Recovery',94)]:s.timeline_markers.new(name,frame=f)
upgrade=pick('Upgrade reception study',True,(-1.04,-.75,2.78));upgrade.rotation_euler[1]=-.3
for f,v in [(1,0),(95,0),(98,1),(103,1.035),(110,1),(120,1)]:
    upgrade.scale=(v,)*3;upgrade.keyframe_insert('scale',frame=f)
for f,v in [(1,1),(94,1),(96,0),(120,0)]:
    tool.scale=(v,)*3;tool.keyframe_insert('scale',frame=f)
s.timeline_markers.new('Upgrade reception - no economy implied',frame=98)
s.frame_set(1)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'excavation_direction_study.blend'))
for f in range(1,121):
    s.frame_set(f);s.render.filepath=str(OUT/'frames'/('%04d.png'%f));bpy.ops.render.render(write_still=True)
metrics={'blender':bpy.app.version_string,'classification':'geometry and authored motion study; not production assets','scenes':[s.name for s in bpy.data.scenes],'motion_frames':120,'motion_fps':12,'audio':'not produced','uploaded_assets':[]}
(OUT/'study_metadata.json').write_text(json.dumps(metrics,indent=2))
