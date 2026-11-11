"""Save the final fitted/private Blender master matching the Studio material adaptation."""
from pathlib import Path
import bpy, json
ROOT=Path(__file__).resolve().parents[3]
PRIVATE=ROOT/'Backups/IdentitySlice_20261111'
bpy.ops.wm.open_mainfile(filepath=str(PRIVATE/'AuthoredPickaxe.blend'))
data=json.loads((Path(__file__).parent/'geometry.json').read_text())
shift=next(r['center'][0] for r in data['primitives'] if r['name']=='PK-001.SHAFT')
colors={'body':(52,134,176),'edge':(194,238,249),'trim':(255,188,53),'shaft':(165,97,47),'inset':(30,48,75),'grip':(35,46,67),'wrap':(190,112,58)}
def linear(c):
    c=c/255
    return c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4
for o in bpy.context.scene.objects:
    if o.type=='MESH':o.location.x-=shift
for m in bpy.data.materials:
    color=colors.get(m.name.split('__')[-1])
    if color:
        rgba=tuple(linear(c) for c in color)+(1,)
        m.diffuse_color=rgba;m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=rgba
bpy.ops.wm.save_as_mainfile(filepath=str(PRIVATE/'AuthoredPickaxe-Fitted.blend'))
