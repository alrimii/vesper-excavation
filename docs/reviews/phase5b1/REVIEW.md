# Phase 5B.1 playable review and repairs

**Checkpoint: stopped at the user's request. Visual result NOT approved.** Play was stopped once after that instruction. No subsequent Play, gameplay input or device changes are authorized until a new bounded scope. This document records partial corrections and remaining defects, not a completed or accepted visual milestone.

## Remaining composition defects identified by the user

- Nodes and labels clip at the left edge in panned/mobile views; framing remains unbalanced with excessive unused space.
- The inspector remains dense technical text rather than a clear player-facing skill presentation.
- Decorative frames do not scale consistently across different controls.
- Mobile panels and guidance crowd gameplay; text is small and the lower-right element is partly clipped.

These issues remain open. No further UI edits were made after the stop instruction. The most recent input-release deduplication adjustment was saved to source/Edit before that instruction, but its repeat-input behavior was **not rechecked** before stopping. Earlier isolated D-pad input moved the detail scroll by 64px; repeated input was inconsistent during review and is not certified fixed.

Original place **94763223427049**, based on `377bb40cc33339bca271d972a2aa7ea453b958f0`, on `planning/development-foundation`. This is a focused repair of the existing eight-node milestone, not acceptance of final UI art or permission for more content.

## Observed issues and corrections

| Observed in Play | Established cause / correction | Recheck |
| --- | --- | --- |
| Panel and navigation artwork lacked bottom/right borders; panel master contained irregular interior transparency. | Nine-slice coordinates extended to 1074 on a 1254px export; those coordinates did not match the rendered Roblox texture. Export panel at 512px, slice `(74,74)-(438,438)`, scale borders appropriately, and composite an opaque navy interior beneath the original image. Outside corners remain transparent. | All four panel/button borders and solid interior rendered in actual Play. Original master unchanged. |
| Art initially appeared blank and 15 runtime images were oversized. | Preserve 1254px masters; produce 256px icons/emblems/frame, 512px panel, 1024px background. Reupload real exports and update bindings. | All 15 replacement images rendered and reported loaded in the desktop client. Cold/network loading can still take time; no loading-speed or GPU-memory benchmark claimed. |
| Initial tree clipped its hub, branch labels, and lower nodes. | Replace first-view framing with a compact graph of the eight implemented nodes, two skill rows, calculated zoom and recenter. Later nodes remain in the catalog but are not rendered as clutter in this checkpoint. | Desktop opening shows all eight, hub, branch emblems and connections. Mouse pan, wheel zoom, +/- and recenter exercised. |
| Strike button extended below the viewport; large credit balance was truncated. | Correct bottom anchor of primary/charged controls. Compact large cash display without altering balances. | Strike button fully visible; original preview balance displays `$100.00M`. |
| Portrait HUD occupied an unnecessary extra control row; offscreen tree branches were difficult to reach. | Compact the portrait action row, preserve XP/points display, add actual branch-focus buttons. Use side details in short landscape instead of consuming most canvas height with a bottom panel. | Samsung Galaxy S22 Ultra preset: portrait and landscape inspected. Native emulated touch opened the tree, focused Technique, selected Chain Lightning and panned the graph. |
| Tree details input opened the older journal; Output reported `Setting GuiService.SelectedObject to invalid GuiObject`. | Journal's global X shortcut competed with the tree; tree attempted to focus a disabled purchase button. Block journal shortcuts while the tree owns input, focus the scrolling detail region, and handle directional navigation before default GUI selection. Include tree state in existing aim-lock/sprint blocking. | Rechecked X with separate D-pad input: detail scrolling moved 64px and the older journal stayed closed, without the previous warning. Ctrl aim lock released its mouse lock while the tree was open. Physical-controller certification is not claimed. |
| Disabled purchases looked actionable; receipts could remain below the scroll viewport. | Clearly dim and label locked/completed purchases; expand and scroll details to server receipts. | Level-0 prerequisite and point requirements inspected; no locked purchase was bypassed. |

## Actual gameplay exercised

