"""Offline asset check only; does not launch or simulate the Roblox game."""
import bpy, bmesh, json
from pathlib import Path
from mathutils import Vector

root = Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(root.parent / 'expansion-v3' / 'VesperExpansionV3.blend'))
worst_volume = 0.0
worst_bounds = 0.0
nonmanifold = 0
for row in range(10, 40):
    name = f'L1_R{row:02d}'
    source = bpy.data.objects[name]
    bm = bmesh.new()
    bm.from_mesh(source.data)
    volume = abs(bm.calc_volume())
    bm.free()
    combined = []
    total = 0.0
    for i in range(1, 4):
        piece = bpy.data.objects[f'{name}_F{i}']
        bm = bmesh.new()
        bm.from_mesh(piece.data)
        total += abs(bm.calc_volume())
        nonmanifold += sum(not e.is_manifold for e in bm.edges)
        bm.free()
        combined.extend(v.co.copy() for v in piece.data.vertices)
    for axis in range(3):
        for operation in (min, max):
            a = operation(v.co[axis] for v in source.data.vertices)
            b = operation(v[axis] for v in combined)
            worst_bounds = max(worst_bounds, abs(a-b))
    worst_volume = max(worst_volume, abs(total-volume)/max(volume, 1e-8))
report = dict(templates=30, fragments=90, maxRelativeVolumeError=worst_volume,
              maxBoundsErrorStuds=worst_bounds, nonmanifoldEdges=nonmanifold,
              gameplayTested=False)
(root / 'stage1-geometry-check.json').write_text(json.dumps(report, indent=2))
print(json.dumps(report), flush=True)
assert worst_volume < .001 and worst_bounds < .0001 and nonmanifold == 0
