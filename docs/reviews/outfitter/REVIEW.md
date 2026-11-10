# Equipment outfitter replacement ? frozen owner-review checkpoint

## Implemented in original place

Original place **94763223427049**, baseline public version 142 / commit `2b69196ef78859a2e159f655ec00ae273a0e3ab2`. Development branch `planning/development-foundation`. Published **version 144**, confirmed by native Publish success and its v144 notes link on 10 November 2026. See [publication evidence](publication-evidence.txt). The owner has not approved this design.

- Replaced `Workspace.VesperLab.SharedWorkshop`: old 62?38 clinical storefront, awning/sign, three identical display benches, light bars and terminal blocks. New 46?29 stone foundation, timber frontage/canopy, large physical pickaxe emblem, central workbench/vise, wall pickaxe rack, drill cradle, charge tray, mounted warm display lamps, front step/apron and marked approach. Displays clone the actual equipped asset family; no fictitious tier or product. Neighboring room access and all unrelated map geometry retained.
- Preserved `SharedWorkshop.Console.OpenEquipment`, `UpgradeConsole.OpenUpgrades`, and `ApproachZone` contracts. Existing `WorldInteractions` entry latch, exit margin and modal checks are unchanged. New source is `ServerStorage.VesperTools.OutfitterBuilder`; the previous MapCleanupBuilder.Shop now delegates to it. Earlier historical shop builders remain guarded against rebuilding superseded geometry.
- Replaced `WorkshopUI` with a modal router plus new `OutfitterUI`, `OutfitterComponents`, `OutfitterArt`. Equipment uses three large actual-model previews, roles, saved ownership/equipped state, selected-tool stats and one buy/equip action. Upgrades uses seven illustrated categories, current/next effective equipment values, ranks, existing price quotes, affordability/max states and existing 1/5/Max quantities. Separate mobile arrangements use a tool rail and one scrolling upgrade column.
- Cleared obsolete `StarterGui.ExcavationHUD.Station` children. The Station frame remains only as the existing modal visibility signal. Removed old station Sell/Power/Speed/Capacity/NextRound click handlers and UIMotion attachment from ExcavationClient. No second shop menu/input loop runs underneath. The formerly combined menu's creature/room/settings pages are isolated in `SecondaryMenus`, built only when accessed. Their old visual quality remains unapproved and pending replacement.
- Added optional correlated ShopReceipt responses around existing BuyTool/EquipTool/Upgrade mutations. One client request remains pending until its matching result; recent IDs are deduplicated in a bounded per-session cache (32). Expected equipped tool is checked for upgrades. Existing authorization, ownership, rate limits, prices, deductions, ranks and save schema remain unchanged. Legacy HUD callers retain their existing remote contract. Trial remains the existing optional 90-second drill trial, not a new product.
- Nine original SVG illustrations, 256px transparent PNG exports and actual returned uploaded IDs: [asset manifest](../../../assets/ui/outfitter/manifest.json), [sources/reference notes](../../../assets/ui/outfitter/README.md). No rejected HUD/tree illustrations reused. No external pack/framework incorporated.

## Actual evidence

- [Physical storefront ? original Edit-mode geometry](storefront-edit.png). Supplemental photograph after Play stopped, same frozen geometry; not runtime/shop-approach evidence. Limited resolution and Studio orientation gizmo retained honestly.
- [Desktop Equipment ? runtime](desktop-equipment.png).
- [Desktop Upgrades ? runtime](desktop-upgrades.png).
- [Landscape phone shop ? runtime](landscape-shop.png). iPhone 17 Pro landscape emulator; it shows Upgrades, not Equipment.

Exactly one Play session: **10:05:20?10:08:57 UTC, 3m37s**, one switch from current desktop to iPhone 17 Pro landscape. Natural Studio preview initialization reached LabReady=true. Clicked the existing Tools access and the shop's two tabs solely for captures. No purchases, mining, grants, movement tests, save manipulation or gameplay regression runs. Existing memory-only preview ownership and 100M credits appear in screenshots; this task did not add them, and they are not published starting values.

The desktop was initially locked; owner unlocked it. Initial screenshot API stalled, screen copies were black and window-only capture was stale. Native fixed-window capture then produced actual frames. Full-window intermediates with unrelated terminal content stayed private; committed images are crops of actual Studio content.

## Issues observed; no post-capture fixes

1. **Landscape Upgrades is too vertically constrained.** The first card's purchase action is cut off at the initial scroll position; lower categories are below the fold. Touch scrolling/action reachability was not tested. The Equipment-tab click immediately before the final snapshot did not produce an Equipment image; whether this was capture timing or touch activation remains unresolved. No retry or runtime debugging followed.
2. **Desktop Upgrades has excess empty space in the left selected-tool summary**, with text rather than a tool portrait there. The third row is partially visible at the bottom and Resonance requires scrolling. Scrolling was not exercised.
3. **Selection outlines at the left content edge are clipped** by the content frame. No layout patch followed capture.
4. **The existing charge model looks unfinished/blocky** when enlarged. It is intentionally the real equipped asset, not a fabricated better weapon. Tool art replacement remains separately unapproved.
5. **Physical shop is darker than the warm palette alone suggests** in the existing lab lighting. Tool labels and the low entrance labels are small in the wide photograph; emblem is still simple part geometry. This is an implemented presentation checkpoint, not a declaration of final asset craftsmanship. No lighting/world expansion followed capture.
6. The physical evidence is Edit mode rather than a runtime storefront photograph. No approach or collision traversal was performed. The mobile capture is small and cannot establish physical-device legibility.

No application error naming the replacement modules was found in the inspected capture-time log excerpt; this is not a complete error-free assertion. Normal shutdown/engine warnings and completed BindToClose messages were present. No tests or diagnostic execution were launched.

## Preservation and verification limits

Nine changed/new live sources match canonical source after line-ending normalization. Pre-capture source hashes remained identical after capture. Temporary Edit UI preview was removed before Play; no Play-only change was mistaken for saved implementation. Studio is stopped in Edit mode. Only camera framing and evidence/save/publication operations followed capture; no UI, geometry or gameplay fixes.

**Unverified:** buying/equipping, pending/error/repeated-request handling, 1/5/Max upgrades, trial, insufficient funds and max-rank states, approach close/re-enter behavior, competing modal behavior, secondary menus, controller navigation, mobile scrolling, actual-device usability, saved ownership/persistence, collision and live-account joining. Existing systems were preserved by source review, not claimed gameplay-verified.

Private recovery directory: `C:/Users/BOSS/Desktop/egg/Backups/Outfitter_20261110_124032/`. Before native file `ComingSoon_94763223427049_before_outfitter.rbxl` **4,130,627 bytes**, plus source/docs/assets/instructions copies. Final native checkpoint `ComingSoon_94763223427049_outfitter_checkpoint.rbxl` **4,139,076 bytes**. Full native copies preserve place hierarchy and embedded sources; hosted asset bytes depend on Roblox, with new vector/PNG masters preserved separately. Neither restore nor durable player persistence was tested. Backups are recovery only and remain out of Git. No data reset/migration/save-generation change.

HUD/loading, skill tree, creature/room/secondary menus, overall room/world layout, remaining frontage, signs, typography and lighting stay open and unapproved. No new skills, rebirth, monetization or other systems. Stop for joint review.
