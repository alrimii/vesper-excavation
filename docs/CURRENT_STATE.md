# Current checkpoint — Interior Phase 2, published v212

Original place **94763223427049**, branch `planning/development-foundation`. **Published v212** at **2026-11-10 23:12:41 UTC**; native saved and Studio stopped in Edit. [Review, actual screenshots and known limitations](reviews/interior-phase-2/REVIEW.md), [Git delivery](reviews/interior-phase-2/delivery.json). All twelve personal-room interiors, left-wall modular collections, training stations and separate care reserves were replaced with one room-local recipe; obsolete instances and generators were removed.

Automatic training checked a client-only LabReady attribute on the server. It now uses existing server-owned readiness and validates the current character/owner station. One 147.295-second existing memory-only session observed start, strength 0→3 at unchanged rates, exit and clean stop. No grants, resets, production writes, unrelated gameplay or additional session. Lifecycle/multiplayer cases remain unverified at runtime. Art froze after final captures; broad open floor, spare shelf space and current creature/label limitations are explicit.

The 13,728 protected parts outside rooms, twelve exterior shells/pivots/frontages/roofs, spawns/thresholds, 39 anchor paths and global environment settings match the baseline. Five scoped runtime sources changed; fixed generation and protected gameplay/data remain intact. [Authoritative source/anchor/removal paths](reviews/interior-phase-2/replacement-ledger.md). `ServerStorage.VesperTools.RoomInteriorBuilder` is the personal-room Edit recipe; `ServerScriptService.Vesper.CollectionCabinet` is the shared Edit/runtime collection recipe. Phase 1 LabInteriorBuilder continues to own shared architecture.

The owner requests continuation through the agreed phases without repeated visual-approval pauses. All Phase 3–5 and deferred requirements remain in [the retained plan](reviews/interior-phase-2/PLAN.md); none began in Phase 2. Current delivery ends in Edit; no new Phase 2 art/test loop is authorized by its completion.

## Previous checkpoint — Interior Phase 1, published v208

Original place **94763223427049**, branch `planning/development-foundation`. **Published v208** at **2026-11-10 22:35:16 UTC**, verified in Studio's original-place publish log. [Review and actual screenshots](reviews/interior-phase-1/REVIEW.md), [delivery identity](reviews/interior-phase-1/delivery.json). The native checkpoint is saved; Studio is stopped in Edit and implementation is frozen for owner review.

The workshop occupies an integrated perimeter wall counter; the lab kiosk is replaced by two shallow wall displays. Twelve finished room roofs, restrained owner identification, removed number/CLIMB signs, fitted platform-edge flooring and connected landing/spiral decorations replace their old instances and generators. Original shop anchors moved coherently; no room relocation or further rescaling. Shared ModalLayout provides full-viewport visual coverage with safe controls and bounded panel fitting. Existing UI artwork remains Phase 5 work.

Nine protected geometry groups, twelve room-interior/pivot records, 39 anchor paths and lighting/atmosphere/cloud values match. Only five authorized runtime GUI sources changed and one layout module was added. One 121.442-second capture-only session supplied world and GUI views; all 824 temporary Edit cutaway parts were restored. No gameplay actions, grants, resets or device changes. Visible limitations and unverified behavior are explicit in the review.

Private native recovery: `Backups/InteriorPhase1_20261111/ComingSoon_94763223427049_before.rbxl` and `ComingSoon_94763223427049_final.rbxl`. Full subsequent requirements, including restrictive interim asset tracking, remain in [Phase 1 plan and later phases](reviews/interior-phase-1/PLAN.md). Do not begin them without the next owner scope.

## Previous compact interior checkpoint — v203, superseded within Phase 1 scope

Original place **94763223427049**, branch `planning/development-foundation`. **Published v203**, confirmed by Studio's original-place publish log at **2026-11-10 21:28:47 UTC**. Baseline `bbd3f1bd8994fcb161c57951a7529efebd9142da`; [Git delivery identity](reviews/compact-interior/delivery.json). Final private native checkpoint saved; Studio is in Edit. Artwork is frozen for owner review.

