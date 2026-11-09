# Phase 5B progression art

Fifteen original illustrations generated with the built-in `image_gen` tool for the eight implemented skills and common tree interface. These are actual UI assets, not tool models or concept boards. User visual approval is pending.

- `source/`: original raster PNG masters and exact generation prompts. The generator returned flattened RGBA/RGB images, **not layered editable paintings**. Preserve these originals.
- `exports/`: the exact PNG bytes submitted to Roblox. Native output size is 1254 x 1254 for each asset; masters and uploaded exports currently match. A smaller-device texture/export optimization pass is still unverified; do not describe these as 256px optimized exports.
- `manifest.json`: names, paths, dimensions, sizes, SHA-256 hashes, real returned asset IDs and owner.
- `upload-ids.json`: direct ID map; `ownership-readback.json`: read-only metadata for all 15 IDs. Owner is User `291892217` (Alrimi), matching original place `94763223427049`.
- Runtime consumers: `src/SkillArt.luau` and `src/SkillTreeUI.luau`. The crafted node frame is reused for node/focus states; literal state labels, dimmed locked art and authored diamond rank sockets distinguish states without relying on color alone. The panel illustration is nine-sliced for detail panels and navigation/action buttons. These state compositions and navigation typography are editable Luau, not additional layered raster files.

Eight node illustrations: fault_survey, charged_swing, steady_aim, batch_unload, sale_latch, precision_relay, chain_lightning, core_drill. Common illustrations: journal_hub, node_frame, panel, background, branch_impact, branch_collection, branch_technique.

The required single-asset upload was established first with `chain_lightning` (`99832335754640`); only then were remaining assets uploaded. All returned IDs resolve to Image assets and owner metadata was read back. No experience publishing occurred. Actual loading/moderation, small-screen readability, texture memory and final Roblox appearance have not been gameplay-verified. No animation/video/Blender scenes were produced. Source PNGs, rather than an external generator cache, are the repository's preserved illustration masters.
