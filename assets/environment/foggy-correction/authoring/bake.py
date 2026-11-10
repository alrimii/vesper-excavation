import bpy,math
from pathlib import Path
from mathutils import Vector,Matrix
p=Path('C:/Users/BOSS/Desktop/egg/Backups/FoggyCorrection_20261110/exports');s=bpy.context.scene;c=s.camera;bpy.context.view_layer.update();cm=c.matrix_world.copy()
originals=list(s.objects)
# Prior bake selected every quad, accidentally including non-foliage gradient Plane.301.
far=[o for o in originals if o.type=='MESH'and(o.name.startswith('tree.0')or(len(o.data.polygons)==1 and any(n.type=='TEX_IMAGE'and n.image for m in o.data.materials if m and m.node_tree for n in m.node_tree.nodes)))]
for o in originals:
 if o.type in {'MESH','CURVE'}:o.hide_render=o not in far and o.name!='Plane.300'
right=cm.to_quaternion()@Vector((1,0,0));right.z=0;right.normalize();forward=Vector((-right.y,right.x,0))
# Retain the existing transfer's side coverage; do not add new scenery placements.
for side in [-1,1]:
 for o in far:
  n=o.copy();n.data=o.data;s.collection.objects.link(n);n.location+=right*(side*36)+forward*12;n.hide_render=False
c.data.lens=36/(2*math.tan(math.pi/6));c.data.sensor_fit='HORIZONTAL'
s.render.resolution_x=1024;s.render.resolution_y=1024;s.render.resolution_percentage=100;s.eevee.taa_render_samples=24
for label,angle in [('left',60),('center',0),('right',-60)]:
 c.matrix_world=cm.copy();c.rotation_euler=(Matrix.Rotation(math.radians(angle),4,'Z')@cm.to_quaternion().to_matrix().to_4x4()).to_euler();s.render.filepath=str(p/('forest-'+label+'-clean.png'));bpy.ops.render.render(write_still=True);print('CLEAN_BAKE',label,flush=True)
