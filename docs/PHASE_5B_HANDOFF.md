# Phase 5B: signature skills and progression checkpoint

Implemented directly in original place **94763223427049**, Edit mode, from `61fea9c446e4c071ee3c11422dfc09d33814a14a` on `planning/development-foundation`. This is an **unpublished development checkpoint**, not a complete public progression release. Source/property readback is synchronization evidence only. Gameplay, device/input navigation, balance, persistence and final visual quality remain unverified/unapproved.

## Foundation and accounting

- Levels 0..100. New schema and the existing memory-only Studio preview start at L0, zero XP, no learned ranks or active skills. Pre-existing Studio preview currency/equipment/creature behavior is unchanged; no new grants or save manipulation were used.
- Configurable provisional cumulative threshold: `T(L)=200L+20L^2+floor(L^4/10)`. Level is the highest reached threshold, including multiple crossings from one action. Cap `T(100)=10,220,000`; no L20 cap or overflow bank.
- `P(0)=0`; otherwise `P(L)=1+floor(L/2)+floor(L/10)`. Available points = derived entitlement minus allocated costs, never a repeatable event grant. Examples: L1 = 220 XP / 1 point; L5 = 1,562 / 3; L10 = 5,000 / 7; L40 = 296,000 / 25; L100 = 10,220,000 / 61.
- Actual positive HP removed is the only XP source: Bronze `0.040`, Golden `0.046`, Volcanic `0.052` XP/HP. Stored as integer 1/10,000-XP subunits (400/460/520 per HP); **XP multiplier 1** is the single reserved later-benefit hook. No overkill, rejected hit, receipt or cosmetic credit. Skill secondaries use the same authoritative mutation/material/contribution path.
- Removed the old 2 section XP, extra 4 deep-section XP, 30 contract XP and 100 completion XP together. End results show already-credited per-egg XP; opening/history/delivery cannot regrant it. Journal thresholds and contract descriptions now agree. Level-up feedback combines crossings over 0.5s without opening menus.
- Section/direct cash, relic/sample awards and contract attribution remain their existing final-hit policy. Contract cash remains; completion credits retain their prior amounts and online-at-reveal eligibility. Creature roll probabilities/mapping and material allocation/Yield rounding are unchanged.

## Eight implemented nodes

| Stable ID | Ranks, requirements, cost | Implemented behavior |
| --- | --- | --- |
| `impact.fault_survey` | L1/L20, 1 point/rank; root | Mark 2/4 other visible exposed sections at <=35% HP, within 8/12 studs of aim. Max 4 updates/s; sort HP fraction then section ID. |
| `impact.charged_swing` | L5, 2 points; Fault Survey | Equipped active pickaxe strike: 0.45s windup, 1.60x ordinary requested damage, 8s technique cooldown plus normal cadence. Q / gamepad Y / touch button. On-screen button uses camera-center aim; Q uses the ordinary aiming mode. |
| `impact.steady_aim` | L15/L40, 2 points/rank; Fault Survey | Ordinary Pickaxe/Drill precision radius 1.00/1.20 studs instead of 0.75; existing multiplier/crit unchanged. Target ring/status use the replicated radius. |
| `collection.batch_unload` | L1/L20, 1 point/rank; root | Explicit Sell processes up to 2/3 actual bucket loads, draining earned pending lots between each. Existing per-load Value formula and integer rounding; no distance restriction added. Receipt includes actual load count/credits/pending left. |
| `collection.sale_latch` | L5, 2 points; Batch Unload | Toggle defaults OFF. Full bucket after a positive root/secondary settlement and active input lease sells one load, max once/8s. Recent damage <=3s. Never invokes Batch or sells between blast/arc targets. Pending refill alone cannot retrigger. |
| `technique.precision_relay` | L1/L20, 1 point/rank; root | On ordinary precise-chain section break, offer earned chain to next precise different section on same layer within 4 studs for 3/5s; 6s ICD, chain cap 3. Nonprecise next ordinary contact consumes offer. |
| `technique.chain_lightning` | L5, 2 points; Precision Relay | Ordinary Pickaxe/Drill only: first positive root in each `floor(serverTime/4)` window consumes one opportunity. If 8s ICD ready, 25% draw. Up to 2 pre-root snapshotted exposed neighbors, 0.80B then 0.50B; hop<=4, origin<=6 studs. No recursive proc, explosion lottery tickets or newly exposed-layer targets. |
| `technique.core_drill` | L15/L40, 2 points/rank; Precision Relay | Flow Drill: 4s validated work across successful section breaks/retargets, then next valid tick starts 3s at 1.25/1.35D. No paused ordinary ticks. |

