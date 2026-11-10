Follow-up: the owner accepted this v149 direction as a foundation only. The [v156 environment-art checkpoint](../lab-art/REVIEW.md) replaces its floor/planting/scenery, lowers frontage, adds focal displays and replaces the obsolete hanging rig generator. Captured quality defects remain open; neither checkpoint is visually approved.

# Living discovery laboratory — frozen checkpoint

Original place **94763223427049**, same universe **10773858644**; published **version 149**, 10 November 2026. Branch `planning/development-foundation`. Owner visual review remains pending. Baseline was v144 / `fb867adf475f7a56474e1382e5ed18f6cad3f034`.

## Actual evidence

- [Central dome, unchanged egg and platform planting](central.png).
- [Recessed workshop and neighboring room/laboratory frontage](workshop.png).
- [Ladder, landing, shell and room frontage](stairs.png).

One desktop capture-only session, **11:00:53–11:01:40 UTC (47 seconds)**, no device switch. Three predeclared camera positions; no character movement, mining, purchases, progression grants, simulations or tests. LabReady was initially false during normal initialization and subsequently true. No readiness bypass or implementation correction was needed. Screenshots are crops of the actual Studio client viewport; unrelated desktop information is excluded. Existing Studio memory-only 100M preview credits are visible; this task added no grants and did not change published defaults.

Implementation froze when capture began. No geometry, source, lighting, UI or gameplay correction followed capture. Temporary client camera binding disappeared when Play stopped; no Play-only edits were saved as implementation. Studio finishes in Edit mode.

## Rebuilt and intentionally preserved

- Replaced old dome/wall dressing with 24-sector glass enclosure, connected ribs, light mineral piers and muted blue-green joints. Added two distant rock layers, trees and three static waterfalls behind sealed glazing; no exterior gameplay route.
- Added 408 shaped, beveled stone slabs with deliberate joints and three restrained tones. Recolored existing access structures without changing geometry/collision. Added six planting pockets around platform/ladder/landing plus integrated bay/frontage planting.
- Replaced standalone timber outfitter with a recessed equipment counter at the perimeter (75 degrees, radius 291). Actual existing pickaxe/drill/charge models, tool board, cabinet/worktop and warm task light. Preserved `SharedWorkshop.Console`, `UpgradeConsole`, their prompts and `ApproachZone` integration. Existing shop UI remains unchanged and unapproved.
- Eleven recessed research bays include curated original skull/bone/ammonite meshes, specimen jars and mineral samples. Twelve room entrances share the architectural palette; saved collection shelving, allocation, spawns, training and reserved future-care areas remain intact. No incubation or discoveries were added.
- Removed old `Workspace.VesperLab` roots `Dome`, `Infrastructure`, `ThermalServiceBays`, `FixtureHousings`, `WayfindingFixtures`, `Presentation`, `CraneGantry`, `RoomConnections`, and obsolete `Architecture` children except `ArenaFloor`/`Foundation`; rebuilt only the current necessary visual modules. Old `SharedWorkshop` was replaced at the same canonical path.
- Updated `LivingLabBuilder`, `OutfitterBuilder` delegation, and guards on `MapCleanupBuilder`, `RoofBuilder`, `FixtureBuilder`, `UtilityPolishBuilder`, `PropSupportCleanup`, `ReviewFixtureRefit`, `RetireOrphanFixtures`, `RepairEntryFixtures`, `CinematicLightingPolish`. Older lab/shop/gantry construction recipes already have retirement guards. Active-source inspection found no runtime references regenerating the deleted roots; existing `EggLifecycle` machinery is a separate unresolved item below.

Static pre/post signatures match for all **8,169 egg BaseParts** (path, CFrame, size, collision, color, material, transparency, mesh ID): `8169:1262027104`. All **1,976 access BaseParts** retain path/pose/size/collision: `1976:3609900555`. Twelve room spawns and training CFrames match the pre-edit record. Eleven changed/new Studio sources match canonical files after line-ending normalization. No runtime gameplay/profile/economy/reward scripts changed. These readbacks are preservation evidence, not gameplay tests.

