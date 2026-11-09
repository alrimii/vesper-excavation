# Phase 2: direct joining and core gameplay HUD

9 November 2026. Applied directly in original Studio place **94763223427049**, Coming Soon, Edit mode, place version 55. The user provisionally accepted Phase 1B and explicitly authorized this phase. No second place, gameplay execution or publishing. Branch: `planning/development-foundation`; pre-phase commit: `5cf5dd96ef152b0d159d37ec570f1ef9cf20107c`. The delivery commit containing this document records the Phase 2 changes; its SHA/link are supplied in the delivery message.

## What is applied

- Joining retains essential profile, client-controller, section, fracture and asset synchronization. A simple loading status replaces the introduction, entry button and loading scene. Normal camera/control and the HUD release when readiness completes. Failed essential loads retain explicit failure/retry handling; no invented percentage or balance is displayed.
- Player arrival no longer starts delivery or resets the egg. The former EnterLab message is a compatibility no-op. A fresh server initializes its egg once without an opening cinematic. Respawning does not rerun loading or an introduction.
- Real selecting/delivery phases retain their server clock and world machinery. Each transition carries its original start time through both stages. A player who finishes joining or respawns after it began sees the current world state without acquiring the transition camera, movement lock or dispatch overlay. Existing participants retain the genuine round transition. Server Reveal events carry their timestamp; eligible local presentation uses elapsed server time instead of restarting from zero. Death/respawn cleanup restores the current character's camera.
- One gameplay layout owner displays actual egg identity/shared excavation progress, cash, relics, bucket capacity, owned tools and equipped state. The existing drill trial timer remains visible. Sell and Upgrades are direct actions. More groups the working journal, current contract, equipment, creatures, room travel/collection, settings, guidance and nearby optional training. No training is required to mine.
- Desktop/touch prompts, compact layouts, safe insets and bounded guidance/toast areas replace competing HUD panels. Tool cards reuse existing equipment previews. Menu/bag opening cancels mining presentation and suppresses target feedback. The existing workshop, material bag and journal remain their own controllers.
- Contextual guidance follows existing TutorialStep data: equip/strike, automatic collection, sell and upgrade. Insufficient capacity for the next section shows a Sell prompt. Dismissal uses the existing saved tutorial-skip action; completed steps do not automatically replay on arrival or respawn. Help can be opened explicitly. Existing IntroStage profile data is preserved for compatibility but no longer drives a mandatory HUD training route.

No damage, upgrade prices, currencies, rewards, eligibility, profile grants, equipment assets or rejected studies were changed. The existing server remains authoritative for transactions and mining.

## Canonical sources applied

| Files under src | Original Studio path |
| --- | --- |
| Loading, LoadingView | ReplicatedFirst, corresponding script/module |
| ExcavationService | ServerScriptService.Vesper.ExcavationService |
| ExcavationClient | StarterPlayer.StarterPlayerScripts.ExcavationClient |
| ModernHUD, Toolbelt, DiscoveryHUD, Targeting, MovementControls | ReplicatedStorage.VesperShared, corresponding module |
| ExpeditionPhase, EggLifecycle, DeliveryCamera, DispatchUI, DiscoveryCinematic | ReplicatedStorage.VesperShared, corresponding module |

All names above have `.luau` canonical files. Fourteen existing sources were changed; no builder, restore recipe or module entry point was executed. Runtime HUD construction remains in these canonical modules, so the new HUD appears when the user presses Play. The affected live sources were compared against the captured baseline before assignment and read back afterward; all fourteen match after line-ending normalization. Targeting's two historical mojibake strings were replaced with readable ASCII labels. HUDLayout retains its initial legacy hierarchy styling but no longer competes for the gameplay layout each update.

## Private recovery copies

Directory: `C:\Users\BOSS\Desktop\egg\Backups\Phase2_20261109_193936`

| Native file | Bytes | SHA-256 |
| --- | ---: | --- |
| ComingSoon_94763223427049_before.rbxl | 4,087,210 | B099B9E34A567E73CF7A31668E347EBC630CBBCB3734D5CD8D22432FA5E7CC33 |
| ComingSoon_94763223427049_phase2_applied.rbxl | 4,091,700 | C47E74B1D1DC40F0EBF7B313C8E7713245F702EC9D121F04E36599DFFA2EADD2 |

Both are complete native place copies saved with Studio's Download a Copy command to new filenames. Neither was opened as an implementation target. File existence, size and hashes were checked; restoration was not tested. The directory also preserves the pre-edit src, assets and release trees and affected live-source captures, including editable Blender/texture sources already on disk. Copies cover the serialized place and asset references, not independent hosted asset bytes, production DataStores or unsaved external application state. These are private copies on the same disk, excluded from Git. No editable art asset changed in this phase; historical studies remain preserved. Old public release binaries are historical snapshots, not refreshed substitutes for the original place.

## Manual review

1. Join a fresh server, then an existing server with a partially excavated egg. After essential loading, expect immediate normal camera/movement, the same egg and matching shared progress. Other players' round must continue uninterrupted.
2. Respawn during excavation. Expect normal control, retained tutorial progress and usable equipment/HUD, with no introduction. Also arrive/respawn during selecting or delivery: expect the current world phase without a replayed camera/overlay or a new round trigger.
3. Equip/select owned tools, strike and collect. Check the equipped indication, desktop Click/E and touch controls, drill toggle/trial display where applicable, and no mining through open menus.
4. Fill the bucket through ordinary play, Sell, then open Upgrades. Compare capacity, cash and materials with the existing inventory; follow or dismiss the concise contextual hints. Do not alter saves or grant items to prepare this review.
5. Inspect a smaller touch layout and desktop layout. Open More, journal/contracts, equipment, creatures, room actions, settings and the bucket details; check closing, scrolling and target visibility. Optional training should remain accessible near its existing station.
6. Complete an egg normally. Existing participants should receive the genuine creature reveal/results and next server-driven delivery, then regain control. A player joining after a reveal began must not replay its completed camera sequence. Check respawn during these phases for stuck control or overlays.

## Unverified and unfinished

- Static source review, source/property comparison, whitespace review and native file checks only. No automated tests, diagnostic execution, Play/Run, simulations, automated gameplay, renders or publishing. Gameplay, replication timing, multiplayer transitions, persistence, touch fit and performance need the user's review; readback is not execution evidence.
- Suitable permitted mining audio remains missing from Phase 1B. No unrelated sound or fabricated asset ID was substituted.
- Existing Studio preview profiles grant extensive currency/unlocks and do not represent normal persistent accounts. That pre-existing path was not changed or invoked by the agent. Saved-tutorial rejoin behavior cannot be established from a resetting preview profile alone.
- Essential runtime fracture/asset preparation can still lengthen loading. This phase retains that readiness dependency rather than bypassing it or rebuilding shell architecture.
- Creature eligibility, final-hitter material ownership, economy and legacy secondary-screen styling are preserved. No new reward or progression policy is implied.

Await user review of this Phase 2 implementation. No later phase is authorized by this delivery.
