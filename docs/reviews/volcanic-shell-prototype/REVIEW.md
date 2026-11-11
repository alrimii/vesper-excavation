# Volcanic shell patch — offline visual prototype

Three **actual Blender Cycles renders**, with identical camera, neutral white lights, exposure and 1600×1520 framing:

1. [Intact neighboring pieces](01-intact.png)
2. [The same patch, central piece partially fractured](02-partially-fractured.png)
3. [The same patch, central outer piece removed](03-removed.png)

This is a small offline prototype, **not an installed Roblox egg**. No Studio connection, gameplay session, live geometry change, asset upload or Roblox publication was performed. The previous v257 game remains unchanged.

## Source and construction

Starting asset: `rodin-volcanic-egg-source/base_basic_pbr.fbx`, **one mesh, 4,150 vertices / 8,296 triangles**, with its actual UV atlas. Alternate FBX exports were not added as components. All ten original source files were copied privately and verified unchanged by SHA-256.

The supplied 2048² maps are connected separately: `texture_diffuse.png` to Base Color (sRGB), `texture_metallic.png` to Metallic, `texture_roughness.png` to Roughness, and `texture_normal.png` through a tangent-space Normal Map node. Data maps use Non-Color. The packed PBR, shaded image and emissive map are unused; there is no guessed packing, added glow or lighting baked into a new color texture.

The source atlas is transferred to **one continuous curved master patch** using barycentric interpolation of the actual FBX UV triangles. The surface follows the current egg equation from [ExpansionV3](../../../src/models/expansion-v3/build.py): radius parameter 40.8, height 104.04, approximately 82.96 overall width, with the existing 0.18 egg asymmetry. Only this small patch was evaluated; no complete replacement egg was generated. This is newly partitioned geometry fitted to the game's envelope, rather than an unchanged cutout from the differently proportioned source egg.

The approximately **13.6×12.6-stud** parameter patch is partitioned into **ten varied cells**, using unequal seed positions and one shared gentle boundary warp. Their pre-seam boundaries form a complete partition of the master. The cells are clipped from that shared surface, not assembled from independent chunks. Nominal seams are **0.018 stud**, without bevels, tabs or tiny slivers. Cell areas are approximately 13.47–19.23 square parameter-studs. Analytic normals preserve smooth shading across joints.

All pieces retain the same source-atlas addresses at corresponding surface points: the orange marking crosses multiple joints without restarting per piece. Boundary generation is independent of orange pixels. The original marking contour visible near the bottom is supplied artwork/normal detail, **not a structural crack**.

There are **three nested layers, ten pieces each**, spaced **0.55 stud** inward along the current egg normal. Each has closed back and cut faces and **0.538-stud real thickness**, leaving nominal 0.012 clearance. The outer front uses the supplied charcoal-purple/amber PBR unchanged. The two inner fronts retain the same maps with modest warm-plum and ember-brown color grades; cut surfaces use coordinated matte volcanic colors. The exposed top/right perimeter shows the three strata.

The central outer piece has a matching **five-chip closed fracture set**, cut from that same piece with the same UV field. The partial state opens narrow real gaps, lifts chips 0.025–0.073 stud and tilts them at most 1.6°. All chips remain; the removed state hides only that outer piece and exposes the closely fitted second layer.

## Private editable delivery and checks

Everything below remains ignored/private under `Backups/VolcanicShellPrototype/`:

- `VolcanicShellPrototype.blend`: packed source maps, hidden original FBX/reference master, editable pieces and **timeline frames 1/2/3** for intact/fractured/removed.
- `prepare_prototype.py`, source inspection and export/verification helpers.
- `exports/VolcanicPatch_intact`, `VolcanicPatch_partially-fractured`, `VolcanicPatch_removed`, each in **GLB and FBX**.
- Original copies, source hashes, geometry metrics and verification JSON.

Actual GLB re-import checks found **30 / 34 / 29 meshes** for the three states, all with UVs and closed edges after merging coincident normal/UV split vertices. Exported totals are **49,620 / 50,416 / 47,820 triangles**, largest piece **1,836**. A visibility-selection issue that initially omitted the fracture chips from the export was corrected using static export copies and rechecked. The saved blend's three states and unchanged camera were also checked. The unseamed partition area error was below 3×10⁻¹⁴; no tiny-piece or open-edge check failed.

GLBs deliberately contain **geometry, normals and UVs without materials**; the blend is the material authority. The inner color-grade nodes would need explicit Roblox material preparation/baking to color-only working maps, without baking lighting. Roblox importer behavior, collision fidelity, texture delivery and runtime performance have **not** been tested. These renders are visual review evidence, not runtime screenshots or generated illustrations.

## Mapping to the current excavation system

The [existing shell inspection](../egg-shell-current-state/REVIEW.md) and focused source reads confirm the following. **This prototype is not yet a drop-in replacement.**

- **Section identity and counts can remain.** A reviewed full layout could assign each irregular cell one existing `L<layer>_R<row>_C<column>` ID, keeping 2,720 sections per layer, permanent-row membership, HP/resource attributes, round counters and rewards. This file includes illustrative ID labels only; it does not replace real sections. Matching cell footprints across layers preserve the current same-row/column outer-to-inner relationship.
- **Hit detection can retain a single whole `Plate` MeshPart under each section.** [ExcavationService](../../../src/ExcavationService.luau) registers that part and [ToolContact](../../../src/ToolContact.luau) checks real rays against its parent section. Each fitted mesh would need a correctly placed surface `Center`, proper query/collision settings and reviewed collision fidelity. Partial cracks should remain cosmetic while the original whole Plate stays authoritative until break, as today. A raised chip must not become a second mining target.
- **The current row-template architecture must change for this layout.** [InstallExpansion](../../../src/InstallExpansion.luau) rotates one mesh per row across 68 columns. [ProgressiveFractureBuilder](../../../src/ProgressiveFractureBuilder.luau) fractures those row prototypes, while [ShellMotion](../../../src/ShellMotion.luau) and the server debris payload look up `L<layer>_R<row>`. These unequal cells and their atlas UVs cannot share one repeated row shape. A piece/SectionId-specific manifest or explicit `FractureKey` is needed, with matching preload assets, fitted chip transforms/pivots/normals and debris lookup. New per-piece UVs also require an asset/memory budget review rather than assuming today's 120-template instancing cost.
- **Neighbor effects need actual adjacency.** ShellMotion's cosmetic ripple searches row/column offsets ±2. A stored neighbor graph from the partition, or a suitable spatial lookup, would avoid missing true neighbors after irregular rearrangement. Existing distance-based blast/secondary-hit validation can remain, but updated Centers and variable cell area can change which pieces fall within a radius. Unchanged damage numbers alone would not establish identical behavior.
- **Layer progression/reveal need no new concept**, provided counts, permanent identities, Exposed/Intact/HP transitions and complete-layer gates remain intact. The future authoring/install path must replace the affected mesh and fracture libraries together, preserve closed rims/inner surfaces and prevent a continuous duplicate skin from covering mined holes. Config-only changes or running the historical generator would not accomplish this.

No gameplay compatibility, full-egg layout, pole/sector stitching, runtime fracture motion or owner visual approval is claimed. The regular outside crop is a specimen boundary, not a proposal for rectangular seams on the finished egg. Review these three states before any live implementation or whole-egg generation.