[Complete review, eight owner references, before/after and actual runtime screenshots](reviews/compact-interior/REVIEW.md). Twelve unchanged-size rooms now form four compact wings. Clear distances reduced from 185–190 to 57.85/84.48 studs; lower dome explicitly refitted from approximately 700 to 428 studs maximum width, retaining crown/delivery geometry. Forward workshop/laboratory counters, finished fossil/microscope/charge meshes, selected planting, connected vines and muted stone replace old assemblies and their generation paths. LabInteriorBuilder is the sole active Edit recipe.

Eight protected roots (six geometry groups plus atmosphere/cloud roots), 81 runtime source signatures, 39 anchor references and exterior atmosphere/cloud settings match. Room spawns, thresholds and world-space training rest poses moved coherently; no data/progression/economy/joining/mining/delivery changes. Exactly one **69-second** capture-only session, no gameplay actions or device changes. All 504 temporary cutaway parts restored; no art edits after capture. Findings include repeated frontage, sparse overall planting, dark floor seams, pale fossil contrast and existing HUD obstruction. Gameplay usability, other devices/performance and owner visual approval remain unverified.

Private native recovery: `Backups/CompactInterior_20261110/ComingSoon_94763223427049_before.rbxl` and `ComingSoon_94763223427049_final.rbxl`. Do not open recovery copies as implementation targets. Exterior and deferred personal-room/collection, UI/menus/shop UI, skill tree/remaining skills, broader tools/creatures, gate/road, rebirth, monetization and worlds remain outside this delivery.

## Previous v192 checkpoint — rejected by owner and superseded

# First laboratory interior rebuild, published v192 (historical)

Original place **94763223427049**, branch `planning/development-foundation`. **Published v192**, confirmed by Studio's successful publish log on 2026-11-10 at 19:31:55 UTC. Implementation commit **c92908dcbadd665c3733a43616d57a05eef902fd**, based on v191 / c8ec194cdfbb417af0b75703ade46b3f4dc9678b. Final native copy and actual Edit/runtime evidence are saved. Artwork is frozen for owner review; Studio is in Edit. Publication does not imply visual approval.

[Layout, before/after screenshots, scope and remaining issues](reviews/interior-rebuild/REVIEW.md). One layout replaces old floor/front portals, removes eight closed research bays, adds four open viewing terraces, three planted commons/two specimen islands, and integrates workshop/ladder architecture. All twelve rooms and functional anchor poses are retained. Static signatures match for 97 protected groups/settings; checked entrance/view/ladder/shop clearances have no new colliders. This does not prove usability or visual quality.

The single capture-only session lasted **62 seconds**, with five fixed cameras at Automatic graphics and no gameplay actions/device changes. Observed: dark workshop recess and visible roof/back slit, repetitive portals, broad pale floor spaces, bold foreground planting and a dome sill limiting the low exterior view. No corrections followed capture. Gameplay/traversal and other devices remain unverified. Before/final native recovery: `Backups/InteriorRebuild_20261110/ComingSoon_94763223427049_before.rbxl` and `ComingSoon_94763223427049_final.rbxl`; sources, asset records and full-window captures accompany them. Wait for owner review; do not open recovery copies as development targets.

Exterior/dome/crown/egg/access and all gameplay/player data/fixed generation are preserved. Exterior refinements, gate/road, full personal-room/collection redesign, UI/skills/tools/creatures and long-term systems remain deferred. [Last published exterior checkpoint](reviews/exterior-atmosphere/REVIEW.md).

## Historical checkpoint records (superseded by the current owner decisions above)

Current checkpoint: focused Foggy Gazebo **partial correction published as v174** in original place **94763223427049**. [Fixed-camera before/after, diagnostics, exact blocker and inventory](reviews/foggy-correction/REVIEW.md). Foliage encoding/normals and terrain seating were corrected; the failed background is undisplayed and the requested atmospheric forest remains unfinished. One 23-second capture-only session stopped on camera failure; final views are labeled Edit-mode fallbacks. Frozen for owner review with no post-capture corrections. Earlier statuses are historical.

Current checkpoint: selected Foggy Gazebo exterior transfer published as **version 170** in original place **94763223427049**, with a saved native checkpoint. [Actual Edit-mode captures, runtime capture limitation, asset inventory and visible defects](reviews/foggy-gazebo-transfer/REVIEW.md). One 59-second capture-only Play session ended in Edit; camera capture failed and the authorized Edit-mode fallback was used. Implementation is frozen, with no post-capture corrections. Gameplay/player data unchanged; visual approval and gameplay/mobile verification remain pending. Earlier statuses below are historical.

