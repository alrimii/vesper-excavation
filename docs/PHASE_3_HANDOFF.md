# Phase 3: distinct tools and per-tool upgrades

Historical delivery. Phase 4 supersedes the original-target cancellation, full-section capacity reservation and final-hit material ownership described below; see [the Phase 4 handoff](PHASE_4_HANDOFF.md). Advancing phases does not establish that this delivery's unperformed checks passed. Current menus/HUD are functional interim UI, not final visual approval.

9 November 2026. Implemented directly in original place **94763223427049**, Coming Soon, Edit mode, place version 55. Pre-phase commit: `9498861fcd426792bcc490232b3a4236c9b708b6`; branch: `planning/development-foundation`. The delivery message supplies this commit's SHA/link. Phase 3 authorization does not establish that outstanding Phase 2 gameplay checks passed.

## Tool behavior

- **Pickaxe:** the authored swing completes on its local timeline instead of holding a frozen pre-contact pose while waiting for a server response. Holding attack repeats individual complete cycles. Preparation is predicted; successful surface effects, sound, damage and materials still require a unique server receipt. The server retains the delayed contact check at 0.47619047619 of the swing duration. Late confirmation can therefore lag the locally predicted swing under network latency; it never fabricates a successful hit.
- **Drill:** one immediate server-validated damage tick per rate-limited Mine request, without a delayed strike or autonomous server damage loop. The client samples current aim while held/toggled and requests only at the existing tick interval. A broken target is reacquired under the same aim; the existing all-sections layer exposure policy remains. Rotation has start/contact/free-running/stop presentation, with the existing rotor and two-hand handling. Confirmed contact adds restrained dust and a contact sound loop. Running without valid contact spins at 35% of full speed and shows NO CONTACT. Desktop release or touch toggle-off stops requests; there is no queued damage to continue afterward. Requests already received by the server are validated against its current state.
- **Explosive:** a server-accepted placement shows a short charge cue, then one detonation. Eligible exposed sections are captured once at detonation, before damage or layer exposure changes. No Roblox physics Explosion, player damage, concealed-layer penetration or recursive search through newly exposed sections. The original targeted section must still exist, be exposed, and be reachable at detonation; otherwise the charge is cancelled.

All tools share the original non-yielding HP/break/material-award path. A section's broken flag and inventory are mutated once in that path; simultaneous requests cannot interleave inside it. Break receipts keep final-hitter ownership. Feedback deduplication now includes section ID as well as player/round/sequence, so a multi-section blast can display distinct legitimate results without duplicating one section's reward.

## Exact values and changes

These are **provisional implementation values, not gameplay-verified balance**. Existing base values, ownership costs, prices and saved upgrade caps are unchanged.

| Tool | Base ordinary damage | Base interval | Power per level | Interval reduction per Speed level | Minimum interval | Power/Speed cap |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Pickaxe | 25 / strike | 0.600 s | +2 | 0.006 s | 0.300 s | 50 each |
| Drill | 55 / tick | 0.380 s | +4 | 0.004 s | 0.180 s | 50 each |
| Explosive | 280 at center | 2.400 s | +16 | 0.020 s | 1.400 s | 50 each |

At level 50 in both upgrades, ordinary values before buffs are 125 / 0.300 s, 255 / 0.180 s, and 1,080 center / 1.400 s respectively. Base drill DPS is 55 / 0.38 = approximately 144.7 while contact is maintained. Actual damage is capped by section HP.

Existing modifiers remain: power is floored after the strength/creature bonus; accurate contact within 0.75 studs of the section Center starts at 1.35x, Precision adds 0.02 per level, repeated precise hits on the same section add 0.05 up to a three-hit chain, and a critical hit multiplies by 1.5. Blast precision/critical are rolled once from placement and apply before distance falloff. Damage is rounded to the nearest integer afterward. No creature or strength progression was added.

New fixed blast settings in `ExcavationConfig.Tools.Explosive`:

| Setting | Implemented value and purpose |
| --- | --- |
| Fuse | 0.45 seconds; readable placement and a cancellation window |
| Radius | 6 studs; localized neighboring shell area |
| Maximum sections | 7 including the primary; bounds damage and rewards per detonation |
| Edge multiplier | 0.35; linear formula `1 - 0.65 * distance / 6` |
| Visibility | Rays from impact + 1 stud along its normal and from the player's head must both reach the candidate section; only the current exposed layer qualifies |
| Neighbor distance | Both candidate center and confirmed surface point must be within 6 studs; this deliberately excludes some partial-edge overlaps |
| Ordering | Ascending confirmed surface distance, then unique section name; primary distance is zero |
| Range | Initial contact retains 16 studs + 0.5 tolerance and the root check. Delayed contact retains the existing 2-stud impact grace. Each blast candidate also has a head-distance limit of 22 studs |
| Capacity | Before each selected section, require room for its full existing material yield. Otherwise skip it entirely, including nonlethal damage; no partial award or overflow. A server notice reports sections hit and skipped for space |

