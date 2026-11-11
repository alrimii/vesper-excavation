# Owner-supplied Crystal Triceratops

Selected `rodin-crystal-triceratops-source/base_basic_pbr.fbx`, SHA256 `fa7a74737d2a2e282998b5f220cd5215e485d63aab7d95fc4ade0c22986b8993`. The alternative FBX/OBJ/shaded exports represent the same creature and were not assembled as additional components. Original file hashes are unchanged; source copies and editable masters remain private under `Backups/RodinCrystalTriceratops_20261111/`.

One unrigged UVMap mesh: **5,030 vertices / 10,050 triangles**, unchanged topology. No simplification, splitting, recoloring, texture edits or lighting baked into color maps. Only uniform scale (3.7704634), rigid coordinate conversion and floor-center origin adjustment. Canonical Roblox size approximately **4.011 × 4.800 × 7.158 studs**, forward **-Z**. Shelf instances fit their existing supports; the reveal instance is uniformly scaled to 46 studs along its longest axis.

| Use | Supplied file / derivative | Roblox asset |
|---|---|---|
| Uploaded model | CrystalTriceratops.glb | 124702277394975 |
| Imported mesh | CrystalTriceratops | 113175300268763 |
| ColorMap | texture_diffuse.png / TriceratopsColor.png | 72193654815759 |
| MetalnessMap | texture_metallic.png / TriceratopsMetalness.png | 133239986373567 |
| RoughnessMap | texture_roughness.png / TriceratopsRoughness.png | 85178923137606 |
| NormalMap | texture_normal.png / TriceratopsNormal.png | 108125817040792 |
| Exact-model rendered icon | CrystalTriceratopsIcon.png | 102662158340345 |

All four source maps are 2048² and copied unchanged. Their FBX material links establish the channel assignments; scalar/normal inputs use non-color data for the icon render. `texture_pbr.png` is unused. The additional emissive image contains crystal and eye regions but is not linked in the selected FBX material; it is inspected and left unused. `shaded.png` is not substituted for the diffuse map. No global lighting changes.

All uploaded assets returned Approved. Roblox generated compressed TexturePack **133172177939408**, also Approved, but its runtime compressed representation produced a delivery warning; see the review. This engine-managed field cannot be read or written by ordinary scripts. No unsupported override was added.

Canonical model: `ReplicatedStorage.VesperShared.SpecimenAssets.crystal_triceratops`. `SpecimenBuilder.Source(id)` resolves the catalog reference for both existing preview renderers. Metadata records the icon, static mesh, floor pivot and forward direction. Existing UI uses live 3D previews; the registered matching icon is ready for thumbnail consumers without replacing generic navigation artwork.

Reproduction: `inspect_source.py` → `prepare.py` → approved Assets API uploads → `install.luau`. Geometry-only GLB and texture/icon upload staging remain private. No superseded Triceratops existed and no other species was removed.
