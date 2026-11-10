# Interior Phase 2 — published v212

Original place **94763223427049** is saved and **published v212**, verified at **2026-11-10 23:12:41 UTC**. Branch: `planning/development-foundation`; baseline **9449bc1f01f9579497dce2b6cc6edad65145f501 / v208**. [Publication evidence](publication.json). Studio is stopped in **Edit**. All twelve rooms received the reusable replacement; Phase 1 and later phases were not reopened. The owner does not require another sample-room or visual-approval pause. This checkpoint's art is frozen after its final captures; publication is not visual approval.

## Rebuilt across all twelve rooms

The old blue/white interiors, cabinets, oversize benches, room signs, fixtures and training cradle were removed. New coordinated limestone inner finishes, selected timber, restrained metal supports and warm local lights surround three separate areas: entrance-left collection, right-side training and a rear care reserve. The original room shells, roofs, frontages, positions, IDs, entrances, spawns, courtyard and global lighting remain unchanged.

The collection has **four modular bays × three rows = twelve physical slots**, with spare wall length and data-driven catalog population. The current catalog contains **three Crownback variants**, using one existing base creature model; it does not specify a final future collection size. Only those three species/variants receive trophies and labels. The other nine positions are empty expansion space, with no invented locked species or random props. Each specimen fits independently within width/height/depth limits, stands 0.08 studs above its deck and has no shelf/wall/neighbor overlap in the focused bounds inspection.

The server resolves each room's OwnerUserId and reads that player's discovery/favorite attributes. Discovered displays retain the existing model/variant treatment, name and rarity; neutral/unknown displays strip textures and reveal only a dark silhouette and UNDISCOVERED label. The small ownership label names the actual owner. No collection rules/rewards, profile schema, favorite count or creature models were redesigned.

Training now uses a finished Kenney lab workbench, clamped mineral sample, supported light/status frame and flush marked pad. The separate care reserve has a low divider, finished bench/work surface and small integrated planters; no fake incubation controls, timers, reward claims or COMING SOON sign. Solid furniture, shelf decks/supports, bases and planters collide; fine foliage does not. [Asset provenance and temporary policy](TEMPORARY_ASSETS.md).

## Training defect and observed correction

The server's automatic entry loop required **LabReady**, but only `ReplicatedFirst.Loading` writes that attribute on the client. That client-local write does not establish server readiness. In the actual runtime session, server ProfileReady and EquipmentReady were true while server LabReady was absent. The correction uses those existing server-owned readiness flags, validates the current living character/root and owner station, and clears station/session start, target and active state when stopped. Death now explicitly calls the same stop path. Existing room-local detection, menu/manual-stop suppression, ownership authority and awards remain intact. The old relocated RestCFrames were already coherent; stale rest transforms were not the diagnosed failure.

Exactly **one 147.295-second combined session** ran from **23:08:11.624 to 23:10:38.919 UTC**, using the unchanged memory-only Studio profile path. The existing preview already unlocks all three variants and tools; no discovery edits, progress grants, production data writes or reset were performed. Normal Humanoid:MoveTo walking entered the own-room pad and left it; no character teleport, anchoring or speed change.

The server recorded:

- Training started at server time **1794352193.544693**, strength **0**, with the station active.
- Strength rose to **1, 2, 3** at **1794352196.144964**, **1794352198.745498**, **1794352201.094229**. The existing **+1 per 2.5 seconds**, 10,000 cap and no-training-XP rules were unchanged; the loop's 0.25-second sampling accounts for observation timing.
- Walking out stopped training at **1794352203.710240**. At **1794352207.095673**, strength remained **3**, player/station active flags were false, and target/start attributes were cleared. Client station feedback changed TRAINING → READY. The root remained unanchored.

[Full server event record](training-observation.json), [capture record and Output](capture-record.json). Screenshots alone are not the behavior evidence. An optional capture helper initially looked for a default PlayerModule that this game does not have; it failed before training entry. Ordinary MoveTo then completed the sequence within the same session. No gameplay code was changed during or after it. The two private, initially named `final-runtime-training-*` files from that failed preparation are excluded from the delivered evidence; the `observed-runtime-training-*` images below are the actual active/stopped views.

Death/respawn, ownership transfer/loss, other-player attempts, cap/manual-stop/menu cancellation and live persistence were **source-inspected but not exercised**. They remain unverified at runtime. No second Play session, unrelated mining/purchase, device cycling or broad gameplay audit occurred.

## Actual capture evidence

