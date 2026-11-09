# Phase 4: persistent placement, shared materials and contribution

9 November 2026. Applied directly in **Coming Soon, original Studio place 94763223427049**, Edit mode. Branch `planning/development-foundation`; pre-phase commit `80cdb430861a41302af468d0bf85907784bd83dd`. The delivery message supplies the new commit. Earlier unperformed gameplay/audio checks remain unverified.

## Blast placement

The accepted action captures the server-raycast world position, surface normal, original exposed layer, round, actual equipped tool and cancellation token. Precision/critical damage is rolled once at placement and retained, so destroying the original section during the 0.45-second fuse no longer invalidates the charge. The blast no longer repeats the original-target contact check at detonation.

Detonation snapshots remaining exposed, non-permanent, unbroken sections from that original layer once, before applying damage. Unchanged settings: **6-stud radius, maximum 7 sections, linear falloff from 100% center to 35% edge**. Both candidate-center and confirmed surface distance must fit the radius. Existing visibility rays from the placement plus one normal stud and the player's current head remain; candidates retain the 22-stud head-distance limit. Sort by confirmed surface distance, then unique section name. The original section is distance zero only if still eligible. Concealed sections and newly exposed layers never enter the same snapshot. An empty snapshot still produces one explosion without damage or materials.

Damage remains ordinary HP subtraction, rounded to the nearest integer and capped at remaining HP. Surviving sections keep their reduced HP and existing hit/crack response. Base power/cooldowns and Phase 3 audio remain unchanged. F, switching/unequipping, death, blocking menus, leaving/training and genuine round transitions still cancel. Accepted cooldown is consumed even when cancelled; releasing attack only stops repeats. Finishing the entire egg starts the existing transition and cancels pending actions; clearing only the placement layer can leave an empty, harmless blast.

## Exact material allocation

Every accepted damage application records `d = actual HP removed` under the contributor's **UserId**, plus `d × YieldLevelAtThatHit × YieldStep`. YieldStep remains 1. Overkill, rejected requests, client effects and repeated feedback do not count. All tools use the same non-yielding damage path. Section records survive death, tool changes and same-server disconnect/rejoin, and remain until the next genuinely new egg.

At break, the section's broken flag and settlement flag prevent a second settlement. Let `B` be base yield, `D_i` each contributor's accumulated effective damage, and `T = sum(D_i)`:

1. Assign `floor(B × D_i / T)` base units.
2. Distribute the remaining base units by descending integer remainder `(B × D_i) % T`; ties go to lower numeric UserId.
3. Personal Yield bonus is `floor(sum(d_hit × YieldLevelAtHit × 1) / T + 0.5)` for that contributor. Round independently to the nearest integer, with exact halves rounded up.
4. The contributor earns their allocated base units plus that personal bonus. The final hitter has no special material allocation.

Base allocations sum **exactly to B**, not B per participant. Current B is 3 shell, 3 membrane, 2 tissue. Bonuses use damage-time upgrades, including mixed tool/upgrade histories; they do not use the final hitter's equipment. Independent bonus rounding can make the sum of bonuses differ from the unrounded damage-weighted average. A contribution can legitimately round to zero units. Solo damage at one constant Yield level retains the old full Yield bonus.

Illustrative arithmetic, not an executed test: with B=3 and 80%/20% damage, base shares are 2 and 1. At Yield levels 5 and 10 throughout those hits, personal bonuses are 4 and 2, giving 6 and 3 total units. At B=2 and equal damage, base shares are 1 each. If B=3 and equal damage, the lower UserId gets the remaining base unit.

Each awarded unit keeps `layer.Value × the section's current-round egg Value` at settlement. Current layer values are 2/4/7; existing egg multipliers are 1/2/4. Pending claims group only identical resource IDs and identical original per-unit values. Partial delivery never averages prices. Selling still uses only actual bucket `materialValue`, multiplied by the seller's existing active Value upgrade and rounded by the existing server sale path.

## Capacity, pending claims and persistence

- A new mining action requires **at least one free bucket unit and no undelivered pending materials**, after attempting to drain existing pending claims. It no longer requires room for a whole section's final-hit yield. The same gate is checked before each blast candidate in stable order. Once a break fills the attacker's bucket, later candidates are skipped with a capacity notice. Nonlethal hits still require room. Pending claims do not permit full-bucket mining.
- Settlement first delivers older pending groups where possible, then adds the new personal share and delivers what fits. Remainders stay in the loaded profile's `pendingMaterials` list. Existing buckets larger than a newly selected tool's capacity are retained; no additional units are inserted until there is room.
- Pending materials drain during player synchronization: after selling, capacity upgrades, tool selection/trial changes, joining and other existing account updates. Selling clears and pays only the bucket that existed at the sale; pending materials then refill it and require a later sale. No new currency or separate inventory UI.
- Profiles default missing `pendingMaterials` to an empty list. Existing profile version, per-tool levels, ownership, balances and bucket data are preserved. Valid claim entries retain their count and unit value. No player profile was loaded or modified for testing.
- Offline settlement goes to an aggregated `serverClaims[UserId]` list. It also covers a player whose profile is not writable. No offline profile or differently locked record is written. These claims are not cleared when a new egg begins, but **untransferred server-memory claims are lost on server shutdown and are not delivered across servers**.
- On successful same-server rejoin, the entire memory list moves once into the newly loaded session-locked profile in a non-yielding operation; the memory entry is removed immediately. Subsequent joins cannot transfer it again. The existing 60-second autosave, departure save and shutdown save serialize pending materials and bucket values. Writable checks reject closing/expired-lock profiles; departure detaches the account before release-save yields. A normal save/network failure or abrupt server loss before a successful save still has the existing durability limits; transfer into RAM is not proof of a completed DataStore write.
- Studio's pre-existing profile mode uses fresh memory accounts and extensive preview unlocks. This was not changed or invoked. It does **not** establish durable save/rejoin behavior; stopping Studio also destroys the running server's contribution and offline-claim memory.

