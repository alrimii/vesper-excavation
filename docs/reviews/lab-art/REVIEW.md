# Living laboratory art pass — published checkpoint 156

Original place **94763223427049**, universe **10773858644**.
Branch: **planning/development-foundation**. Baseline: v149,
`d7ae610d48db7fd9a8c79b17f1d9bbd6d62f101b`.
Direction accepted as a foundation only; this execution is **not visually approved**.

## Actual runtime captures

One desktop capture-only session: **2026-11-10 11:56:25–11:57:36 UTC**, approximately
**71 seconds including start/stop calls**. Five predeclared cameras; no device switching,
character navigation, mining, purchases, grants or tests. Normal initialization reached
LabReady without bypassing readiness. Camera positions changed only in the temporary client
session. Studio is stopped in Edit mode.

| Capture | View |
|---|---|
| [Overview](overview.png) | Dome, retained egg, exterior depth and interior distribution |
| [Central planting](central.png) | Player-height egg, planted crescent and stone |
| [Workshop](workshop.png) | Player-height recessed workshop and actual equipment |
| [Fossil/frontage](fossil.png) | Player-height mounted specimen, room frontage and waterfall |
| [Ladder/landing](access.png) | Player-height preserved access and planting |

These are actual Studio runtime viewport crops, not Blender renders or concept images.
No scene elements were retouched. Existing HUD remains visible. The 100M currency/tools
shown are the **pre-existing memory-only Studio preview behavior**, not new grants or
published-player defaults. Screenshots do not verify gameplay, physical-device usability
or visual approval. No implementation fixes were made during or after capture.

## What changed

- Replaced the coarse exterior ring with ten unequal near/middle landscape groupings,
  varied tree families and rock ledges, eleven distant ridge placements, and two composed
  waterfall source/fall/pool assemblies. Outside remains scenery only; no exit/gameplay.
- Actually imported and placed fourteen Quaternius Standard and two KayKit Free assets.
  Their materials share a harmonized color/alpha atlas; red foliage was adapted to green.
  See [exact sources, licenses and modifications](../../../assets/environment/lab-art/README.md)
  and [real Roblox asset IDs](../../../assets/environment/lab-art/asset-manifest.json).
- Replaced 408 oversized flat slabs with four shared meshes comprising shaped/chamfered
  radial stones, deliberate joints, boundary courses and subdued ambientCG Rock004 detail.
  Original continuous collision floor retained; decorative slabs are noncolliding.
- Replaced small platform planters with four substantial crescent beds, mixed foliage,
  three planted research-garden destinations, portal planting and attached landing pocket.
- Added two large mounted ribcage/skull displays; enlarged selected fossil alcoves and
  varied mineral shelving. Existing jars, samples, collection systems and original skull/
  ammonite assets were retained. Their model quality is not thereby approved.
- Lowered oversized room architectural walls/roofs/headers to 60% original vertical scale,
  and laboratory/workshop envelopes to 80%, around floor height. Room floor plans, entrance
  width, spawn positions, collection shelves and training anchors were retained. New
  portal piers, angled bay framing and planting help expose the landscape above frontage.
- Retained recessed workshop location, actual equipment and interactions. Added stronger
  header framing, attached warm task lighting and roof planting. No shop UI/tool redesign.
- Retained ladder/deck dimensions and added noncolliding support shoes and a bracketed
  landing planter outside the deck. Balanced daylight against warm, darker research bays.
- Removed developer-facing FUTURE/IMPLEMENT/PLANNED text from decorative room labels.

## Hanging machinery and exact sources

The obsolete client-generated rig lived under
`Workspace.LocalExpeditionPresentation`, generated every session by
`ReplicatedStorage.VesperShared.EggLifecycle` (`src/EggLifecycle.luau`):
`MovingYokeX`, `MovingYokeFront`, `MovingYokeBack`, and numbered
`UpperArm`, `Forearm`, `Cable`, `Grip`, `Shoulder`, `Elbow`,
`PistonBarrel`, `PistonRod`, `ArmInset` instances. Their constructor and
per-frame arm/yoke transforms were removed, not merely hidden.

Replacement: `Workspace.VesperLab.CrownDeliveryDock.AttachedCrownBridge` cross-members
join the dome crown, with `DeliverySocket1..4`. The existing lifecycle presentation
creates `AttachedDeliveryCable1..4` only during Delivering and destroys them afterward.
They connect the saved sockets to the delivery proxy height. Shared selection, proxy
motion, access retraction, reveal and server transition authority are retained.
**Delivery/hatch/transition execution was not exercised in this capture-only session.**
The original `CinematicFixtures` container contains no remaining BaseParts.

Saved authoring source:
- `ServerStorage.VesperTools.LivingLabArtBuilder` / `src/LivingLabArtBuilder.luau`.
- `LivingLabBuilder` now refuses its older foundation recipe after LivingLabArtRevision.
- `OutfitterBuilder` delegates to current workshop framing.
Historical backup scripts remain archived in ServerStorage and are not runtime generators.

