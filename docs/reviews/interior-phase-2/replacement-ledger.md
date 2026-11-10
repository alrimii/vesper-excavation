# Replacement and migration ledger

All paths below refer to the original place. Recovery lives privately in `Backups/InteriorPhase2_20261111/`; no old geometry was hidden or moved elsewhere in Workspace.

## Removed from every Workspace.VesperLab.Rooms.Room01–Room12

- Old `CollectionShelf`, replaced by the new owner-specific modular shelf recipe.
- `MonitorStem`, `Workbench`, `BenchCabinet`, `Drawer`, `DrawerPull`, `BenchStool`, `StoolLeg`: old oversize furniture replaced by imported finished desks and compact supports.
- `WallPanel`, `PanelFrame`, `RearPanel`, `RearSeam`, `ServiceConduit`, `Skirting`, `SpawnLane`, `InnerSign`, both `CeilingFixture` assemblies and their lights: removed. New room-local wall linings, restrained timber details and warm local lights replace them.
- `FrontageAndZones` including `FutureCareSign`, `FutureCareMat`, `CareSignFoot` and `TrainingInstructions`: removed. No COMING SOON or training instruction boards remain.
- Every child of the preserved `TrainingStation` except the exact functional `PracticeEgg` and `TrainingSpot` instances: old `Base`, `Deck`, `Cradle`, `CradleArm`, `CradleHinge`, `ContactJaw`, `Hydraulic`, `PressHead`, `SafetyStripe`, `BenchRearRail`, `Control`, `MachineLabel`, `BenchFinish` and old `Screen`. Replaced by a finished lab workbench, mineral sample, support frame, clamps, small real status display and flush active pad.
- Both old terminal SurfaceGuis are deleted, not left disabled. Existing terminal instances/prompts/page identities remain, with new concise world labels.

The original structural Floor is intentionally reused as the sole floor and refinished in limestone; no old/new floor overlays are stacked. Structural LeftWall/RightWall/BackWall remain intentionally selected exterior boundaries. The old inner panels are removed, then new inner linings are fitted. Phase 1 roof/frontage and exterior faces remain unchanged.

## Deliberately migrated functional references

All twelve room pivots, RoomNumber IDs, RoomSpawn, Threshold, OwnerSign and 39 FunctionalAnchors paths are unchanged. Collection moves from room-local -X to **+X**, the entering player's left wall.

Each existing TrainingSpot moves to local `(-23, 1.3475, -9)`, size `7 × 0.12 × 5`; the existing PracticeEgg contact reference moves to `(-23, 4.9825, -4.4)`, RestSize `3.2 × 3.2 × 3.2`. RestCFrame and target-visual pivot are set from the actual room pivot. PracticeEgg is explicitly a nonrendering/noncolliding functional contact anchor; its superseded decorative assembly is destroyed, not hidden. The visible target is `TrainingTargetVisual.PracticeSample`.

ARCHIVE terminal local position becomes `(26.35, 5.3325, -24)` facing into the room; ROOM terminal becomes `(-34.35, 5.3325, -26)`. `RoomTerminals` uses preserved `RoomTerminalPage`, not the old X-sign assumption. Ownership/distance validation stays in the existing server handler. Existing saved favorites, themes, companion selection and discovery data remain intact.

## Authoritative code and retired paths

- New `ServerStorage.VesperTools.RoomInteriorBuilder` / `src/RoomInteriorBuilder.luau`: sole Edit architecture/training/care recipe, applies to all twelve rooms. It never loads profiles or changes ownership.
- `ServerScriptService.Vesper.CollectionCabinet`: single Edit/runtime shelf geometry and owner-state presentation. `ExpeditionWorld` uses this exact recipe, with catalog-driven attribute subscriptions. No competing shelf builder.
- `RoomAnimation` no longer clones the old `DeliveryShell`/`PracticeShell` presentation; it animates the authored sample and displays actual server TrainingActive state.
- Canonical `RoomRigRefit`, `RoomLayoutRefit`, `TrainingBenchPolish`, `RoomLightingCleanup`, `CollectionCabinetV2` now explicitly refuse execution. They were not installed among the live VesperTools modules. Already-retired RoomExperienceBuilder and other historical world installers remain retired.
- Phase 1 LabInteriorBuilder still owns shared architecture, frontages and roofs; it contains no obsolete personal-room recreation path. It was not executed or changed here.

Removed exact archived room copies and obsolete sources are listed in [archive-removal.json](archive-removal.json): room-only cabinet/training backups, generated primitive training source, twelve room subtrees from terminal/Stage26/Stage30 archives, obsolete collection/room-animation creators, RoomLights and RoomRebuildArchive.TrainingStation. Mixed archives retain unrelated functional/exterior records; no broad deletion of gameplay dependencies occurred.
