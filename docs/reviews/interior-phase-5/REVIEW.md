# Phase 5 — unified player interface, published v223

Original place **94763223427049**, universe **10773858644**, branch `planning/development-foundation`. Baseline actually found: **65ae7715c8682ea0c1d705f7a66a0529be33f15d**, published v221. Publication of v223 is confirmed by the original Studio log at **2026-11-11 09:28:00 UTC**, `publishType=1`, “Add publish notes to v223”. Studio's in-memory `PlaceVersion` remained stale at 203 and was not used as publication evidence.

The owner stopped further testing during the focused session. Play was stopped immediately, device simulation was restored to default, the temporary memory-only fixture was removed, and the identified UTF-8 synchronization defect was corrected in Edit mode. No further Play session or runtime test followed. Publication is not visual approval or a claim of complete verification.

## Implemented

One mineral-green/parchment interface now supplies the HUD, compact navigation folio, equipment and upgrades, connected three-branch skill map, journal, discoveries, creature collection, room themes, settings/help, materials, results, confirmation dialogs, loading and delivery/reveal captions. `InterfaceTheme` and `InterfaceKit` own tokens, controls, scroll surfaces, safe-area modal layout and exclusive modal focus. The full-bleed input shield is separate from safe-area content. Existing actions/data bindings remain authoritative.

The equipment catalogue and dock reuse the actual Phase 4 tool models. Pickaxe, drill and charge have distinct sourced icons and selected-tool upgrade context. The skill map retains the actual 21-node catalog: eight implemented skills and thirteen visibly planned nodes, with existing costs, prerequisites and server transactions. No deferred skill was activated.

Sound and reduced-motion settings now have normalized `preferences` fields in the existing profile and a strictly validated, rate-limited `InterfacePreference` action. Existing autosave owns persistence. The fixed save generation, currency/progression defaults and rules are unchanged.

## Actual observations

All transactions below used a temporary **Studio memory-only fixture**, clearly separate from production: 25,000 credits, level 20, one existing Crownback discovery, no drill/charge ownership initially. No live saves were read, spent, reset or granted by this setup. It was removed before the final native save/publication.

| Interaction | Observed result |
| --- | --- |
| Equipment category selection | Drill artwork, actual preview, stats and 18,000-credit purchase context appeared. |
| Buy drill | Server ownership became true; credits changed 25,000 → 7,000 exactly once. |
| Equip drill | Server tool family became Drill. |
| Drill power upgrade | Server Drill Power rank 0 → 1; credits 7,000 → 6,928. Other tool ranks remained zero. |
| Skill selection/purchase | Fault Survey details opened; server rank became 1; available points 13 → 12. |
| Settings | Sound became false and reducedMotion true in the actual server account. JSON encode/decode plus existing profile normalization retained both values. |
| Collection shelf assignment | Shelf 1 became `crownback` in both server account and replicated attribute. |
| Navigation, close/reopen, scrolling | Journal, equipment, upgrades, skills, settings, collection and empty results opened; close returned to HUD. Real mouse-wheel scrolling moved upgrade content. |
| Narrow viewport | iPhone 7 portrait simulation showed safe headers/close controls and readable empty results/skill details. This is emulation, not real-device verification. |

Early MCP pointer input opened the Roblox emote overlay; subsequent interactions used the native pointer. Several missed clicks hit clipped or hidden controls and are not counted as successful actions. A read-only inspection used an incorrect icon instance name, and the first simulator orientation request was rejected while the default desktop device was active; neither was a game runtime failure.

**Not established before the owner stopped testing:** completed-result interaction/capture, explosive purchase/equip, bulk upgrades, skill loadout/respec confirmation, room-theme purchase/application, settings persistence across a real published rejoin, respawn/rejoin recreation behavior, every narrow-screen menu/action, controller navigation and real-device performance. Room/help/loading/cinematic/completed-results implementations are not claimed as captured or runtime verified. The final encoding correction was source-synchronized without another runtime session.

## Actual screenshots

These are crops of real Studio runtime captures, not concepts or retouched game content. They show the labeled memory-only fixture. Some captures retain the visibly malformed punctuation from before the final UTF-8 source correction. Scrolled images intentionally show partial preview/card content; this does not prove all viewport layouts.

| Screen | Evidence |
| --- | --- |
| HUD | [Desktop HUD](01-hud-desktop.png) |
| Navigation | [Compact navigation](02-navigation.png) |
| Equipment | [Pickaxe catalogue](03-equipment.png), [drill after purchase, scrolled](04-drill.png) |
| Upgrades | [Drill upgrade receipt/state, scrolled](05-upgrades.png) |
| Skills | [Selected Fault Survey](06-skills.png) |
| Settings | [Sound and reduced motion](07-settings.png) |
| Collection | [One fixture discovery and two undiscovered silhouettes](08-collection.png) |
| Journal | [Research journal](09-journal.png) |
| Results | [Empty result](10-results-empty.png) |
| Narrow | [Portrait empty result](11-narrow-results.png), [portrait skill details](12-narrow-skills.png) |

Visible limitations: short desktop windows require substantial scrolling; the default skill map shows a subsection and depends on branch focus/zoom/scrolling; the HUD still occupies a noticeable area of the world. Capture coverage was incomplete when testing was stopped. No owner visual approval is claimed.

## Replacement and preservation

The old StarterGui HUD construction was replaced with a minimal bootstrap and one current FieldHUD controller. Old `ExcavationChrome`, `InterfaceStyle`, `ModalLayout`, `NavigationArtwork`, `OutfitterArt`, `OutfitterComponents`, `ResearchJournal` and `UIMotion` sources were deleted. Superseded live modules and obsolete UI factories in historical in-place backup folders were removed: **32 instances**, [exact paths](removed-instances.json). Replaced modules now use the shared kit; their old constructors/listeners are gone. Private native/source recovery retains the prior implementation. A final Edit inspection found none of the retired shared modules and no temporary verification hook.

All **15,962** protected VesperLab BaseParts and global lighting matched the pre-edit checksum. [Preservation record](preservation.json). World, architecture, planting, tools, training, mining, delivery mechanics, economy and fixed save generation were not changed. The two server changes are narrowly scoped preference normalization and validation; no access settings were touched. Reopening/respawning/rejoining has not been fully runtime verified, so source cleanup is not presented as that proof.

New artwork: [Game-icons.net family and exact attribution/source records](../../../assets/ui/phase-5/README.md), hosted image **121599750729304**, owner **291892217**. Existing SkillArt illustrations and Phase 4 models are reused. No restricted source library was added to Git.

Private recovery directory: `C:\Users\BOSS\Desktop\egg\Backups\InteriorPhase5_20261111\`.

- Before: `ComingSoon_94763223427049_before.rbxl`, 6,617,124 bytes, SHA256 `FF05B2769FDC78FCA92B2BF40C52EA000DC825206B464F4992614866436A668A`.
- Final: `ComingSoon_94763223427049_final.rbxl`, 6,596,371 bytes, SHA256 `22BBDDFE840F420CB599D23F7F2C2E80ECC29FE5BC7F4B22B6737F2605B4B2CD`.
- Full pre-edit source, untrimmed captures and private verification setup are retained there; recovery copies were never used as implementation targets.

[Delivery identity](delivery.json). [Remaining requirements](PLAN.md). Stop in Edit; do not resume testing without a new owner instruction.
