# Existing egg shell: geometry and damage inspection

Read-only inspection accompanying the creature/timer delivery, published **v257** in original place **94763223427049**. **No egg geometry, materials, generators, targeting outlines or gameplay were changed.** Runtime pictures use the same isolated Studio session as that delivery; no additional egg-only session was started.

## Actual construction

The current `Workspace.VesperLab.Egg.Sections` contains **8,160 section Models**, each with one anchored **MeshPart named Plate**: 68 columns × 40 staggered rows × **3 concentric layers**, or **2,720 pieces per layer**. Bottom rows 0–9 are permanent: 680 per layer / **2,040 total**. There are **6,120 breakable sections**, 2,040 per layer. This is a segmented curved shell, not a single sphere or an assembly of flat Parts.

The current surface is an asymmetric egg of nominal radius **40.8**, height **104.04**, base **(0, −10.2, 0)**. Actual MeshPart bounding-box corners span approximately **82.9605 × 104.04 × 82.9605 studs**, from y −10.2 to 93.84. The lower cap is below the lab floor. Rotational radius follows `40.8*sin(phi)*(1 + 0.18*cos(phi))`; vertical height follows `104.04/2*(1-cos(phi))`, translated by the base. It bulges below its midpoint and tapers at both ends.

The controlling authored implementation is [expansion-v3/build.py](../../../src/models/expansion-v3/build.py), its [120-template manifest](../../../src/models/expansion-v3/egg-manifest.json), [uploaded mesh IDs](../../../src/models/expansion-v3/uploaded-assets.json) and [InstallExpansion](../../../src/InstallExpansion.luau). Three layer-specific meshes are authored for each row; copies are rotated around the egg for all 68 columns, with alternating half-column stagger. `ServerStorage.EggPlateLibrary` and `VesperShared.EggAssetPreload` each actually contain **120 templates**. Example outer row 20 mesh: **rbxassetid://73491009726523**, 240 authored triangles; its live rotated Plate bounding size is approximately **1.456 × 5.489 × 3.744**. That first number is a curved bounding-box extent, **not shell thickness**.

Historical paths also exist: [EggBuilder](../../../src/EggBuilder.luau) / [ImportEgg](../../../src/ImportEgg.luau), [older build_egg.py](../../../src/models/build_egg.py), RestoreDenseShell and FitEggAndAccess. Several saved descriptive attributes and the embedded `EggManifest` still describe the **older 40×24 / 72-template** shell. They are not current counts. The ExpansionV3 source/manifest and actual models agree on 68×40 /120; running an older authoring entry without updating it could recreate a different egg. Nothing was regenerated here.

## How neighbors fit

Each piece begins as a six-sided cell in angular/row coordinates, with offsets `(0,−2/3),(.5,−1/3),(.5,1/3),(0,2/3),(−.5,1/3),(−.5,−1/3)`. Each triangular wedge is subdivided **four times** before projection onto the egg surface. Front and back are therefore curved, triangulated surfaces, with smooth outer shading, rather than a flat hexagon forced onto a curve.

Adjacent cells use the same surface equation and row staggering. Authoring contracts cell boundaries by **0.996**, leaving deliberate narrow seams; the visible lighting/finish emphasizes the six-sided boundaries. The mesh closes the side walls and back. The next layer is offset inward along the analytic normal by **0.55 studs**. Each plate's front-to-back authored depth is **0.538** (`pitch − .012`), leaving a nominal **0.012 gap** before the next layer. This is a normal offset, not simple concentric scaling. At the poles, angular spacing collapses and triangles become degenerate/omitted.

Exact current vertex-to-vertex seam widths, overlap tolerances around pole/row junctions and collision hull fit were **not numerically measured**. The source intentionally separates edges; the pictures show actual adjacent fit. World-space material pattern and independently shaded cell edges contribute to the segmented appearance. A material replacement alone cannot change those boundaries or the shape of damage openings.

