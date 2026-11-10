# Phase 3 environment assets

Original place 94763223427049. The two new plants were downloaded as actual GLB geometry and inspected in Blender before adaptation; screenshots in the review are actual Studio evidence, not those source renders.

| Actual asset | Publisher / source | License record | Adaptation and use |
| --- | --- | --- | --- |
| **Ivy on Trellis**, Cozy Plants Kit | [Grab3D](https://grab3d.com/models/nature/ivy-vine/); no separately named artist on the downloaded page | Site lists CC0. This is the publisher's claim, not independent verification of upstream authorship. | Original 14,373 triangles; remove brown pot/trellis faces, retain connected stems/leaves, 10,845 triangles. ArchitecturalIvy on four frame gardens, fixed ladder support and fixed outboard crown braces. |
| **Hanging Vine**, Cozy Plants Kit | [Grab3D](https://grab3d.com/models/nature/hanging-vine/); no separately named artist on the downloaded page | Same CC0 claim and provenance limitation. | Original 13,592 triangles; remove brown display branch, retain actual trailing branches/leaves and moss head, 11,937 triangles. TrailingVine on six roof groups, frame boundaries, fixed access/crown and ground-bed edges. |

Exact downloads: `https://grab3d.com/dl/ivy-vine/ivy-vine.glb` and `https://grab3d.com/dl/hanging-vine/hanging-vine.glb`. Original pages, untouched downloads, inspection render and editable adapted `.blend` masters are private in `Backups/InteriorPhase3_20261111/source/`. Source colors/textures remain recognizable; 2K maps reduced to 1K color maps, roughness .82, no normal/metal texture microdetail. Fine plants are anchored, noncolliding, non-touching, non-querying and do not cast shadows. Solid stone planters/supports collide.

The upload exports were written directly to the previously approved `assets/environment/compact-interior/exports/` directory. They are explicitly Git-ignored while provenance remains provisional. No restricted source/library bytes are added to the public repository. Export scripts, measured bounds, original/download/export hashes, source URLs and actual hosted IDs are retained here. The native checkpoint contains the normalized, unlinked imported assets in `ServerStorage.IntegratedGreeneryAssets`; it is the recovery source for hosted bytes as well as scene state.

Two Model uploads, owned by **User 291892217**, both Approved:

| Normalized template | Model ID | Mesh ID | Importer-created color image |
| --- | --- | --- | --- |
| ArchitecturalIvy | 96590538703628 | 98916380528913 | 119834959865291 |
| TrailingVine | 139719362993538 | 74083467446945 | 91970065682514 |

The native importer changed placement/orientation. Bounds were checked against `export-manifest.json`, templates normalized, source rotations preserved, and the plant faces oriented inward on architectural supports. Missing texture repair uploads were unnecessary. Package links were removed for maintained local copies, consistent with the authorized replacement workflow. Re-inserting the original hosted Model does not reproduce the normalized template automatically; `normalize-imports.luau` records that operation.

**Replacement ledger:** both Grab3D assets are provisional until upstream authorship/license provenance is confirmed. Replace them if that cannot be established; free download is not proof of unrestricted rights. No separate owner approval stage was introduced. Existing Foggy/Blendkit/Maxtree provenance issues remain recorded in earlier reviews; this pass does not clear them and places no new Foggy assets.

Existing assets reused: Innerscene **Mountain Range** (`AlpineRange`), Poly Haven **Rock Face 02** (`RockButtress`), Quaternius **CommonTree_1/CommonTree_3/TwistedTree_2/Pine_2**, **Fern_1**, **Plant_1_Big**, **Clover_2**, ground plants/rocks, and KayKit Forest shrubs/rocks. Exact authors, CC0 records and original-to-template mapping remain in [exterior composition](../exterior-composition/README.md) and [laboratory art](../lab-art/README.md). The five existing massifs, seven buttresses, 168 trees, 192 meadow objects, 64 ground tiles and sixteen fitted grass meshes are reused. Ground and fitted-grass transforms are preserved; other placements are deliberately recomposed. No new mountain set was acquired.

`ExteriorIntegrationLayout` is the final placement table; `compose-exterior.py` derives it from the private v212 inventory. `Phase3EnvironmentBuilder` orchestrates only the current exterior, planting and lighting recipes. Triangle/instance counts describe geometry; they are not performance measurements.
