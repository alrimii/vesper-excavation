"""Rebuild only the enclosure using the canonical final section of prepare_assets.py."""
import bpy, json, math
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).parent
EXPORT=ROOT/'exports'
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'compact-interior-assets.blend'))
for o in list(bpy.context.scene.objects):
    if o.type=='MESH' and o.name.startswith('Pane_'):bpy.data.objects.remove(o,do_unlink=True)
allmesh=[o for o in bpy.context.scene.objects if o.type=='MESH']
report=json.loads((ROOT/'geometry.json').read_text(encoding='utf-8'))
report={k:v for k,v in report.items() if not k.startswith('Pane_')}
def select(objects):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:o.select_set(True)
    if objects:bpy.context.view_layer.objects.active=objects[0]
def bounds(objects):
    pts=[o.matrix_world@v.co for o in objects for v in o.data.vertices]
    return Vector([min(p[i] for p in pts) for i in range(3)]),Vector([max(p[i] for p in pts) for i in range(3)])
canonical=(ROOT/'prepare_assets.py').read_text(encoding='utf-8')
exec(compile(canonical[canonical.index('# Build each roof pane'):],str(ROOT/'prepare_assets.py'),'exec'))
