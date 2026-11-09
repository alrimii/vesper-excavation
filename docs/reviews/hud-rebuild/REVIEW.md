# Interface replacement — first HUD checkpoint

Original place **94763223427049** only; baseline **26ced72aea5811d597d43bea1d574e9642bad022 / published v137**. All current visuals are rejected. No design acceptance is implied. The full owner-described feedback remains in the [existing open issue ledger](../hud-checkpoint/REVIEW.md); the owner's screenshots were not received. Every described issue predates the reset. The fixed save generation, economy and progression rules are unchanged.

## Delivered composition and assets

New `FieldHUD` / `ExcavationChrome` / `ExcavationArt` presentation with a live-state `HUDController` and `EquipmentDock`. Original high-contrast, broad-shape illustrations replace the prior atlas. Circular skill/tool/explore controls have short outlined labels; a distinct skill entry carries the actual available-point badge. Credits/relic counters share the upper-left with a readable XP strip, storage has a recognizable bucket and fill gauge, and egg identity selects its own bronze/golden/volcanic illustration from replicated EggId. Brief dismissible guidance is separated from the lower character/equipment area. Existing owned tool models provide actual item portraits and gold equipped state.

Landscape uses a horizontal navigation group under the wallet/XP, compact egg header, right attack control and bottom tool dock; desktop uses a vertical navigation group and more generous labels/art. CoreUISafeInsets protect the HUD. Keyboard hints are hidden for touch. All balances, capacity, XP, point entitlement, egg progress and equipment state come from existing replicated data; no placeholder rewards. Existing secondary functions remain reachable through Explore or Tools: journal, equipment/upgrades, creatures, home, room collection, settings, guidance, results, contract and nearby optional training. These unreplaced menus remain **pending replacement and unapproved**, including the tree, shop, inventory and results artwork.

Nine original **256×256** image exports with two flattened transparent masters, export script, actual upload IDs and integration manifest are under `assets/ui/hud-rebuild/`. Original illustrations were generated with the built-in image tool; no claim of layered painting sources. The bucket was uploaded first to establish the working path, then the remaining eight. Bucket and bronze image metadata confirm owner **291892217**, matching this experience. See the [asset provenance/resources](../../../assets/ui/hud-rebuild/README.md). No UI Labs/Vide/Kenney dependency was imported; production factories themselves supplied temporary Edit previews. No installation or framework migration.

## Retired implementations

Removed live/canonical `ModernHUD`, `ExcavationHUDView`, `Toolbelt`, `HUDLayout`, `MenuArtwork`, and the obsolete `ExcavationUI` builder. Removed StarterGui `Status`, `Bag`, `Shop`, `Help`, `Tools`, `Tutorial`, `Guidance`, `FieldGuide`, `FieldGuidePanel`. Their old client callbacks, periodic hidden-status writes, retired objective marker, and DiscoveryHUD background rank/tutorial/status writers are removed. DiscoveryHUD retains journal/reward/reveal behavior. UIMotion is limited to the pending-replacement workshop, so it no longer installs competing feedback handlers on new HUD controls. The existing single mining-input route attaches to the new Use control. Historical Git/native recovery copies are not live implementations; do not run old builders/restore snapshots to recreate them.

Static packaging note: `src/DiscoveryEnvironment.luau` is a historical one-off Edit-mode world/staging recipe, not a canonical runtime module; its old ExcavationUI rebuild call is obsolete. It was not executed or updated during this HUD checkpoint. Do not use that recipe to restore the current project.

## Narrow readiness correction (source-established risk)

Loading captured one Backpack reference, waited only 8 seconds for equipment and did not recheck current equipment after asset preload. Character initialization can replace that Backpack; simultaneous CharacterAdded/deferred equip calls could also race. No claim that this reproduces the owner's original incident.

The server now guards equipment requests by current character and per-session revision, reacquires the current Backpack after Humanoid readiness, checks the real tool template and acknowledges `EquipmentReady` only after parenting/equipping. Death clears readiness. Loading reacquires the current Backpack on every check, requires a living character and the server acknowledgment plus an owned matching Tool/required Handle, permits up to 45 seconds for genuine equipment replication, and rechecks after asset preload. Errors remain blocked with an explicit “Unable to join / EQUIPMENT UNAVAILABLE” state rather than stale synchronizing text. No fake readiness, tool grant, profile mutation or initialization bypass. Loading backdrop uses full-screen insets to remove the exposed world strip. The rest of loading's final visual design remains pending.

