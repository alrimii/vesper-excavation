# Owner-selected Rodin pickaxe

The sole visual source is the owner-supplied `agentic_0003_pack_fbx_model.fbx` in the project root. No substitute model, asset search, primitive rebuild or generated illustration was used. Source SHA-256: `fd986e665b296d1bb016b4f6da7fffb44ef6bee883d06d5c3cd2e096220f320c` (1,823,404 bytes). The original is untouched and also copied into private recovery.

The owner identifies this as a Rodin-generated model and authorizes its use/upload in this experience. No external redistribution license was supplied. Accordingly the FBX, Blender masters, GLB, palette maps and rendered icon remain private and ignored. Original scripts, metadata and actual Studio review screenshots are tracked. This is not a claim that the source is CC0 or cleared for redistribution.

## Geometry and materials

Original: 217 mesh objects, 63,928 triangles, seven materials, no image textures. Only the four named raised strap-edge objects were decimated: 7,360 to 882 triangles each. All other source topology is retained. Material-compatible regions were consolidated into seven meshes, totaling **38,016 triangles**. The equipped assembly adds one invisible Handle and seven welds; it contains eight BaseParts, seven of them visible MeshParts.

Uniform scale makes the complete model 3.85 studs tall, with the grip origin inside the wrapped handle. Source proportions, head, crystal blades, gemstones, fittings, spiral grip and stitching remain intact. `geometry.json` records the reductions and original material values.

The seven source materials are encoded into tiny color/metalness/roughness palettes with material-center UV coordinates. Base color converts source linear values to sRGB; metallic and roughness values remain source-derived. No cyan/purple recolor or invented materials. The preview clones the existing sky into its ViewportFrame so its metalness has an environment. Roblox rendering still differs visibly from the Blender studio render, especially in dark metal and highlights.

## Uploaded assets

All assets are revision 1, creator UserId **291892217**, active and moderation **Approved**. Exact authenticated responses are in `uploads.json`.

| Purpose | Asset ID |
| --- | --- |
| Seven-mesh model | 125687100665406 |
| Color palette | 90874713782709 |
| Metalness palette | 106595719402423 |
| Roughness palette | 71119738114898 |
| Exact-model icon | 92425113043430 |

The 768px transparent icon is a tightly framed three-quarter Blender render of the final model, with approximately 4% safe margin per side. It is used by the inventory/hotbar, equipment tab and Tool.TextureId. It is not an AI reinterpretation.

## Reproduction and replacement

Run `inspect_source.py`, `prepare.py`, `material_maps.py` and `render_icon.py` with the existing local Blender/Python tools. Private masters: `Backups/RodinPickaxe_20261111/source-inspected.blend`, `RodinPickaxe-Game.blend`, `RodinPickaxe-Icon.blend`. Approved upload staging is under `assets/environment/compact-interior/exports/` and ignored.

`install.luau` documents fitting a fresh insertion of the uploaded model. Preserve all imported part transforms and rotate the complete assembly. Resetting individual CFrames from bounding-box centers causes separation because the imported local mesh axes differ. This concrete import fault was fixed before runtime verification.

`ToolPresentationBuilder.Pickaxe()` is the scoped canonical recipe. It updates the equipped template, equipment preview and workshop display only. The live `AuthoredPickaxe` source and its three v235 generation/fitting scripts were removed; recovery copies remain private. Historical v235 provenance and upload IDs remain for traceability, not active use.
