# Living laboratory art assets

Implemented in original place 94763223427049; visual approval and performance are pending.
The owner reference `example.png` was inspected privately; it is not redistributed.

## Exact incorporated sources

| Source | Edition / author / license | Selected original assets | Use and changes |
|---|---|---|---|
| [Quaternius Stylized Nature MegaKit](https://quaternius.com/packs/stylizednaturemegakit.html), [official download](https://quaternius.itch.io/stylized-nature-megakit) | Standard FREE ZIP, upload 11055123; Quaternius; CC0. The downloaded license specifies 68 assets, not the larger advertised paid catalog. | CommonTree_1, CommonTree_3, TwistedTree_2, Pine_2, Bush_Common, Fern_1, Plant_1_Big, Plant_7_Big, Grass_Wispy_Short, Clover_2, Flower_3_Group, Rock_Medium_1, Rock_Medium_2, Rock_Medium_3 | Main exterior trees/rocks, interior planted beds, room portals, workshop roof, research gardens. Imported glTF meshes joined per asset, grounded and scaled, atlas UVs prepared; red twisted-tree foliage harmonized to green. Source originals retained. |
| [KayKit Forest](https://kaylousberg.itch.io/kaykit-forest) | Forest Free 1.0, upload 13520330; Kay Lousberg; CC0. No paid Extra/Source edition. | Bush_2_D_Color1, Rock_1_J_Color1 | Ground shrub clusters, mineral trays and landscape underplanting. Grounded/scaled, original vertex colors retained and common atlas/material used. |
| [ambientCG Rock004](https://ambientcg.com/view?id=Rock004), [exact 1K JPG download](https://ambientcg.com/get?file=Rock004_1K-JPG.zip), [license](https://docs.ambientcg.com/license/) | Rock004 1K-JPG; ambientCG; CC0 | Color and NormalGL maps | Stone paving: desaturated, blurred, low-contrast five stone tones; normal detail reduced to 28%, roughness fixed near matte. No photorealistic full-strength material. Downloaded source files retained; renderer materials were not executed/imported. |

CC0 permits raw and modified source redistribution. Exact included license texts are beside
Quaternius/KayKit sources. No paid assets, subscriptions or generation credits were used.
Poly Haven and Kenney catalogs were inspected; no new assets from them were incorporated.
Small pre-existing Kenney sample stones in v149 specimen jars remain; their prior provenance
is in `../living-lab/`. Existing original skull/ammonite models remain unapproved art.

## Original authored geometry and files

- `lab-art-master.blend`: editable selected source geometry/materials plus original dressed
  paving, crescent edging/soil, ribcage/supports, three mountain silhouettes, slope and cascade.
- `lab-art-runtime.blend`: editable atlas-mapped counterpart used for native mesh import.
- `build_art.py`: Blender source assembly; `pack_export.py`: atlas UV conversion/export.
- `assemble_atlas.py`: original image-processing source, preserving source images.
- `exports/lab-art.fbx`: full final mesh set; `paving.fbx` and `ridges.fbx`: import subsets.
- `exports/environment-atlas.png`: shared 2048 color/alpha atlas, ten 512 source-image tiles,
  palette tile and five stone tiles. Four-pixel insets limit adjacent-tile sampling.
- `exports/stone-normal-atlas.png`, `roughness-atlas.png`: paving PBR maps.
- `geometry.json`: authored dimensions/origins/triangle counts.
- `asset-manifest.json`: actual Roblox mesh/image IDs, normalized template bounds, usage counts.
  Creator is experience owner UserId 291892217; templates are in
  `ServerStorage.LivingLabArtAssets`. All 16 selected third-party meshes are actually placed.

Already-installed Blender 4.5.15 was used in background authoring mode. No plugins/software
were installed. No renders, videos, concept boards or gameplay simulations were generated.
The original .blend is genuinely editable geometry; texture inputs are raster images, not
invented layered illustration sources.

Rebuild order: run `build_art.py` in Blender; run `pack_export.py` once to refresh
`atlas-layout.json`; run `assemble_atlas.py` with the existing Python/Pillow environment;
run `pack_export.py` again. Final files above are already saved. Native Studio mesh import
uploads under the experience owner, followed by normalization to `geometry.json` bounds.
Do not execute downloaded material .blend files or embedded third-party code. Selected
glTF/bin/images contain geometry/material data; no imported scripts were executed.

## World assembly and preservation

`src/LivingLabArtBuilder.luau` is an Edit-only original-place builder, saved in
`ServerStorage.VesperTools`. Its named methods replace only their visual modules.
Room/lab height adjustments use recorded original transforms, so reapplication is stable.
`LivingLabBuilder` refuses to restore the v149 foundation after this art revision.
`OutfitterBuilder` delegates to the current workshop framing.

Four paving meshes overlay the retained continuous collision floor. Exterior geometry has
collision, query and touch disabled; the original sealed dome remains the playable boundary.
The landscape has near planted slopes, middle tree/rock groups and distant ridges. Two static
cascade meshes connect source pools to receiving basins with supporting rock/terrain; they do
not introduce exterior gameplay or animated particle systems.

There are 25 reusable mesh templates. Edit-mode property counts show 822,315 triangles across
their placed instances, excluding the retained egg/world assets, and 66 light instances in
the complete laboratory (many pre-existing). These are inventory counts, not measured
rendering cost or a performance approval. Shared meshes/atlas, noninteractive scenery,
opaque water and non-shadowing task lights are deliberate cost controls; physical-device
performance and distant foliage mip/alpha behavior remain unverified.
