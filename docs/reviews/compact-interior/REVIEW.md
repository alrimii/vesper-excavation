# Compact interior replacement — published v203, frozen for review

The original place **94763223427049** now contains the compact replacement. Studio confirmed **published v203** at **2026-11-10 21:28:47 UTC** (2026-11-11 local time). Branch: `planning/development-foundation`; starting commit: `bbd3f1bd8994fcb161c57951a7529efebd9142da`. Git delivery identity is recorded in [delivery.json](delivery.json). The original place was the only implementation target. Studio is stopped in **Edit**. Publication is not owner visual approval.

The complete [owner brief](owner-feedback/IMPLEMENTATION_BRIEF.md) and all eight rejected screenshots were read before editing. This checkpoint replaces the old layout and creation code. It does not approve the rejected v192 appearance. No art corrections followed the final capture session.

## Eight references and resulting work

| Rejected owner reference | Replacement and actual evidence | Remaining finding |
| --- | --- | --- |
| [01-room-spacing-and-empty-gaps.png](owner-feedback/01-room-spacing-and-empty-gaps.png) | All twelve original rooms moved into four wings of three; original dimensions and identities retained. Lower dome/foundation refitted to **428 studs maximum width**. [Readable overhead inspection cutaway](screenshots/final-edit-overhead-cutaway.png), [normal-height frontage](screenshots/final-runtime-room-frontage.png), [annotated plan](plan.svg). | Clear distance is now 31–45% of the former distance, not 25% everywhere. Repeated room fronts and broad shared floor remain apparent. |
| [02-rejected-blocky-planter.png](owner-feedback/02-rejected-blocky-planter.png) | Removed block shrubs and obsolete beds; selected finished Quaternius fern, broadleaf, clover and young-tree assets, exposed soil, solid bases and seating. [Planted seating](screenshots/final-runtime-planting.png). | Planting is small relative to the whole court; the young tree's crown reads dark at this view. |
| [03-rejected-skeleton-display.png](owner-feedback/03-rejected-skeleton-display.png) | Entire crude assembly removed. Actual Smithsonian Triceratops scan adapted to a warm uniform finish, 38-stud length, four simplified mesh chunks; colliding plinth, hulls and two mesh-measured bearing posts. [Specimen](screenshots/final-runtime-skeleton.png). | The pale scan is more detailed than surrounding architecture and loses some bone contrast under the task light. Owner acceptance of the stylistic fit remains open. |
| [04-repetitive-planting-bed.png](owner-feedback/04-repetitive-planting-bed.png) | Three purposeful planting compositions replace long repeated beds. Uneven heights, soil and compatible foliage; leaves/stems do not collide. [Workshop botanical bed](screenshots/final-runtime-botanical-bed.png), [planted seating](screenshots/final-runtime-planting.png). | The compositions are restrained and may still need more visual weight; no correction loop was started. |
| [05-white-floor-and-pointless-path.png](owner-feedback/05-white-floor-and-pointless-path.png) | Old radial white strips, floor overlays and route generators removed. Limestone slabs over a fitted foundation, controlled tones and softened 16:00 lighting. [Floor and frontage](screenshots/final-runtime-room-frontage.png). | Dark seams are visible in some floor views; existing personal-room floors remain bright. The global shared floor still occupies a large visual area. |
| [06-rejected-ladder-vines.png](owner-feedback/06-rejected-ladder-vines.png) | Old pasted leaves removed; connected stems, petioles and finished clover clusters on selected fixed ladder/frame/hoist supports. Moving delivery machinery unchanged. [Player-height access view](screenshots/final-runtime-ladder-vines.png). | Vines read small and dark on the shaded access support. The capture does not clearly demonstrate the upper stationary-hoist planting. |
| [07-recessed-laboratory-display.png](owner-feedback/07-recessed-laboratory-display.png) | Old cavity removed; forward 37-stud counter with two finished compound microscopes, small specimen tray, shallow backing and task light. [Laboratory](screenshots/final-runtime-laboratory.png). | Apparatus remains small against the broad back panel. Existing HUD overlaps upper architecture. |
| [08-recessed-workshop-and-tools.png](owner-feedback/08-recessed-workshop-and-tools.png) | Old cavity/framing/display assembly removed; forward 37-stud counter, deliberately reused pickaxe/drill and finished charge bundle. Original equipment/upgrade interaction instances relocated coherently. Same charge meshes replace both functional tool templates' old cells. [Workshop](screenshots/final-runtime-workshop.png). | Existing blue personal-room interiors flank the service frontage; they were deliberately preserved. Shop UI and its existing charge illustration are deferred and unchanged. |

