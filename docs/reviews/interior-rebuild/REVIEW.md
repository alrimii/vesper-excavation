# First shared laboratory interior rebuild

Original place **94763223427049**, branch `planning/development-foundation`. Started from clean **c8ec194cdfbb417af0b75703ade46b3f4dc9678b / published v191**. The exterior is frozen for this milestone, without implying visual approval.

**Delivered: published v192**, confirmed 2026-11-10 19:31:55 UTC by Studio's `publishType=1` success for the original place. Implementation: [c92908d](https://github.com/alrimii/vesper-excavation/commit/c92908dcbadd665c3733a43616d57a05eef902fd). Final evidence is committed alongside this review. Studio is stopped in Edit; artwork frozen, visual approval pending.

## One implemented layout

[Annotated layout](layout.png), [saved comparison cameras](cameras.json).

- Replace the broad repetitive paving with warm stone commons, a defined excavation loop, four broad viewing approaches and separate room/workshop approach finishes. The original continuous collision floor remains; new finishes are noncolliding and flush.
- Remove eight closed inter-room research bays. Retain three recessed research nooks and the existing workshop; four principal viewing terraces have open sightlines to the sealed dome glazing.
- Replace all twelve repetitive front portal assemblies with recessed stone/metal portals, grouped depth variations, attached lighting and selective planting. All twelve personal rooms, room IDs and functional entrances remain.
- Replace old isolated garden/displays with three substantial planted commons and two supported physical specimen studies closer to the excavation circulation. Reuse existing ribcage/skull and foliage meshes; no new asset downloads.
- Re-frame the workshop around its existing physical tools/counter and interaction instances. Integrate the ladder landing with fixed bearing posts/braces; vines follow one support and two selected fixed frame borders outside access clearances.

No functional anchors relocated. `RoomSpawn`, `Threshold`, training, collection/care areas, `OwnerSign`, `NumberSign`, shop `Console`, `UpgradeConsole` and `ApproachZone` retain their original paths and transforms. Personal-room interiors and collection/care redesign remain deferred.

## Evidence and checks

Before, all **Edit mode**: [full overhead](before-overhead-edit.png), [above egg](before-above-egg-edit.png), [workshop](before-workshop-edit.png), [room frontage](before-frontage-edit.png), [ladder](before-ladder-edit.png), [blocked exterior sightline](before-sightline-edit.png). The solid crown occludes the central area in the overhead; nothing was hidden for capture. Existing purple checker geometry is an Edit-mode presentation artifact, not runtime proof.

Final **Edit-mode comparisons**, using the saved transforms and vertical FOV:

| View | Before | After |
| --- | --- | --- |
| Complete overhead | [Before](before-overhead-edit.png) | [After](after-overhead-edit.png) |
| Above egg | [Before](before-above-egg-edit.png) | [After](after-above-egg-edit.png) |
| Workshop | [Before](before-workshop-edit.png) | [After](after-workshop-edit.png) |
| Room frontage | [Before](before-frontage-edit.png) | [After](after-frontage-edit.png) |
| Ladder | [Before](before-ladder-edit.png) | [After](after-ladder-edit.png) |
| Exterior sightline | [Before](before-sightline-edit.png) | [After](after-sightline-edit.png) |

Additional Edit overviews: [east oblique](after-oblique-east-edit.png), [west oblique](after-oblique-west-edit.png). No scene objects were hidden. Viewport crops only; original full-window captures retained privately. Desktop layout after unlock changed the viewport from 1525×752 to 1426×670, so matched camera/FOV comparisons have slightly different aspect ratios.

Actual **runtime**: [workshop](after-workshop-runtime.png), [room entrance](after-frontage-runtime.png), [ladder](after-ladder-runtime.png), [floor-level exterior sightline](after-sightline-runtime.png), [above egg](after-above-egg-runtime.png). One **62-second capture-only session**, 19:27:03–19:28:05 UTC, Automatic graphics. Temporary fixed client cameras; `LabReady=true` naturally. No navigation, mining, purchases, grants, gameplay tests, data manipulation or device changes. The existing memory-only Studio preview balance is visible, not a new grant. [Session/camera record](capture-session.json). No art edits after capture.

### Visible issues and verification limits

- Workshop tool recess is very dark in runtime; the existing HUD partly covers the sign, and a slit above its back display exposes exterior vegetation.
- Room portals remain large/repetitive, and substantial pale open floor areas remain despite the new paths and islands.
- The new viewing gap opens sky/trees/ridge, but the unchanged dome sill blocks much of the lower landscape at floor height.
- Ladder foreground planting is bold and simple; specimen supports and beds still have a straightforward geometric appearance.
- Crown hides the excavation in the true overhead. Existing purple checker geometry appears in Edit captures but is absent from the captured runtime egg view.
- Capture confirms presentation at these fixed viewpoints only. Traversal, shop interactions, all room/training behaviors, persistence, other devices and performance were not tested. No owner visual approval is implied.

[Static preservation/clearance record](static-verification.json): all **97 protected groups/settings match** before and after, including egg/access/central platform, dome/crown/exterior, all room anchors and shop interactions. Twelve unique room IDs remain. Bounds queries found no new colliding objects within the checked twelve entrance corridors, four viewing routes, ladder climbing corridor or workshop approach. These are static checks, not traversal/gameplay tests. Four scoped sources pass StyLua/Selene.

## Removed authoring paths and reused assets

Canonical recipe: `ServerStorage.VesperTools.LabInteriorBuilder`. Superseded constructors in `LivingLabBuilder`, `LivingLabArtBuilder` and `OutfitterBuilder` are replaced with scoped delegates; retired dome/exterior/global-lighting entry points refuse execution. Old `StoneCirculation`, `ResearchGardenIslands`, `ExcavationPlanting`, `FocalResearchDisplays`, `PerimeterPlanting`, room `LivingLabFrontage`/portal dressing and workshop/access framing are removed or replaced. Research bays **2, 4, 5, 7, 8, 10, 11, 12** are removed; **1, 6, 9** remain.

Reused existing imported Quaternius/KayKit CC0 vegetation and original stone-bed/fossil meshes from the [lab-art provenance](../../../assets/environment/lab-art/README.md) and [living-lab asset record](../../../assets/environment/living-lab/README.md). No new mesh/texture IDs, installations or catalog research. Existing unresolved exterior source-rights records remain unchanged.

Private recovery: `C:\Users\BOSS\Desktop\egg\Backups\InteriorRebuild_20261110\`, including `ComingSoon_94763223427049_before.rbxl` (6,629,454 bytes), prior/final sources, scene inventory and full-window captures. Native recovery files are not alternate development places or player-data backups.

Final native: `ComingSoon_94763223427049_final.rbxl`, **6,612,300 bytes**, SHA-256 `43302712553AB662944BB361B1DEC0567BE7073437D208A72D98484BB856224C`. Publication excerpt saved privately as `publication-v192.txt`.

Gameplay, economy, progression, equipment, rewards, joining, fixed save generation and player records are unchanged. Exterior refinements, gate/road, full personal-room/collection redesign, UI/skill-tree work, tools/creatures, rebirth, monetization and worlds remain deferred.
