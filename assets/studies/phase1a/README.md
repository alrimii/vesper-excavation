# Phase 1A: playful discovery workshop

Status: historical work. The user supports the stylized foundation and starter, but has rejected BOTH the reinforced and fire upgrades for production and ended concept iteration. No study has been imported into the original place. Preserve these files; produce no additional concepts or animation previews. Phase 1B now changes the original game's interaction using its existing temporary visuals; see [the current handoff](../../../docs/PHASE_1B_HANDOFF.md). Statements below describe the past design-study delivery, not current authorization.

## Historical focused revision: rejected fire-themed pickaxe
Exactly one replacement proposal, delivered as two compact static boards:
- [Starter and fire proposal: front, side, three-quarter](fire_revision/01_starter_and_fire.png)
- [Held fire proposal: close and gameplay-distance approximation](fire_revision/02_held_scale.png)
- [Editable static Blender model/scenes](fire_revision/fire_pickaxe_study.blend), [authoring source](fire_revision/build_fire_study.py), [board layout source](fire_revision/package_boards.py).

Design: a continuous, balanced crescent forging flows into an integral eye and bronze socket sleeve. Broad charcoal metal faces, honed pale tips and copper bevels establish the silhouette without stacked reinforcement plates. An oxblood shaft, palm-swollen leather grip, one continuous wrap seam and compact forged pommel form a deliberate full-tool design. Small amber enamel details suggest embers; no emissive materials, particles, bloom or other effects are used. The shared shaft/grip scale, warm-metal accents and readable swept head retain the starter's visual family while giving the replacement its own construction and material identity.

The accepted starter is copied directly from the previous editable study without mesh/material changes. The existing mannequin and lighting are reused. The shell and all earlier source assets remain untouched. Five necessary component stills are local layout intermediates; only the two boards are delivered as new images. No GIF, video, animated render or frame sequence was produced for this revision. Earlier motion deliverables below are historical, not part of this revision.

Appearance limits: Blender materials are conceptual and still need production UVs/maps and Roblox material implementation. The enamel is reflective color, not a promised glowing effect. The static 5.5-stud mannequin is a scale/hold reference, not final R15 grip fitting; contact clearance across avatars and Roblox lighting remain unverified. No new Roblox asset IDs or production exports exist. Fire damage, rarity, currency, stats and progression position are not approved or assigned. Approval is requested only for this silhouette, construction and material direction; implementation requires a subsequent explicit scope and must target the original place directly.

## Original Phase 1A deliverables (historical; reinforced upgrade rejected)
- [Design board: three-quarter, front, side and character scale](01_design_board.png)
- [Shell states and approximate gameplay distance](02_shell_and_distance.png)
- [Animated motion study: 120 authored frames, 12 fps, silent](03_authored_motion.gif)
- [Static contact sheet from the animation](04_motion_contact_sheet.png) — this sheet itself is not an animation.
- [Editable multi-scene Blender study](excavation_direction_study.blend), [construction source](build_study.py), [layout source](package_previews.py), and individual stills in renders/.

Classification: these images are renders of actual Blender geometry studies, not painted concept artwork, production meshes, Roblox animation assets or proof of the final game appearance. The mannequin is a stylized 5.5-study-unit scale/pose reference, not a fitted Roblox rig. One study unit is intended as one stud; final exporter axis/unit conversion still needs approval and integration verification. No external concept image, raster texture pack or audio asset was generated. Materials are editable node materials inside the blend. Intermediate PNG animation frames remain local and can be regenerated; the animated GIF, contact sheet and editable animation are delivered.

## Recommended design
Keep the laboratory lighthearted through warm ivory ceramic, sea-green enamel, deep teal rubber, coral identifiers and restrained brass fasteners. Broad satin metal faces carry controlled highlights. Color roles distinguish contact edges, hand contact and construction details rather than assigning glow to every surface.

The starter has a swept asymmetrical forging, a distinct striking tooth, rounded eye socket, tapered shaft, palm grip lands and a visible captive axle. It should feel like a thoughtfully made discovery tool, leaving head breadth, layered construction and mechanical reinforcement available for later tiers.