The live outer Plate uses SmoothPlastic plus **MaterialVariant VesperPearlShell**, sampled color approximately (245,224,184), no TextureID and no child SurfaceAppearance. Its actual variant has ColorMap **115768884596558**, RoughnessMap **112092866313293**, MetalnessMap **77145586316101**, empty NormalMap, **StudsPerTile 28**. Inner samples use `VesperLivingMembrane`, tinted jade on layer 2 and blue on layer 3. [EggFinishes](../../../src/EggFinishes.luau) / [ApplyEggFinish](../../../src/ApplyEggFinish.luau) describe an earlier SurfaceAppearance finish; those definitions do not exactly describe today's sampled live material setup. No finish was reapplied.

When an outer piece is removed, the jade mesh already behind it becomes visible through the opening. Closed remaining shell side walls form the rim; more removal reveals neighboring jade cells. The jade is visible but cannot be mined until **the entire active outer layer** is cleared. The third layer lies another 0.55 inward; the reveal chamber/veil is farther inside. There is no automatic bevel/cap dynamically rebuilt around a new hole.

## Damage and cracks, separately from targeting

[ExcavationService](../../../src/ExcavationService.luau) owns HP, break state and hit validation. Base layer durability is **180 / 240 / 300**, multiplied by the current egg's durability modifier and exposed through MaxHP. **The original whole Plate remains the authoritative collision/raycast object during partial damage.** Client cracks are cosmetic and do not make a new server hit mesh.

[ProgressiveFractureBuilder](../../../src/ProgressiveFractureBuilder.luau) runs once per server before excavation readiness. For outer breakable rows 10–39, it calls `GeometryService.FragmentAsync` on a neutral copy using **28 deterministic uneven sites** per template and stores fitted cut pieces plus RelativeCFrame, pivot, crack seed, normal and direction metadata. It requires at least 12 results; **28 fragments were observed for runtime row 20**. Combat does not perform a new CSG operation. The persisted fracture library has 120 row/layer groups; outer groups are replaced at startup, while inner/persistent source fragments remain in their existing path. [InstallOuterShellStage1](../../../src/InstallOuterShellStage1.luau) records the prior 3-fragment/stagger correction, not the final per-server outer fragment count.

[ShellMotion](../../../src/ShellMotion.luau) responds to HP/Intact/Exposed:

1. Intact: show the original authored Plate.
2. Any outer damage: hide that Plate **locally**, fit cosmetic fragments in `LocalShellReactions.Stress_<SectionId>` and drive stress from `1−HP/MaxHP`. Inner layers use the existing 0.92 health threshold. This effect is distance/budget limited (95 studs, 96 active stress pieces).
3. Increasing damage opens actual fragment boundaries progressively from the hit region and deterministic seeds. Small outward separation, local pivot rotations/loosening and damped impulses reveal cut/internal faces. Current outer gaps are bounded by approximately `.025*opening + .075*localDamage*opening`, with size scaling; loosening begins around 55% stress and outer rotation is capped around 3.5°. Inner behavior uses CrackGap .14 and StressTilt 7°. This is **geometry separation**, not a targeting outline or a sequence of crack decals.
4. HP zero: server sets Intact false, disables Plate collision/query and makes it transparent, while retaining the section object/identity. Existing Fragments feedback/debris releases the cosmetic pieces and settles rewards. Stress copies wait briefly for release (up to .35s) and clean up. The underlying layer remains visible. Exposed membrane also has an existing subtle cosmetic pulse.

There are empty ShellIntact/CrackLight/CrackHeavy texture settings in [ExcavationConfig](../../../src/ExcavationConfig.luau); current damaged shell finish does **not** swap those maps. This distinction matters for an art replacement: improving a crack texture would not fix current separated fragment fit.

**Targeting is a separate presentation.** [Targeting](../../../src/Targeting.luau) creates a Highlight with FillTransparency 1, OutlineTransparency .05 and Occluded depth. It follows the Plate or stress model, changes color for valid/distant/confirmed states, and is suppressed on damaged outer stress pieces and while using the charge. A separate local hit anchor, billboard precision ring/dot, cursor crosshair and target status/HP UI show aim/contact. These are not shell geometry or crack lines. The disliked targeting visuals were only inspected and were not changed.

