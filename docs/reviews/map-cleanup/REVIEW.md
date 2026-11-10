# Original-place map cleanup checkpoint

10 November 2026. Original place **94763223427049**, existing universe **10773858644**. HUD/menu/tree design is paused and remains rejected. This checkpoint changes the existing map and its interaction entry points, not gameplay balance or the save generation. No owner visual approval is claimed.

## Implementation and exact source ownership

| Area | Applied implementation | Source |
| --- | --- | --- |
| Central props | Removed all six `Workspace.VesperLab.FixtureHousings.IndustrialLuminaire37` through `IndustrialLuminaire42`, including their housing/support/fasteners; these were orphaned housings without active lamps. Removed `Workspace.VesperLab.AtmosphereDetails`, containing eight `CoolingVent`/`VentMist` assemblies and eight `StatusLens`/PointLights. | `MapCleanupBuilder.Central`; obsolete `DeckLamp`/`DeckLightStem` and `UpperShellLight`/`FixtureDrop` generation removed from `LabBuilder`; central lamp inclusion removed from `FixtureBuilder`; vent generation removed from `SideWorldPolish`; status-lens wait/pulsing removed from live `LabAtmosphere`. |
| Surrounding structure | Replaced 16 `CraneGantry.TowerChord`, 40 `TowerDiagonal`, 20 `TowerCollar`, four `ImpactGuard` and four `GuardStripe` pieces with four slim grounded tower/socket assemblies. Retained the upper crane, cable anchors and their illumination. Replaced 38 `ExcavationAccess.OutboardBrace` diagonals with eight top brackets/eight short knees. | `MapCleanupBuilder.Central`. `DeploymentSections` decks, railings, invisible collision guards and retraction attributes retained. Exact coincident visible rail/post/edge duplicates are removed only if found; none were reported in this application. |
| Ladder | Replaced `ExcavationAccess.AccessRevision4`'s `EntryFooting`, `LadderTransferLanding`, `ClimbableEntry`, `LadderRail`, `LadderRung`, `AccessSign`, `LandingHandrail`, `LandingGuard` with the grounded `LadderEntrance` assembly. Deck top remains 22.005; bottom is central deck top 3.645. Narrow ladder, attached sign, supported landing and open top exit. | `MapCleanupBuilder.Ladder`. Removed the old footing's overlapping deck surface; no arbitrary lighting/transparency flicker workaround. Invisible truss and safety guards have deliberate collision roles. |
| Paths/frontage | Removed detached `Presentation.PortalPier`, `PortalLintel`, `PierInset`, `PierFoot`, `PortalLight` and decorative `RouteLight` pieces; removed their `WayfindingFixtures.RoomRouteSign`, `RouteSignFace`, `RouteAccent`, `SignMount`. Added `RoomConnections.ConnectingPath1..12`, grounded entrance aprons and readable room-number signs. Repositioned existing owner signs while retaining `OwnerSign.Display.Text`. | `MapCleanupBuilder.Rooms`. Utility lamp poles/lenses, room lights and service illumination retained. Room footprint and all 12 spawn positions remain unchanged; direct neighboring-room paths reduce the need to return through the center, not the arena diameter. |
| Shop | Rebuilt `SharedWorkshop` as a 62×38 open-front workshop, with three separated existing-tool benches, attached lighting and a clear entrance. Preserved `Console` / `UpgradeConsole` prompts. Added `ApproachZone`. | `MapCleanupBuilder.Shop`, `WorldInteractions`, `ExcavationClient`. Existing shop UI/purchases unchanged. One auto-open per entry; 2-stud exit hysteresis; an entry blocked by another menu is consumed rather than queued. Poll 0.15 seconds. Manual access remains. |
| Rooms/collection | Replaced each `Rooms.Room01..Room12.CollectionShelf` with left-wall, three-column shelves, initially two rows. Three actual catalog entries have models/silhouettes; other bays are expansion space, not invented creatures. Existing display choices mark favorites. Right-rear care space is reserved only. | `CollectionCabinet.Build/Refresh`, `ExpeditionWorld`, `MapCleanupBuilder.Rooms`. Discovery uses actual `Creature_<variant>` ownership attributes, not aggregate species discovery or display selection. Known entries show name/rarity; unknown entries are dark untextured silhouettes. Existing Crownback/variant models are reused and remain artistically unapproved. |
| Training | Moved the existing station to the right front, away from the main spawn/entrance route. Enter the marked 5×4 pad to start; leave to stop. Removed keyboard prompt and teleport/anchoring. Death, ownership loss, unequip and blocking menus stop training. Manual cancellation requires leaving/re-entering before automatic restart. | `ExcavationService`, `RoomAnimation`, `WorldInteractions`; server 0.25-second area check. Existing 2.5-second cycle and strength rules unchanged. No new multipliers or grants. |
| Targeting | Actionable outline/marker require an exposed, nonpermanent current-layer section, active/ready round, head/root reach and an unobstructed head ray. Invalid targets may retain explanatory status but no actionable highlight. | `Targeting`; server validation and reach values unchanged. |

