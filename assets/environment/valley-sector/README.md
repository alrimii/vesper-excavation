# Eastern forest valley assets

Used in original place **94763223427049**, published checkpoint **162**.
Actual scenery, not a concept/demo place. Visual quality and mobile performance remain unapproved.

## Incorporated sources and rights

| Actual asset | Source and license | Placement / adaptation |
|---|---|---|
| CommonTree_1 / CanopyOak | [Quaternius Stylized Nature MegaKit](https://quaternius.com/packs/stylizednaturemegakit.html), [official free download](https://quaternius.itch.io/stylized-nature-megakit); Quaternius; Standard FREE, CC0 | Main oak canopy, asymmetric near/middle/upper forest groups; normalized ground pivot, shared source texture atlas, coordinated tint and varied scale |
| CommonTree_3 / CanopyYoung | Same pack/edition/license | Smaller tree silhouettes within the same oak foliage family |
| Bush_Common / LeafShrub; Fern_1 / ForestFern | Same pack/edition/license | Understory concentrated around woodland edges and outcrops; no glossy KayKit blob shrubs in the rebuilt sector |
| Rock_Medium_1 / RockLedge; Rock_Medium_2 / RockShoulder | Same pack/edition/license | Buried shore outcrops and broad buttresses attached to the continuous authored cliff mass; anisotropic scaling and coordinated tint |
| Rock004 Color and NormalGL, 1K JPG | [ambientCG Rock004](https://ambientcg.com/view?id=Rock004), [exact download](https://ambientcg.com/get?file=Rock004_1K-JPG.zip), [CC0 license](https://docs.ambientcg.com/license/); ambientCG | Cliff material: grayscale, blurred, contrast limited to 16% across the full range, colorized grey-green; normal intensity 18%, matte roughness |

These exact downloaded source files and license texts were already preserved in
`../lab-art/source/quaternius/` and `../lab-art/source/ambientcg/`; they are reused,
not duplicated here. The Standard archive contains **68 assets**; paid editions were not
obtained. CC0 permits modification and redistribution. No third-party scripts were
imported/executed. KayKit, Kenney and Poly Haven were inspected; no additional assets
from them are incorporated in this sector. Other unchanged v156 sectors retain their assets.

Actual original and derived Roblox IDs are in [asset-manifest.json](asset-manifest.json).
Inherited Quaternius mesh IDs/atlas are in [the prior manifest](../lab-art/asset-manifest.json).
Uploads use the existing experience owner, UserId **291892217**.

## Original editable work

- `build_valley.py`: original continuous valley surface, eroded cliff/plateau, two long
  unequal ridges, curved two-stage cascade, irregular receiving basin, outflow and foam arcs.
- `make_materials.py`: original material source. Ground color follows woodland groups
  and stream banks; water color softens rigid striping. Small transparent streak texture
  supports native flow accents. No layered illustration sources are claimed.
- `valley-master.blend`: editable geometry/material source.
- `valley-runtime.blend`: editable mapped export counterpart.
- `exports/valley.fbx`: full final eight-mesh set.
- `exports/valley-materials.fbx`: final ground/water import subset.
- `geometry.json`, `water-path.json`: authored bounds, triangles, source geometry path.
- Runtime maps: 1024x1024 ground, 512x512 cliff color/normal, 256x512 cascade,
  512x128 transparent flow streaks, 1024x32 palette. Existing 2048 shared foliage atlas
  and matte roughness map are reused.

Already-installed Blender 4.5.15 and Python/Pillow were used. No installations, paid assets
or generation credits. No videos, concept boards or gameplay simulations.
Run make_materials.py, then run build_valley.py through Blender background authoring.
Source paths are relative to this directory and the retained lab-art source directory.

## Native mapping and assembly

The native FBX importer mirrors authored X into Roblox -X; Blender Z maps to Roblox Y,
and Blender Y maps to Roblox Z. Native import may scale the file to its size limits.
Templates are normalized to geometry.json bounds, with mirrored X in SourceCenter.
This mapping was established by reading native mesh vertices in Edit mode, not assumed.

`src/ValleySectorBuilder.luau` lives in `ServerStorage.VesperTools.ValleySectorBuilder`.
It is restricted to the original place in Edit mode. Mesh templates are saved under
`ServerStorage.ValleySectorAssets`; instances live under
`Workspace.VesperLab.DecorativeExterior.EastValleySector`.

The assembly recipe positions the valley at bearing 56 degrees. The connected ground
rises gradually from z350 to the basin; cliff/water are offset +40 studs to remain visible
above retained perimeter architecture. Near/far ridges use vertical scales 1.5/1.95,
with offsets 40/10 studs. These scene transforms are intentional and recorded in source.
Native mesh triangles are read once during Edit authoring to seat foliage on actual
surfaces. No editable mesh API, builder or new script runs during gameplay.

The older LivingLabArtBuilder.Exterior recipe refuses to overwrite this sector after
ValleySectorRevision is set. No new world framework or gameplay system was introduced.

## Cost and motion

Edit property inventory: **232 BaseParts**, **586,345 instanced triangles** including
85 source trees, 92 shrubs, 24 ferns and 22 rock instances; eight original scenery meshes
contribute 15,818 triangles before scene instancing. Meshes/materials are reused.
All new scenery has CanCollide/CanTouch/CanQuery disabled. Zero new lights or particles.
Native beam accents: 18 short segments forming two flow tracks, width 4 studs,
TextureLength 18, TextureSpeed 0.6 cycles/second, transparency 0.38. Positive speed follows
Attachment0 toward Attachment1; see [official Beam documentation](https://create.roblox.com/docs/reference/engine/classes/Beam).

The cliff, pool and water body are opaque; only sparse flow accents use transparency.
This is not a mobile performance measurement or guarantee. Full source trees remain a
potential cost at distance; no separately authored reduced-detail tree LOD was delivered.
Reduced Motion integration for these native ambient accents was not added in this
scenery-only milestone. Existing gameplay effects/settings were unchanged.
