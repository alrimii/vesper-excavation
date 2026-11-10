# Gameplay HUD redesign checkpoint

Map cleanup delivery: [scoped implementation and evidence](../map-cleanup/REVIEW.md). World/ladder/frontage/shop/room and targeting corrections are delivered for review, **not closed or visually accepted**. HUD/menu/tree redesign remains paused. The mobile dark-boundary cause remains unresolved.

## Owner review ledger — all issues open until corrected and reviewed

The owner rejected HUD, loading, menus, skill tree, shop and world presentation. **The owner's screenshots were not supplied; the following are owner-reported observations, not screenshots inspected by the implementation engineer. All described problems predate the progress reset and must not be attributed to it.** The fixed fresh-start save generation is unchanged. This earlier checkpoint is historical, not an approved visual foundation. The new HUD delivery is recorded in [replacement checkpoint](../hud-rebuild/REVIEW.md).

| Area | Preserved feedback / required correction | Status |
| --- | --- | --- |
| Joining/loading | Simultaneous “Joining the excavation”, “SYNCHRONIZING” and equipment-unavailable/reconnect error; world strip above backdrop. Correct presentation AND real equipment readiness. Never conceal a failure or release without functional equipment. | Open; narrowly scoped source correction included in HUD replacement, owner recheck required |
| HUD identity | Unrelated illustrations pasted into generic rectangular navigation; confusing storage art; creature used for egg identity; inconspicuous skill entry. | Open; new composition/illustrations delivered for review, not accepted |
| HUD devices | Deliberate desktop/landscape layouts, readable mobile labels, guidance/XP/equipment must not crowd the character; essential actions on both devices. | Open; bounded captures only, physical-device review pending |
| Skill tree | Excess empty space/weak composition, tiny similar framed nodes, poor branch/state distinction, technical confirmation/implementation copy. Needs an exciting navigable progression map, readable connections/prerequisites/states, distinct branches and concise illustrated details; mobile details must preserve map area. Eight skills are partial, not the full progression vision. | Open; separate replacement checkpoint |
| Equipment/upgrades | Blue-white application panels; plus signs and empty preview areas instead of item artwork; dense current/next text. Needs matching illustrated equipment/upgrade experience. | Open; existing screen temporarily accessible |
| Targeting | Prominent distant section indicator while OUT OF RANGE. Actionable marker must agree with real range/obstruction; do not increase reach. | Open; no mining/range tests or unrelated targeting rewrite in HUD checkpoint |
| World/egg surroundings | Oversized room gaps, repetitive dull frontage; unwanted floating/orbiting light-like objects and square fixtures around egg; confusing columns/braces; unfinished ladder entrance, platform and signs. Remove unwanted generation at its source, not only temporary instances. | Open; no world redesign in HUD checkpoint |
| Physical shop | Sparse three-tool display/small signs. Needs inviting physical destination, approach-based mobile opening and matching illustrated equipment/upgrades. | Open; integrated later milestone |
| Rooms/creatures | Current layout and adjacent large cabinets do not scale; creature models/presentation unapproved. Organized left-wall shelves/slots, dark undiscovered silhouettes; discovered creature/name/rarity. Separate collection from future incubation/care. | Open; later scoped room/collection work |
| Broader vision | Remaining skill mechanics, rebirth, more tools and distinct evolutions, eggs/creatures, incubation, customization and worlds remain future work. | Open; no partial implementation labeled complete |

10 November 2026. Original place **94763223427049** only. The prior Phase 5B.1 result was rejected; this is a new composition, not visual acceptance. Skill-tree redesign and additional progression content are excluded.

## Implementation

- Cream, mint, gold and violet surfaces with consistent rounded forms, bold labels and existing original illustrated artwork replace the dark HUD panels and ornamental frames.
- Compact top-center egg identity/progress; tap for current layer and personal contribution. Currency counters are upper-left, bucket/Sell upper-right.
- Left navigation exposes equipment, creatures (desktop) and More. The drawer retains journal, equipment/upgrades, creatures, room, room collection, settings, controls, results, current contract and nearby optional training.
- Existing equipment models appear as static tool portraits in the bottom-center belt, with mint equipped state. One XP/level/points strip opens the existing tree. Short guidance is dismissible. The redundant floating FieldGuide control is suppressed; guidance remains under More.
- Landscape uses fewer edge buttons, compact counters/strip and a right attack control above the native jump region. Touch hides keyboard shortcuts. Shared components have separate desktop/landscape layouts and CoreUISafeInsets.
- `ExcavationHUDView` owns presentation, `ModernHUD` adapts actual replicated state and existing callbacks, and `Toolbelt` retains existing selection/ownership. No server, profile, economy, combat or tree scripts changed.

## Resources inspected and reused

