# Phase 1B: core breaking interaction

9 November 2026. Implemented in the original open Studio place **94763223427049**, in Edit mode. User gameplay review is pending. This is a scoped interaction delivery with an **audio gap**, not a claim that the full quality milestone is accepted.

## What is applied

- Existing starter mesh retained. Tool grip removes the extra roll, moves the hand down the shaft and keeps the existing blade orientation. StrikeTip now follows the mesh's previously rotated striking end. The canonical property values live in MotionClips and are also applied when the server gives a pickaxe.
- The procedural R15/R6 coordinator now has a lower resting pose, clearer preparation, accelerated strike, follow-through and recovery, with bounded arm aim. Targeted pickaxe swings predict preparation, reserve contact/recoil for confirmation, and recover on rejection or timeout. Locomotion remains under the existing controller. Sequence/tool checks prevent old acknowledgements restarting a cancelled or switched swing. Unequipping, death and character removal clear presentation state.
- Server Hit events carry the actual raycast normal, round and break result. Client feedback deduplicates by player/strike within the round. Damage numbers are personal; shared surface effects occur once per accepted event. Initial rejected mining requests now receive a Miss acknowledgement; validation and damage math are retained.
- Contact dust/chips follow the confirmed surface normal. Breaks have a stronger localized burst and a BREAK label. Existing progressive fractures remain; the original surface is hidden before its visual replacement is parented. Recoil is reduced to avoid pushing shell faces deeply into adjoining layers; delayed reactions recheck exposure/intact state.
- Collection uses the existing server award and inventory path. The award receipt contains the actual quantity and resource name and goes only to its recipient. Cosmetic fragments do not represent extra units or grant rewards. The prior final-hitter eligibility rule remains unchanged.
- Bounds: eight simultaneous impact bursts, two ordinary/three strong/five break chips, dust lifetimes up to 0.3 seconds; four damage and two material labels, lasting 0.75/1.2 seconds; up to eight collection pieces per break and 48 total flights, each lasting at most 1.134 seconds. Reduced Motion suppresses flying impact chips, reduces dust, keeps gain labels stationary, and fades at most two collection pieces per break. These are code limits, not measured performance results.

## Sources and Studio paths

| Canonical file | Applied instance |
| --- | --- |
| src/ExcavationService.luau | ServerScriptService.Vesper.ExcavationService |
| src/ExcavationClient.luau | StarterPlayer.StarterPlayerScripts.ExcavationClient |
| src/ToolMotion.luau | ReplicatedStorage.VesperShared.ToolMotion |
| src/MotionClips.luau | ReplicatedStorage.VesperShared.MotionClips |
| src/ShellMotion.luau | ReplicatedStorage.VesperShared.ShellMotion |
| src/ImpactFX.luau | ReplicatedStorage.VesperShared.ImpactFX |
| src/CollectionMotion.luau | ReplicatedStorage.VesperShared.CollectionMotion |
| src/MiningFeedback.luau (new) | ReplicatedStorage.VesperShared.MiningFeedback |

Template property changes: ServerStorage.VesperKit.StarterPickaxe.Grip and Handle.StrikeTip.Position, recorded in assets/phase1b/pickaxe-handling.json. Existing mesh ID **108416490695072** and its materials/geometry are unchanged. No new uploaded assets, animation IDs or Blender exports. Both rejected upgrade studies remain historical and were not imported.

## Recovery and synchronization

Baseline commit: `f9c09f2a088a9d0e995ec24a0bad7324ed482f04`; branch: `planning/development-foundation`.

Private directory: `C:/Users/BOSS/Desktop/egg/Backups/Phase1B_20261109_190946/`.

- Fresh full native **ComingSoon_94763223427049_before.rbxl**, **4,083,531 bytes**, saved before edits through Studio File > Download a Copy. SHA-256: `80AA95B10727FF215CCB24211DD47C980B851AEF454518B952F62EA3B56A5687`.
- Post-edit native **ComingSoon_94763223427049_after_1925.rbxl**, **4,087,210 bytes**, saved through the same native operation.
- Pre-edit src, assets and release copied, including existing editable Blender/texture/export files. Eight relevant live source strings captured separately. Backup coverage includes the native saved DataModel; externally hosted asset IDs remain references, not independent downloaded bytes or ownership guarantees. Unsaved external application state is not captured.

Files exist and their sizes/hashes were read. Neither native copy was opened as a development target; restoration was **not tested**. Backups are local on the same disk and excluded from Git. The current original place remains the implementation/manual-review target; nothing was saved or published to Roblox servers.

All eight delivered source strings were compared against Studio readback with line endings normalized and matched. Grip/tip properties were read back, and the unchanged mesh ID was confirmed. The pre-edit eight inspected scripts matched the backup immediately before mutation. Only these mapped sources and the two template properties were edited; no builder/restore recipe was executed. Old release snapshots remain historical and must not overwrite this delivery. No profile or production-data mutation was performed by the agent.

## Incomplete and unverified

- **Mining sound is incomplete.** Read-only inspection found no Sound or Animation instances and no suitable local audio source. The old mining path reused `rbxasset://sounds/action_jump_land.mp3`, a generic landing sound; that mining substitution has been removed. Existing unrelated sale audio is untouched. MiningFeedback contains bounded Hit/Break/Collection hooks with empty IDs. The available integration has no audio upload operation; no permitted replacement asset was established. Suitable existing audio IDs with experience access, or permission to produce/upload suitable audio through a supported workflow, are needed to finish audible impact. No IDs were invented.
- Existing procedural poses need manual approval on actual R15/R6 avatars, avatar scales and camera angles. Physical blade-to-shell fitting is not established: the unchanged 16-stud mining reach exceeds the physical reach of the current tool/arm. Bounded arm aiming and confirmed surface effects do not solve that geometric mismatch. Range/damage rules were deliberately preserved; a later scoped reach/pose decision may be needed after manual review.
- Confirmation latency can lengthen a targeted swing's contact hold/recovery, affecting perceived cadence; server cooldown values remain unchanged. No network or device performance was measured.
- Surface replacement ordering and recoil overlap were addressed in code, but absence of flicker, seams or clipping is not verified. Full egg geometry and fracture startup readiness were not rebuilt. Existing broad startup, HUD and reward-policy issues remain outside this slice.
- No tests, Play/Run, simulations, synthetic players, gameplay automation or diagnostic execution. No publishing, installs, save grants, new economy/progression systems or new concepts/previews. Static review and source/property comparisons are the only verification performed.

## Manual review in the original place

1. Press Play yourself. Equip the existing pickaxe; inspect hand placement, blade orientation and rest pose while standing and moving.
2. Strike nearby shell faces and their centers, then hold the strike control. Look for one preparation/contact/recovery cycle, clear ordinary/precise damage numbers, localized effects and no doubled impact. Mining sound is currently absent.
3. Break a section. Look for a distinct break, brief fragments and one `+quantity material` receipt. Compare the bucket/material totals before and after; only the actual final-hit recipient should receive the award under existing rules.
4. Unequip or switch an already-owned tool during preparation/recovery, then re-equip. Also try a blocked or out-of-range target, a full bucket and character death/respawn when convenient. Rejected strikes must show no confirmed damage or gain and must not leave a stuck pose.
5. If available during your review, have two players hit the same section; inspect per-player damage feedback and the single break/award. Check normal camera distance and Reduced Motion for readable targets and short-lived effects.

Report issues within Phase 1B before advancing. The pending decisions are feedback on handling/contact/readability and the permitted mining audio source; neither rejected upgrade nor any later phase is approved by this delivery.