Main replaced visual roots are `VesperLab.StoneCirculation`, `ExcavationPlanting`,
`DecorativeExterior`, `PerimeterPlanting`, and each room's `LivingLabFrontage`.
Added roots include `ResearchGardenIslands`, `FocalResearchDisplays`,
`AccessArtIntegration`, `CrownDeliveryDock`; workshop additions are under
`SharedWorkshop.ArtFraming`.

## Static preservation / synchronization evidence

Before and after capture, property signatures matched the retained baseline:
- Egg: **8169:1262027104**, including part paths, transforms, sizes, collision, colors,
  materials, transparency and MeshPart IDs.
- Excavation access: **1976:3609900555**, part paths, transforms, sizes and collision.
- All twelve RoomSpawn and TrainingSpot CFrames match; no anchor mismatches.
- Four changed/new canonical Lua sources match their active Edit-mode instances after
  line-ending normalization. Historical archived backups are intentionally not overwritten.
- All decorative exterior parts have collision/query/touch disabled. Existing dome
  enclosure is retained. No save generation, profile data, reward, economy, reach,
  damage or training-rate code was changed.

These are source/property inspections, not collision traversal, persistence or gameplay tests.

## Visible issues recorded at capture — still open

1. **Landscape quality:** distant mountains remain simple, smooth pointed silhouettes.
   The waterfall still reads as a straight pale sheet between stacked rock towers on a
   rounded mound. Source/pool geometry exists but the receiving basin is obscured from
   these interior views. Rock/tree silhouettes at its top appear precarious or disconnected.
   This is not a fully resolved convincing natural waterfall.
2. **Interior composition:** broad paved areas still dominate several views; room fronts
   remain recognizably repetitive. New destinations and lower roofs improve distribution,
   but do not establish final environment quality. Distant paving joints form dense
   dotted/aliased lines and the stone pattern remains visibly repeated.
3. **Planting/material cohesion:** imported leaves have visibly fine/noisy edges at some
   distances; the large smooth green shrub beside the fossil contrasts with the finer
   leaf meshes. Central planting is more substantial but still low relative to egg scale.
4. **Fossil quality:** the ribcage is recognizable but angular/repetitive; the existing
   skull remains simple. The end-on player-height view foreshortens the specimen.
5. **Workshop:** the unchanged HUD obscures much of the main sign in the selected view.
   Existing equipment models and simple counter remain provisional; neighboring
   architecture is only partly included in this close capture.
6. **Access:** the camera is dominated by the egg at right, and the landing pocket is
   largely hidden behind/above the deck. Thin ladder/support geometry and the broad
   undecorated platform remain visually utilitarian. Climbing was not exercised.
7. **Lighting/presentation:** central egg/undersides are relatively dark against the
   bright sky; existing white frontage and dome rib grid remain visually strong.
   The HUD itself is outside this pass and remains unapproved.

No correction loop followed these observations. No additional Edit-mode or runtime
captures were used to conceal the issues.

## Existing log observations and limitations

The capture log contains Studio debugger send failures, local-secrets parse failure,
preset-chat HTTP403/social-service request errors and a telemetry timeout. Normal
initialization still completed. The reviewed capture interval did not show a project
Lua stack trace; this limited log inspection is not a claim that the game is error-free.
Native FBX import previously showed File Geometry warnings; final imported dimensions
were normalized to authored bounds, but the warning details were not fully established.

Unverified: mobile performance/readability, all gameplay interactions, collision traversal,
shop approach behavior, room collection updates, live profiles, egg completion/reveal/
delivery, distant foliage quality on low settings, asset availability on every client.
No benchmark or test suite was run. Static triangle/light inventory is in the asset README.

## Native backups, save and publication

Private folder:
`C:\Users\BOSS\Desktop\egg\Backups\LivingLabArt_20261110_141750\`

- `ComingSoon_94763223427049_before_art_pass.rbxl` — **4,185,635 bytes**;
  complete native original-place recovery copy created before editing.
- `ComingSoon_94763223427049_art_checkpoint.rbxl` — **4,440,042 bytes**;
  completed Edit-mode implementation saved before the final capture.
- Pre-edit source/assets/docs/AGENTS copies also retained privately.

Native files preserve the DataModel/scripts/instances and asset references, not all remote
Roblox-hosted asset bytes or player DataStores. Source glTFs, Blender files, textures and
FBX exports preserve the new editable art separately. Restoration was not tested.

Publication to the same original place succeeded at **2026-11-10 11:58:32 UTC**.
Studio log confirms **publishType=1**, **PublishSuccessful**, place **94763223427049**,
“Published new changes,” and **“Add publish notes to v156.”** No audience settings changed.
Intermediate native-copy saves created saved versions; this delivery's actual publish is
**version 156**. No duplicate playable place or staging world was created.

This checkpoint is frozen for the owner's review. UI/menu/tree, room decoration, broader
world quality, creature art and future progression remain unapproved/open.
