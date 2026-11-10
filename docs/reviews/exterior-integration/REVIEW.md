> Subsequent checkpoint: [v184 ground/grass and ridge integration](../exterior-grass/REVIEW.md). The record below describes v182, including its then-unresolved ridge gap.

# Landscape integration and balance — v182

Published **v182**, original place **94763223427049**, **2026-11-10 17:18:25 UTC**. Branch `planning/development-foundation`. Started from clean `edff414d722db3f0b0ea8b242cfc879cf11e8df9` / v180; the initial native snapshot is byte-identical to the prior final recovery file. Publication is confirmed by the Studio log's `publishType=1`, “Published new changes” and “Add publish notes to v182”. Implementation/evidence commit: [c0b92621421700a3bf6fbc2bafb292014c768256](https://github.com/alrimii/vesper-excavation/commit/c0b92621421700a3bf6fbc2bafb292014c768256). A following documentation-only commit records this identifier.

The owner sees substantial improvement and likes the existing direction. This pass integrates those assets; it does not restart the exterior or claim approval of this new result. Joining remains owner-confirmed and closed. All final captures show one frozen scene state; no art changes followed capture.

## Camera evidence

The dome footprint is approximately **698.54 × 698.54 studs**. Highest continuous access `TerminalDeck` walking surface: **Y 90.6425**. The above-egg camera is **(2.95433,95.6425,−23.49734)**, five studs above that surface, with the egg crown at approximately Y 93.84. It is substantially higher than v180's earlier Y 64 capture. Valley target: **(1500,75,1850)**. Interior FOV **70°**; exterior overview FOV **60°**. [Named positions, targets, up vectors and recorded transforms](cameras.json). No scene objects were hidden.

| Required evidence | Actual captures |
| --- | --- |
| Same above-egg camera, before/after — **Edit mode** | [Before](before-above-egg-valley-edit.png) / [After](after-above-egg-valley-edit.png) |
| Vertical full-layout overview — **Edit mode** | [Before](before-overhead-edit.png) / [After](after-overhead-edit.png) |
| Vertical perimeter overview — **Edit mode** | [Before](before-perimeter-overhead-edit.png) / [After](after-perimeter-overhead-edit.png) / [closer perimeter detail](after-perimeter-detail-edit.png) |
| Two opposing oblique overviews — **Edit mode** | [East side](after-oblique-east-edit.png) / [West side](after-oblique-west-edit.png) |
| Highest access deck toward valley — **runtime** | [above-egg-valley-runtime.png](above-egg-valley-runtime.png) |
| Same high position, other principal directions — **runtime** | [North](above-egg-north-runtime.png) / [West](above-egg-west-runtime.png) / [South](above-egg-south-runtime.png) |
| Normal floor height through glazing — **runtime** | [floor-runtime.png](floor-runtime.png) |

The before/after Edit comparisons use identical transforms/FOV and 1525×752 captures. The existing purple Edit egg proxy remains visible and obscures some interior surfaces; the runtime views show the actual egg, walkway and room roofs. Edit images are not runtime proof.

One **66.3-second capture-only Play session**, approximately **17:16:17–17:17:23 UTC**. Five prepared views; camera positioning worked. No navigation, mining, purchases, grants, rewards, round changes, device switching or persistence tests. Visible preview credits are unchanged pre-existing Studio-only behavior.

## Implemented changes