At the radius edge, an unmodified ordinary blast uses 98 damage (280 x 0.35). The actual number of affected sections may be lower than seven because of visibility, distance, exposure or capacity. This conservative radius/cap/falloff favors a controlled area action over clearing whole layers. The previous explosive used the single-target delayed mining path; it now uses this snapshot blast. Its base power/cooldown are preserved, but its old cooldown-proportional windup is replaced by the fixed fuse. Drill ticks no longer inherit pickaxe windup. Pickaxe windup/cadence values remain unchanged.

Cooldown is consumed on accepted initiation, including a subsequently cancelled charge. Cancelled attempts do not receive a cooldown refund. Cancel/DrillStop invalidate pending tokens even when the ordinary remote budget is full; cancellation broadcasts are capped at ten per second. Mine requests retain the 0.08-second ingress gate, 24 ordinary requests/second budget, integer/monotonic sequence checks and existing 0.035-second cooldown scheduling tolerance. Ordinary client drill requests are at most about 5.56/second at maximum Speed, never once per rendered frame.

## Upgrades and persistence

The existing `toolId`, `toolLevels[family][key]`, active upgrade fields and profile version are retained. Switching banks active levels and restores the destination's saved levels. Purchases now write the active field and matching per-tool entry immediately. Profile normalization falls back to the saved per-tool entry when the active top-level field is absent, instead of replacing it with zero. No save was loaded or changed for testing.

Temporary drill trials read the drill's own levels rather than borrowing the selected owned tool's levels. The pre-existing trial upgrade-purchase restriction is now visible in the UI. A trial does not overwrite owned-tool investment.

Every existing upgrade displays current level, current/next effective value, next price and affordability, batch result where applicable, and a plain-language description. Power values include the current strength/creature bonus. Drill Power/Speed show damage per tick, interval and derived ordinary DPS; explosive descriptions show center damage, cooldown, fuse and fixed radius/falloff. Maxed upgrades explicitly show MAXIMIZED. The existing scrollable inspector accommodates the details. Comparisons describe play style, not universal superiority.

Other unchanged per-tool upgrades:

| Key | Effect | Cap | Base price / growth |
| --- | --- | ---: | --- |
| Power | Tool-specific step above | 50 | 18 / 1.12 |
| Speed | Tool-specific reduction above | 50 | 24 / 1.14 |
| Capacity | 40 base storage +10/level | 40 | 16 / 1.11 |
| Precision | 1.35x base +0.02/level | 20 | 30 / 1.14 |
| Yield | +1 material per broken section/level | 15 | 45 / 1.18 |
| Value | +2% sale value/level | 25 | 30 / 1.15 |
| Critical | +1.25 percentage points/level; 1.5x critical damage | 20 | 40 / 1.15 |

Price remains `floor(BaseCost * toolPriceScale * growth^currentLevel + 0.5)` with scales 1/4/12 for pickaxe/drill/explosive. Ownership costs remain 0 / 18,000 / 85,000 credits. No radius upgrade, new currency, tree or equipment family was added.

## Audio and effects

The prior missing-mining-audio integration is now implemented with these discovered free Creator Store assets:

