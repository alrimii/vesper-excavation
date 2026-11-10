# Joining and bounded dome / distant landscape checkpoint

**Published v177**, original place **94763223427049**, 10 November 2026 15:36:08 UTC. Branch `planning/development-foundation`. Joining correction commit: [9e9442d](https://github.com/alrimii/vesper-excavation/commit/9e9442dada6ddc3a5b9cd130f6332186f2005b96). Final visual/source delivery is the commit containing this review. Studio finished in Edit; visual implementation is frozen after final capture.

The owner accepts the **distant Foggy exterior direction**, not every defect or this new checkpoint. Historical assessments in foggy-correction/transfer do not override that decision. No source replacement or laboratory-interior redesign.

## Joining

[Diagnosis, exact correction, published-path analysis and remaining real-join check](JOINING.md). Character load completion now gates idempotent physical-tool initialization; missing tools are repaired using the existing selection/ownership rules. ResearchProfiles, Loading, save namespace, ownership values and upgrade values are unchanged.

**Publication distinction:** the attempted separate joining publication was actually a cloud save. Generic PublishSuccessful in the save log was initially misread; the detailed log says Saved new changes, not Published new changes. The separately saved native joining checkpoint is intact, but a joining-only live publication was not achieved. The first confirmed live release is v177, with both corrections. Final log explicitly reports Published new changes, place 94763223427049, and Add publish notes to v177. Cached game.PlaceVersion remains 128 and is not the publication authority.

## Implemented presentation

- Retained the existing private-source Foggy landscape, terrain seating, gazebo and foreground placements. No lift of the whole transferred scene or close foliage against the dome.
- Added continuous grounded distant terrain rings (radius 980–3200), middle wooded slopes and pale farther ridges. The tree line reuses the already imported source canopy mesh `87782436536409` and corrected leaf/roughness maps `137012180294436` / `113355786572368`. 60 repeated canopies and 1,152 simple slope wedge parts; no new third-party uploads. These are simple distant silhouettes, not detailed accessible terrain. Rendering cost was not profiled.
- Replaced Glass on the existing enclosed panels with matte SmoothPlastic, RGB 94/115/110, transparency 0.9, reflectance 0. Collision and access boundaries are retained. Meridian/latitude frame widths are 1.5 with dark neutral divisions. No overlapping extra glazing surfaces.
- Reused the top 24 panels as the solid metal crown. Added attached cross-braces, fixed winch housing, cable guides and four stowed grippers. Small fixed casing seam oxidation and rim moss leave moving routes clear. Walkway supports, access platforms and ladders are untouched.
- Replaced disappearing delivery cables with `DeliveryHoist`, driven by unchanged DeliverySequence samples. It descends with the existing egg lift, opens on the existing release, and uses the existing retraction to return to the crown. No new wait, round state, reward or camera sequence. Moving parts are client-only/noncolliding and removed outside delivery.
- Atmospheric haze/density adjusted modestly to connect the layers. Existing sky remains blue. Existing baked forest templates remain retained but undisplayed: the comparison still did not provide a useful grounded background. Opaque continuous geometry plus matte glazing resolves reliance on the failed alpha-through-Glass path; it does not claim that the old bake itself was repaired.

Canonical paths: `ServerStorage.VesperTools.DomeLandscapeBuilder` (new Edit-only recipe), `ReplicatedStorage.VesperShared.DeliveryHoist`, `...EggLifecycle`, `ServerScriptService.Vesper.RoomAllocator`, `...ExcavationService`. The historical FoggyGazeboBuilder now refuses to overwrite the accepted new layer checkpoint. New terrain/hoist geometry is saved natively and reproducible from the recipe with existing native templates.

## Actual runtime captures and bounded check

One desktop session, **102.744 seconds**, no device change, character navigation, mining, purchase, currency grant or server-round mutation. The prepared runtime camera worked on its first attempt. These are cropped actual Studio **Play/client screenshots**, not Edit renders or Blender images. Full windows remain private. HUD and its pre-existing Studio preview grants are unchanged.

| View | Actual capture |
| --- | --- |
| Normal player-height exterior | [central-runtime.png](central-runtime.png) |
| Offset continuity | [offset-runtime.png](offset-runtime.png) |
| Wide dome/crown/interior | [wide-runtime.png](wide-runtime.png) |
| Normal stowed mechanism, elevated inspection camera | [hoist-runtime.png](hoist-runtime.png) |
| One client-only cosmetic hoist traversal, elevated inspection camera | [delivery-cosmetic-runtime.png](delivery-cosmetic-runtime.png) |

Client LabReady and EquipmentReady were true, Field Pickaxe had Handle and RightGrip. Removing only the in-memory physical tool once produced exactly one equipped replacement; cash stayed unchanged. No tool strike was performed. One cosmetic hoist traversal of the production module sampled the unchanged 16-second sequence: lowest gripper Y=101, highest Y=237.5, zero remaining moving parts after completion. The server egg stayed in its ordinary round; this is not a full egg-transition/reward or delivery-proxy alignment test. No server errors were observed in the session log.

Static checks: affected live/canonical sources compared; ResearchProfiles and Loading unchanged. Selene using a private copy of the existing Roblox standard library reported **0 errors / 0 parse errors, 5 warnings** (unused local in builder, shadowed local in equipment routine, and three pre-existing service warnings). Syntax was parsed by StyLua; no gameplay/persistence suite was run. Twelve rooms and 8,160 egg sections remain. Streaming stays disabled as before.

## Frozen shortcomings / verification gaps

- Far ridges remain broad, visibly angular low-detail shapes. The repetitive canopy line is more regular than the source composition; some foliage edges look detached. Mountains and wooded slopes are not yet richly differentiated.
- Mist is modest; the saturated existing blue sky remains more prominent than the source's muted atmosphere. This is not exact Blender fidelity.
- Crown underside is quite dark and has thin bright seams between some panels. Fixed machinery details and weathering are small from floor height. No correction was made after capture.
- The original gazebo remains secondary/mostly hidden behind frontage. Elevated delivery inspection exposes low-detail ground and transitions that normal player-height views hide.
- HUD obscures parts of the runtime captures and remains visually unapproved. Interior redesign is deferred.
- Real published fresh/existing-profile joining, saved nonstarter equipment, respawn, real-network delays, mobile/performance, tool attacks and a full server-driven egg handoff remain unverified. Owner should rejoin the actual experience and confirm entry, equipped tool use and unchanged progress.

## Recovery / provenance / preservation

Private `C:/Users/BOSS/Desktop/egg/Backups/JoinDome_20261110/`:

- `ComingSoon_94763223427049_before.rbxl`: 5,974,580 bytes, fresh pre-edit full native recovery.
- `ComingSoon_94763223427049_joining.rbxl`: 5,975,010 bytes, distinct equipment checkpoint.
- `ComingSoon_94763223427049_visual.rbxl`: 6,018,711 bytes, pre-check implementation.
- `ComingSoon_94763223427049_final_v177.rbxl`: 6,018,711 bytes, frozen published implementation.
- `src/` pre-edit sources, implementation helpers, full capture windows and `recovery-manifest.json`.

Backups are recovery copies, never opened as implementation targets; restoration untested. They do not back up DataStores or guarantee independent hosted bytes. No reset, migration, deletion or explicit production player-data write. Economy/progression/skills/rewards, rooms/training, shop, mining authority and UI are retained; only narrow character/equipment integration and cosmetic lifecycle code changed.

Original downloaded scene and restricted derivatives remain private. Existing [provenance and unresolved constituent/Maxtree rights](../blendkit-gazebo/README.md) remain unresolved; no clearance claim or raw library in Git. No new asset catalog search/download. Installed executable `.tools/blender-5.2.3-windows-x64/blender.exe --version` reports Blender 5.2.3 LTS (build 22 October 2026), the existing inspected installation. No Blender scene edits or renders were needed for this native pass; no older executable was used. Fresh web verification of latest stable was inconclusive (official download fetch blocked), so no new latest-release claim is made.

[Deferred work remains in the existing development plan](../../DEVELOPMENT_PLAN.md). No next milestone is started. Owner visual approval and real-game verification remain pending.
