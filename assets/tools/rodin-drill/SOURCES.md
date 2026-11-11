# Owner-supplied Rodin drill

Only `rodin-drill-source/base_basic_pbr.fbx` and its supplied texture maps were used. SHA-256: `f041424d6c1aaf1881aa62d99a9f9c37ede9a2cc515c2a3d5655d8722c27e06d`. All ten source-package files match the untouched private copy. Alternate FBXs were not assembled as extra components. No replacement asset search, generated art or decimation.

The owner supplied and authorized this model for this experience. No separate redistribution license was supplied. Original files, Blender masters, GLB, textures and rendered icon remain private and ignored. Scripts, metadata and actual Studio screenshots are tracked.

The working copy is uniformly scaled by 1.85, with its origin at the rear purple handle. Overall dimensions are approximately **1.59 × 1.45 × 3.51 studs**. The auxiliary grip is on the player's left. One cut at source Y = -0.405 separates the silver shaft inside its collar; it subdivides crossed faces without reducing or replacing surfaces. Source UVs remain on both meshes. The two resulting meshes have **8,838 + 732 = 9,570 triangles**, versus 9,506 initially. No cap or external replacement geometry was added. The hidden internal split is not exposed in the assembled tool.

`prepare.py` exports geometry with UVs, normals and tangents. `install.luau` repairs the importer's assembly orientation as in the pickaxe workflow, preserves every part transform and attaches explicit PBR maps. The local fitted model is unlinked from its upload package. One invisible Handle, one housing weld and one shaft-centered Motor6D form the equipped tool; only the bit rotates.

## Texture mapping and uploads

Seven uploads, revision 1, creator UserId **291892217**, all **Approved / Active**. Exact API results: [uploads.json](uploads.json).

| Purpose | Input / property | Asset ID |
| --- | --- | --- |
| Model | geometry-only `RodinDrill.glb` | 138354353381740 |
| Diffuse | `texture_diffuse.png` → ColorMap | 90195186307933 |
| Metalness | `texture_metallic.png` → MetalnessMap | 109105119248998 |
| Roughness | `texture_roughness.png` → RoughnessMap | 116118521758364 |
| Normal | `texture_normal.png` → NormalMap, unchanged OpenGL orientation | 135980048625105 |
| Emission mask | maximum RGB channel of `texture_emissive.png` → EmissiveMaskContent | 120770337746294 |
| Exact-model icon | transparent 768px Blender render | 138062140706342 |

The model importer also created mesh IDs **74615865802297** (housing) and **107695395365542** (bit), and no image assets. Each original PBR map remains 2048 × 2048. `texture_pbr.png` is unused; its channel layout was not assumed. Emission support was checked in Studio and the [SurfaceAppearance reference](https://create.roblox.com/docs/reference/engine/classes/SurfaceAppearance): its grayscale mask modulates albedo, with white tint and restrained strength **0.25**. No lights, bloom or global lighting changes. A redundant MeshPart.TextureID was cleared after its legacy content request warned; SurfaceAppearance owns the maps.

Private recovery/reproduction files are under `Backups/RodinDrill_20261111/`. `ToolPresentationBuilder.Drill()` is the canonical drill-only recipe. The old `HelixDrillSource` and `DrillBodyTexture` attribute were removed after replacement verification; the two legacy drill-fitting entry points now call this scoped recipe. Equipped tool, equipment preview, workshop and icon all derive from the same supplied mesh.