## Contribution and feedback

Whole-egg damage has its own UserId ledger and total. It survives death, switching and rejoining this running server, resetting only in `beginRound` for a new egg. HUD/results percentage is **100 × personal effective damage / all players' effective damage dealt to this egg so far**, or zero before anyone damages it. It is not progress toward the egg's total HP and is not a creature drop chance. Final results freeze those numerator/denominator values; same-server rejoin during that result can display them without granting rewards again.

Each recipient gets a private material receipt with base/bonus and actual delivered/pending units. Zero rounded shares are labeled. Distant recipients' popups move near their own camera so the receipt is not hidden beyond the world-popup range. The existing bucket card shows total pending units; its existing bag shows each material's bucket and pending counts. Sales report refilled/pending amounts, and same-server recovered claims have a join notice. Shared section debris happens once and falls/fades locally instead of flying to the final hitter. Existing damage/crack feedback, drill/pickaxe behavior, audio bounds and direct joining remain in use.

**Unchanged attribution:** section XP (+2), section cash (+layer index), the 1% relic roll, deep-section sample/+4 XP/+3 cash, Break/Sample contract credit, and legacy Collect contract credit still go to the final hitter. Collect contract credit remains base yield plus that final hitter's current Yield level even if their actual material share is smaller. Sell/Upgrade contract credit remains with the actor. Existing online completion stipends, creature probabilities and online candidate/winner selection are unchanged; contribution percentage is not used for creature selection. No trophies, levels, rebirth or new economy was added.

## Applied sources and UI scope

Ten source files were applied and read back against canonical files after line-ending normalization:

- `ServerScriptService.Vesper`: ExcavationService, ResearchProfiles, new MaterialRewards.
- `StarterPlayer.StarterPlayerScripts`: ExcavationClient.
- `ReplicatedStorage.VesperShared`: MiningFeedback, ModernHUD, MaterialBag, ExpeditionResults, UpgradePresentation, CollectionMotion.

No equipment models, world geometry, rejected designs or hosted assets were replaced. No builders/restores were executed. Current HUD/menus remain **functional interim UI, not approved final visual quality**. The roadmap now explicitly retains dedicated illustrated equipment/upgrade screens and a genuine navigable skill tree with connected nodes, branches, prerequisites and locked/available/unlocked states. Mechanics and final UI art direction need their own scoped phase. This delivery adds factual contribution/claim feedback only, not that redesign.

## Private recovery coverage

Folder: `C:\Users\BOSS\Desktop\egg\Backups\Phase4_20261109_210913`

Before edits: `ComingSoon_94763223427049_before.rbxl`, **4,098,956 bytes**, SHA-256 `CBA31C41D87431647F75CC7F1FB5EC42E40565D7C3C6FA37EE1646846D25D345`. Saved by native Download a Copy to a unique filename before source changes. Pre-edit src/assets/release and affected live-source captures are also preserved privately.

An intermediate post-implementation copy, `ComingSoon_94763223427049_phase4_final.rbxl`, is retained: **4,102,457 bytes**, SHA-256 `5D6064A522173CC88DCB444A8AF9333827E243A8C8C092E53B8899E19602FE1F`.

Final reviewed copy: `ComingSoon_94763223427049_phase4_reviewed.rbxl`, **4,102,446 bytes**, SHA-256 `DE23A101D21E5098771369E68AB898F98E310D3609B1BD71F3C661130749FBD3`. This includes the percentage-first HUD wording for narrow screens. Original place ID and Edit mode were read back; no publication occurred.

Native copies cover the serialized original place and hosted asset references, not DataStores, independent hosted audio/image bytes or unsaved external-application state. Copies remain private/ignored on this disk and were never opened as development targets. Existence/size/hash verification does not establish restoration.

## Manual review in the original place

1. Share a section with another player using all three tools. Compare effective damage and integer material shares; reverse who lands the last hit. Check base-unit conservation, damage-time Yield bonuses and no duplicate receipts on simultaneous hits.
2. Use an edge blast on a durable section. Confirm reduced HP/cracks persist without guaranteed destruction. Have another player destroy the original target during the fuse; remaining original-layer neighbors should still be hit. Clear that layer before detonation and check a harmless blast with no next-layer damage.
3. Cancel charges with F, switching, unequipping, a blocking menu and death. Confirm the spent cooldown remains. Review the genuine egg transition separately from target destruction.
4. With one free bucket slot, break a shared section. Check delivered/pending amounts, full-bucket action blocking and stable blast skips. Sell once: only prior bucket contents pay, pending units refill afterward. Sell again and check values; switch to a smaller/larger capacity tool and check retention/no added overflow.
5. Contribute, disconnect before another player breaks the section, and rejoin the **same still-running server**. Check recovered materials, retained egg contribution and one-time transfer. Repeat rejoin to look for duplication. Separately review persistent profile claims where the existing save workflow permits; Studio fresh preview profiles do not validate production persistence.
6. Check personal percentage as other players deal damage, death/respawn, the final result and reset on the next egg. Recheck direct joining, audio, touch/desktop controls and small-screen layout; none is newly claimed verified.

Only static code review, source/property readback, native file verification and Git whitespace review were performed. **No tests, Play/Run, simulations, synthetic players, gameplay input automation, save manipulation, grants, audio audition, concept media or publishing.** Multiplayer settlement, persistence, audiovisual fit, layout, balance and performance remain unverified through gameplay. Prior unresolved runtime fracture-loading, preview grants and creature-eligibility limitations remain. Stop for user review; no later phase is authorized.