`B` is existing equipment/strength/creature base power; `D` applies existing precision/chain and crit once. Skill ranks replace previous rank effects, not multiply them together. Existing equipment ownership, prices and purchased upgrades are preserved. No L60/L85 equipment gates.

Flow first tick starts at zero; later valid ticks credit `min(interval, elapsed)` up to the 4s buildup. Gaps <=2s preserve partial buildup without catch-up; longer gaps reset it. Ready expires after 4s; enhancement expires after 3 wall-clock seconds, even without targets. No buildup during enhancement. Release/F, switch, unequip, death, blocking menus and round change clear temporary state. Invalid contact grants no damage or buildup. Client retargeting stops contact presentation without sending a whole-action cancellation.

Lightning snapshots unique sections before primary damage, nearest hop then ID, validates exposed original layer and surface visibility, rechecks owner/life/range/capacity, and applies through the existing non-yielding damage path. A successful draw with no neighbors consumes ICD and shows a spark without rewards. Secondary feedback is deduplicated by existing action/section keys and does not replay a tool swing/audio. Effects last 0.18s, max 12 cosmetic segments/client, distance-limited; Reduced Motion/Reduced Effects show endpoint accents. No new audio asset is claimed.

Accepted cadence, charged/proc/relay/latch/respec guards are retained in the profile and by UserId in same-server memory. Free respec does not clear cooldowns. Existing pending-claim gates still stop new/remaining damage once full or pending; skills never bypass them. Persistent explosive placement, 6-stud blast/7-section cap/0.35 edge falloff and ordinary partial HP damage remain intact.

## Tree and profile compatibility

- Three connected branches, selectable illustrated nodes, literal LOCKED/AVAILABLE/PARTIAL/COMPLETE/PLANNED states, rank sockets and distinct focus frame. Selection never purchases. Current/next effect, rank, level, prerequisites, cost and points are shown in the scrollable detail panel.
- Mouse/touch drag; wheel/pinch and +/- zoom 0.55..1.40; recenter. Keyboard arrows and gamepad graph links; X moves between node/details, Y recenters, LB/RB zoom, B closes. K / gamepad Select or the compact level/XP/points HUD entry opens the tree. No forced opening on join/respawn/level-up.
- One active slot at L5, two at L30. Only Charged Swing is implemented as an active; no future skill can be equipped. Server validates IDs, ranks, entitlement, prerequisites, slots, compatible tool, cooldown and loaded session.
- Loadout changes/free respec require a living player **inside their own room's floor/ceiling bounds**, no pending attack and 10s since accepted mining/effective damage. Respec has 60s throttle and clears only ranks/loadout/toggle/temporary counters; tools/currency/inventory/XP stay. Available points recompute from level. Sale Latch toggling does not grant inventory or attack.
- Historical Phase 5B behavior: `progression.version=1` contains XP subunits/ranks/loadout/toggle/highest level/guards inside the session-locked profile; nonempty legacy profiles were refused. **Superseded by the separately authorized [one-time reset, v137](LIVE_RESET_20261110.md)**: current published profiles start in a fixed fresh store with no legacy import. The original Phase 5B implementation itself did not reset or migrate player data.
- The unchanged legacy `xp` field is not a second displayed model and receives no new awards. Existing old `DiscoveryTests` level expectations are historical and were neither updated nor executed. No durable save/lease/crash/rejoin guarantee was tested.
- Pending material and creature claims remain same-server memory until transferred into a legitimate loaded profile; untransferred claims do not survive shutdown or cross servers. Studio preview remains memory-only and cannot prove persistence or preserve its progression across fresh preview sessions.

## Art and integration evidence

See [art README](../assets/ui/progression/README.md), [manifest](../assets/ui/progression/manifest.json) and `src/SkillArt.luau`. Fifteen original PNG illustrations: eight nodes, journal hub, three branch emblems, common frame, nine-slice panel/navigation skin and restrained backdrop. Masters and actual upload exports are preserved with prompts; raster files have no fabricated layers. State/focus/rank compositions are editable UI source using those assets.

