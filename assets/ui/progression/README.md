# Phase 5B progression art

Fifteen original illustrations generated with the built-in `image_gen` tool for the eight implemented skills and common tree interface. These are actual UI assets, not tool models or concept boards. User visual approval is pending.

- `source/`: original raster PNG masters and exact generation prompts. The generator returned flattened RGBA/RGB images, **not layered editable paintings**. Preserve these originals.
- `exports/`: Phase 5B.1 runtime PNGs actually uploaded: 256px icons/emblems/frame, 512px panel, 1024px background. `prepare_exports.py` uses the already-installed Pillow to resize originals and fill the enclosed panel's alpha holes. Masters remain unchanged. Exports total 3,225,122 bytes, down from 24,700,347; this does not establish runtime memory/performance.
- `manifest.json`: names, paths, dimensions, sizes, SHA-256 hashes, real returned asset IDs and owner.
- `upload-ids.json`: current runtime ID map; `ownership-readback-phase5b1.json`: current read-only metadata. `upload-ids-phase5b.json`, `ownership-readback.json` and each manifest `previousAssetId` preserve the earlier uploads. All 15 new owners are User `291892217` (Alrimi), matching original place `94763223427049`.
- Runtime consumers: `src/SkillArt.luau` and `src/SkillTreeUI.luau`. The crafted node frame is reused for node/focus states; literal state labels, dimmed locked art and authored diamond rank sockets distinguish states without relying on color alone. The panel illustration is nine-sliced for detail panels and navigation/action buttons. These state compositions and navigation typography are editable Luau, not additional layered raster files.

Eight node illustrations: fault_survey, charged_swing, steady_aim, batch_unload, sale_latch, precision_relay, chain_lightning, core_drill. Common illustrations: journal_hub, node_frame, panel, background, branch_impact, branch_collection, branch_technique.

Phase 5B established single-asset upload with `chain_lightning` (`99832335754640`). Phase 5B.1 first uploaded repaired `panel` (`89278413581087`), then the other runtime exports. All returned IDs resolve to Image assets owned by the experience owner. Actual images rendered in original-place Play, including a phone emulator; see [the focused review](../../../docs/reviews/phase5b1/REVIEW.md) for evidence and limits. Final visual approval and performance remain pending. No experience publishing, animation/video or Blender presentation occurred. Source PNGs are flattened preserved masters, not layered paintings.
