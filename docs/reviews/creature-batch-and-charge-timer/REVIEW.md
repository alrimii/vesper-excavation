# Three Rodin creatures and physical charge timer — v257

Published to original place **94763223427049** on **2026-11-11 20:11:30 UTC**, branch `planning/development-foundation`. Studio is stopped in Edit. Native before/final recovery and bulky masters remain private under `Backups/CreatureBatchTimer_20261111/`. No occupied servers were shut down.

## Sources and assets

Each folder under `rodin-creatures-source/` uses **base_basic_pbr.fbx**. Alternate FBX exports are the same creature, not additional components. All **28 original files** match their private before copies byte for byte.

| Source folder | New stable catalog ID | Meshes | Vertices | Triangles | Uniform fit factor |
| --- | --- | ---: | ---: | ---: | ---: |
| frost-spirit-mammoth | frost_spirit_mammoth | 1 | 5,438 | 10,872 | 3.79575661 |
| volcanic-sabertooth | volcanic_sabertooth | 1 | 5,120 | 10,236 | 3.87088319 |
| fossil-tortoise | fossil_tortoise | 1 | 5,383 | 10,766 | 4.21206362 |

No decimation, topology edits, hole filling, mesh splitting, texture edits or rig fabrication. Each is one static mesh with its original UVs. Mammoth bone openings, both saber teeth, tortoise fossils/shell and tails remain source geometry. Preparation applies only a rigid orientation and uniform fit, with **floor-centered pivot**, forward **-Z**, and height **4.8 studs** before each surface applies its existing display scale.

All supplied maps are 2048×2048. `texture_diffuse.png` → `SurfaceAppearance.ColorMap` (sRGB); `texture_metallic.png` → `MetalnessMap`; `texture_roughness.png` → `RoughnessMap`; `texture_normal.png` → tangent-space `NormalMap` (data maps treated as non-color). Separate maps are copied unchanged. Inspected files contain no diffuse alpha; the mammoth openings are geometry, not a normal map or opacity trick. Packed `texture_pbr.png`, shaded exports and additional emissive artwork are unused; no packed channels guessed and no lighting baked into color maps.

[Import/fitting details](../../../assets/creatures/rodin-batch/geometry.json), [approved upload IDs](../../../assets/creatures/rodin-batch/uploads.json), [source inspector](../../../assets/creatures/rodin-batch/inspect_source.py), [preparation/icon renderer](../../../assets/creatures/rodin-batch/prepare.py), [canonical installer](../../../assets/creatures/rodin-batch/install.luau). Uploaded models and maps returned Approved. Matching transparent icons were rendered from the imported meshes with their supplied PBR, rather than concept art.

## Shared integration and access

Three distinct entries were appended; existing IDs and creatures were retained. Canonical models live in `ReplicatedStorage.VesperShared.SpecimenAssets.<id>`. `SpecimenBuilder.Source/Build` resolves all three, with `CanonicalCreature`, `PreserveMaterials`, `StaticMesh` and forward/pivot metadata. Small actual-geometry support hulls improve framing of these long creatures without fitting empty bounding-box corners. Older tools/species retain their existing framing path.

The existing paths now resolve these same assets:

- Creature collection cards/details and selection: `ProgressionRules`, `SecondaryMenus`, `EquipmentPreview`.
- Every room's collection shelf and future room builds: existing `CollectionCabinet` / `SpecimenBuilder`; all 12 Edit cabinets refreshed. Feet rest on the supports. Existing three favorite assignments remain server-authoritative.
- Journal/discovery cards: `DiscoveryCatalog`, `DiscoveryHUD`, `SpecimenPreview`.
- Last Egg Results/reward presentation: `ExpeditionResults` uses `SpecimenBuilder.Source` and `EquipmentPreview`.
- Existing central egg reveal: `DiscoveryWorld` already uses `SpecimenBuilder.Build` and its static whole-model branch. No new spawn, care-display or companion system was built; those additional renderers do not currently exist for these species.
- Exact-model icon IDs are registered in both catalogs and canonical metadata; screens that already use 3D viewports continue doing so.

They follow Crystal Triceratops' **test-only acquisition**: `TestOnly=true`, weight 0, reward/bonus 0, TEST label. Normal acquisition is **not configured**. The normal three-entry drop pool remains 80/18/2. No new costs, rarity balance, bonuses or drops were introduced.

In a **fresh v257 server**, owner **291892217** joins through the unchanged isolated Test Mode flow. Open **CREATURES**, scroll to the new cards, select one, and use the existing **Shelf 1/2/3** buttons to mark favorites. All owned species also appear on the room collection shelves. The existing test-profile load loops grant the new ownership/discoveries automatically. Other players keep normal ownership and restrictions.

