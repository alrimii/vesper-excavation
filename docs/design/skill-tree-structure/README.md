# Skill tree: unified disciplines with local branching

**One static structural proposal, awaiting owner review. Not implemented or visually approved.** Neither preceding painted proposal was selected; the version-139 HUD style and current tree remain rejected. This checkpoint changes no runtime code, Studio objects, player data, gameplay rules or published version. No Play, device emulation, input automation, gameplay testing or capture cycle occurred.

## Deliverables and editability

- [Complete screen image](skill-tree-structure.png): 2000 × 1360 PNG, exported from the SVG.
- [Editable layout](skill-tree-structure.svg): real text, separate named node groups, original vector symbols, state badges and individual prerequisite paths. No embedded flattened painting. Edit with an SVG-capable editor; labels remain text rather than outlines.
- [Layout data](layout.json): coordinates, explicit edge paths, stable IDs, names, ranks, point costs, implementation flags and illustrative state.
- [Build source](build_layout.py): editable authoring script for the SVG, using the existing design-content record derived from the specification. No game logic. Direct SVG edits are possible; rerunning the builder replaces them, so keep the script/data in sync when using that route.
- [PNG renderer](render_preview.py): installed headless Chrome/Playwright renders only the local static document. No visible browser input, Studio connection, live game, device emulation or software installation. A sandboxed screenshot timeout was resolved by rendering the local HTML/SVG outside the restricted subprocess sandbox; this was not gameplay testing.

Original, deliberately simple vector skill symbols establish readable silhouettes only. They are not a completed illustrated production icon collection or an approved visual style. No rejected artwork is reused. Segoe UI with Arial fallback is referenced as live system typography; no font binaries are redistributed. No external art, framework or assets were incorporated.

## Actual reference screenshots studied before drawing