Current checkpoint: focused eastern valley sector published as **version 162** in original place **94763223427049**. [Three actual runtime views, preservation evidence and unresolved shortcomings](reviews/valley-sector/REVIEW.md). Frozen after one 52-second capture-only session; Studio is stopped in Edit. Interior/gameplay/save generation unchanged. Visual approval and gameplay/mobile verification are pending. Earlier checkpoint statuses are historical.

Current checkpoint: substantial living-lab art pass published as **version 156** in original place **94763223427049**. [Actual runtime captures, source preservation, external assets and all visible shortcomings](reviews/lab-art/REVIEW.md). Frozen after one 71-second capture-only session; Studio stopped in Edit. Current egg/access and twelve spawn/training anchors retained. Implementation/publication are confirmed; visual approval and gameplay/performance verification are not. Earlier checkpoint paragraphs are historical.

Current checkpoint: living discovery laboratory published as **version 149** in original place **94763223427049**. [Actual captures, preservation evidence and unresolved defects](reviews/living-lab/REVIEW.md). Current egg/access geometry and all room spawn/training anchors preserved; source and native place saved. One 47-second capture-only session; no gameplay verification or visual approval. Hanging lifecycle machinery, coarse scenery, broad circulation and partial workshop occlusion remain open. Prior status below is historical.

Current checkpoint: equipment outfitter replacement applied to original place 94763223427049 and frozen after one capture-only session. See [shop review/evidence](reviews/outfitter/REVIEW.md). Mobile scrolling/action visibility and visual approval remain unresolved; no purchase or persistence verification. Previous status below is historical.

# Current state and development baseline
Latest checkpoint: **Phase 5B.1 paused**, original place 94763223427049. Play stopped once after the user stop instruction; original place returned to Edit. Visual result is explicitly NOT approved. Further Play, gameplay automation and device switching require a new bounded scope. Actual Play review now supersedes source-only verification for the specifically exercised paths in [the review record](reviews/phase5b1/REVIEW.md). Five client/shared presentation modules and runtime image exports changed; server reward/progression rules are unchanged. Higher-level skills and persistence remain unverified. No visual approval or publication is implied.

Latest development checkpoint: **Phase 5B** in original place 94763223427049, Edit mode, based on 61fea9c446e4c071ee3c11422dfc09d33814a14a. Full L0..100 contribution XP/points, eight skills including passive lightning and cross-target Flow Drill, navigable illustrated tree, authoritative purchases/loadouts/free room respecs. Fifteen canonical sources are synchronized; fifteen original UI images returned real Roblox IDs, with all owners read back as User 291892217. See [Phase 5B handoff](PHASE_5B_HANDOFF.md) and [asset manifest](../assets/ui/progression/manifest.json). XP multiplier 1; no rebirth transactions or lifetime-level equipment gates. Legacy published profiles are refused unchanged instead of migrated/reset. This remains unpublished and pending manual gameplay/persistence/device/visual review. Historical phase paragraphs below do not override the new XP rules or compatibility boundary.

Latest delivery, 9 November 2026: Phase 4B is implemented in original place 94763223427049 in Edit mode, based on b36cf180defb75d4a453d34063fec2cacbf2fe78. Nine changed/added runtime sources match canonical files by source readback after line-ending/trailing-whitespace normalization. Positive effective-damage contributors receive independent personal creature rolls at existing solo probability times final contribution share; frozen same-server settlements survive later eggs, and loaded session-locked profiles receive undelivered rewards once. Existing end stipend amounts and online-at-reveal eligibility are retained. Personal results/history and Archive odds replace single-winner/player-count assumptions. See [Phase 4B handoff](PHASE_4B_HANDOFF.md) for probabilities, backups, limitations and manual review. No gameplay or persistence verification was performed. The user reports manually publishing the latest prior update; cached open-place version 55 is not evidence of older live content. Phase 4B was not published by the assistant. Future full-progress reset and redeem codes remain roadmap notes only.

