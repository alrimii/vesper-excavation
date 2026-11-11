# Treasure interface artwork — 2026-11-11

One original cyan/purple/gold cartoon family replaces the rejected parchment/mineral direction. `treasure-icons.png` and `skill-icons.png` are actual generated RGBA masters, not borrowed pack artwork. Full prompts and tool identity are preserved in [prompts.json](prompts.json). The built-in image-generation tool produced twenty interface illustrations and eight skill illustrations. Planned skills reuse their discipline's illustration and remain explicitly planned/unpurchasable.

Roblox image uploads to owner **291892217**: **132558544808738** (twenty icons) and **82521932688624** (eight skills), both revision 1, approved, active and published. See [uploads.json](uploads.json). `InterfaceKit` and `SkillArt` contain the actual post-upload atlas cropping, including Roblox's 1024-pixel resampling. Original PNGs and prompts are retained; no invented asset IDs or bitmap substitutes for 3D tools.

Actual previews were inspected before selecting this family:

- [Craftpix cartoon GUI category](https://craftpix.net/categorys/cartoon-gui/): Jungle Cartoon UI, Cartoon UI Elements Mini Kit and Casual UI Vector Game Asset Pack preview images.
- [Second Shift Studio mining icons](https://secondshiftstudio.itch.io/mining-icons-pack): actual mining-tool/ore preview images from the itch.io page.
- [Kenney UI Pack](https://kenney.nl/assets/ui-pack): the direct page returned HTTP 403; the actual official Kenney preview was inspected through its public image listing/official social preview. No claim is made that the blocked page was viewed successfully.

Exact retrieved Craftpix/itch preview URLs are retained in [reference-preview-sources.json](reference-preview-sources.json). Reference images remain private and were not copied into the game or Git. No reference pack was purchased or treated as automatic approval.

The repository's `docs/reviews/interior-phase-1/17-legacy-navigation-menu.png` was inspected. It records rejected legacy navigation, not a separately approved placement reference. No missing reference was claimed as viewed. The delivered edge navigation leaves the center of the world open.

The shared foundation is `InterfaceTheme` + `InterfaceKit`: rounded outlined surfaces, substantial buttons, original illustrated icons, FredokaOne display numbers/titles, concise supporting text, safe-area modal ownership and reduced-motion-aware pointer feedback. Existing validated action/data bindings are retained. `preview-slice.luau` is an Edit-only temporary view built from production components; it is never installed in the published place.