1. **Last Epoch — Shift specialization:** [screenshot](https://cdn.staticneo.com/ew/c/c2/Shift_Xt52g.jpg), shown in this [build guide](https://www.neoseeker.com/last-epoch/builds/Shadow_Dagger_Blade_Dancer). Visually inspected the large central entry, local forks, rank fractions and strong distinction between invested and uninvested paths. Adopted the hierarchy and route readability; did not copy its ornate border, icons, layout or mechanics.
2. **Assassin's Creed Origins — ability map:** [screenshot](https://images.squarespace-cdn.com/content/v1/5b1562924cde7ad879d8107c/1530809214662-FIPJW7O8AKDYRRLJ719N/assassins-creed-origins-skills-screenshot.jpg), shown in this [interface discussion](https://www.ramblingaboutgames.com/blog/aco-skills). Visually inspected the distinct Hunter/Warrior/Seer regions within one map, visible selected discipline and highlighted learned connections. Adopted regional separation and a coherent overview, not its exact triangular arrangement, symbols or branding.

These are historical screenshots used for visual architecture, not claims about current game versions. Reference images were downloaded for local inspection in ignored Backups/skill-tree-reference-study and are not redistributed in this repository. Their artwork remains with its respective rights holders. The proposal has original vector elements only.

## Structure and state language

One continuous map occupies approximately three quarters of the screen. Impact, Collection and Technique have quiet tinted regions and direct focus controls, with an All paths overview. Each has an identifiable entry connected to the free Field Journal. Region boundaries do not create separate screens or new skill gates.

- Small rounded nodes: foundational/incremental upgrades.
- Larger hexagonal nodes: distinct abilities or techniques.
- Largest diamond nodes: capstones.
- Purchased: filled branch color, checkmark and actual rank fraction. Partial purchases show 1/2; one-rank completed purchases show 1/1.
- Available: white surface, colored outline and AVAILABLE label.
- Locked: subdued surface, padlock and dashed incoming path. Dashed paths still represent required prerequisites, not optional ones.
- Selected: gold corner brackets and SELECTED label, while availability is separately stated.
- Planned: small P badge, explained in the footer, plus a locked state. Planned skills cannot be purchased even when their proposed level/prerequisites are met.

Solid colored paths show purchased/available early progression; dashed gray paths show inaccessible later progression. Names and ranks/costs remain on the map; detailed effects stay in the selected-skill panel. AND markers at Crosscut and Claim Priorities indicate both incoming requirements. Selecting is separate from purchasing. Level labels on planned nodes show first-rank requirements; later-rank requirements belong in the selected panel.

The selected Chain Lightning panel uses existing mechanics: rank 0/1, passive Pickaxe/Drill, up to two extra exposed targets at 80% then 50% base power. The concise chance text summarizes 25% on the first eligible ordinary action in each fixed 4-second window when the 8-second proc cooldown permits. It does not propose rolling on every hit. The two-point action requires level 5 and Precision Relay rank 1. Range, exposure, action eligibility, cooldown and contribution authority remain unchanged.

## Existing topology: preserved limits, no invented choice

Source: [Phase 5A specification](../../PHASE_5A_PROGRESSION_SPEC.md), section 3, and [SkillCatalog](../../../src/SkillCatalog.luau). There are 21 skill nodes and 20 skill-to-skill prerequisite edges, plus three free-root access links.

- Impact: Fault Survey forks to Charged Swing and Steady Aim; both are required for Crosscut, then Overbreak → Fault Mark → Fault Collapse.
- Collection: Batch Unload forks to Sale Latch and Sample Packing; both are required for Claim Priorities, then Clean Extraction → Refinery Link → Expedition Harness.
- Technique: Precision Relay forks to Chain Lightning and Flow Drill. Chain Lightning independently opens Shaped Charge and Arc Routing; Arc Routing opens Storm Circuit. Flow Drill opens Pulse Drill. The drill and explosive spurs do not gate the lightning capstone.

**Specific limitation:** Impact and Collection have a single early fork that merges through an AND prerequisite, followed by a linear late sequence. These are not mutually exclusive sub-build choices comparable to every Last Epoch specialization. Technique has more independent side choices. A richer late branching structure would require separately approved mechanics/prerequisite changes; none are implied or made here. The present topology fits the layout without altering rules.

## Illustrative build and implementation status

The proposal uses no real account values. At level 15, entitlement is 1 + floor(15/2) + floor(15/10) = **9 points**. Fault Survey 1, Charged Swing 1, Batch Unload 1, Sale Latch 1 and Precision Relay 1 cost 1+2+1+2+1 = **7 points**, leaving **2**. Chain Lightning is selected at rank 0/1 and costs 2; buying it would leave 0. Steady Aim and Flow Drill also have available purchase states. Tool ownership is not asserted: learning Flow Drill does not grant a drill. A future selected Flow Drill panel must state that an owned drill is needed to use it.

**Eight implemented mechanics:**

- impact.fault_survey — Fault Survey
- impact.charged_swing — Charged Swing
- impact.steady_aim — Steady Aim
- collection.batch_unload — Batch Unload
- collection.sale_latch — Sale Latch
- technique.precision_relay — Precision Relay
- technique.chain_lightning — Chain Lightning
- technique.core_drill — Flow Drill

**Thirteen planned mechanics, still unavailable:**

- Impact: Crosscut, Overbreak, Fault Mark, Fault Collapse.
- Collection: Sample Packing, Claim Priorities, Clean Extraction, Refinery Link, Expedition Harness.
- Technique: Shaped Charge, Pulse Drill, Arc Routing, Storm Circuit.

No implementation or gameplay verification is claimed by this classification. The entire proposed interface is new design-only work.

## Focus, mobile and respec behavior for later approval

Impact/Collection/Technique focus controls pan and fit that region within the unobstructed canvas; they never swap in a separate graph or change prerequisites. All paths restores the complete overview. Recenter returns to the selected node's branch or the three entries when nothing is selected. Reduced Motion uses an immediate reposition instead of a camera animation. Panning remains available between regions.

Mobile keeps a compact, persistent branch selector and close/points controls. Branch focus brings seven nodes to readable size instead of shrinking all 21 to fit. The details panel becomes a collapsible bottom sheet: title/rank/action summary when collapsed, concise effect and requirements when expanded. Fit/recenter use only the area not covered by the sheet. A landscape phone may use a narrow side sheet if adequate map width remains. Drag/pinch navigate the canvas; a tap selects without buying; unlocking needs its own deliberate action. Zoom controls remain available. No additional mobile image or device verification was produced.

Free respec remains the existing room-based action: own room, 10 seconds without mining, no pending action, writable profile and 60-second throttle. The overview control names the room restriction; its later selected confirmation must expose the applicable reason rather than silently allow remote respec. No point price, currency cost or rule change is proposed.

Await review. After explicit approval, implement in original place 94763223427049 and publish only under the established authorized implementation workflow.
