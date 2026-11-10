# Personal-room furniture

Finished free models selected for Phase 2 after visual/scale checks:

| Source | Original file | Use | Uploaded owner asset |
| --- | --- | --- | --- |
| [Kenney Space Station Kit](https://kenney.nl/assets/space-station-kit), CC0 | table-inset.glb | Training workbench and reserved care work surface | 88228421948876 |
| [Kenney Furniture Kit](https://kenney.nl/assets/furniture-kit), CC0 | benchCushionLow.glb | Low care-area bench | 108529717122743 |
| Same kit, CC0 | desk.glb | Existing archive/style terminal desks | 70949500748841 |

All three were uploaded to experience owner UserId 291892217 and returned approved/active. Exact returned mesh IDs and color correspondence are in [import record](../../../docs/reviews/interior-phase-2/asset-imports.json). Original selected GLBs/licenses are in source/. Original complete downloads and unused inspected options remain in private Backups/InteriorPhase2_20261111/.

`prepare_assets.py` uses the already installed Blender to bake the original palette to flat materials, normalize scale and save the editable blend. Exports are written directly to the previously owner-approved `../compact-interior/exports/` upload directory: LabTable.glb, CareBench.glb, ArchiveDesk.glb. No denied upload was relocated to bypass an allowlist. `normalize-imports.luau` restores importer-lost colors/orientation and strips package links. RoomInteriorBuilder applies the final muted bench/table finish; the care bench cushion is sage. Imported solids use hull collision; foliage does not collide.

Also intentionally reused: existing CC0 Quaternius ForestFern and RockRound geometry from LivingLabArtAssets; exact prior provenance remains in [lab-art manifest](../lab-art/asset-manifest.json). The training sample removes the moss finish in favor of slate. Current Crownback specimen models/variant finishes are reused without redesign; model-quality limitations are separate from the shelf layout.

No newly selected asset requires replacement for license reasons. The owner's temporary-asset policy remains accepted, including recording restrictive/unresolved assets for later replacement without another asset approval stage. Inherited exterior and microscope/charge rights limitations remain in the [prior ledger](../../../docs/reviews/interior-phase-1/TEMPORARY_ASSETS.md); those assets were not changed here.