## Gameplay contracts an art replacement must keep

- Stable Model IDs **L&lt;layer&gt;_R&lt;row&gt;_C&lt;column&gt;**, Layer/Row/Column/SectionId/Resource/Permanent/Center/HP/MaxHP/Intact/Exposed attributes, and a discoverable authoritative **Plate** under each section.
- Server registration and round reset of all sections, permanent lower rows, collision/query rules and direct head-to-contact ray validation. Reach is 16 studs plus existing tool-specific grace, not the cosmetic fragment positions.
- Existing pickaxe/drill/charge contact, precision distance from **Section.Center**, charge rear-contact/normal placement, server tool ownership/cadence/pending guards, rewards and contribution settlement. Center is a surface contact reference, not the curved mesh's bounding-box center.
- Global outer → membrane → matrix progression: 2,040 breakables per layer; inner visibility is not permission to hit it early. Completion thresholds are currently RemovedFraction 1 and DeepLayerFraction 1, with 30-second reveal and automatic reset.
- Round state and creature reveal timing, collision/access around the egg, fitted fracture/debris metadata and cleanup. A new visual must not cover holes with an unbroken second skin or create queryable duplicate fragments.

Config exposes dimensions, rows/columns, pitch, base, permanent rows, durability/colors and cosmetic fracture settings. **Changing those values alone will not reshape uploaded MeshParts.** ExpansionV3's mesh generator hard-codes the same dimensions, `.996` inset and four subdivisions; runtime ProgressiveFractureBuilder also hard-codes 40 rows /52.02 half-height /40.8 radius /.18 asymmetry. Fracture relative transforms, row libraries, preload references, saved Section.Center values and access geometry depend on the present shape. Config SeamInset .009 belongs to a fallback path; it is not the .004 contraction used by the current authored meshes.

## Practical direction for a later art task

The most practical substantial improvement is **fitted replacement segment meshes authored from one continuous master shell**, partitioned along the existing 68×40 staggered section boundaries. Share edge positions/normals before introducing only a deliberate small seam, preserve inward thickness and closed rim/cut faces, then derive matching damaged fragments from each segment. Keep the 120 rotational row/layer template convention, existing Section IDs and authoritative colliders/attributes; replace the visual/fracture libraries together. Recalculate the matching surface centers/relative transforms only as required, and update both authoring and runtime dimensional assumptions coherently.

Materials on existing geometry would be a lower-cost finish pass, but cannot fix cell silhouette, raised/separated seams or how damage fits the neighbors. Unrelated replacement hex meshes would risk inconsistent curvature and exposed edges. One unpartitioned shell mesh would conceal removed pieces and break the working section/damage presentation. A continuous master **partitioned into fitted pieces** best addresses the owner's stated geometry concern while retaining server gameplay.

Unknowns: no complete per-vertex seam/collision audit, deepest-layer removal/reveal was not exercised, and no new shell artwork was approved or prepared. The cause of content-representation warnings during fracture/debris was not diagnosed in this documentation task. These findings describe current code/models and observed outer damage only.

## Actual pictures

- [Intact adjacent shell pieces](intact-adjacent.png).
- [Intermediate damage: inspected section at 75/180 HP](damaged.png), after three ordinary memory-only pickaxe strikes. The HUD's separate aim indicator is on another intact piece; it is not the damaged section's HP label.
- [Removed outer pieces revealing the jade layer and surrounding shell edges](removed-membrane.png), after the same session's charge detonation. The blue outline on a neighboring intact piece is the separate targeting Highlight.

The owner's R15 avatar, a temporary invisible support and staged inspection cameras were used in memory only. No real save was used; the support/helpers are absent in Edit. [Companion implementation report](../creature-batch-and-charge-timer/REVIEW.md).
