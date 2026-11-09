# Phase 4B: personal creature rolls

9 November 2026. Implemented in original Studio place 94763223427049 in Edit mode, continuing from b36cf180defb75d4a453d34063fec2cacbf2fe78 on planning/development-foundation. All nine changed/added runtime sources match canonical files by source readback, normalizing line endings and trailing whitespace. No gameplay, tests, diagnostics, simulations, publishing or player-save manipulation was performed. This is implementation evidence, not gameplay or durable-persistence verification.

## Eligibility and probabilities

At completion, freeze the existing server-authoritative effective-damage ledger. Personal share is personal effective damage divided by total effective damage dealt to that egg. Positive damage gets exactly one independent Bernoulli creature roll with probability `egg.DropChance * personalShare`. Zero damage gets no roll; overkill/rejected damage never enters the ledger. The last hit adds no chance. Multiple players can win; all can lose. No minimum, pity, boosts or guarantees.

Existing DropChance values are fractions, not percentages; ProgressionRules is unchanged:

| Egg | Stored fraction | 10% contribution | 50% contribution | 100% / solo |
| --- | ---: | ---: | ---: | ---: |
| Ancient Bronze | 0.08 | 0.8% | 4% | 8% |
| Gilded Sovereign | 0.15 | 1.5% | 7.5% | 15% |
| Volcanic Heart | 0.25 | 2.5% | 12.5% | 25% |

On success, retain the existing conditional variant selection: Vesper Crownback weight 80, Gilded weight 18, Ember weight 2. The existing shared reveal specimen mapping is unchanged; personal awarded variants use the existing collection mapping. A win adds one owned creature and one crownback discovery, and equips it only if no creature is equipped. No new creatures or asset IDs.

## Settlement, claims and existing stipends

New server-only EggRewards owns completion records. Identity is server JobId plus a fresh GUID, round number and (for delivery receipts) UserId. Freeze and Reveal are idempotent; Freeze resolves rolls immediately at completion, before the existing 2.2-second hatch delay. There is no client roll/grant endpoint. Results, death and respawn cannot reroll.

Disconnected contributors remain in the frozen ledger and receive the same independent roll. Revealed undelivered rewards persist in server memory across later eggs. On same-server rejoin, delivery checks the exact loaded Player/profile and existing CanMutate session-lock/lease gate. It never loads or writes an offline profile. Delivery changes the existing creature/cash/XP fields and records a receipt without yielding. Settlements retain delivered flags for the full server session; the profile keeps the latest 256 receipt IDs as a second guard. Receipt pruning does not discard or reopen server settlements. Old saves default to an empty receipt list without resetting progress.

Untransferred server-memory claims are lost on server shutdown and do not travel to another server. Transferred rewards/receipts use the existing autosave, departure save and shutdown save path. Persistence, save failures and crash recovery have not been verified; there remains the existing window between an in-memory grant and a successful save. Studio's existing preview profiles are memory-only and retain their pre-existing preview grants; they cannot demonstrate production save durability.

End credits/XP keep their previous amounts and eligibility: a positive-damage contributor must have a loaded account/session and be online at the reveal roster snapshot, 2.2 seconds after completion. Ancient Bronze grants 250 credits, Gilded Sovereign 500, Volcanic Heart 1,000; each grants 100 XP. Formula remains `floor(250 * egg.Value)` and 100 XP. Offline at that snapshot means no stipend, even if the creature roll wins. Returning before that snapshot retains eligibility. A temporarily unwritable profile does not receive a write; an established entitlement remains pending for a later valid delivery. These stipends are not proportional and are separate from creature eligibility.

Section XP, direct cash, relic rolls and existing Break/Sample/legacy Collect contract credit remain under their existing final-hit attribution. Shared base material allocation, combined-pool Yield rounding, hit-time Yield levels, pending material claims, unit values and selling are untouched. Other action contracts retain their existing actor attribution.

## Results and integration

The existing results panel shows personal effective damage, final contribution percentage, actual personal creature chance as a percentage, no-roll/loss/win outcome, awarded creature and actual delivered completion credits/XP. Pending profile delivery is labeled separately. No global winner label remains. The shared reveal and next-egg sequence retain their original server timing.

MORE > Egg results / this server opens up to 12 recent personal results with previous/next controls. Opening only reads replicated history; limiting displayed history never deletes claims. Returning contributors can recover rewards from older eggs. Archive odds now use contribution so far rather than a player-count split, explicitly labeled provisional until completion. Results use the existing style and responsive scaling; this remains interim UI, not approved final illustrated equipment or skill-tree work. Result menus cancel mining and participate in existing input/modal guards.

Runtime source changes:

- ServerScriptService.Vesper: new EggRewards, ExcavationService, ResearchProfiles.
- ReplicatedStorage.VesperShared: ExpeditionResults, WorkshopUI, ModernHUD, Targeting, MovementControls.
- StarterPlayer.StarterPlayerScripts: ExcavationClient.

Canonical files are the corresponding names under src. SOURCE_MAP documents placement. No builders, release snapshots, tool models, sounds or production DataStores were edited.

## Recovery and limitations

Private recovery folder: `C:/Users/BOSS/Desktop/egg/Backups/Phase4B_20261109_213911`.

- Before-edit full native place: `ComingSoon_94763223427049_before.rbxl`, 4,102,591 bytes, SHA-256 `F57B29E54692D96A4574C7287E9651CE55AAF8146477E8036A883370DA191F9F`.
- Pre-edit src and editable assets are copied there; affected-live-before.json records the inspected Studio sources.
- After-change full native place: `ComingSoon_94763223427049_phase4b_final.rbxl`, 4,105,498 bytes, SHA-256 `2C229E6CDC50ABE09AAC01C6770F193987A5F99665F67DBC51A12F5E0CA5AD66`.

Native copies use Studio's Download a Copy command, saved without opening them as implementation targets. They cover serialized place state and referenced asset IDs, not independent hosted asset bytes, DataStores/player progress, unsaved external editor state or off-device disaster recovery. Restoration was not tested. Original Studio remained in Edit. Its reported open version is 55; the user reports manually publishing the latest prior update, and cached open-place metadata does not establish the currently published contents. Phase 4B has not been published by the assistant.

Phase 2/3/4 unperformed gameplay checks, audio quality/asset accessibility, multiplayer timing, mobile/gamepad layout, session-lock delivery and save durability remain unverified. Settlements are retained for the running server's lifetime; memory use in very long-lived servers is not measured. No probability increase was made to make a manual win easier to observe.

## Manual review

1. Join a partly completed egg; confirm direct control, current progress and personal contribution. A zero-damage spectator should receive no roll or stipend.
2. Share effective damage, including different tools and overkill. At completion, compare final shares and displayed odds with the table. Verify each personal result and unchanged online stipend; a loss is a valid outcome even for solo completion.
3. Reopen results repeatedly, browse history and respawn: outcomes and collection counts must not change. Check desktop/touch/gamepad fit and cancellation while results are open.
4. Leave after contributing and return to the same running server after completion, including after the next egg starts. Confirm the recorded outcome is unchanged and any earned creature transfers once. Offline-at-reveal stipend stays zero. Do not expect recovery after shutdown or in a different server.
5. Confirm shared creature reveal and server-driven next egg still occur once. Joining during a transition must not replay completed sequences or reset the egg.
6. Recheck shared materials/pending capacity, persistent explosive placement and partial damage, tool switching and audio; these systems were preserved, not newly gameplay-verified.

Future one-time full published-progress reset and public/restricted testing redeem codes are roadmap notes only. No reset, migration, currency grant or code redemption was implemented. Stop at Phase 4B for user review.
