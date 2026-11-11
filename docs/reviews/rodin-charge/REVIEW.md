# Rodin sticky charge — published v248

Integrated the owner's supplied charge in original place **94763223427049**, preserving the approved pickaxe/drill, corrected grips, owner test access and normal save generation. No visual approval is claimed.

## Source and changes

The actual package contains `base.obj`, not an FBX/PBR alternate: **one mesh, 4,309 vertices, 8,620 triangles, UVMap**. Originals remain unchanged. No decimation, mesh splitting or replacement geometry. A uniform 0.85 fit and rigid orientation/origin adjustment preserve the supplied proportions. The same imported mesh supplies the held tool, placement ghost, anchored placed model, equipment viewport, workshop and rendered icon.

Explicit `texture_diffuse`, `texture_metallic`, `texture_roughness` and `texture_normal` maps feed SurfaceAppearance ColorMap, MetalnessMap, RoughnessMap and NormalMap respectively. Only the baked screen digit regions were neutralized on private working copies of these maps; the frame and surrounding artwork remain. `texture_emissive` contains the static “03” and is not applied. The packed `texture_pbr` is unused; no channel layout was assumed. A self-lit SurfaceGui displays the server-clock countdown. Lighting is unchanged. [Import details and asset IDs](../../../assets/tools/rodin-charge/SOURCES.md).

The charge uses an upright, outward-facing side hold. Placement maps its measured rear plate contact to the validated hit plane with 0.012-stud clearance and timer facing along the hit normal. Placed copies are anchored, noncolliding and contain no copied joints. The local ghost hides during an active placement. The superseded SurveyDynamite source and old import/generation paths are retired.

The existing **0.45-second fuse**, 2.40-second cadence, 280 center power, 6-stud radius, seven-section limit, falloff, costs, upgrades, server validation, effects and cleanup are unchanged.

## Checks actually performed

Two memory-profile verification sessions (178 and 142 seconds), plus a 10-second aborted startup after a source-sync automation error. The first pass found the inverted grip and checked the local ghost and out-of-range rejection; the final pass checked the corrected hold and placement behavior. No real save was used or written.

- Actual owner **291892217 / Alrimi**, R15 avatar: equipped hold and equipment viewport/icon captured.
- Invalid out-of-range request rejected without creating a charge.
- Valid shell placements: countdown observed; Cancel and server-authorized tool switch each removed the pending visual without a blast.
- Exactly **one detonation**: normal Charge/Blast feedback, 1,080 effective damage in the isolated round, target no longer intact and no placed visual remaining.
- Actual operating screen captured at **0.33 seconds**; no fabricated or extended countdown.
- Five Edit-mode surface normals checked for rear contact/orientation; cloned parts anchored with zero copied joints. PBR IDs match across template, equipment and workshop. Ten final canonical sources match Studio; StyLua passes. Helpers removed; native before/final backups saved; Studio stopped in Edit.

Limitations: visual/runtime coverage is one desktop owner avatar and one shell face. Other avatar sizes, multiplayer latency, mobile and published-client play were not tested. The short fuse intentionally makes the countdown brief. The equipment viewport leaves the unarmed screen blank because SurfaceGui does not render there.

## Actual screenshots

- [Final in-hand hold](in-hand.png)
- [Placed charge: real 0.33-second countdown, outward timer and rear plate edge at shell](placed-countdown.png)
- [Equipment preview and charge icons](equipment-preview.png)

[Delivery identity and backup hash](delivery.json). Existing public servers were not shut down; a fresh server running v248 is required for this replacement.
