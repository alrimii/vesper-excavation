# Interior rebuild — owner-approved direction, not approved existing appearance

Read this entire brief and inspect all eight PNG files in this folder before editing. These are actual owner screenshots of problems in v192, NOT examples to imitate. The owner has finished this feedback batch and authorizes implementation now. Continue communicating in English.

## Baseline and scope

- Original place: 94763223427049.
- Repository: https://github.com/alrimii/vesper-excavation
- Branch: planning/development-foundation.
- Last reported publication: v192.
- Last reported commit: bbd3f1bd8994fcb161c57951a7529efebd9142da.
- Project: C:\Users\BOSS\Desktop\egg
- Existing review: docs/reviews/interior-rebuild/REVIEW.md.
- Prior backup: Backups/InteriorRebuild_20261110/.

Check the actual workspace and preserve newer legitimate work. This brief authorizes implementation after the previous read-only opening message. Do not restart a full audit or stop at a plan. Build one coherent replacement interior, not an additional decorative layer.

## 01 — 01-room-spacing-and-empty-gaps.png

The clear distance between the egg's excavation/access area and the rooms is excessive. Bring the rooms and services inward and make the whole interior more compact. Approximately one quarter of the current clear walking distance is the owner's initial target; measure from the outer excavation/access boundary to the room frontage, not from the egg center. Retain sufficient working and walking clearance. Record the actual before/after distance and explain any necessary departure from this target.

Do not uniformly scale characters, the egg, rooms and props. Reposition and rebuild architecture deliberately. Preserve all twelve rooms and their ownership identities, but move their entrances, spawns and dependent functional anchors coherently where required. Keeping every anchor unchanged is NOT a success criterion for this rebuild.

Remove purposeless inter-room gaps and corridors. Keep useful circulation without filling leftover space with random planters. A selected exterior view may remain where it genuinely improves the compact layout; do not retain four arbitrary viewing gaps simply because the previous implementation created them.

The owner also wants the overall enclosure to fit the compact interior. A coordinated reduction of the dome footprint is authorized if required by the measured layout. Preserve its established glass/frame/crown visual direction, a sealed boundary, delivery clearance and working hoist. Adjust enclosure-related supports coherently, not by blindly scaling the entire place. Keep existing exterior scenery, mountains, trees, mist and clouds unchanged. Do not leave an empty inaccessible annulus or old room shells as the apparent solution to compactness.

## 02 — 02-rejected-blocky-planter.png

The blunt green block-like bushes and token planting are rejected. Replace this planting treatment with coherent finished vegetation assets and believable combinations of heights, foliage and soil. Avoid identical groups repeated along every wall. Solid planter bodies need collision so the player cannot walk inside them; individual leaves do not need obstructive collision.

## 03 — 03-rejected-skeleton-display.png

Replace the entire crude skeleton display, including its simplistic repeated ribs, head and presentation supports. Do not reshape a few ribs and retain the rejected assembly. Find a good finished fossil/skeleton model, inspect its actual mesh and license, and adapt scale, materials and supports to the game's stylized laboratory identity. Do not invent another skeleton from basic bars and polygons.

Use a physically convincing display with appropriately simplified collision for the base and substantial accessible structure. Do not put a giant invisible collision box across surrounding walking space. Retain provenance and editable/import sources. If no suitable usable model can be obtained, report that specific blocker rather than silently substituting another crude model or claiming completion.

## 04 — 04-repetitive-planting-bed.png

This long bed illustrates monotonous planting and an inconsistent mix of foliage styles. Rebuild planting composition as part of the compact architecture. Use irregular but deliberate groupings, compatible leaf detail and color, exposed soil where appropriate, and varied heights. Use fewer purposeful beds if appropriate; do not simply repeat this bed at a smaller scale or remove greenery almost entirely.

## 05 — 05-white-floor-and-pointless-path.png

The glaring white flooring and broad white strip ending at an empty gap are rejected. Remove the obsolete strip and its creation code. Give each path a real destination. Rebuild the floor using coordinated stone tones, readable functional zones and restrained pattern variation. Avoid a uniform white expanse, arbitrary patchwork and decorative lines that imply nonexistent destinations.

The overall lighting is too harsh. Adjust time of day and lighting toward a comfortable, softer environment while retaining readable tools, entrances and specimens. This is an intentional exception to the previous instruction freezing global lighting. Inspect its effect through the glass and preserve the exterior's established colors and atmospheric identity. Do not fix brightness by darkening everything, making it night, or adding fog indoors.

## 06 — 06-rejected-ladder-vines.png

The disconnected polygon leaves pasted onto a support are rejected. Replace them with a suitable finished vine asset or a convincing connected stem-and-leaf assembly. Stems must follow and attach to the support, with natural branching and restrained variation.

Use vines selectively on ladder supports, some fixed dome/frame boundaries and appropriate stationary hoist structures. Keep climbing routes, interaction points, moving grippers, cables and the delivery envelope clear. Do not distribute vines uniformly over every column or cover the glazing. Preserve useful greenery rather than interpreting restraint as almost no vegetation.