The rejected first upgrade added a broader/thicker impact head, layered ceramic spine, twin cheek plates and double neck collars. It is retained below only as historical review evidence and is superseded by the focused fire-themed visual proposal above. The old film's upgrade reception is not an approved design or acquisition flow.

The ancient shell uses a warm glazed face, cool mineral fracture interior and restrained strata marks. The small curved patch is a construction study, not the final egg silhouette or texture solution. Its intact/damaged/broken versions share matched edges. The current broad polygon facets need smoother curvature and a more authored mineral motif during approved production; the study must not be mistaken for a completed egg surface.

## Motion and feedback direction
The film slows and separates beats to make them reviewable. It does not establish attack rate, durability or number of hits required in the game. Contact markers, grip anchors and timeline markers are editable. The arm is an authored geometric pose reference, not animation retargeted to R15; elbow lengths and avatar-specific clearances remain production work.

| Beat | Proposed game timing/character | Visual information | Sound direction, not produced audio |
| --- | --- | --- | --- |
| Prepare | About 0.15–0.22 s anticipation | Shoulder/hand draw back, clear head silhouette; no full movement lock | Short soft cloth/grip creak |
| Accelerate/contact | About 0.08–0.12 s acceleration; contact event aligns damage/audio/FX | Tool tip reaches surface; 3–5 local ceramic chips and compact cream accent | Air swish ending at a dry ceramic tick with a low metallic body |
| Follow-through/recoil/recover | Brief overshoot, 0.08–0.12 s recoil, 0.18–0.25 s recovery | Wrist/forearm carry weight, then settle; no camera shake required | Very short head ring, quickly damped |
| Precise hit | Same contact instant | Slightly sharper brief accent and 6–8 chips; optional small readable precision glyph later | Brighter high tick layered over the same material body |
| Stronger upgrade hit | Keep readable cadence; no promised speed buff | Broader contact accent, firmer recoil and deeper damage state; restrained extra chips | Lower, fuller knock rather than simply louder sound |
| Crack progression | Changes after accepted damage | Thin dark seams open toward cool mineral interiors; no permanent bloom | Brief gritty ceramic creak at a state change |
| Final break | Release immediately after final accepted contact | About 5 large readable shards travel a short distance outward, then retire; no target-covering cloud | Low ceramic snap plus a few separated small ticks |
| Collection | Approximately 0.35–0.55 s arc | Up to 5 mineral pieces converge toward the player's collection anchor; gain acknowledgement proposed | Soft rising sequence ending on a small confirmation plink |
| Upgrade received | Approximately 0.5–0.8 s presentation | New construction shown with restrained settle; no full-screen flash or forced camera | Short two-note resolved tool-bench chime |

Animation execution exists for swing, ordinary/precise contact accents, break, collection and upgrade reception. The GIF does not contain final sound, floating gain UI, a separate upgraded-hit comparison, camera shake or a production avatar rig. Those remain proposed work after approval. The precision beat is illustrative feedback vocabulary, not a newly implemented mechanic.

## Integration preparation, after approval only
Reuse the server-owned strike/validation and collection pipeline, existing targeting path, ToolMotion pose coordination, ImpactFX/FragmentMotion hooks, shell section identifiers and reveal lifecycle where they remain appropriate. Preserve useful reference meshes and existing uploaded asset metadata. Phase 1A edits none of those systems.

Replace only the approved pickaxe visual meshes/materials and representative shell geometry/finish after approval. Do not preserve visibly flawed geometry merely to avoid a scoped rebuild. Existing sections are numerous and their flat/overlapping representations may limit a continuous curved surface. Recommended follow-up: author one matched curved section boundary family and its fractured variants, integrate a representative area directly into the original egg, and retain section identity/hit rules. Do not build a duplicate map or alternate place.

GripAnchor is at the palm center; ContactMarker is at the active tooth. Keep separate head/socket/shaft/grip parts in the source; the pickaxe needs no moving mechanical component in normal use. The axle is construction detail, not an animated hinge. Use a consistent tool origin, named attachment points and evaluated transforms before export. Final Roblox grip orientation, R15 shoulder/elbow/wrist tracks, contact markers and cancellation/unequip behavior need scoped implementation and the user's manual review. Do not reuse the current Grip CFrame blindly.

