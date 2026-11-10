# Focused moving-atmosphere checkpoint — v188

Published **v188** to original place **94763223427049**, **2026-11-10 18:28:59 UTC**, confirmed by Studio's `publishType=1`, place ID and “Add publish notes to v188” log. Branch `planning/development-foundation`; clean starting commit **a74146310a56e5341e7cb7144f4f34cfe66ca14f**, Studio loaded v184. Implementation/evidence commit: [8f1706c507b76b9645c64975b70901f9d513c559](https://github.com/alrimii/vesper-excavation/commit/8f1706c507b76b9645c64975b70901f9d513c559). Frozen after the single runtime session; no post-capture art corrections.

## Actual evidence

| Runtime view | Capture |
| --- | --- |
| Identical above-egg valley, minimum/maximum selectable Studio quality | [Quality 1](valley-low-runtime.png) / [Quality 21](valley-high-runtime.png) |
| Other above-egg direction, quality 21 | [North](north-runtime.png) |
| Normal room/floor approach, quality 21 | [Floor](floor-runtime.png) |
| Fixed above-egg camera, normal playback speed | [MP4 recording](valley-motion-runtime.mp4) |

[Saved cameras](cameras.json), unchanged from v184: high eye `(2.95433,95.6425,-23.49734)`, FOV 70°. No scenery hidden. One session **18:23:02–18:26:15 UTC**, approximately **193 seconds**. No mining, movement/navigation, purchases, grants, lifecycle triggers, data changes or device switching.

Quality setters reported a capability error even though the underlying rendering value changed. The final pair was therefore explicitly selected using Studio's visible **1…21** quality dropdown and read back as **Level01 / Level21**. These are Studio renderer endpoints, not a claimed player-menu 1/10 comparison. Original Automatic was restored; player SavedQualitySetting remained Automatic. [Readbacks and preservation evidence](verification.json).

**Video limitation:** 240 viewport frames recorded at 20 fps over 12 seconds; MP4 duration **11.85 seconds**, normal speed, fixed camera. The first **4.3 seconds** show the existing joining overlay, leaving approximately **7.7 seconds of scenery**. Thus this is partial motion evidence, not a complete 10–15 seconds of unobstructed scenery. No second session was started. Frame timing is [recorded](recording-timing.json); [duration/loading inspection](video-inspection.json). The installed VLC ultimately encoded the recorded AVI after its direct screen recorder failed. No installation, generated frames, camera motion or speed-up.

## Implemented approach

- Replace the two old `ValleyWisp*.LowValleyHaze` beams with **eight localized lowland/foothill ribbons**, each one Beam/two Attachments/one invisible noninteractive host. No particles, transparent scenery panels or added landscape geometry.
- One local presentation script updates shape/density at **10 Hz**, with independent continuous phases and slow native texture advection. No spawn/despawn/reset cycle or server replication loop. Global haze/lighting never pulse.
- Existing native Clouds: cover **.58→.52**, density **.62→.39**, pale neutral color; steady GlobalWind **(0,0,0)→(7,0,3)**. Initial inspection found no existing Smoke/Fire or wind-sensitive emitters. Static imported vegetation is unchanged.
- Stable Atmosphere density **.18→.205**, haze **1→1.2**, neutral green-gray color; offset .15/glare 0 retained. Brightness, exposure, ambient lighting, sky images and glazing untouched. Atmosphere is global, not falsely described as spatially restricted.
- Reused the installed Roblox `smoke_main.dds` mask, converted privately to **128² PNG** with alpha normalized ×3 and full-ribbon texture spacing. Actual image **137322546799462**, owner **291892217**. Engine-supplied source is not claimed CC0 and is not redistributed in Git. No downloaded weather framework or external asset library.
- Active sources: `ReplicatedStorage.VesperShared.ExteriorAtmosphereConfig`, `StarterPlayer.StarterPlayerScripts.ExteriorAtmosphereMotion`, and Edit-only `ServerStorage.VesperTools.ExteriorAtmosphereBuilder`. `ExteriorCompositionBuilder` now delegates atmosphere creation to that recipe; its old wisp creation block is removed. The scenery builder was **not executed** during this pass.

Used official guidance for [Atmosphere](https://create.roblox.com/docs/environment/atmosphere), [Clouds](https://create.roblox.com/docs/environment/clouds), [GlobalWind](https://create.roblox.com/docs/environment/global-wind), [particles](https://create.roblox.com/docs/effects/particle-emitters), [performance](https://create.roblox.com/docs/performance-optimization/improve) and [surface transparency](https://create.roblox.com/docs/art/modeling/surface-appearance). The supplied old particle URL was unavailable; its current official effects URL was read.

## Outcome and limits

- **Low-quality requirement remains unmet:** at quality 1 the renderer removes most distant trees/mountains, including the ridge, although the ridge instance exists on the client. At quality 21 the ridge and mountain composition remain visible. No stronger fog, quality requirement or out-of-scope landscape relocation was added to hide this.
- Mist remains **too faint from the required player cameras**, and the floor frontage obscures lowlands. The intended clearly readable mist identity is not established by these captures. The local animation runs and attachment positions change; the short partial video does not establish clearly perceptible mist **and** cloud motion at normal playback speed. No visual-success claim is made from still images.
- Interior colors/readability remain intact in the captured floor/high views. No dense indoor fog or glass change. The previously recorded grass, mountain footprint and frontage defects are untouched.
- Eight beams ×16 segments (about 256 ribbon triangles), eight hosts, sixteen attachments and one small shared texture replace two beams/two hosts. No measured before/after frame costs, mobile claim, multiplayer or published-client verification.
- All **15,219 non-mist BaseParts** retain property signature **834804654**, including landscape and protected laboratory geometry. Gameplay/economy/progression/rewards, player data and fixed generation `VesperDiscovery_FreshStart_20261110` are untouched. Joining remains closed. Scoped source lint passed.

## Recovery and next milestone

Private root: `C:\Users\BOSS\Desktop\egg\Backups\ExteriorAtmosphere_20261110\`.

- `ComingSoon_94763223427049_before.rbxl`: **6,619,325 bytes**, SHA256 `86C9AD7AF7C4D96B0058B4BDAC0922548CB62D954C0F6519F9AB89D4A4AEDCA5`.
- `ComingSoon_94763223427049_final.rbxl`: **6,621,223 bytes**, SHA256 `95D3F4B19FAD4DB0E71561EFE08B4CB576EF4C81D8A906D7F9DAA107BB03C322`.
- Prior builder source, final atmosphere sources, private texture derivative, full-window evidence, original AVI/frame timestamps and publication log. Recovery copies were never opened as playable targets.

The detailed dome/interior rebuild, room/frontage/circulation work, selective vines/planting, gate and scenic road are recorded in [the existing roadmap](../../DEVELOPMENT_PLAN.md), not implemented. Studio is stopped in Edit; stop for owner review.