- [UI Labs](https://github.com/PepeElToro41/ui-labs): component-preview plugin; repository GPL-3.0. Not available in the inspected plugin/project setup; not installed. Temporary Edit previews called the same production view and toolbelt with explicitly labeled sample values. No second playable environment or persistent preview UI.
- [Vide](https://github.com/centau/vide): MIT reactive library. Not added: the existing controller/view separation supports this checkpoint without a framework migration.
- [Kenney UI Pack](https://kenney.nl/assets/ui-pack): CC0; inspected, no assets imported. Existing original illustrations fit the excavation identity more closely.
- [Official Studio MCP](https://create.roblox.com/docs/studio/mcp): retained the working connection for source editing/readback and the bounded capture session. No replacement integration or installation.
- Actually reused: original `assets/ui/stage30/navigation-atlas.png` and its `generation.txt` provenance, Roblox image **136029899303945** (1024px served atlas). Equipment, hatchling, coins and a crystal crop provide HUD illustrations. Existing `assets/ui/progression/` masters/exports/manifest supply `journal_hub` **107667320750383** and `batch_unload` **127558201030086**. No new uploads, third-party game art, invented IDs or claims of layered raster sources. Existing `EquipmentAssets` models feed `EquipmentPreview` for tool portraits; temporary/rejected upgrade models are not imported.

## Recovery and compatibility

Fresh private recovery folder: `C:\Users\BOSS\Desktop\egg\Backups\HUDCheckpoint_20261110_003015`. Native `ComingSoon_94763223427049_before.rbxl`, **4,121,376 bytes**, plus pre-edit source, assets, documentation and instructions. File existence/size verified; restoration not tested. This is not a player-progress backup and does not preserve hosted asset permissions or DataStores. Recovery copies are not development targets.

**Existing live-access blocker:** `ResearchProfiles.Load` refuses nonempty legacy profiles without `progression.version == 1`. It reports that the unpublished checkpoint cannot load legacy progress and requires an approved release/reset operation. This HUD work does not resolve that compatibility issue, reset/migrate old profiles or grant resources. Publishing the HUD must not be represented as guaranteeing those accounts can join. Existing Studio preview balances/ownership remain unchanged.

## Bounded capture and publication

One Play session ran for approximately **75 seconds**, 21:42:16–21:43:33 UTC on 9 November (10 November locally). One switch from desktop to the existing **iPhone 17 Pro landscape** emulator; no further device cycling or Play session. No character navigation, attacks, purchases, selling, grants or progression/persistence tests. The existing preview's 100M balance was not added by this work.

- [Actual desktop HUD](desktop.png): 1426×670 capture; client HUD usable size approximately 1141×478 logical pixels after Roblox safe insets.
- [Actual landscape phone HUD](landscape-phone.png): 784×360 capture. Client reported Touch preferred input and a 750×323 logical safe HUD. Capture pixels and logical UI coordinates differ because of Studio/emulator scaling. Native joystick and jump controls are visible; attack is above the jump control. The private native-window inspection also showed the device bezel and Roblox menu controls.
- Loading completed with `LabReady` and `ProfileReady` true. The inspected MCP runtime Output contained `[Vesper] 12 session rooms ready` and no reported runtime error. This is a bounded observation, not proof that all interactions work.
- All three modified/new runtime modules matched the canonical files by normalized source readback in **original Edit mode** after stopping. Temporary Edit previews were removed; Play-only changes were not used as implementation.
- Final native checkpoint: same private folder, `ComingSoon_94763223427049_hud_checkpoint.rbxl`, **4,122,461 bytes**. Source and original-place implementation are saved; restoration not tested.
- **Publication succeeded to the original place 94763223427049**, existing universe 10773858644. Native Studio File > Publish was used, not Publish As. Studio's local log records `PublishSuccessful`, `Publish succeeded for placeId 94763223427049`, `Published new changes in "Coming Soon" to Roblox.` and publish notes **v136**, at 21:44:42 and 21:44:59 UTC. The same publication command was activated twice because MCP Output and loaded `game.PlaceVersion` stayed stale; the native log establishes success. No second place, audience change, server restart or main-branch merge. See [minimal publication evidence](publication-evidence.txt). Existing running public servers were not inspected or forced to restart.

## Remaining limits and visual review

User visual approval is pending. Small mobile XP/caption/tool-label text still needs real-device judgment; no physical phone usability claim. The reused collection illustration has a busy small silhouette, the relic crop includes part of a coin, and existing explosive geometry makes a blocky portrait. These are visible limitations, not finished new equipment art. Only the idle HUD was captured; drawers, inventory, skill tree, charged/Flow states, tool selection and touch actions were not exercised in this bounded session. The tree and other menus retain their previous unapproved visuals. The legacy-profile compatibility blocker above still affects live access for those profiles. Published gameplay, persistence, performance and multiplayer behavior remain unverified.

Stop at this checkpoint for the user's visual feedback; no next UI/content phase is authorized by completion.
