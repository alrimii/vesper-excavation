# Current state and development baseline
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