## 07 — 07-recessed-laboratory-display.png

Replace the dark room-like laboratory recess with a distinctive forward-facing laboratory counter/display integrated into the perimeter and projecting toward the shared space. The player should see the specimens and apparatus clearly from the approach. It needs no room entrance or interior corridor.

Replace crude token apparatus with a small number of convincing finished assets. Give equipment believable supports and use focused readable lighting. Resolve exposed background slits and unfinished wall/roof junctions as part of the replacement. Avoid signs that merely label obvious decorative objects, such as a generic FOSSIL sign on a bone.

## 08 — 08-recessed-workshop-and-tools.png

Replace the room-like workshop with a prominent, attractive service frontage. It should project into the shared space and feel deliberately designed, with clear actual-tool displays, coordinated colors/materials, convincing supports and readable lighting. Players interact from the front; they should not enter a deep cavity.

Personal rooms have entrances. The shop and shared laboratory are service/display frontages, not additional personal-room doors.

The old blocky charge/explosive appearance is explicitly rejected. Improve the visible physical tool presentation and replace weak visual models with suitable finished assets where needed; preserve tool behavior, ownership, prices, statistics and interactions. Keep display/tool appearance consistent where they share visual assets. Do not expand this into redesigning the shop UI or gameplay systems. Reframing the same crude objects is insufficient.

## Asset selection

Prefer suitable finished assets over invented primitive stand-ins. Research only the assets actually missing for this scope, inspect actual geometry rather than trusting thumbnails, and retain license/source records. A catalog name alone is not evidence of quality or actual use.

Useful sources:
- https://quaternius.com/
- https://quaternius.com/packs/stylizednaturemegakit.html
- https://kaylousberg.itch.io/kaykit-forest
- https://kenney.nl/assets
- https://polyhaven.com/models
- https://ambientcg.com/
- https://sketchfab.com/ (verify each selected asset's license and suitability)

Choose a coherent stylized treatment. Do not mix photorealistic fossils, primitive foliage and cartoon machinery without adapting them to a common visual standard.

## Mandatory replacement cleanup

For each replaced element, identify its exact instances and generating builders/scripts. Remove the superseded active geometry AND obsolete generation calls so startup or rebuilding cannot recreate it. Retire overlapping old floors, decorative shells, planters, specimen assemblies, framing, signs and fixtures within this replacement scope.

Do not hide old objects underground, outside the dome, behind new geometry or with transparency. Keep recovery material privately in backups, not as leftover assemblies in the active world. Reuse only deliberately selected assets. Preserve functional systems or migrate their dependent anchors coherently; do not indiscriminately delete gameplay objects.

Keep one authoritative active interior layout. Record removed generators and any relocated functional anchors. Check for duplicate generation and abandoned collidable objects after replacement.

## Protected behavior and deferred work

Preserve player data, fixed save generation, economy, progression, rewards, room ownership/capacity, working joining, equipment behavior, mining rules, actual egg geometry and delivery/reveal behavior. No reset, grants or gameplay changes.

Preserve exterior landscape assets and atmosphere systems; only the authorized lighting/time-of-day adjustment and coordinated enclosure fit may affect their presentation. Do not resume exterior art iteration.

Defer personal-room interiors/collection redesign, HUD/menus, shop UI, skill tree/remaining skills, large entrance gate/road, creature redesign, rebirth, monetization and new worlds. Keep these in the roadmap. Physical shop display/tool appearance improvements described above are included, not deferred.

## Execution and evidence

1. Create a private native recovery backup before editing. Work directly in the original place.
2. Measure the current layout, choose one compact replacement arrangement and save a concise annotated plan. Proceed with implementation; do not stop merely to present a proposal.
3. Prefer source/API/Edit-mode work. Avoid lengthy mouse automation, a new broad audit, repeated reports or unrelated installation work.
4. Perform focused static clearance, dependency and duplicate-generation checks. Prepare capture cameras before Play.
5. Use one bounded capture-only runtime session. No repeated Play/Stop loops, device switching, purchases, mining or gameplay simulations. Runtime usability remains the owner's review.
6. Capture a readable full overhead layout and matched above-egg view, plus player-height views of rooms, planting, skeleton, ladder/vines, lab and workshop. For overhead inspection, temporarily hide obstructing roof/preview elements if necessary, label that image as an inspection cutaway and restore them afterward. Do not deliver an overhead image whose roof hides the layout.
7. Record shortcomings found during final capture and freeze the art for owner review. Do not start another autonomous correction loop.
8. Save a final native checkpoint, publish to original place 94763223427049 and push to planning/development-foundation. Publication within this scope is authorized.

Return a short report linking each numbered reference to what changed, any unresolved requirement, actual screenshots, before/after clear distances, removed old assemblies/generators, relocated anchors, published version, commit link and private backup location. Distinguish source checks from runtime evidence and do not claim owner visual approval. Stop with Studio in Edit mode.
