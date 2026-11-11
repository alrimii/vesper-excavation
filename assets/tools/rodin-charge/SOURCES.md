# Owner-supplied Rodin sticky charge

Source: untouched `rodin-charge-source/base.obj`, SHA256 `89d4879e42e1cc4bfaed481b3ef3a64ae65f57adb930ff6c643656181fe49f43`. The package has no FBX or alternate PBR model. One UV-mapped mesh: 4,309 vertices / 8,620 triangles, unchanged topology. Supplied source, working textures, GLB and editable masters stay private under the existing backup/upload convention.

`inspect_source.py` reads a private source copy. `material_maps.py` clears only the baked timer digit mask in the four explicit maps; `screen-edit.json` records it. `prepare.py` makes a uniformly fitted, UV-preserving geometry-only GLB and exact-model transparent icon. The importer’s assembly orientation is corrected as in the drill workflow. `geometry.json` records the hand origin, rear contact and screen plane. `install.luau` installs the source and calls only `ToolPresentationBuilder.Charge()`.

| Use | Working derivative | Roblox asset |
|---|---|---|
| Model | RodinCharge.glb | 92010232869320 |
| Imported mesh | RodinStickyCharge | 100836062740084 |
| ColorMap | ChargeColor.png ← texture_diffuse.png | 107516321449088 |
| MetalnessMap | ChargeMetalness.png ← texture_metallic.png | 73326595026303 |
| RoughnessMap | ChargeRoughness.png ← texture_roughness.png | 71409232252049 |
| NormalMap | ChargeNormal.png ← texture_normal.png | 129645955556486 |
| Rendered icon | RodinChargeIcon.png | 124689974420203 |

All final uploads returned Approved. Image-content updates are not supported by the Assets API, so corrected screen-map derivatives were uploaded as new image assets; earlier intermediate images are unreferenced. `uploads.json` records the final asset identities. No packed-channel assumption, raw emissive digit texture, automatic decimation, global lighting change or third-party replacement.

The only extra part is an invisible screen carrier for the real timer. Its SurfaceGui uses LightInfluence=0, not a glow/light source. Equipped unarmed display is “--”; the placed display uses `DetonatesAt` and `workspace:GetServerTimeNow()` without changing the existing fuse. All physical clones remove joints and are anchored.

Private recovery: `Backups/RodinCharge_20261111/`. Active source model: `ServerStorage.ToolPresentationAssets.RodinCharge`. Legacy SurveyDynamite and its combined normalizer/generator are retired. [Actual review captures](../../../docs/reviews/rodin-charge/REVIEW.md).