For shell fitting, derive adjacent edges from the same curved surface, preserve consistent thickness and align inner/outer boundaries. Use one visible surface per state, not a second coplanar skin. Cracks should be authored in state-specific maps or real gaps without stacked surfaces. Hide/swap intact geometry once fractured geometry is visible. Neighboring sections must share boundary samples, normals and UV continuity; stagger or author seam junctions. Current study facets and tiny intact seams are unresolved production details, not accepted final quality.

UVs/maps: unwrap hard-surface seams along concealed/back edges, maintain consistent texel density, allow sufficient island padding, and avoid stretched curved shell islands. Produce intentional color, roughness, metalness and tangent normal maps where useful; bake bevel/detail only when it remains readable. The studies currently use node materials without production UVs or baked maps. Map export/color-space settings must follow the chosen Roblox material pipeline at implementation time.

### Proposed targets, not measured performance
| Item | Initial target |
| --- | --- |
| Starter / upgrade | 2–4k / 3–6k triangles, excluding avatar; consolidate materials for delivery |
| Tool maps | One 1024² atlas per tier initially; consider shared grip/metal atlas and 512² lower-quality option |
| Representative shell | 200–500 triangles per intact curved section; 5–8 reusable fracture pieces; do not multiply bespoke textures across thousands of sections |
| Shell maps | Reusable 1024² set with optional 2048² hero set only if actual visibility warrants it |
| Local impact | 3–8 ordinary/precise chips, at most 12 strong/break accent elements, short lifetimes, bounded local radius |
| Concurrent visibility | Proposed cap of 32 small visible accent elements near the camera; prioritize local/nearby events and suppress distant repetition |
| Collection | At most 5 illustrative trails/pieces per acknowledgement; batch rapid gains |

Reduced motion: no camera kick, no rapid scale bounce, shorter direct collection travel or a static gain acknowledgement. Reduced effects/mobile: 2–3 chips, one contact accent, fewer/larger fracture pieces, simple direct collection markers, disable distant cosmetic chips. Keep damage state and collection acknowledgement in all modes. Avoid flashes and constant emissive overlays. These are targets; no device performance has been measured.

## Preservation and actual integration status
Full native recovery copy: Backups/Phase1A_20261109_182432/ComingSoon_94763223427049_20261109_182432.rbxl, 4,083,531 bytes. Created through Studio File > Download a Copy while the original Coming Soon place was in Edit mode, version 55. SHA-256: 80AA95B10727FF215CCB24211DD47C980B851AEF454518B952F62EA3B56A5687. File existence, size and hash were checked; restoration was not tested and the backup was not opened.

Coverage: the native place save covers the open place's serializable DataModel, scripts, geometry and settings; src, assets and release were separately copied into that same private backup directory before study creation. External hosted asset contents/permissions, DataStore records and unsaved external Blender sessions are not included by a place save. The backup stays ignored locally, not on public GitHub.

Installed Blender 4.5.15 is used directly in background mode for isolated authoring/rendering. No installation/update or paid service was used. Existing BlendRelay source/setup was inspected; its documentation requires Blender 4.5+, but no BlendRelay MCP tools are exposed to this session. The studies were therefore authored using the already-installed Blender executable, not through a claimed live BlendRelay connection. No integration configuration was changed.

Keep approved editable blend/material sources, exports and upload manifests versioned together. Future exports must record scale, axes, named grip/contact points, triangle/map counts, asset IDs and owner permissions. After implementation approval, apply only scoped changes to the original place and synchronize the affected repository sources with it. No new Roblox IDs or exports are claimed in this proposal.

## Approval needed
Approve or revise the tool silhouettes/construction, palette/material balance, shell face/interior direction, and restrained motion/effects vocabulary. The upgrade is stronger impact, with numbers deferred. Approval of this direction does not automatically authorize a broader content pass; production and integration need an explicit next scope.

Not tested: Roblox appearance, gameplay, input, animation retargeting, multiplayer, mobile performance, saves, asset permissions or restoration. No Play/Run, player simulations, automated tests or gameplay input automation occurred. Studio UI automation was used solely for the authorized native backup save. No publication occurred.
