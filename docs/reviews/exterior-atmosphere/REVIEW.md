# Atmosphere and minimum-quality correction — v191

Published **v191**, original place **94763223427049**, **2026-11-10 18:51:53 UTC**; Studio publication log confirms the place ID and version. Branch `planning/development-foundation`, clean starting commit `3b81d8e4b8c64050ace4010e0d12943d7037ba5c`. No newer local work was overwritten. Studio's loaded PlaceVersion still read 184; the existing v188 publication log, native bytes and synchronized sources established the actual starting checkpoint. Implementation/evidence commit: [9d5abc9211776ec7b14e8f9dd3fcc86ec29608bf](https://github.com/alrimii/vesper-excavation/commit/9d5abc9211776ec7b14e8f9dd3fcc86ec29608bf).

## Actual runtime evidence

- Matched above-egg valley: [minimum Studio quality 1](correction-low-runtime.png) / [maximum Studio quality 21](correction-high-runtime.png).
- [Other above-egg direction](correction-north-runtime.png) and [normal floor](correction-floor-runtime.png), quality 21.
- [Fixed-camera motion video](correction-motion-runtime.mp4): **14.85 seconds encoded**, from 300 actual frames captured at 20 fps over 15 seconds. **No loading frames**, camera movement, generated frames or speed-up. [Recording inspection](correction-video-inspection.json), [frame timings](correction-recording-timing.json), [motion observations](correction-motion-observations.json).

Same [saved cameras](cameras.json), FOV 70°. One runtime session **18:46:58–18:49:39 UTC**, approximately 161 seconds. A bounded mist-height/width/color/opacity correction was accepted during this session, persisted to canonical sources and rebuilt in the Edit place afterward. No later art changes. Render and Edit quality restored to Automatic. No gameplay actions, grants, mining, navigation, purchases or data manipulation. Existing preview credits in the HUD are unchanged.

## Causes and correction

**Mist:** former ribbons were 835–1,990 studs away; the valley examples were 1,098–1,990 studs away and only 56–76 studs tall. Ground probes showed their centers above terrain, so burial was not the main cause. Through the existing SmoothPlastic glazing, an untextured diagnostic ribbon appeared while the old textured mapping did not. Switching to **Stretch / TextureLength 1** restored the mask; the asset fetch reported Success. The old long Wrap mapping, screen coverage and distance jointly made the effect ineffective. Eight existing ribbons are replaced with nearer, broader lowland/foothill ribbons, stronger neutral opacity/color and the same slow continuous client motion. No extra ribbon layers, global haze pulses or glass changes. Native clouds retain the same cover/density; steady GlobalWind is **(12,0,5)**. Atmosphere density/haze are unchanged from v188.

**Scenery:** StreamingEnabled is false. Changing only Edit quality reproduced disappearance of representative mountains and trees. The same mountain asset rendered at quality 1 after being scaled/moved closer. This is evidence of quality/distance rendering behavior, not a missing generator or streaming diagnosis. Final runtime contains all five mountain instances and 168 trees; low quality visibly retains the principal groups and valley ridge. Mesh fetch status reported None despite the rendered geometry, so that status alone was not treated as loading failure.

`ExteriorScenicDistanceBuilder` now idempotently adapts the **existing five massifs and 168 trees** from saved original transforms: principal massif centers at 850-stud radius, valley ridge 630, trees approximately 460–540. Mountain bases extend below the existing grade; tree bases are seated against the unchanged ground mesh. The scenic buffer remains outside the dome. Same mesh/texture IDs and Automatic fidelity; no duplicate overlapping representations, panels, custom LOD engine or quality-forcing script. The full scenery recipe calls this correction after placements, so historical layout data cannot silently recreate the old distant arrangement. The full recipe was not executed during this pass.

## Observed result and limits

Mist is now plainly visible over the valley and across mountain foothills in both quality captures, with recognizable peaks/trees. The clean recording shows gradual mist-shape drift; cloud movement is considerably subtler. All 300 recorded frames were checked for temporal continuity; no abrupt effect reset was identified. Screenshots and first/middle/last recorded frames were visually inspected. The sampled mist region changes substantially more than the static interior; these image differences are not performance measurements.

Low quality retains the principal silhouettes and forest masses, while fine foliage/cloud rendering differs. This is a single Studio comparison, not universal device or published-client verification. The scenic compression changes apparent depth and makes some mountain bases/footprints abrupt; the small central ridge sits lower than before. Floor frontage still hides much of the low mist. Interior colors/readability remain intact. No claim of owner approval, every-position perfection or mobile performance.

No meshes or textures were added: **452 exterior MeshParts, 92 unique mesh IDs**, same source triangle estimate (~1.196 million; not a frame-cost measurement). Eight beams/16 segments each remain about 256 ribbon triangles. Existing 128² texture **137322546799462**, owner **291892217**, is reused; its engine-derived private source/provenance remains as recorded in the [v188 review](https://github.com/alrimii/vesper-excavation/blob/3b81d8e4b8c64050ace4010e0d12943d7037ba5c/docs/reviews/exterior-atmosphere/REVIEW.md). No resource downloads/installations. Four changed sources match Studio and pass scoped StyLua/Selene checks. [Client/source evidence](correction-verification.json).

## Recovery and preservation

Private root: `C:\Users\BOSS\Desktop\egg\Backups\AtmosphereCorrection_20261110\`.

- Before: `ComingSoon_94763223427049_before.rbxl`, 6,621,223 bytes, SHA256 `95d3f4b19fad4db0e71561efe08b4cb576ef4c81d8a906d7f9daa107bb03c322`.
- Final: `ComingSoon_94763223427049_final.rbxl`, 6,629,454 bytes, SHA256 `4581529450e7f15406ea24eedd05d21185658cb4c4c688d20294577786f84d11`.
- Prior/final sources, full-window captures, original AVI, frame inspection and publication log retained privately. Recovery places were never opened as alternate targets.

Ground/grass, dome/glazing, interior, egg/hoist/access, HUD and every gameplay/economy/progression/reward source are unchanged. Player records and fixed generation `VesperDiscovery_FreshStart_20261110` are preserved. Joining stays closed. Interior/gate/road work remains deferred in the existing roadmap. Studio is stopped in Edit; artwork frozen for owner review.
