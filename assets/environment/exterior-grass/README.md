# Ground and static grass integration

Continues the accepted v182 exterior in original place 94763223427049. No new mountain source, vegetation engine, animation, gameplay code or global lighting change.

`prepare_grass.py` runs with the existing Blender **5.2.3 LTS**, build `e13b728c6880`, with auto-execution disabled. It reads preserved source geometry, writes private native/FBX/material derivatives under `Backups/ExteriorGrass_20261110/`, and emits `layout.json` plus `src/ExteriorIntegrationLayout.luau`. The active Edit-only recipe remains `src/ExteriorCompositionBuilder.luau`. Earlier integration preparation is historical; use this preparation for the current layout.

## Incorporated assets and rights

- **Grass:** the existing Quaternius Standard FREE `Grass_Wispy_Short`, named `SoftGrass` in the [established library](../lab-art/README.md). CC0. Its existing 494-triangle geometry is simplified to **140 triangles per tuft**, retaining atlas UVs; 76 short tufts are combined into each of 16 terrain-fitted patches. Total **1,216 tufts / 170,240 source triangles / 16 MeshParts**. The individual blades are approximately 1–1.9 studs tall. This is a static asset preparation, with no runtime generation or bending scripts.
- **Trees, shrubs, ferns and small rocks:** reuse the same Quaternius/KayKit CC0 library and existing mesh/texture IDs. Original 102 trees and 88 low props remain. Only recent woodland-link additions are regrouped/reduced.
- **Mountains:** the same [Innerscene Mountain Range](https://www.innerscene.com/tools/library/3d-parts/mountain-range-ac633cbe), CC0, mesh `131140296893821`, five placements. **Rock buttresses:** existing [Poly Haven Rock Face 02](https://polyhaven.com/a/rock_face_02), CC0, mesh `81361590725377`, seven placements. [Original source/download records](../exterior-composition/README.md). New color derivatives retain original resolution and rock structure, with mild contrast/saturation reduction and no downsample/upscale blur.
- **Ground:** existing original 64-tile grading structure, 512 triangles per tile, with four restrained additional foothill fields and a continuous 2048-pixel meadow/woodland/soil map. Grass roots are fitted to the actual triangulated surface, not only the analytic grading function. No Terrain conversion or alpha ground overlays.

Actual imported mesh/image IDs are recorded in `imported-assets.json`. Private originals remain unchanged. Existing unresolved Foggy Gazebo/Maxtree constituent-rights records remain unresolved and are not superseded by these CC0 sources.

## Engine documentation and resource decisions

Read for this pass:

- [Terrain](https://create.roblox.com/docs/parts/terrain) and [Terrain API](https://create.roblox.com/docs/reference/engine/classes/Terrain): Decoration generates blades on native Grass Terrain; it does not decorate arbitrary MeshParts. Limited static clumps fit the existing graded mesh ground and the inaccessible exterior. Native blades would not by themselves solve readability from the saved distant cameras.
- [Improve performance](https://create.roblox.com/docs/performance-optimization/improve) and [environment optimization](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/optimize-your-experience): use appropriate geometry/detail and shared asset IDs; inventory estimates are not frame-time or mobile evidence.
- [SurfaceAppearance](https://create.roblox.com/docs/art/modeling/surface-appearance): retain the common nature atlas `96148416703392`, AlphaMode Transparency with MeshPart Transparency **0**, and double-sided grass. No large overlapping transparent cards behind the glazing. Collision, query, touch and small-detail shadows are disabled.
- [Meshes](https://create.roblox.com/docs/parts/meshes): RenderFidelity adjusts mesh detail. It is not treated as a draw-distance guarantee; the exterior remains Automatic.
- [WindShake source](https://github.com/boatbomber/WindShake): available, MIT; source and license inspected. **Not incorporated** because this static inaccessible exterior does not justify another per-frame foliage system. No benchmark claims adopted.
- [Reddit resource discussion](https://www.reddit.com/r/robloxgamedev/comments/1txjdso/does_anyone_know_how_to_make_stylized_grass_like/): points to SkinnedGrass, but establishes neither licensing nor performance for this place.
- [SkinnedGrass](https://devforum.roblox.com/t/skinnedgrass-performant-interactive-foliage/3364812) and [grass-on-parts generator](https://devforum.roblox.com/t/grass-generator-easily-generate-grass-on-top-of-parts/2746519): the supplied pages returned verification screens during this pass. Full source/license/compatibility could not be established. Neither was installed, imported or executed. Existing licensed static assets are sufficient.

Sixteen fitted patch meshes trade unique mesh IDs for only sixteen scene instances and exact slope seating. They reuse one existing atlas; the other vegetation/mountain repetitions retain shared IDs. Far ground uses material variation and larger vegetation masses, without distant individual grass fields. No animation or active animation range is introduced.

See [the bounded review and actual captures](../../../docs/reviews/exterior-grass/REVIEW.md) for runtime evidence, geometry totals and remaining limitations.
