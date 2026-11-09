# Skill-tree visual selection — two design proposals

**Historical, neither selected.** The owner requested a new editable structural proposal using Last Epoch and Assassin's Creed Origins as information-architecture references. See [the subsequent structure checkpoint](../skill-tree-structure/README.md). Do not implement or extend these painted directions.

Status: **design proposals only, not implemented or visually approved**. Both the version-139 HUD illustration direction and existing tree presentation are rejected. Do not propagate them to other screens. These are two complete-screen alternatives for owner selection; no Studio, runtime, data, device, publication or gameplay operations occurred in this task.

## Images and recommendation

- [A — Branching constellation](A-branching-constellation.png): a central Field Journal with three outward paths over pale mineral terrain. Sculpted floating shell islands, copper/turquoise/amethyst branch identities and larger outward destinations emphasize choosing a discipline.
- [B — Ascending progression map](B-ascending-progression.png): a lower starting area with three ascending paths through warm excavation terraces. Graphic painted-paper shapes, stronger vertical reading order and explicit node-level labels emphasize the journey toward capstones.

**Recommend B** for easier prerequisite reading, comparing paths at similar progression stages, and adapting the map to a narrow viewport. This is a recommendation, not owner acceptance. A is the more exploratory composition; its long sideways late-tier links need particularly careful readable routing if selected.

Both contain all 21 specified skills, three branch starts, exact prerequisite topology, purchased/partial/available/locked/selected cues, rank/cost labels, zoom/recenter/respec/close controls, and a prominent selected Chain Lightning illustration and purchase panel. No random cross-branch connections are intended. Connections to Field Journal are visual roots, not additional paid prerequisites.

The displayed level-15 build is illustrative, never read from or written to a player: point entitlement 9, 7 spent (A1/A2/B1/B2/C1 rank1), 2 remaining; Chain Lightning rank0 is affordable. Purchase/action mockups are not functioning buttons. The eight existing mechanics are distinct from this entirely unimplemented interface.

## Mobile adaptation (no additional images produced)

A: preserve the radial map on a pannable canvas; begin framed around the hub and reachable nodes, with branch-focus controls and a persistent recenter. Keep readable node sizes rather than shrinking the whole desktop screen. Selected details become a collapsible bottom sheet; landscape may use a narrow side sheet. Branch ends remain reachable by pan.

B: use a predominantly vertical pannable map with horizontal pan between three lanes; start at the foundations and show the next reachable tier. A compact branch navigator recenters the selected lane without replacing the connected graph. Selected details collapse to a short bottom tray and expand on demand. Keep capstones visible through pan/zoom, not tiny always-fit thumbnails.

Both: safe-area-aware controls, touch drag/pinch and clear zoom/recenter, separate selection/purchase, large touch targets, no hover-only information or keyboard-only labels. These are adaptation plans, not physical-device verification.

## Implemented versus planned content

Implemented mechanics in canonical source (no new gameplay verification):
- Impact: Fault Survey, Charged Swing, Steady Aim.
- Collection: Batch Unload, Sale Latch.
- Technique: Precision Relay, Chain Lightning, Flow Drill.

**Planned, not functioning/purchasable in this milestone**:
- Impact: Crosscut, Overbreak, Fault Mark, Fault Collapse.
- Collection: Sample Packing, Claim Priorities, Clean Extraction, Refinery Link, Expedition Harness.
- Technique: Shaped Charge, Pulse Drill, Arc Routing, Storm Circuit.

The images illustrate the complete intended structure. All thirteen planned entries remain planned even where shown with a level-lock icon rather than a PLANNED badge. Sample Packing is explicitly tagged because the illustrative player has reached its proposed first level. In any later checkpoint implementation, every unavailable planned node must be explicitly unavailable; leveling must not suggest it becomes purchasable before its mechanic exists. Nothing here approves their implementation.

The editable content reference is [design-content.json](design-content.json), sourced from the current specification and SkillCatalog. Both required-prerequisite merges (Crosscut and Claim Priorities) mean AND. Flow Drill/Pulse Drill are an optional spur; Shaped Charge is an optional spur off Chain Lightning. Neither gates Arc Routing or Storm Circuit.

Chain Lightning player text summarizes the existing passive: ordinary Pickaxe/Drill, 25% opportunity per fixed 4-second window when its 8-second cooldown permits, up to two additional exposed targets at 80% then 50% base power. Full eligibility/range/authority rules remain in the existing specification; the compact screen copy does not change them. No new ranks or abilities were invented.

## Sources and editability

Generated with the built-in image-generation tool. No rejected illustrations, other game's branding, third-party artwork or new dependencies were reused. No asset upload or Roblox IDs were produced.

The two PNGs are the full-resolution **flattened raster masters and proposals**. The generator does not provide layered painting files or independently editable text/node layers; none are claimed. Editable inputs provided: full [generation and correction prompts](prompts.txt) plus structured names, ranks, costs, prerequisites, implementation status and mock state in design-content.json. These inputs are not a layered art source or runtime implementation. If selected, production artwork/UI will need deliberate separation into assets and genuine text/components.

Image inspection caught erroneous generated connectors in intermediate drafts; focused image edits corrected those before selecting the two final files. Intermediate drafts were not adopted or committed. Raster text and contours remain concept artwork, not a validated Roblox interface; screenshots, gameplay, accessibility and performance verification are outside this design task.

No changes to save generation, economy, progression mechanics, runtime source, original place 94763223427049 or published version139. Await owner selection before implementation/publication.