`MapCleanupBuilder` is an **Edit-only** module at `ServerStorage.VesperTools.MapCleanupBuilder`, not a startup world generator. It asserts original place and Edit mode. Runtime collection rebuilding uses the same shelf source. Historical broad builders are guarded against restoring pre-cleanup geometry once `MapCleanupRevision` exists. Existing ServerStorage recovery archives are inert and were not restored or deleted.

Inspected active startup/transition paths (`ExcavationService`, `DiscoveryWorld`, `EggLifecycle`, `DeliverySequence`, `LabAtmosphere`, `RoomAnimation`, `ExpeditionWorld`) do not recreate the removed central housings/vents. Mining, lightning, shell response, delivery/crane and reveal effects remain. **No specific continuously orbiting decorative-object generator was identified**; removal of every object the owner may mean by “orbiting” is not claimed.

## Static review and unresolved items

- Source review and original Edit-mode geometry/property inspection are separate from gameplay verification. Room ownership/spawn paths, equipment prompt paths, existing assets, mining values, material/creature settlements, profiles and the fixed `VesperDiscovery_FreshStart_20261110` generation are preserved.
- The existing `docs/reviews/hud-rebuild/landscape-phone.png` was inspected. Its dark rectangular left/center boundary has **no established cause** from source/Edit inspection. No speculative lighting/GUI patch, device switch or mobile verification was made.
- The existing Edit preview contains a purple checkerboard membrane surface under `Egg.ContainedSpecimen.HatchingVeil`; `DiscoveryWorld` replaces this preview through `MembraneBuilder` during normal initialization. It was not deleted to conceal it or changed as part of the shell architecture.
- Creature model quality, complete world redesign, final equipment-shop UI, HUD and tree replacements remain open. Current models/menu art have not been approved. No new incubation, rewards, skills, prices or progression was implemented.
- No automated tests, gameplay interaction tests, mining, economy actions, save manipulation or device emulation are authorized here. Runtime shop rearming/focus, training cancellation/rates, ladder traversal, collection transitions, targeting, multiplayer and persistence require owner review.

## Recovery

Private pre-edit native backup: `C:\Users\BOSS\Desktop\egg\Backups\MapCleanup_20261110_113627\ComingSoon_94763223427049_before_map_cleanup.rbxl`, **4,123,298 bytes**, plus source/docs/assets/instructions. Complete native implementation copy; not a DataStore backup or a copy of externally hosted asset permissions. File existence/size checked; restoration not tested. Backups are not development targets and are excluded from Git.

## Prepared capture list and freeze

One desktop Play session, maximum five minutes, for photographs only. Wait for natural initialization; if access/readiness fails, capture the blocker and stop. No character movement, attacks, purchases, training, grants or debugging. Camera-only framing, in this order:

