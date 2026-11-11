# Crystal Triceratops — published v250

Delivered to original place **94763223427049** on `planning/development-foundation`. Studio is stopped in Edit; private native before/final backups are saved. No visual approval is claimed.

## Asset and catalog

Used the supplied **base_basic_pbr.fbx** and its explicit diffuse, metallic, roughness and normal maps, all 2048². Original files and textures are unchanged. **One mesh, 5,030 vertices, 10,050 triangles**, unrigged. No decimation or replacement geometry. Only uniform scaling, coordinate conversion and a floor-centered pivot with forward **-Z**. Crystal horns, frill, face, eyes, markings, feet and tail remain in the original mesh. [Source, import scripts, map assignments and asset IDs](../../../assets/creatures/rodin-crystal-triceratops/SOURCES.md).

No matching species existed: Crownback is a different armored drake. Added distinct ID **`crystal_triceratops`**, marked **TEST**, with zero bonus and no acquisition weight. The normal drop pool still contains exactly the original Crownback/Gilded/Ember entries at **80/18/2**; normal round species selection is unchanged. Normal acquisition is **not configured**. Existing IDs, ownership and stats are preserved.

Owner **291892217** receives this creature and its Journal entry through the existing isolated test profile. Join a fresh v250 server with Test Mode active, open **Creatures**, select **Crystal Triceratops**, and optionally assign a shelf. Switching Test Mode retains the existing safe rejoin/profile isolation behavior.

## Existing surfaces integrated

- Creature inventory/selection/detail and read-only Last Egg Results now resolve the entry's canonical model instead of always cloning Crownback.
- Journal/Discoveries uses the same model and registers the new entry.
- Central egg reveal supports the static source without fabricated limbs or a fake rig; the ordinary round selection remains Crownback.
- All twelve personal-room shelves, favorites/assigned display labels, and the shared cabinet factory for future room builds use the canonical reference, preserve supplied materials and face outward. Feet sit 0.01 stud above the support.
- The matching whole-model rendered icon is uploaded and registered. Existing creature screens use 3D previews; generic navigation icons are unchanged.

There is no existing selected-creature care/training renderer, world creature spawner or visual companion system to extend. Fixed Crownback research monitors and the empty ResearchGallery are preserved. No pet system or limb animation was added.

## Actual verification and limitations

One **221-second memory-only** desktop session checked visible appearance/assembly, preview framing, owner inventory access, normal server selection/shelf assignment, shelf contact, Journal and the existing reveal/results renderers. Reveal state, shell cutaway and synthetic zero-reward result history were **test-only staging**, visibly labeled in the captures; no egg settlement, real grant or acquisition was invoked.

An Edit check with an injected store verified owner test Load/Save performs **zero persistent calls**, new normal ownership/discovery defaults are zero, existing counts survive normalization, and the normal three-entry drop pool/round species remain unchanged. Eleven final canonical sources match Studio; StyLua and import-script syntax checks pass. All original source hashes match. Helpers are absent after Stop.

**Remaining material warning:** Roblox's generated TexturePack **133172177939408** reported `No asset content representation found while do_not_fallback_to_baseline is set to true`. All uploaded source assets and the pack report Approved; the creature's supplied color appearance is visible in the captures. A second, approximately **2-second** startup attempted only material preloading. MCP preloading returns Failure for both these maps and known-good approved drill assets, so it is inconclusive and does **not** establish that the compressed-pack warning cleared. Published-client material delivery remains unverified. No integration gameplay-script errors were observed; one inspection query initially omitted recursive mesh lookup and was corrected.

Other avatars/devices, multiplayer and live-client play were not tested. Static reveal scale is a presentation fit, not a new acquisition. No rigging, companion motion or owner visual approval is claimed.

## Actual runtime screenshots

- [Creature preview / owner memory inventory](creature-preview.png)
- [Owner room shelf](room-shelf.png)
- [Existing Last Egg Results — synthetic test staging](last-results-test-staging.png)
- [Existing central reveal model — memory-only shell cutaway](reveal-test-staging.png)
- [Journal / Discoveries — test staging](journal-test-staging.png)

[Delivery identity and private backup hash](delivery.json). Existing public servers were not shut down; use a fresh server running v250.