## Dimensions and enclosure fit

Measurements start at the unchanged **74.25-stud outer excavation/access platform radius**, ending at the frontmost entrance architecture along the direct radial line. They are geometric clear distances, not measured walking trials.

| Room IDs | Before clear distance | After clear distance | Fraction retained |
| --- | ---: | ---: | ---: |
| 01, 04, 07, 10 | 190.15 studs | 84.477478 studs | 44.4% |
| 02, 05, 08, 11 | 185.15 studs | 57.850006 studs | 31.2% |
| 03, 06, 09, 12 | 188.15 studs | 84.477478 studs | 44.9% |

Original rooms remain **86.4 × 70.2 studs**. Their wing-local centers are X = -88, 0, 88; Z = 169.1. The departure from the initial quarter-distance target retains these interiors without corner overlap, character/prop scaling or new stairs. Counter centers are (+113.5,+113.5) and (-113.5,-113.5); the specimen is (+114.8,-114.8), all X/Z.

The old dome was approximately 700 studs across. The final lower footprint uses half-width **214**, corner extent **|X|+|Z| = 356**, and 24 fitted sectors. The initial 414-stud proposal intersected room rear corners and was revised to 428 before capture. The original crown/top panes and delivery rim at Y247 remain; 96 new lower mesh panes meet that rim. This is a coordinated enclosure/floor refit, not uniform scene scaling. Exterior geometry, cloud/mist/wind settings and their generators are unchanged. Corner construction pockets and room roof junctions remain visible from above, but no old outer room shells or obsolete annular floor remain.

## Before/after and capture evidence

| View | Before v192 | Final v203 |
| --- | --- | --- |
| Matched above-egg camera, Edit | [Before](screenshots/before-above-egg-edit.png) | [After](screenshots/final-edit-matched-above-egg.png) |
| Readable overhead **inspection cutaway**, Edit | [Before, camera Y560](screenshots/before-overhead-cutaway-edit.png) | [After, camera Y390](screenshots/final-edit-overhead-cutaway.png) |
| Runtime above egg | — | [Actual runtime](screenshots/final-runtime-matched-above-egg.png) |
| Runtime overhead **inspection cutaway** | — | [Actual runtime, HUD partly obscures layout](screenshots/final-runtime-overhead-cutaway.png) |

The final Edit overhead is the primary readable layout image. Dome, crown dock and room ceilings/ceiling fixtures were temporarily hidden for it, then all **504** affected parts were restored. The closer final overhead is explicitly not a matched-distance comparison. The above-egg camera position, target and 70-degree vertical FOV match. Before images were center-cropped from a 1426×670 viewport to the final 1224×670 aspect; no scene pixels were repainted or rescaled. Full-window originals remain private.

Exactly **one 69-second capture-only Play session**, 21:26:00–21:27:09 UTC, provided nine fixed views. The seven close views use camera height **6.5 studs**. No character navigation, mining, purchases, grants, interaction tests, device switches or simulations were performed. The displayed 100M balance is pre-existing memory-only Studio preview behavior, not a new grant. Temporary client camera/cutaway changes were restored before Stop. [Capture record](capture-record.json), [camera poses](cameras.json); the nine saved poses also live in `ServerStorage.VesperTools.CompactInteriorCameras`.

The existing HUD obscures parts of the runtime views; it was not redesigned. Edit captures show the pre-existing purple checker egg preview, absent from runtime. No owner visual approval, gameplay usability, traversal, climbing, shop transactions, multiplayer, persistence, delivery animation or device/performance verification is claimed.

## Replacement cleanup and authoritative source

`ServerStorage.VesperTools.LabInteriorBuilder` / [canonical source](../../../src/LabInteriorBuilder.luau) is the sole active Edit authoring recipe. Its former constructors were replaced, not retained underneath the new arrangement. `LivingLabBuilder`, `LivingLabArtBuilder` and `OutfitterBuilder` are scoped compatibility forwards. Runtime does not build a competing interior.

Removed old roots and assemblies include `StoneCirculation`, `InteriorCommons`, `LaboratoryBays`, `AccessArtIntegration`, old room `InteriorPortal` assemblies/aprons, repeated `PerimeterPlanting`, `ResearchGardenIslands`, `FocalResearchDisplays`, `ExcavationPlanting`, old workshop shells and decorative children, original shared floor/foundation, lower dome panes/frames and four `ChargeCell` parts in each of the two tool templates. Selected original pickaxe/drill assets were explicitly reused on new mounts.