| Role | Asset | Creator | Observed duration |
| --- | --- | --- | ---: |
| Pickaxe impact | [9118617342: Rock Impact Large Hit Scrape](https://create.roblox.com/store/asset/9118617342) | ProSoundEffects | 0.864 s |
| Drill contact loop | [199754867: Drill Loop](https://create.roblox.com/store/asset/199754867) | Hydrablox | 2.508 s |
| Detonation | [120212342534790: Debris Explosion + Small Rocks Rumbling 2](https://create.roblox.com/store/asset/120212342534790) | GleonoffG | 2.887 s |

No existing Sound instances or universe inventory audio were found. All three Creator Store insertions succeeded; subsequent property reads reported `IsLoaded=true`, `Playing=false`. No sound was played for audition and no runtime was started. There is no observed asset-loading blocker in this Studio session; audible fit, loop seam, timing, mixing and actual runtime permission behavior still need user review. Asset sources and template properties are preserved in `assets/audio/mining-audio.json`. The [official audio-assets guidance](https://create.roblox.com/docs/audio/assets) identifies Creator Store audio as a free-to-use source; these are hosted third-party references, not new uploads or locally owned sound masters.

Runtime sound bounds: eight simultaneous mining sounds including at most four drill loops; one loop per player; 6-to-70-stud inverse-tapered attenuation. Base volumes are 0.18 impact, 0.14 drill, 0.24 blast, multiplied by existing SFXVolume. One-shots are removed within 3.2 seconds. Contact leases are refreshed only by confirmed ticks, expire at interval +0.12 seconds (hard cap 0.55), and stop sooner on local invalid aim/input, target break, tool removal, death, cancel or round/status change. Volume changes affect existing sounds too.

Existing impact limits remain eight concurrent bursts and at most five short-lived chips per break. Ordinary drill ticks use one dust particle and no chips; breaks retain their distinct feedback. Charge cues are capped at eight and expire by fuse +0.2 seconds; blast accents are capped at three and live 0.24 seconds. No screen shake or physics explosion was added. Reduced Motion removes drilling vibration, slows rotor rotation to 20%, removes flying chips and uses a small fading blast accent. These are configured bounds, not measured performance.

## Cancellation and manual review

Releasing attack stops repeats; a valid already-placed explosive completes its short fuse. F, switching/unequipping, opening blocking menus, losing focus, death, training or leaving the round invalidates the pending action. Target eligibility and range are checked again at detonation; an invalid original target cancels the blast. Cancelling cannot leave delayed damage scheduled against a new tool/round. Existing touch drill toggle remains; STOP DRILL and CONTACT/NO CONTACT reflect its active local state. A confirmed break stops its drill loop immediately, without waiting for the section's replicated Intact flag. Reduced Motion applies to all drill rigs viewed by the local player.

Please review in the original place:

1. Hold pickaxe attack, release, then strike again. Look for separate smooth cycles without frozen confirmation poses; check sound and damage align acceptably under real latency.
2. Hold desktop drill attack and use the touch toggle. Move off the shell, out of range, and back; check NO CONTACT, loop stop/restart, and reacquisition after breaks. Stop through a menu, tool switch and death.
3. Place a charge near several exposed sections. Check the cue, one blast, center/edge damage, seven-section maximum and no hidden-layer damage. Cancel during the fuse with F, a menu or a switch; check target destruction by another player and round changes.
4. With a nearly full bucket earned through ordinary play, detonate over several sections. Confirm stable capacity-limited skips, no overflow/partial awards, and materials matching inventory. Have another player hit the same section to check single-break ownership/receipts.
5. Buy an existing upgrade with earned funds, switch through all three tools and return. Compare saved levels, current/next values and prices; check the drill DPS and explosive description. Normal persistent rejoin remains a user review item; Studio preview accounts reset and grant extensive pre-existing unlocks.
6. Mute/unmute effects and enable Reduced Motion. Check the three sound characters, attenuation and drill-loop cleanup. Recheck the Phase 2 direct join, respawn, small-screen HUD and genuine end reveal/next delivery.

## Applied sources and backup

Thirteen sources were applied and read back against canonical UTF-8 files after line-ending normalization: ExcavationService and ResearchProfiles in ServerScriptService.Vesper; ExcavationClient in StarterPlayerScripts; ExcavationConfig, ProgressionRules, ToolMotion, DrillHandling, UpgradePresentation, WorkshopUI, ModernHUD, ImpactFX, MiningFeedback and new ToolFeedback in ReplicatedStorage.VesperShared. Three non-playing Sound templates were inserted in VesperShared.MiningAudioAssets. Existing equipment geometry and models remain unchanged. No builder/restore recipe was executed.

Private folder: `C:\Users\BOSS\Desktop\egg\Backups\Phase3_20261109_202230`

| Native copy | Bytes | SHA-256 |
| --- | ---: | --- |
| ComingSoon_94763223427049_before.rbxl | 4,091,700 | C47E74B1D1DC40F0EBF7B313C8E7713245F702EC9D121F04E36599DFFA2EADD2 |
| ComingSoon_94763223427049_phase3_applied.rbxl | 4,098,914 | 8C4660EE6466610B98D12EBD60BB81B32ECB35460D18F398BF89E1CD38A67DF0 |
| ComingSoon_94763223427049_phase3_final.rbxl | 4,098,956 | CBA31C41D87431647F75CC7F1FB5EC42E40565D7C3C6FA37EE1646846D25D345 |

All three were saved by native Download a Copy to new filenames, never opened as development targets. The final copy includes the last drill cleanup and Reduced Motion corrections; the intermediate applied copy is retained for recovery history. The folder also preserves pre-edit src/assets/release and affected live source captures. Existence, size and hash were checked, not restoration. Native copies contain the serialized place and hosted references, not independent hosted audio bytes, production DataStores or unsaved external-app state. All backups remain private on the same disk, excluded from Git. Public release binaries remain historical.

Only static source review, source/property readback, metadata inspection and file/whitespace checks were performed. **No tests, diagnostic execution, Play/Run, simulations, synthetic players, gameplay input, audio audition, concept previews or publishing.** Multiplayer, save migration/persistence, audiovisual quality, balance, device performance and the prior Phase 2 checklist remain unverified. Existing Studio preview grants, runtime fracture-loading dependency and contribution/creature eligibility limitations remain documented and unchanged. Stop here for user feedback; Phase 4 is not authorized.