| View | Screenshot and interpretation |
| --- | --- |
| Matched entrance | [Before](screenshots/before-room-entrance.png) / [after](screenshots/final-edit-entrance.png), identical room-local camera `(0,6.5,-40)` toward `(0,8,12)`, FOV 70. Both Edit views have unoccupied-room silhouettes. |
| Runtime entrance | [Owner room](screenshots/final-runtime-entrance.png), existing memory-only Studio preview. |
| Readable overhead | [Interior layout — inspection cutaway](screenshots/final-edit-overhead-cutaway.png). **474** dome/room-roof/upper-fixture parts were temporarily hidden and restored exactly. This is not a player view. Entrance is bottom, collection left, training right, care rear. |
| Left-wall collection | [Full display](screenshots/final-runtime-collection.png), actual owner preview with all three discovered variants and nine empty expansion slots. |
| Discovered close | [Actual names/rarities](screenshots/final-runtime-discovered-close.png), existing preview data, not fabricated unlocks. |
| Unknown close | [Neutral silhouettes](screenshots/final-runtime-unoccupied-silhouettes.png) in actually unoccupied Room02. This is not falsely presented as a real player's undiscovered profile. |
| Training | [Active](screenshots/observed-runtime-training-active.png) / [stopped](screenshots/observed-runtime-training-stopped.png). Actual character provides scale; measured equipped-character bounds were approximately 3.80 × 6.25 × 4.80 studs. |
| Care reserve | [Separate furnished area](screenshots/final-runtime-care.png), no incubation mechanics. |

Six reusable [room-local camera poses](cameras.json) are saved in `ServerStorage.VesperTools.PersonalRoomCameras`. Public images are unchanged 1224 × 670 viewport crops; full-window originals remain private. Game ScreenGuis were temporarily hidden for clear captures and restored; Roblox core controls remain visible in runtime images. No art changes followed the final captures.

## Cleanup, preservation and verification

[Replacement ledger](replacement-ledger.md) lists exact old instances, retired generators and migrated anchors. `RoomInteriorBuilder` is the sole personal-room architecture recipe. `CollectionCabinet` is the sole shared Edit/runtime shelf recipe; runtime ownership changes refresh data without rebuilding old furniture. Five historical room/cabinet installers now refuse execution. Archived room geometry and obsolete room creation sources were removed from the active place, with exact paths in [archive-removal.json](archive-removal.json).

The exact TrainingStation, TrainingSpot, PracticeEgg and two terminal instances were deliberately migrated. PracticeEgg is now an explicit nonrendering contact anchor, with the old decorative egg/cradle removed and a separately authored visible sample. Local training position is `(-23,1.3475,-9)`; target/rest position is `(-23,4.9825,-4.4)`. ARCHIVE/ROOM terminal identities now survive relocation instead of being inferred from world-side coordinates. No ownership, discovery, economy, reward, equipment, joining, mining or delivery behavior was replaced.

[Preservation comparison](preservation-comparison.json): all **13,728** protected BaseParts outside Rooms match; all twelve pivots, structural exterior walls, spawns, thresholds, owner signs, Phase 1 frontages/roofs match; all **39** anchor paths and global lighting/atmosphere/cloud/wind values match. Of **82** prior runtime sources, only the five scoped room/training/presentation sources changed. ResearchProfiles, RoomAllocator, TrainingCycle, progression/economy and joining sources remain unchanged. Fixed save generation remains **VesperDiscovery_FreshStart_20261110**.

[Focused Edit checks](static-results.json): twelve unique recipes, twelve slots each, clear entrance/spawn/training/care approach volumes, coherent target rest transforms, all specimen fits valid, no inspected superseded names and no colliding fine foliage. These checks do not establish every possible route or device behavior. Eleven changed sources pass StyLua; Selene reports **zero errors/parse errors**, with four pre-existing ExcavationService warnings. Final canonical/live source comparison is recorded in [source-sync.json](source-sync.json).

## Visible limitations and remaining scope

The original large shells still leave a **broad open center floor**; nine spare shelf positions make the upper display visually empty. The tall beige wall surfaces and limestone pattern remain prominent. Shelf owner/name labels and the training status subtitle are small from wide views, although names/rarities are readable in the close view. The existing three variants look very similar and retain the current model/texture quality; stronger creature models/finishes were explicitly not implemented. The training frame remains simple, the mineral sample visibly faceted, and the care furniture/planting sparse. No post-capture polish loop was started. Performance, all-device readability, multiplayer and owner visual approval are not claimed.

All remaining requirements stay in [PLAN.md](PLAN.md), the complete Phase 1 owner brief and its exact reference index: Phase 3 vines/planting, existing scenery closer/redistributed, nearer moving mist and coordinated lighting; Phase 4 tools/grips/animations/charge placement/explosions; Phase 5 complete coherent interface/icon/navigation/results replacement and handler cleanup; gate/road, skills, rebirth, monetization and worlds remain deferred. No requirement was discarded and none of those phases began here.

## Recovery and Git delivery

Private directory: **C:\Users\BOSS\Desktop\egg\Backups\InteriorPhase2_20261111\**.

- Before: `ComingSoon_94763223427049_before.rbxl`, **6,825,842 bytes**, SHA256 `0DD64F7F1098DCE08411150D0009C305064AC5EB1870B0FDCC7695D8E180D379`.
- Final: `ComingSoon_94763223427049_final.rbxl`, **6,589,977 bytes**, SHA256 `F2008DFD1CB524E56614CD66372EAD3439D756F084C1F387E30F615668AA0419`.
- Source snapshot, original downloaded packs, full-window captures and native save helpers remain alongside them. Backups were never opened as implementation targets and are not player-progress backups.

[Git delivery identity and commit link](delivery.json). No main merge or force push. The owner can inspect the linked evidence and later exercise the unverified lifecycle/multiplayer cases manually; this delivery does not impose another visual-approval gate or authorize a second agent runtime session.