Removed obsolete archived scenery in `ServerStorage.BeforeToolworksPolish_20261109`, `BeforeWayfinding_20261109`, `RetiredPrivateShops`, and the superseded `PlatformFinish`, `CollectionApron`, `FloorMarkings`, `RouteDetails`, `ObservationConsole1..4` entries inside `RoomRebuildArchive`. Private native/source recovery retains the old version. No rejected scenery was hidden underground, outside the dome, transparent or disabled as a cleanup substitute.

[Retired generator ledger](retired-generators.json) lists the removed creation paths. Older LabBuilder, MapCleanupBuilder, RoofBuilder, FixtureBuilder, PresentationBuilder and polish/repair entries now refuse execution; standalone DiscoveryEnvironment, UpgradeWorldBuilder, SharedWorkshopBuilder, ToolworksPolishBuilder, WayfindingPolishBuilder and PlatformPolish are retired. `AssetIntegration.Lighting` is retired; its Tools behavior remains. Empty `ResearchGallery` and `CinematicFixtures` containers remain as runtime dependencies, with zero decorative descendants. In particular, DiscoveryHUD waits for ResearchGallery, so deleting that container would break readiness.

All twelve original room Models, RoomSpawn/Threshold/training/collection instances and ownership IDs remain. Each room and its world-space CFrame attributes, including PracticeEgg/PressHead RestCFrame, were moved by the same transform. All **39 FunctionalAnchors** still reference their original instance paths. Workshop Console, UpgradeConsole and ApproachZone were moved to the counter without replacing their gameplay authority.

## Verification and assets

[Preservation comparison](preservation-final.json): eight protected roots (six geometry groups plus atmosphere/cloud roots), **81 runtime source signatures**, 39 anchor references, seven atmosphere/wind settings and three cloud settings match the baseline. Egg, access, central platform, crown delivery dock, resource depot and exterior geometry are preserved. Fixed save generation remains `VesperDiscovery_FreshStart_20261110`. No player data or balance/progression/reward/ownership/joining/mining/delivery logic was changed.

[Static geometry checks](static-verification.json) found no colliders in the twelve checked 12×6×24 entrance approach volumes or the two 30×6×10 service approach volumes; no lower glazing/room intersections; no duplicate new roots, obsolete inspected roots, colliding foliage or old ChargeCell parts. Room anchor/rest-pose errors are below 0.00004 studs. [Ladder/source addendum](clearance-addendum.json) records the clear 8×22×8 ladder volume against new decorations. Solid planter/counter/plinth/post collisions and four fossil mesh hulls are present. These bounded queries do not prove every possible route or interaction. Scoped changed source passes StyLua and Selene; fifteen live authoring files were compared/synchronized, with six historical standalone installers absent from Studio.

Actual source meshes, editable Blender scene, exports, geometry renders and attribution are preserved in [asset sources](../../../assets/environment/compact-interior/README.md). The Smithsonian scan was obtained from an explicitly CC0 Innerscene distribution after the museum direct retrieval failed; that source limitation is disclosed. Microscopes and charge are CC BY 3.0, by 3Donimus and Hunter Paramore respectively. Selected vegetation is Quaternius CC0. Mesh attribution is also stored on the imported models/parts.

All four active uploads belong to **291892217**: charge **71037013578643**, fossil **107023481414590**, microscope **100649639061568**, final enclosure panes **108736426745511**. [Manifest](../../../assets/environment/compact-interior/asset-manifest.json). Superseded initial pane upload 120405930482097 is unused; its live templates/instances were removed. Import normalization restored source colors/orientation and recorded mesh correspondence; no scripted catalog models were installed.

## Recovery and owner handoff

Private recovery folder: `C:\Users\BOSS\Desktop\egg\Backups\CompactInterior_20261110\`.

- Before: `ComingSoon_94763223427049_before.rbxl`, **6,612,300 bytes**, SHA-256 `24817EA1B4A8B2443270E1AB5F6F493361455B901E17A6FD6952910A1918E377`.
- Final: `ComingSoon_94763223427049_final.rbxl`, **6,821,403 bytes**, SHA-256 `0E9872FC63E6FDC0C381CDCDAA6951A81BF8065999609DFA1D345BC3F0C26F4F`.
- Full before source, full-window captures, in-progress recovery and publication excerpt are private. These are recovery copies, not alternate playable targets or player-progress backups.

Review the overhead and seven player-height views first, then manually assess room access, climbing, equipment/upgrade approach and delivery in the original place when desired. Gameplay usability remains unverified. Further art changes require owner feedback after this frozen checkpoint.

Deferred: personal-room/collection redesign; HUD, menus and shop UI; skill tree and remaining skills; broader tools/creatures; entrance gate/scenic road; rebirth, monetization and additional worlds. Exterior remains frozen.
