# Authorized one-time fresh start

The user explicitly authorized a complete fresh start for all pre-reset player progress on 10 November 2026. HUD checkpoint remains unapproved and unchanged. Original place: **94763223427049**, universe **10773858644**. No Play, automated gameplay, synthetic profiles, grants, redemption codes or new systems.

## Exact operation

`ResearchProfiles` now uses the fixed standard DataStore **VesperDiscovery_FreshStart_20261110**, default/global scope, with UserId keys and envelope generation **fresh-start-20261110**. This is a one-time active-save cutover, **not deletion of the retired store**. The name is a literal, not derived from current date, join count, place version or publication. Keep it unchanged on future releases.

Every player, including players with valid schema-1 saves in the retired store, begins afresh on their first join to the new release. No old record is read, retained in the active profile, copied or migrated. The first atomic UpdateAsync writes complete normalized current-schema defaults and acquires the normal session lock. Later joins load that same profile; later publications do not reset it. Invalid current-generation data is rejected rather than silently reset. Saves require both the current generation and matching session token.

Pre-reset servers only reference **VesperDiscovery_v1**. Their autosaves, late rewards and shutdown saves cannot write the new namespace. Never roll back to a loader using the retired store: that would re-expose old progress. Deployment should retire outdated servers so players do not continue using the old loader.

## Fresh published defaults

- Credits, income, relics, strength, legacy XP, new XP, derived level, skill points and all equipment upgrade levels: **0**.
- Owned/equipped tool: **starter Pickaxe only**. Drill/explosive ownership false. All per-tool upgrade levels 0.
- Material counts/value, pending materials, creature settlement receipts, samples, discoveries and creature counts: empty/0. No equipped creature; display slots normalize against an empty collection.
- Skill schema **1**, no purchased ranks, empty active loadout, no progression high-water mark or retained cooldown guards.
- Starting teal room theme only; tutorial/intro stage 1, first contract with progress 0, drill trial unused. Normal existing bucket/tool base stats apply.
- No paid entitlement or Roblox platform ownership is altered. No separate implemented achievement/world/rebirth store was found in the canonical runtime save path; no such system is introduced.

All saved profile fields are abandoned together; no prior equipment, currency, creatures or permanent acquisitions are carried into this fresh start. Existing Studio memory-only preview money/unlocks stay in the IsStudio-only branch and are never used for a published fresh account. No preview behavior or grants were added.

## Recovery and verification

Private development recovery: `Backups/LiveReset_20261110_005220/`, original native place before editing **4,122,461 bytes**, source/docs/instructions; final native reset checkpoint **4,122,785 bytes**. These copies contain game implementation, not player-progress backups. Restoration not tested.

Static inspection and normalized original Edit-mode source readback only. No DataStore test records, gameplay sessions, persistence tests or user impersonation. User will check real joining. The old legacy-schema refusal no longer affects new-release loads because the retired store is never read. Network/service failures or a legitimate lock can still temporarily prevent loading; corrupt new-generation profiles fail closed rather than losing progress.

Publication confirmed by Studio local log: **v137**, `Published new changes in "Coming Soon" to Roblox.`, `Publish succeeded for placeId 94763223427049`, at **2026-11-09 21:55:23 UTC**. Same existing place; no audience change or duplicate experience.

## Deployment outcome and remaining stored records

Creator Hub Server management for the sole place 94763223427049 reported **0 outdated servers and 0 players to migrate**. The outdated-only/no-delay Restart action was disabled; the dialog was cancelled. No restart was executed or needed for the observed population. Namespace isolation remains the protection against any stale write; this does not rely on a client reset flag.

Creator Hub Data Stores Manager listed only **VesperDiscovery_v1**, **2 keys**, **802 B**. Individual player contents were not opened or exported. The user-authorized old-progress cleanup was applied using that exact store's **Mark for Deletion** action. Creator Hub returned **Operation successful** and displayed **Permanent deletion begins after December 10, 2026 at 12:59 AM**. The confirmation specifies a 30-day retention period. Thus the old records still exist in Roblox's deletion-retention window; permanent erasure has NOT already happened. No copy/migration into the new store and no player-progress recovery backup were made. Do not restore this retired store. Its deletion is distinct from the namespace cutover and does not affect the active fresh-start store.

The new store/profile keys are created by legitimate published joins, not by artificial review accounts. No claim that affected accounts have already joined or that persistence was gameplay-verified. The legacy-schema access blocker is removed in the published loader. Creator Hub still shows **Game access: Private / Audience reach: Private**; this existing setting was not changed, so friends must have appropriate access. Roblox service availability and normal profile locking remain external possible load blockers.