## Defects observed during capture — left open, no fixes afterward

1. **Hanging machinery remains visibly suspended above the egg.** The fixed gantry was removed, while pre-existing client `ReplicatedStorage.VesperShared.EggLifecycle` still creates `Workspace.LocalExpeditionPresentation` (`MovingYokeX/Front/Back`, four UpperArm/Forearm/Cable/Grip assemblies). Read-only source inspection after capture identifies this source. Its cable anchors still use Y=189. Removing the static support exposes an unfinished floating presentation; it was not corrected after the freeze. Round machinery/reveal behavior was not exercised.
2. **Exterior rocks read as large repeated polygonal blocks**, with simple straight waterfall ribbons and small sparse trees. Layering is present, but the distant scenery is coarse and not approved finished environmental art.
3. **The circulation area still feels broad and relatively empty.** The 12 preserved room positions constrain the footprint. Slab courses end with an irregular edge against the unpaved central apron; joints and the abrupt floor transition remain conspicuous. A screenshot cannot establish whether any seam flickers in motion.
4. **Workshop composition remains partly obscured from the prepared angled camera.** The right-hand display is behind a pier/nearer room frontage; equipment labels are small at this distance. This capture does not prove all three products are readable from normal approach positions. No camera retry or layout fix followed.
5. **Fossils/specimens are small at overview distance**, and the new bays remain repetitive. Skull and shelf forms appear in the evidence, but it does not provide a close material/mesh-quality inspection of each specimen. Existing room owner labels and bright threshold strips still contrast with the new architecture.
6. **The ladder remains visually exposed and industrial**, with thin supports against the larger architectural forms. Its existing functional geometry was deliberately preserved; the landing planter does not establish that traversal/mining access is unobstructed.
7. **The unchanged HUD occupies a substantial part of the photographs.** It and the shop/tree/room menus remain unapproved; no UI changes were made in this checkpoint.

Capture-time existing Output includes Roblox platform HTTP 403 errors for preset chat/social access APIs, plus engine/network warnings. No environment-builder runtime error was observed in the inspected excerpt; this is not a complete error-free claim. No diagnostics or tests were launched.

## Verification limits and provenance

Observed: natural Studio loading reached LabReady, actual egg and new environment appeared, three cameras captured the scene. **Unverified:** collision/traversal, exterior containment under gameplay, ladder/platform access, mining/obstruction, approach open/re-arm and purchases, room allocation/collection/training behavior, full round/reveal transitions, live-account loading, asset delivery on other accounts, persistence, mobile appearance and performance. No visual approval is asserted.

Actual external use: four Kenney Nature Kit CC0 GLBs, customized in existing Blender; original fossil/slab/dome meshes. [Exact sources, license, modifications and real Roblox IDs](../../../assets/environment/living-lab/README.md). Fifteen uploaded mesh assets; editable `.blend`, authoring recipe, source GLBs and FBX are committed. Owner reference stays private. No paid resources or installations.

Private recovery directory: `C:/Users/BOSS/Desktop/egg/Backups/LivingLab_20261110_133630/`.

- Before: `ComingSoon_94763223427049_before_living_lab.rbxl`, **4,139,076 bytes**, plus source/assets/docs/instructions copies and owner reference.
- Frozen final: `ComingSoon_94763223427049_living_lab_checkpoint.rbxl`, **4,185,635 bytes**.

These complete native place copies preserve hierarchy and embedded code; externally hosted asset availability still depends on Roblox. New editable/export asset bytes are also preserved in Git. Recovery restoration was not tested. Backups are private recovery copies, never development targets or player-progress backups.

Native Publish (type 1) succeeded at **11:02:33 UTC**, original place ID confirmed, Studio logged “Published new changes” and “Add publish notes to v149.” This is publication evidence, not a subsequent live-server verification. No access-permission, save-generation, economy or progression changes. Stop for owner review; no new UI, skill, rebirth or other content phase begins.