- **Preserved mountains:** the same five instances of the existing 13,999-triangle AlpineRange mesh. Selective changes retain a stronger northwestern range, a secondary eastern flank and quieter western/southern directions, with the valley opening intact. No primitive replacement mountains or new source selection.
- **Placement/scale:** distances from center changed **2100→2250**, **1850→2070**, **1900→2350**, **2210→2850**, **3520→4600** studs. Vertical scales changed **1.70→1.43**, **1.75→1.62**, **2.00→1.30**, **1.50→.90**, **1.10→.75**. Selected rotations also differ; widths remain unchanged. [Exact configuration](../../../assets/environment/exterior-integration/composition.json).
- **Grading:** continuous ground receives gentle foreground variation, asymmetric low foothills and an irregular low valley. Terrain inside the dome footprint stays at Y −8. No lift of the entire exterior or enclosing ridge. The 12,000-stud ground extent remains; 64 tiles now have 512 triangles each, with shared analytical normals to avoid boundary-lighting seams.
- **Materials:** one continuous 1K meadow/woodland/soil color map replaces the single ground color. Mountain/buttress source maps are softened to 512 pixels with reduced contrast/desaturation; existing UVs and silhouettes remain. Global lighting, Atmosphere density .18/haze 1, sky/cloud settings, glass tint and all dome geometry are unchanged. Two subtle valley wisps are reseated above the new grade.
- **Vegetation:** all **102 original trees + 88 meadow objects** retain their horizontal positions, sizes, rotations and colors; only ground seating changes. Added **94 trees + 104 low plants/rocks** in irregular woodland links, valley-bank patches and sparse near pockets. Tree centers span approximately **690–3315 studs** from the center; the open buffer remains. A few low plants occupy the foreground without introducing a road or gate.
- **Targeted cleanup:** removed the **seven `RockyFoothills.StrataCliff` open-backed scan-sheet placements** after the grading exposed thin fragments. Their creation calls are removed from the active recipe; source/template remains preserved. Seven buttress placements are reseated using surrounding ground minima. Replaced the v180 flat ground tiles; their original templates remain retained. No other superseded assembly was found in this focused inspection. The five older retired exterior entry points remain disabled.

Active recipe: `ServerStorage.VesperTools.ExteriorCompositionBuilder`; generated data: `...ExteriorIntegrationLayout`; new grading library: `ServerStorage.ExteriorIntegrationAssets`. The original rock and vegetation libraries remain. [Sources, actual IDs, preparation, material maps and rights](../../../assets/environment/exterior-integration/README.md).

## Verification and limitations

Protected non-exterior geometry remains **14,767 BaseParts**, identical property signature **247828899** before/after. Both native source readbacks match disk. StyLua and scoped Selene checks passed with zero errors/warnings. Final exterior inventory: **466 BaseParts**, all noncolliding/nonquerying/nontouching; [counts](scene-inventory.json). Estimated instantiated source geometry is **1,226,210 triangles**, up from v180's 750,035 because of richer planting and grading. This is not a measured rendering cost or mobile-optimization claim. No performance profiling was performed.

Visible shortcomings, frozen for owner review:

- **Runtime valley gap:** the far range at radius 4,600 is visible in Edit but absent from the final runtime valley capture, leaving a blue horizon beyond the low terrain. This requirement remains unresolved. Streaming is disabled in the place; the cause was not established during the capture-only session. No extra session or post-capture correction was made.
- The overhead/oblique views still reveal discrete mountain footprints, some abrupt/clipped base transitions, and the outer square ground boundary. The full-layout overhead is intentionally distant; the closer perimeter view supplies readable spacing. The inaccessible outer boundary is not finished as a full outdoor world.
- Grading and planting now connect more of the layers, but broad sparse areas remain. Some connecting trees still read as loose chains, and the meadow color variation is subdued through the dome. Mountain textures are visibly soft; their snowy/rocky character still differs from the foliage style.
- Preserved frontage continues to hide lower scenery from normal floor height. Wide overviews retain the existing atmospheric haze; lighting was not altered for screenshots.
- Published-client scenery, every reachable angle, multiplayer, persistence, gameplay regressions and device performance were not verified. No visual approval is claimed. Player records and fixed generation `VesperDiscovery_FreshStart_20261110` were not edited; no runtime gameplay source changed.

Deferred gate/road, dome proportions, interior/frontage, room/shop/UI/tree and progression/content work remains recorded in [the roadmap](../../DEVELOPMENT_PLAN.md), not implemented. Studio finished stopped in Edit.

## Private recovery

Root: `C:\Users\BOSS\Desktop\egg\Backups\ExteriorIntegration_20261110\`.

- `ComingSoon_94763223427049_before.rbxl`: **6,083,178 bytes**, SHA256 `C0CA5188F94AF56DA4640789F6036AFD1CD84FF16C29212092D7811A81FDEC53`.
- `ComingSoon_94763223427049_final.rbxl`: **6,235,709 bytes**, SHA256 `807EBC8A19900CB3577647ECD6D3BAC2F060CA2F32D861631A84433950C9CC1A`.
- `src-before/`, `src-final/`, `asset-records-before/`, `assets-before.blend`, `exports-before/`, `old-planting.json`, `integrated-grading.blend`, `exports/integrated-grade-normals.fbx`, actual texture maps, full-window captures and publication evidence.

Native copies were never opened as alternate playable targets. These are development recovery files, not player-progress backups.