The following Phase 4 status paragraphs are historical; Phase 4B supersedes their creature eligibility/results statements only.
Phase 4 focused correction, 9 November 2026: Yield bonuses now round the combined entitlement once and apportion that integer pool by largest remainders, with the existing UserId tie-breaker. Only MaterialRewards runtime source changed; base allocation, hit-time tracking, pending claims, values and other reward attribution remain unchanged. Applied and source-read back in the original place; not gameplay-tested. See the corrected formula and backup record in [Phase 4 handoff](PHASE_4_HANDOFF.md).
Latest status, 9 November 2026: Phase 4 persistent blast placement, damage-shared materials, pending claims and whole-egg contribution are applied in original place 94763223427049, Edit mode. Ten changed/added sources match canonical source by readback after line-ending normalization. Branch: planning/development-foundation; pre-phase commit: 80cdb430861a41302af468d0bf85907784bd83dd. See [Phase 4 handoff](PHASE_4_HANDOFF.md) for exact formulas, claim/persistence limitations, native backups and manual review. Phase 1B retains provisional user acceptance; Phase 2/3 unperformed checks, including audio quality, remain unverified. Both upgrade studies remain rejected. Current HUD/menus are functional interim UI, not visually approved; illustrated screens and a navigable skill tree remain a separate future phase. No tests, diagnostic execution, simulations, gameplay sessions, audio auditions or publishing were performed.

The sections below preserve dated Phase 0/1A evidence. Earlier backup gaps and approval gates are historical, superseded by subsequent phase handoffs. Fresh complete native copies were saved before each implementation phase; the user does not need to make those backups. Phase 2 resolved the previously noted Targeting string-encoding differences. Phase 3 replaced the historical single-target explosive path and missing mining-audio wiring. Phase 4 replaces final-hit material ownership only: relic rolls, section XP/cash and legacy contract attribution remain with the final hitter. Preview grants, creature eligibility and the runtime fracture-loading dependency remain unchanged. Offline untransferred claims are same-server memory and do not survive shutdown. Affected pre-edit sources were preserved and compared before writing. Release snapshots and historical builders remain unchanged; they are not the current implementation.

Phase 0 inspection date: 9 November 2026. At that stage only read-only inspection and file preservation were performed.

## Repository and place
- Workspace: C:/Users/BOSS/Desktop/egg.
- Remote: https://github.com/alrimii/vesper-excavation.git.
- Initial branch: main; initial commit: a738d8d95bf78f7ab1406193b14590deb4193e9d. Tracked working tree and ordinary untracked status were clean.
- Dedicated Phase 0 branch: planning/development-foundation. No merge or force-push authorized.
- Existing ignore-all allowlist hid local work: Backups, .tools, .agents, root place/model snapshots, checkpoint JSON, export-place.ps1, studio-ui files, reference image and PROJECT_AUDIT_AND_DEVELOPMENT_PLAN.md. They remain in place.
- No applicable pre-existing AGENTS.md was found in the workspace or inspected ancestor locations. The existing root audit remains untouched as historical evidence; these docs govern the new plan.
- Connected Studio: Coming Soon, place 94763223427049, universe 10773858644, reported place version 55; Edit mode, Edit DataModel. This is the sole connected instance and matches the historical audit's place ID. Published contents and unsaved-state status were not independently established.

## Preservation and limits
Local backup: Backups/Phase0_20261109 (ignored, not uploaded).
It copies src, assets and release, including editable .blend files, texture/map sources, FBX exports and asset manifests; the existing root audit; Place1.rbxl, Checkpoint_Before_Milestone1.rbxlx, VesperDiscovery.rbxl and three root release .rbxm files.
It also captures a fresh live script inventory, 64 canonical live script sources, a UTF-8 source comparison and the live Targeting source. file-manifest.json records sizes and SHA-256 values. Copied/captured payload was approximately 169 MB before the manifest. This is a local duplicate on the same disk, not off-device disaster recovery.
An initial all-script response exceeded the MCP output limit; live-scripts.json is an incomplete capture, NOT a usable source backup. canonical-live-scripts.json is the successful bounded capture. Archived scripts are inventoried but not freshly exported in full.
No fresh complete native backup of the current Studio DataModel was made. Existing saved place files are preserved, but may not contain unsaved edits. Non-script live geometry/properties, terrain and unsaved Blender state are not newly preserved. Hosted assets are references, not independent copies of uploaded bytes or proof of permissions.
The exposed Studio tool set has no native save/export operation. The existing SaveReleasePackage recipe clones selected roots and temporarily changes HttpEnabled to send serialized data to a local receiver; it is not a full-place save and was not executed. No UI automation was used. Before implementation, the user should save a fresh native place copy in this backup directory through Studio.
No snapshot was restored or opened over the current place. release/ApplySnapshot.luau destroys/replaces matching objects and sets lighting/player/workspace properties: do not use it as a synchronization shortcut.