## Recovery

Fresh private native/source/asset recovery: `C:\Users\BOSS\Desktop\egg\Backups\HUDRebuild_20261110_012043\ComingSoon_94763223427049_before_hud_rebuild.rbxl`, **4,122,785 bytes**, plus source/docs/assets/instructions. This captures game implementation, not player DataStores or hosted asset permissions. Restoration not tested. The pre-existing owner Play session was stopped once before this backup; no gameplay interaction was performed in it.

## Exact capture plan and freeze rule

1. One new Play session, maximum five minutes. Wait for natural initialization; no grants, movement, attacks or menu navigation.
2. Capture the idle desktop HUD at the initial spawn.
3. Switch once to the existing landscape phone preset and capture the same idle HUD.
4. Stop Play. If either screen cannot be reached, capture the blocker and stop. No live debugging, fixes during the session, repeat session or device cycle.

After capture, freeze implementation. Only evidence/documentation and publishing/commit/push may follow. Capture findings will be listed below without fixes. Screenshots establish neither gameplay correctness, physical-device usability nor visual approval.

## Capture outcome — implementation frozen

One agent-started capture session: **59 seconds**, starting **2026-11-09 22:35:43 UTC** (10 November locally). Natural loading reached the idle HUD. No movement, mining, economy actions, menu navigation, grants, synthetic players or live debugging. One desktop-to-landscape-phone switch; stopped afterward. No post-capture implementation changes: the full source hash list recorded before capture had **zero changed files** afterward.

- [Desktop HUD, 1426×670](desktop.png).
- [Landscape phone HUD, 856×394](landscape-phone.png).
- The current tool is visible in the player's hand and the HUD loaded once through the real readiness gate. This does not reproduce or prove the owner's intermittent loading problem solved. Respawn, slow replication and failed equipment initialization remain unverified.
- The existing Studio-only 100M preview balance/all-tool ownership appears in these captures. It was not added by this checkpoint, is not a normal published starting profile, and no current save generation or player data was altered.

### Visible findings retained without fixes

1. Landscape XP/currency captions and equipment labels remain small at the captured size; physical-device reading and touch comfort are unverified.
2. A dark rectangular region/boundary is visible across part of the left/center landscape world. Its cause was not investigated during this capture-only session; no world/UI patch was made afterward.
3. Existing tool portraits retain the unapproved model quality, particularly the blocky explosive. No new weapon model was introduced.
4. The old laboratory frontage, braces/fixtures and sparse surroundings remain visible and unapproved. The new egg portraits are UI illustrations, not replacement world shells; exact world/art correspondence remains for later visual review.
5. At zero excavation/XP the empty dark tracks dominate their bars. This appearance is recorded for review rather than adjusted after capture. The idle Sell button is dim because the actual bucket is empty.

No correctness claim for navigation, tool switching, mining, skills, buying, selling, multi-player rewards, persistence, performance or physical-device usability. Output/live runtime diagnostics were not used for an autonomous debug cycle. No tree/shop/room/creature/world defects were closed by these screenshots. All owner-review ledger items remain open pending the relevant delivered correction and owner review.

## Original-place save and publication

All **11** modified/new canonical runtime sources matched the original Edit-mode place after capture. Retired GUI roots/modules were removed from the original place; temporary CoreGui Edit previews were removed before Play. Final native implementation checkpoint: `Backups/HUDRebuild_20261110_012043/ComingSoon_94763223427049_hud_rebuild_checkpoint.rbxl`, **4,123,298 bytes**. Restoration untested.

**Published v139** to the same original place **94763223427049**, universe **10773858644**, at **2026-11-09 22:37:57 UTC**. Studio's native log confirms `PublishSuccessful`, the original place ID, `Published new changes in "Coming Soon" to Roblox.`, and publish notes v139. [Minimal publication evidence](publication-evidence.txt). No audience/access change, server restart, duplicate experience, reset, migration, economy change, save-generation change or main merge. Existing access remains Private. New live joins and existing running server adoption were not inspected.

Checkpoint stops here for owner review. No subsequent skill-tree/menu/content implementation is authorized by this delivery.