## Physical charge countdown

The initial floating badge was removed following the owner's correction. The final code creates **only the SurfaceGui on the charge's physical timer**. There is no countdown ScreenGui, BillboardGui or timer above the model.

The old 400×220 canvas and TextScaled's 100px ceiling underused the display. The source OBJ glass was inspected: approximately x −0.248…0.258, y 0.784…1.166, front z ≤0.357 in source coordinates. The overlay now fits inside that glass at **0.40×0.30 studs**, with a rounded near-black fill, **64×64 canvas, GothamBlack 84px cyan digits**, clipped boundaries and 2.5% padding. Its alignment/clearance was corrected without enlarging or editing the explosive mesh. The source digit-removal texture remains unchanged.

Each accepted charge retains its own authoritative server deadline and existing **3.0-second fuse**. The screen still displays 3 → 2 → 1 → 0, with the existing final warning/ember pulse. Existing rope ember, sparks, smoke, audio, rear-plate placement, grip, pending guard, damage, radius, prices, cooldown, validation and cleanup code were preserved. Preview clones have no accepted deadline and acquire no active timer/fuse effects.

## Verification actually performed

- One **249-second Studio memory-only combined session**, using the owner's R15 appearance. All three collection previews loaded with original materials; selection and favorite assignments were accepted through the real server remotes. Each actual shelf display was inspected and photographed.
- Source/factory inspection verified journal, result and static reveal resolution for every new ID. No real egg round was completed, and no reveal/result settlement was fabricated.
- Injected-store profile check: owner grants all three; test Save makes **zero persistent calls**; normal counts retain previous creatures, new ownership stays zero; normal drop pool and 3-second fuse remain unchanged. This is an isolated code check, not a live reserved-server/teleport test.
- Initial combined session also captured the read-only egg documentation states after three normal pickaxe strikes and one charge. Following the owner correction, charge-only checks lasted **61 seconds**, then **76 seconds** for the measured screen fit. Final observer recorded 3/2/1/0, ember present, **zero floating countdown GUIs**, **one Blast**, roughly **3.029 seconds from observed replication to Blast**, one model removal, and no timer/ember objects remaining. These follow-ups did not repeat creature checks.
- Final normal-distance capture: fixed third-person camera, FOV 72, approximately **15.3 studs from the charge** (within the configured 8–42 orbit range), with temporary memory-only support to reach the documented shell section. The camera was positioned so the avatar did not cover the timer. No charge scale change or zoomed-in replacement is presented as normal-distance evidence.
- Five changed canonical source modules match Studio exactly; formatting/diff checks pass. Temporary helpers/supports disappear on Stop. Final native backup saved; original-place publication verified from Studio's successful publish log.

Limitations: physical digits remain small at long zoom because the approved screen is small; this delivery deliberately obeys physical-screen-only presentation. Published Roblox-client joining/teleport, multiplayer latency, other avatar/device layouts and a full reveal/results round were not runtime-tested. Audio effects were preserved and ember observed; the clip is **silent**, not an audio mix review. Output emitted content-representation warnings for IDs **80966883072594 / 76889045966278 / 90769756923866** during shell fracture/debris. These are not the batch's uploaded IDs; their cause was not investigated or fixed in this task. No creature/timer Luau exception was observed. No owner visual approval is claimed.

## Actual evidence

All images are actual Studio memory-only runtime captures; shelf cameras are staged for inspection. Collection cards use the existing interface, not a new mockup.

| Creature | Collection preview | Actual room shelf |
| --- | --- | --- |
| Frost Spirit Mammoth | [PNG](mammoth-collection.png) | [PNG](mammoth-shelf.png) |
| Volcanic Sabertooth | [PNG](sabertooth-collection.png) | [PNG](sabertooth-shelf.png) |
| Fossil Tortoise | [PNG](tortoise-collection.png) | [PNG](tortoise-shelf.png) |

[Final physical countdown: 3, normal distance](charge-countdown-normal.png) · [Final physical countdown: 2](charge-countdown-two.png) · [6.5-second actual countdown/detonation clip](runtime-countdown.mp4) · [Clip timing](clip-timing.json) · [Runtime observations](runtime-observations.json).

The video holds each actual desktop frame until its next recorded timestamp; no generated frames, interpolation or time compression. Only Studio chrome was cropped. Superseded floating-timer captures remain private and are not delivered as final evidence.

[Read-only egg shell findings and intact/damaged/removed evidence](../egg-shell-current-state/REVIEW.md). No egg model, generator, targeting or gameplay source was modified.