Preserved release hashes:
- BasePlace.rbxl (2,210,041 bytes): B0FF7DB256536A9C82D56C23B4DBA356E8CC14A28B9A314EDDAE77D392F3F4E7
- VesperCurrent.rbxm (3,907,789 bytes): 3687FCE5560D02DC976B12698B9EA3E9984D19CD0C51606B2EC5A7793BAB5177

Existing binary assets are tracked directly; .gitattributes has binary declarations, no LFS filter. The inspected largest source asset was 16,777,216 bytes. Phase 0 adds documentation only; no new large assets are being uploaded. Later asset growth requires an explicit storage decision if remote limits prevent delivery.

## Source correspondence and synchronization
See SOURCE_MAP.md for all 64 canonical script paths.
- ServerScriptService.Vesper contains server scripts and supporting modules.
- ReplicatedStorage.VesperShared contains shared/client modules and Packages.spr.
- StarterPlayer.StarterPlayerScripts.ExcavationClient is the main client; ReplicatedFirst holds Loading and LoadingView.
- Workspace.VesperLab, StarterGui.ExcavationHUD and ServerStorage asset libraries/kit are model/UI data, not reconstructed merely by copying runtime scripts.
- src is a flat mixture of runtime modules, one-off builders/installers, exporters and historical refits. No root Rojo project mapping was found. Never run src wholesale.
- Builder names are not sufficient to classify code as offline: ProgressiveFractureBuilder is required by ExcavationService during startup; other builders are required by runtime world setup.
- ServerStorage contains historical backup folders, VesperTools builders, DiscoveryTests and generated procedural source. These are not the canonical runtime source just because names overlap.

Fresh comparison: 63/64 canonical live sources match corresponding local files after removing whitespace. This is a coarse source comparison, not semantic certification (whitespace inside strings is also ignored). Targeting differs: live strings contain mojibake around an em dash and middle dots, and an extra trailing newline. UTF-8 reads confirmed the difference; neither side was overwritten.
The live inventory contains a single canonical WorkshopUI; duplicate versions appear in historical ServerStorage archives. The older audit's duplicate-live-module statement is not accepted as a current fact.
release/RESTORE.txt describes a Stage 30 selected-root snapshot plus original base configuration. Its label does not establish equality with the open DataModel. Binary snapshot geometry/property/source equivalence has not been established. Current source, live scripts and release snapshots must not be treated as interchangeable.

Future synchronization: capture current place and exact live paths first, compare only affected canonical sources using UTF-8, review any differences, make scoped edits after authorization, save both Studio and repository representations and report omissions. Do not choose old snapshots as authority over current edits.

## Integrations and controls
Roblox Studio MCP responds to instance listing, state inspection and read-only Luau queries. Only metadata/source reads were executed; no modules were required or game entry points called.
Blender 4.5.15 directory, blendrelay-mcp, relay-runtime and historical request/scripts exist under .tools. No Blender process was observed and no Blender/BlendRelay tools are exposed in this conversation. Presence on disk is not connection verification. No integrations were installed, launched or updated.
Git metadata writes required sandbox escalation because .git is read-only in the normal execution environment. The elevated user encountered an ownership mismatch; a command-scoped safe.directory exception for this workspace resolves it without changing global settings.

OpenAI's [plugin policy documentation](https://developers.openai.com/plugins/build/plugins) documents plugin-scoped MCP server enabling, enabled_tools allowlists, and per-tool approval modes. These are potential controls, not settings applied here; exact applicability to this Studio server's registration remains to be checked before configuration changes.
A read-only allowlist is stronger than merely blocking start_stop_play, character_navigation and input tools: unrestricted execute_luau can also mutate or simulate. Retaining that tool requires reviewing each call as read-only. The Studio state tool's description suggests starting/stopping play when needed; the user's prohibition overrides that suggestion.
Existing local Roblox skills are available but were not used to execute gameplay workflows. No external skill collection is proposed or installed. OpenAI Docs was used solely for permission-control documentation. No shared skill/global setting was altered.