1. Central egg surroundings, camera (108,64,-117) toward (0,39,0).
2. Ladder entrance, camera (77,16,-38) toward (52,15,-5).
3. Room gap/connecting path, camera (76,18,224) toward (72,8,277).
4. Physical shop, camera (103,9,18) toward (142,8,0).
5. Assigned personal room, camera transformed from room-local (22,16,-24) toward (-19,9,9).

Stop Play after the five captures. Record observed defects without fixes; freeze implementation for owner review. Capture evidence is not proof of correct gameplay, mobile usability or visual acceptance.

## Capture and publication outcome

One agent-started desktop session, **37 seconds after Play started** (09:00:56?09:01:33 UTC). Natural initialization reported LabReady=true and assigned Room01. No gameplay inputs, device changes, grants or runtime fixes. The client camera requests did not retain the requested distant viewpoints: captures stayed near the spawned character. No camera debugging or second session followed. Retained one useful runtime room view instead of publishing four misleadingly named/redundant spawn views.

- [Personal room ? actual runtime](personal-room.png).
- [Central surroundings ? Edit mode](central-edit.png).
- [Ladder ? Edit mode](ladder-edit.png).
- [Room gap/connecting path ? Edit mode](room-path-edit.png).
- [Physical shop ? Edit mode](shop-edit.png).

The four supplemental Edit screenshots inspect the frozen actual original-place geometry, not a separate scene or another Play session. They are **not runtime evidence**. Screenshots were checked for unrelated private information. Existing Studio preview discoveries/tool ownership/100M credits appear in the runtime image; this checkpoint did not create them or change published starting profiles.

### Findings retained without post-capture fixes

1. Four requested runtime viewpoints were unavailable through the capture camera; runtime central/ladder/path/shop presentation remains unverified.
2. Creature name/rarity labels are too small to read comfortably in the retained wide room view. The existing rejected HUD/guidance covers part of the shelf header/upper-right area. No HUD or label patch followed capture.
3. The three existing creature variants look very similar in the room photograph; existing creature materials/model quality are not approved. Known/unknown rendering was not exercised by changing discoveries; Edit shelves show silhouettes with no owner, runtime shows existing preview ownership.
4. The fixed room footprint still leaves substantial indoor/open travel space; direct neighboring paths and frontage changes do not constitute a compact world rebuild. Old corner machinery/wall styling remains visible.
5. The supplemental central Edit view is partly obscured by a foreground gantry column and the pre-existing checkerboard membrane preview. The corresponding runtime center could not be captured. This does not establish that the membrane is broken in published gameplay or that all sightline problems are solved.
6. The existing explosive model remains a blocky display, and the physical shop/room/world artwork remains subject to owner visual review.
7. The shop display light bars lack visible mounting brackets; their illumination is attached to saved parts, but the visual attachment needs correction in the next approved scope. This was retained rather than patched after the capture freeze.
8. The old mobile dark boundary and the precise identity of the owner's ?orbiting? objects remain unresolved; no mobile capture was performed.

Implementation was frozen after capture: comparison of every canonical source hash against the pre-capture list reported **zero changed sources**. No geometry corrections followed either the runtime or supplemental Edit captures. Only documentation/evidence/save/publication/Git work followed.

### Saved and published

- Final private full native checkpoint: `C:\Users\BOSS\Desktop\egg\Backups\MapCleanup_20261110_113627\ComingSoon_94763223427049_map_cleanup_checkpoint.rbxl`, **4,130,627 bytes**. Existence/size checked; restoration not tested.
- Original-place native Publish succeeded at **09:04:16 UTC**, version **142**, place **94763223427049**, same existing experience. See [minimal publication evidence](publication-evidence.txt). Native Download a Copy also saved the current original place to Roblox before the explicit Publish; neither operation changed save generation or player records.
- Studio finished in **Edit mode**. No main merge or audience/access changes. Existing live servers were not forced to restart; joining published gameplay was not verified.
- Source/property readback established synchronization, not behavior correctness. Shop entry/rearming/menu focus, training movement/cancellation, ladder traversal, targeting and rewards/persistence remain for the owner's manual review. No tests were run.

