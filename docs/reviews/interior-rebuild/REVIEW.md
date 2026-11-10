# First shared laboratory interior rebuild

Original place **94763223427049**, branch `planning/development-foundation`. Started from clean **c8ec194cdfbb417af0b75703ade46b3f4dc9678b / published v191**. The exterior is frozen for this milestone, without implying visual approval.

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

The implementation is applied in Edit mode. Final visual review/capture/publication are pending while the Windows desktop is locked; no Play session has been started for this checkpoint yet.

[Static preservation/clearance record](static-verification.json): all **97 protected groups/settings match** before and after, including egg/access/central platform, dome/crown/exterior, all room anchors and shop interactions. Twelve unique room IDs remain. Bounds queries found no new colliding objects within the checked twelve entrance corridors, four viewing routes, ladder climbing corridor or workshop approach. These are static checks, not traversal/gameplay tests. Four scoped sources pass StyLua/Selene.

## Removed authoring paths and reused assets

Canonical recipe: `ServerStorage.VesperTools.LabInteriorBuilder`. Superseded constructors in `LivingLabBuilder`, `LivingLabArtBuilder` and `OutfitterBuilder` are replaced with scoped delegates; retired dome/exterior/global-lighting entry points refuse execution. Old `StoneCirculation`, `ResearchGardenIslands`, `ExcavationPlanting`, `FocalResearchDisplays`, `PerimeterPlanting`, room `LivingLabFrontage`/portal dressing and workshop/access framing are removed or replaced. Research bays **2, 4, 5, 7, 8, 10, 11, 12** are removed; **1, 6, 9** remain.

Reused existing imported Quaternius/KayKit CC0 vegetation and original stone-bed/fossil meshes from the [lab-art provenance](../../../assets/environment/lab-art/README.md) and [living-lab asset record](../../../assets/environment/living-lab/README.md). No new mesh/texture IDs, installations or catalog research. Existing unresolved exterior source-rights records remain unchanged.

Private recovery: `C:\Users\BOSS\Desktop\egg\Backups\InteriorRebuild_20261110\`, including `ComingSoon_94763223427049_before.rbxl` (6,629,454 bytes), prior/final sources, scene inventory and full-window captures. Native recovery files are not alternate development places or player-data backups.

Gameplay, economy, progression, equipment, rewards, joining, fixed save generation and player records are unchanged. Exterior refinements, gate/road, full personal-room/collection redesign, UI/skill-tree work, tools/creatures, rebirth, monetization and worlds remain deferred.