## Rechecked external-review leads
These observations concern source, not demonstrated gameplay behavior. The baseline is exactly the cited a738d8d commit.

| Lead | Current evidence and implication |
| --- | --- |
| Preview unlocks/currency | ResearchProfiles.Load Studio path grants owned tools, room themes, creatures and 100,000,000 cash (around lines 115-132). Preview progression is unrepresentative; no account was loaded or modified by this inspection. |
| HUD hides access | ModernHUD hides Status/Shop/Help/Bag/Tools/Tutorial/Guidance (around line 323); DiscoveryHUD uses Help for JOURNAL. Competing visibility ownership is confirmed; actual journal/contract reachability requires user review. |
| Creature eligibility | ExcavationService lines 451-465 collects players with accounts/sessions and selects one winner on DropChance, without mining contribution in that eligibility loop. Multi-recipient contribution-aware rewards remain future design work. |
| Final hitter resources | strike updates the breaking player's contents, cash and XP; CollectorUserId is that player's ID (around lines 642-679). Earlier contributors are not apportioned those plate materials. |
| Explosives | Mine calls strike; the reviewed strike damages one target and uses common timing. No neighboring-section damage loop appears in that path. Distinct explosive behavior remains a later phase. |
| Training feedback | Server emits TrainingPulse; ExcavationClient around line 407 deliberately does nothing for it with a no-numeric-toast comment. Training animation exists; whether it feels rewarding remains subjective/manual review. |
| Fracture startup | ExcavationService immediately calls ProgressiveFractureBuilder.Prepare; Loading waits for fracture readiness. Startup coupling is confirmed, latency/performance is not measured. |
| Reports versus source | Historical audit and stage JSON describe earlier states; current canonical inventory and Targeting encoding drift show why each claim must be rechecked. |

No fixes to these systems were made. No runtime safety, persistence, performance, sound, visual or multiplayer certification is implied.

## Phase 1A update and next gate
The Phase 0 native-backup gap was resolved on 9 November 2026 using the explicitly authorized Studio UI save exception. File > Download a Copy saved the original place in Edit mode to Backups/Phase1A_20261109_182432/ComingSoon_94763223427049_20261109_182432.rbxl (4,083,531 bytes; SHA-256 80AA95B10727FF215CCB24211DD47C980B851AEF454518B952F62EA3B56A5687). It is a full native place recovery copy, not a script export or selected-root model. src/assets/release were separately preserved. Restoration was not tested. Hosted asset bytes/permissions, DataStores and unsaved external Blender sessions are not captured by this save.
The original place 94763223427049 is the single implementation and user-manual-playtest target. Never create a second test/development place, staging world, duplicate map or parallel playable implementation. Recovery copies remain unopened. Repository source/editable assets must stay synchronized with approved changes directly in that original place.
Phase 1A authorizes non-playable visual/Blender studies only. Installed Blender 4.5.15 rendered the isolated studies through its background executable; no BlendRelay MCP tools are exposed, no connection is claimed and no software was installed. See assets/studies/phase1a/README.md for visual proposal, actual deliverables and limitations. Runtime scripts and live assets are unchanged.
Next gate: approve or revise the cartoon visual/motion direction and explicitly authorize a scoped production/integration phase. Contribution formulas, rebirth values, purchase prices and world thresholds remain for their respective phase gates.

## Map cleanup checkpoint ? 10 November 2026

Original place 94763223427049, published **version 142** at 09:04:16 UTC; same universe 10773858644. Current map recipe: `ServerStorage.VesperTools.MapCleanupBuilder` / `src/MapCleanupBuilder.luau`, Edit-only. Live collection source and original client/server interactions are synchronized. No save-generation, balance or player-data changes. Studio stopped in Edit. One 37-second capture session obtained a runtime room view; the other four region images are labeled Edit-mode because camera requests did not retain their runtime viewpoints. No gameplay verification or visual acceptance. [Exact changes, removals, backup and unresolved findings](reviews/map-cleanup/REVIEW.md). HUD/menu/tree redesign remains paused.