- Joined the original server preview and waited for its existing initialization; normal camera/movement resumed without a joining cinematic. Walked from entry to the egg and used actual controls.
- Pickaxe held strikes broke a section: **180 effective damage, 7.2 XP, 3 bucket units**. Switched to drill and broke another: cumulative **360 damage, 14.4 XP, 6 units**. Releasing drilling stopped its running/contact state.
- Sold those six actual units through the HUD: **12 credits**, bucket emptied. Existing section cash remained separate. These were ordinary preview interactions, not resource grants.
- Switched to explosive and detonated: cumulative **1417 effective damage, 56.68 XP**. This checks the existing bronze factor `0.04 XP/HP` through the tools; it does not verify every blast edge/cancellation/multiplayer case.
- Opened upgrades, attempted K, and confirmed the tree did not overlay the open workshop. Closed menus and resumed movement/mining.
- Confirmed an ordinary free respec of the empty level-0 build in the existing preview room: server receipt `Build updated.`, zero points and empty ranks remained. This does not verify refunding a learned build.
- Read runtime Output during review. The GUI-focus warning above was observed and repaired. No game-script exceptions were observed in the exercised paths. Existing `[Vesper] 12 session rooms ready` message is informational.

## Evidence

Actual Studio viewport captures, not mockups or edited UI composites. Checked for unrelated desktop/private information before committing. Private native-window inspection captures are excluded.

- [HUD before](hud-before.png) / [HUD after](gameplay-hud.png).
- [Tree panel before](tree-detail-before.png) / [full tree after](skill-tree.png) / [selected node after](selected-node.png).
- [Latest landscape touch HUD](touch-hud.png) / [latest captured portrait selected node](touch-tree.png). These existing screenshots retain the defects listed above. Desktop images precede the last input-only adjustment; there is no screenshot from after that final adjustment. No new session was run to obtain checkpoint evidence.

## Limits and retained unfinished work

This review used existing memory-only Studio preview behavior, including its pre-existing equipment/currency. No extra XP, currency, skills, balance changes or production-save edits were made. Level 0 was not bypassed. **Successful skill purchases, points across level crossings, learned-rank states, active loadouts, respec refunds from a learned build, lightning procs and Flow Drill remain gameplay-unverified.** Also unverified: physical gamepad/phone hardware, two-finger pinch, multi-client contention, rejoin/persistence/shutdown claims, full egg completion/reveal, audio quality/attenuation and performance. Input injection exercises relevant button bindings, not a physical controller. No automated suite or synthetic player was used.

Loading still waits for existing runtime fracture/essential initialization. This phase did not redesign the world, older equipment/journal/help screens, or the egg geometry. User visual approval remains outstanding. Previous profile-compatibility refusal and same-server claim limitations remain unchanged. No rebirth/content expansion, publishing, merging, resets, migration or redemption codes.

## Recovery and synchronization

Fresh private folder: `C:\Users\BOSS\Desktop\egg\Backups\Phase5B1_20261109_235049`.

- Complete native **before** copy: `ComingSoon_94763223427049_before.rbxl`, **4,120,319 bytes**, SHA-256 `288738D1244C5A87C8FD441ACADE4F5B23D5BE33F05701792D138287297BEB27`.
- Complete native **checkpoint** copy: `ComingSoon_94763223427049_checkpoint.rbxl`, **4,121,376 bytes**. File existence and size verified; restoration not tested. All five changed modules matched canonical source in final Edit-mode readback after the stop instruction.
- Before copies of `src/`, `assets/`, `docs/` and `AGENTS.md`. Native place recovery includes current instances/scripts; saved local asset sources accompany it. This is not a player-progress backup or a copy of every externally hosted asset. Restoration was not tested.
- Changes are applied to the original **Edit** place and canonical `SkillTreeUI`, `SkillArt`, `ModernHUD`, `DiscoveryHUD`, `MovementControls` modules. No implementation is left only in Play. Mining, sale, empty-build respec, character position and menu selections during review were temporary memory-only preview state, not saved implementation or production progress. The checkpoint native-copy metadata is recorded privately alongside the backup.
- Runtime image bytes reduced from **24,700,347 to 3,225,122** (about **86.9%**). This is file size, not measured runtime memory. [Manifest](../../../assets/ui/progression/manifest.json), reproducible [export preparation](../../../assets/ui/progression/prepare_exports.py), original upload history and new ownership readback are retained. All 15 new IDs belong to User `291892217`, the original experience owner.