One required image upload established the route before the batch. All 15 returned IDs were metadata-read back as Image assets owned by User 291892217, matching the place owner. Loading/moderation and final rendered Roblox appearance are unverified. Native 1254px exports are currently retained; mobile texture-memory optimization is not claimed complete. No repeated concepts, animated renders, videos, rejected models or new weapon assets.

Fifteen canonical sources were applied to the original Edit DataModel using source-only edits/new ModuleScripts; no builders or game modules were executed. Source readback matched canonical files after line-ending/outer-whitespace normalization. The UI and abilities initialize through the original runtime on the owner's next manual Play; an Edit-mode rendered UI/gameplay preview was not executed. No duplicate place, staging map, publishing or main merge.

## Backup and manual review

Private recovery directory: `C:/Users/BOSS/Desktop/egg/Backups/Phase5B_20261109_225406/`.

- `ComingSoon_94763223427049_before.rbxl`: **4,105,498 bytes**, SHA-256 `2C229E6CDC50ABE09AAC01C6770F193987A5F99665F67DBC51A12F5E0CA5AD66`, native copy saved before edits.
- `ComingSoon_94763223427049_final.rbxl`: **4,120,854 bytes**, SHA-256 `AA83A08B8B99516986CAB367AFE7D1DAFEFAE163E003FEDBE5D164F22EA67C9D`, saved after the final formatted source/readback. The intermediate `..._after.rbxl` is retained separately.
- `src/`, `assets/`, affected live source captures and source readback records preserve the pre-change editable/code baseline. `live-sources-final.json` preserves the delivered source text. The existing installed formatter was used for formatting only; no game module or test/diagnostic runner was executed.
- Coverage: complete current native place DataModel plus local source/editable assets, not a selected-root snapshot. Hosted asset references are not a full independent download of all hosted bytes; player DataStores and unsaved external editor sessions are not backed up. Recovery copies remain private/unopened. Restoration was not tested.

Manual review (no grants are required or supplied by the assistant):

1. Join/respawn directly into the current egg. Confirm L0/no skills in a fresh memory-only Studio preview and that existing equipment/inventory/HUD access remains.
2. Compare shared effective damage and fractional XP; overkill/invalid hits add no extra XP. When naturally crossing multiple levels, confirm the final level and total entitlement; reopening the tree grants nothing.
3. Learn a root, then at L5 choose lightning or charged strike. Check rejected prerequisite/point/PLANNED purchases and repeated clicks; selection itself spends nothing. Verify current/next rank at L20/L40.
4. Use the tree on mouse, touch and gamepad: pan/zoom/recenter, detail scrolling, focus, close and compact HUD entry. Review the **actual** illustrations at gameplay sizes; report any overlap, unreadable state or missing/moderated image.
5. For lightning, use ordinary pickaxe/drill on exposed neighbors; compare shared materials/XP, no concealed layers or recursive arcs. Check full/pending bucket behavior and concurrent hits.
6. For Flow, keep drilling across breaks; test a short contact gap, >2s interruption, ready expiry and 3s boost. Release/F, switch, die, or open a menu: no residual boost/damage/contact loop.
7. In your room after 10s idle, equip/clear Charged Swing and free-respec. Outside the room/while recent mining, requests should explain refusal. Respec must refund only spent points and preserve tools/materials/currency/cooldowns. Try normal, charged and held input afterward.
8. Compare one-load Sell, Batch Unload with earned pending materials, and opt-in Sale Latch while holding mining. Verify original unit values and that pending refill alone does not trigger more sales/mining.
9. Complete an egg: personal creatures/credits/reveal/next egg remain; XP says **already earned**. Reopen results/rejoin without rerolls or XP grants. Persistence/legacy refusal require a separately authorized appropriate environment; do not treat Studio's memory preview as a live save check.

Deferred: rebirth benefit/transactions, 13 later nodes, final equipment-shop illustrations, public progression release/reset/codes and home/incubation/world work. No tests, Play/Run, simulations, synthetic players, automated gameplay, production-save changes, currency grants, installs or publishing were performed.
