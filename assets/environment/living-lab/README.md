# Living discovery laboratory assets

Used in original place **94763223427049**, published checkpoint **149**. These are real imported environment meshes, not concept renders. Appearance remains subject to owner review.

## Sources and rights

Owner-provided `example.png` was inspected locally for composition/material relationships. It is not redistributed here and was not copied as a floor plan or egg design.

Four exact meshes are from **Kenney, Nature Kit**, [official pack/license listing](https://kenney.nl/assets/nature-kit), **CC0 1.0** ([license](https://creativecommons.org/publicdomain/zero/1.0/)). Raw redistribution and modification are allowed. The official ZIP endpoint did not deliver a usable archive in this session; the original named GLBs were obtained from these public mirrors:

| Original filename | Exact download | Adaptation and use |
| --- | --- | --- |
| rock_largeA.glb | https://raw.githubusercontent.com/rajsinghtech/spurfire/main/game/assets/kenney/nature-kit/rock_largeA.glb | Ground pivot, normalized scale, tinted/reshaped instances for distant rock layers and sample stones |
| tree_default.glb | https://raw.githubusercontent.com/rajsinghtech/spurfire/main/game/assets/kenney/nature-kit/tree_default.glb | Ground pivot/scale; muted native foliage tint and separate brown stem sleeve; exterior tree belt |
| plant_bush.glb | https://raw.githubusercontent.com/milnet01/Vestige/main/assets/models/nature/plant_bush.glb | Ground pivot/scale and restrained green; built-in planting |
| plant_flatTall.glb | https://raw.githubusercontent.com/milnet01/Vestige/main/assets/models/nature/plant_flatTall.glb | Ground pivot/scale and restrained green; planter foliage |

The committed exact downloaded bytes and SHA-256 hashes in `roblox-assets.json` identify this revision even if mirror branches change. No third-party Lua scripts were imported. No other resource library or paid generation service was used.

**Original project geometry:** FossilSkull (snout, jaw, eye sockets and teeth), FossilBone, Ammonite, three beveled/clipped stone slab variants, five fitted dome panel templates. Authored in the already-installed Blender 4.5.15. Architecture, shelves, jars, planter housings, static waterfall ribbons and lighting use native Roblox geometry/materials. Display tools are the existing actual equipment assets; no upgraded weapon is advertised.

## Editable and integration files

- `living-lab-assets.blend`: editable mesh/material master. No layered raster sources are claimed.
- `build_assets.py`: reproducible authoring recipe using the four source GLBs.
- `export_fbx.py` and `exports/living-lab-assets.fbx`: native Studio import path actually used.
- `exports/*.mesh.json` / compact equivalents: geometry interchange exports, not the successful upload path.
- `geometry-manifest.json`: actual source vertex/triangle counts. `geometry-bounds.json`: desired normalization bounds.
- `roblox-assets.json`: fifteen real returned mesh IDs, normalized centers/sizes, owner UserId **291892217**, master/source hashes.
- Studio templates: `ServerStorage.LivingLabAssets`. Builder: `ServerStorage.VesperTools.LivingLabBuilder` / `src/LivingLabBuilder.luau`.

Native FBX import uploaded to the signed-in experience owner. The imported hierarchy was normalized from Studio's FBX scale into intended stud bounds before assembly. Native colors/materials replace renderer materials; Blender procedural shaders do not transfer. Flat-color meshes require no texture maps. No production texture baking is claimed. Import preview displayed a File Geometry warning whose detailed cause was not established; successful upload does not prove UV or visual quality. Native `CreateAssetAsync` was unavailable, so the normal Studio importer was used; no software/integration was installed.

## Assembly and cost assumptions

Edit-only methods: `Envelope`, `FloorAndAccess`, `Workshop`, `BaysAndRooms`, `Exterior`, `Anchors`. The saved original place is the implementation; builders are not startup scripts and must not be installed as runtime regenerators. Historical geometry/lighting recipes are guarded; the old Outfitter recipe delegates to the current recessed workshop. Functional references live in `Workspace.VesperLab.FunctionalAnchors`.

120 single-surface dome panes reuse five very small meshes, plus 24 lower windows. Shared edges have structural ribs; no stacked pane layers. Enclosed lower sill/windows and collidable dome prevent an intended outdoor route. Exterior meshes are noncolliding/nonquerying decoration with no interactions or spawns. This is architectural intent/static inspection, not a traversal guarantee.

408 slab instances reuse three 92-triangle templates. Foliage templates have 32 triangles; tree 114 and rock 80. Fossil skull 2,424, bone 1,120, ammonite 948 triangles. There are 13 new task lights across research/workshop bays; outdoor scenery has none. Mesh reuse, no large textures, static scenery and bounded transparency are cost controls, **not measured performance results**. Actual screenshots expose coarse scenery and remaining composition limitations; see the review record before further refinement.
