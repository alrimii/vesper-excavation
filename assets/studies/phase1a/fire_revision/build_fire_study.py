"""Static-only revision. Reuses the accepted starter, mannequin and lighting.
Run with the installed Blender 4.5 executable, --background --python this_file.
Does not execute the earlier animation builder or connect to Roblox.
"""
import bpy, math, ast
from pathlib import Path
from mathutils import Vector

OUT=Path(__file__).resolve().parent
BASE=OUT.parent
TEMP=BASE.parents[2]/'Backups'/'Phase1A_FireRevision_20261109'/'static_views'
TEMP.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(BASE/'excavation_direction_study.blend'))
bpy.context.preferences.filepaths.save_version=0
# Import only reusable geometry/lighting function definitions; no top-level execution.
tree=ast.parse((BASE/'build_study.py').read_text(encoding='utf-8'))
names={'mat','finish','empty','box','cyl','profile','line','newscene','cam'}
exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name in names],type_ignores=[]),'reused_study_helpers','exec'))
floor=bpy.data.materials['Warm neutral backdrop']
starter=bpy.data.scenes['01 Tool construction studies'].objects['Starter']
mannequin=next(o for o in bpy.data.scenes['03 Scale and grip reference'].objects if o.type=='EMPTY' and o.name.startswith('5.5-stud'))

def duplicate(root,name,loc):
    def visit(o,parent=None):
        c=o.copy();c.animation_data_clear();bpy.context.collection.objects.link(c);c.parent=parent
        for child in o.children:visit(child,c)
        return c
    c=visit(root);c.name=name;c.location=loc;return c

forge=mat('Fire study - blued charcoal forging',(.105,.14,.165),.72,.31)
copper=mat('Fire study - warm copper edge bevel',(.68,.25,.085),.72,.29)
cutting=mat('Fire study - pale honed steel',(.65,.72,.72),.8,.27)
brass=mat('Fire study - muted golden bronze',(.71,.40,.12),.65,.32)
ember=mat('Fire study - amber enamel NOT emission',(.95,.29,.035),.12,.29)
shaftmat=mat('Fire study - oxblood enamel',(.25,.037,.028),.3,.33)
leather=mat('Fire study - charcoal leather grip',(.045,.062,.068),0,.7)
wrap=mat('Fire study - warm leather piping',(.19,.075,.045),0,.61)

def bezier(a,b,c,d,n=9):
    return [tuple((1-t)**3*a[k]+3*(1-t)**2*t*b[k]+3*(1-t)*t*t*c[k]+t**3*d[k] for k in range(2)) for t in [i/n for i in range(n)]]
def outline(segments):
    return sum([bezier(*s) for s in segments],[])

