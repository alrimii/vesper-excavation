# Identity slice assets

The owner reference pack controls composition. All seven images were inspected; 01 is rejected, 02–05 guide this slice, and 06–07 are retained for later work. No artwork was extracted from the referenced games.

## Finished pickaxe

- Author/source: [Baziliq Games, Stylized Pickaxes](https://baziliqgames.itch.io/stylized-pickaxes), free constructor sample, **PK-001**. Download file ID **19897601**; obtained 2026-11-11. The author discloses an AI-assisted procedural workflow, with Blender inspection. This is a finished downloaded model, not newly constructed primitive geometry.
- Free sample licence permits personal/commercial games and modification, prohibits standalone redistribution, asset-store/UGC listing, and source sharing. Its in-experience use is provisional under the owner's recorded policy; retain a replacement record if these terms become unsuitable. No purchase made.
- Original ZIP, licence, models, editable adapted Blender masters and illustrated derivative remain private in `Backups/IdentitySlice_20261111/`. Do not commit or list them in the Creator Store.
- Retained authored topology: **4,288 triangles**, eight named mesh groups / 23 material primitives. Beveled head, twin socket braces, rivets, shaft collars, spiral wrap and pommel are retained.
- Adaptation: uniform overall height 3.85 studs; grip origin aligned to the shaft; original orientation converted to Roblox; coherent steel blue, pale edges, gold fittings, brown wood/wrap and navy recesses. No mesh reconstruction, subdivision, head reshaping or simplification.
- Uploaded model **94048862317867**, revision 1, owner **291892217**, Approved. Used in original universe **10773858644**. Installed at `ServerStorage.ToolPresentationAssets.AuthoredPickaxe`; `ToolPresentationBuilder` is still the sole tool template/display recipe. The rejected `TreasurePickaxe` live source was removed.
- Templates, equipped clones, workshop display and equipment previews derive from the same fitted model. StrikeTip is fitted to this mesh in `MotionClips`; cadence, damage, reach, prices and the existing grip/animation/contact solver are unchanged.

## UI artwork

- Existing original illustrated atlas `assets/ui/playful/treasure-icons.png` remains the shared visual family. New matching pickaxe illustration generated with built-in `image_gen`, using the inspected model render and atlas style. Prompt: [icon-prompt.json](icon-prompt.json).
- New image **89389342218586**, revision 1, owner **291892217**, Approved. Master copied into the private workspace recovery folder. It is tab/icon artwork; it does not replace the functioning 3D tool.
- New `SimulatorStyle` provides outlined type, illustrated edge buttons, layered rims and restrained patterned surfaces for this bounded slice. Other screens retain their existing content/design until review.

## Recovery / repeatable fitting

Original sample: `Backups/IdentitySlice_20261111/baziliq-free-sample.zip`; original terms: `baziliq-sample/LICENSE.txt`; final editable master: `AuthoredPickaxe-Fitted.blend` (initial import retained as `AuthoredPickaxe.blend`); generated image: `pickaxe-icon.png` in the same private directory. `prepare_pickaxe.py` records the Blender import/export operation. `geometry.json` records non-mesh bounds/material metadata; `fit_pickaxe.luau` applies the recorded Roblox fitting. Upload staging GLB/PNG files are explicitly ignored. Native before/final copies preserve the complete imported asset instances.