def firepick(name,loc):
    root=empty(name,loc)
    # Continuous symmetric crescent; shoulder rolls into integral eye, not stacked plates.
    right=outline([
        ((0,2.43),(.21,2.39),(.38,2.22),(.63,2.16)),
        ((.63,2.16),(1.02,2.12),(1.43,1.86),(1.63,1.12)),
        ((1.63,1.12),(1.31,1.32),(1.02,1.52),(.70,1.64)),
        ((.70,1.64),(.48,1.73),(.29,1.72),(.23,1.47)),
        ((.23,1.47),(.18,1.30),(.18,1.19),(.16,1.08)),
        ((.16,1.08),(.10,1.04),(.04,1.04),(0,1.04)),
    ])+[(0,1.04)]
    pts=right+[(-x,z) for x,z in reversed(right[1:-1])]
    # Integrated bevel rings, with assigned material zones; no overlapping face plates.
    center=Vector((0,1.78));verts=[]
    for inset,y in [(1,0),(.965,-.19),(.89,-.26),(.965,.19),(.89,.26)]:
        for x,z in pts:
            v=center+(Vector((x,z))-center)*inset;verts.append((v.x,y,v.y))
    n=len(pts);faces=[];mats=[]
    for a,b,material in [(0,1,0),(1,2,1),(0,3,0),(3,4,1)]:
        for i in range(n):faces.append((a*n+i,a*n+(i+1)%n,b*n+(i+1)%n,b*n+i));mats.append(material)
    faces += [tuple(reversed(range(2*n,3*n))),tuple(range(4*n,5*n))];mats += [0,0]
    mesh=bpy.data.meshes.new('Continuous forged crescent with integral eye');mesh.from_pydata(verts,[],faces);mesh.update()
    o=bpy.data.objects.new('Single-piece swept fire forging',mesh);bpy.context.collection.objects.link(o);o.parent=root
    for m in [forge,copper,cutting]:mesh.materials.append(m)
    for p,mi in zip(mesh.polygons,mats):
        p.material_index=2 if abs(p.center.x)>1.32 else mi
    b=o.modifiers.new('Small finishing bevel','BEVEL');b.width=.018;b.segments=3
    o.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
    # Warm, inset-looking enamel flame seal; reflective color only, all effects disabled.
    flame=outline([
        ((0,2.14),(.07,2.02),(.23,1.94),(.16,1.80)),
        ((.16,1.80),(.1,1.66),(-.1,1.66),(-.16,1.8)),
        ((-.16,1.8),(-.21,1.93),(-.06,1.99),(0,2.14)),
    ])
    for y in [-.275,.275]:
        seal=profile('Small enamel flame seal',flame,.025,ember,root,.012);seal.location.y=y
    # The socket has the same width as the forged tang and sleeves the shaft.
    cyl('Continuous bronze socket sleeve',(0,0,.88),(0,0,1.23),.205,brass,root)
    profile('Tapered oxblood shaft',[(-.14,-.57),(.14,-.57),(.13,.9),(.11,1.14),(-.11,1.14),(-.13,.9)],.23,shaftmat,root,.045)
    for y in [-.133,.133]:
        inlay=profile('Single shaft ember lozenge',[(0,.81),(.065,.67),(0,.52),(-.065,.67)],.025,copper,root,.016);inlay.location.y=y
    # Palm swell formed by a smooth turned contour, rather than a pile of rings.
    def lathe(name,rings,material):
        v=[];sides=32
        for z,r in rings:
            v += [(r*math.cos(i*math.tau/sides),r*math.sin(i*math.tau/sides),z) for i in range(sides)]
        f=[tuple(reversed(range(sides))),tuple(range((len(rings)-1)*sides,len(rings)*sides))]
        f += [(j*sides+i,j*sides+(i+1)%sides,(j+1)*sides+(i+1)%sides,(j+1)*sides+i) for j in range(len(rings)-1) for i in range(sides)]
        me=bpy.data.meshes.new(name);me.from_pydata(v,[],f);me.update();ob=bpy.data.objects.new(name,me);bpy.context.collection.objects.link(ob);finish(ob,name,material,.018,root)
        for p in me.polygons:p.use_smooth=True
        return ob
    lathe('Ergonomic leather grip',[(-.53,.16),(-.47,.19),(-.30,.205),(.05,.20),(.29,.17),(.35,.17)],leather)
    # One tidy spiral wrap, four turns, no fine noise.
    curve=[((.203 if t<.8 else .186)*math.cos(t*math.tau*4),(.203 if t<.8 else .186)*math.sin(t*math.tau*4),-.44+t*.7) for t in [i/128 for i in range(129)]]
    line('Continuous leather wrap seam',curve,.016,wrap,root)
    lathe('Small grip guard',[(.31,.17),(.35,.23),(.41,.23),(.44,.15)],brass)
    lathe('Forged ember pommel',[(-.82,.07),(-.78,.14),(-.68,.22),(-.58,.23),(-.52,.16)],forge)
    lathe('Pommel copper rim',[(-.69,.222),(-.66,.23),(-.63,.232)],copper)
    inset=profile('Pommel enamel drop',[(0,-.56),(.07,-.65),(0,-.74),(-.07,-.65)],.025,ember,root,.012);inset.location.y=-.225
    grip=empty(name+' GripAnchor');grip.parent=root
    tip=empty(name+' ContactMarker',(1.63,0,1.12));tip.parent=root
    root['Design status']='Static visual proposal only; no fire mechanic or rarity assigned'
    root['Effects']='No emission, particles, bloom or animated material'
    return root

def still(filename):
    s=bpy.context.scene;s.render.image_settings.file_format='PNG';s.render.filepath=str(TEMP/filename);bpy.ops.render.render(write_still=True)

newscene('Fire revision - tool comparison')
s=bpy.context.scene;s.cycles.samples=32;s.render.resolution_x=640;s.render.resolution_y=560
a=duplicate(starter,'Accepted starter - unchanged',(-1.85,0,1.0));b=firepick('Fire visual proposal',(1.85,0,1.0))
cam((0,-15,4),(0,0,1.7),7.7);still('front.png')
cam((6,-14,6),(0,0,1.7),7.7);still('three_quarter.png')
a.rotation_euler[2]=math.pi/2;b.rotation_euler[2]=math.pi/2
cam((0,-15,4),(0,0,1.7),7.7);still('side.png')
a.rotation_euler[2]=0;b.rotation_euler[2]=0;cam((6,-14,6),(0,0,1.7),7.7)

newscene('Fire revision - held scale reference')
s=bpy.context.scene;s.cycles.samples=32;s.render.resolution_x=900;s.render.resolution_y=740
duplicate(mannequin,'Existing 5.5-stud reference mannequin',(0,0,0))
held=firepick('Held fire visual proposal',(1.36,-.75,2.78));held.rotation_euler[1]=.6
cam((6,-17,7),(1.05,0,2.8),7.7);still('held_close.png')
cam((9,-20,11),(1.05,0,2.8),16);still('held_distance.png')
cam((6,-17,7),(1.05,0,2.8),7.7)
# Deliver only the two new static scenes; original file and shell remain untouched.
for scene in list(bpy.data.scenes):
    if not scene.name.startswith('Fire revision -'):bpy.data.scenes.remove(scene)
bpy.data.orphans_purge(do_recursive=True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'fire_pickaxe_study.blend'))
print('Static fire study saved. Five component stills belong to exactly two boards.')
