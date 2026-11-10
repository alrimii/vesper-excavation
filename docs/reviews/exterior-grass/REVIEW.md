# Exterior ground, grass and ridge integration

Original place **94763223427049**, branch **planning/development-foundation**. Began from clean **e92ab1134060db758672f0a14322f8e795690b5d / v182**. The fresh native backup is byte-identical to the v182 final recovery file. The accepted landscape direction and useful source assets are retained. Joining remains owner-confirmed and closed.

Published **v184** to the same original place at **2026-11-10 17:54:17 UTC**, confirmed by Studio's `publishType=1`, successful place ID, “Add publish notes to v184” and “Published new changes” log entries. Implementation/evidence commit: [d169e2afce76e6a84d87aab3b5aeb124d2a6aceb](https://github.com/alrimii/vesper-excavation/commit/d169e2afce76e6a84d87aab3b5aeb124d2a6aceb); a following documentation-only commit records this identifier. Artwork is frozen following the one runtime session and final Edit captures. No post-capture art correction was performed; the validated runtime ridge transform was synchronized exactly into Edit/source before the Edit captures.

## Actual camera evidence

All interior camera transforms and FOVs are reused from v182. Highest-access eye position **(2.95433,95.6425,-23.49734)**, FOV **70°**; exterior overviews **60°**. No objects were hidden. [Named camera data](cameras.json).

| Evidence | Actual screenshots |
| --- | --- |
| Above-egg valley, comparable **runtime** views | [Before: v182](../exterior-integration/above-egg-valley-runtime.png) / [After](above-egg-valley-runtime.png) |
| Above-egg valley, comparable **Edit** views | [Before](before-valley-edit.png) / [After](final-above-egg-valley-edit.png) |
| Other principal directions, same high position — **runtime** | [North](above-egg-north-runtime.png), [West](above-egg-west-runtime.png), [South](above-egg-south-runtime.png) |
| Normal floor / room approach — **runtime** | [Floor](floor-runtime.png) |
| Full top-down exterior — **Edit** | [Overview](final-overhead-edit.png) |
| Closer top-down perimeter, comparable — **Edit** | [Before](before-layout-edit.png) / [After](final-perimeter-overhead-edit.png) |
| Opposing oblique exterior views — **Edit** | [East](final-oblique-east-edit.png) / [West](final-oblique-west-edit.png) |
| Supplementary grass detail outside dome — **Edit**, not player-view proof | [Grass detail](final-grass-detail-edit.png) |

The existing purple egg proxy remains visible in Edit comparisons. Runtime captures show the actual egg, roofs and walkway. No generated imagery or Blender renders substitute for Studio evidence.

## Ridge diagnosis and correction

**Confirmed:** `Workspace.VesperLab.DecorativeExterior.SeparatedRockMassifs.RockMassif5` exists on the client. All **454** exterior parts and all **16** grass patches replicated. Streaming is **false** in Edit and on the client. The ridge has Transparency **0**, LocalTransparencyModifier **0**, the same AlpineRange mesh as the visible other massifs, and the same face orientation/material. Texture fetch reported Success; the mesh-ID fetch-status API reported None, which is not treated as a load failure because that shared mesh renders on the other massifs. No runtime scenery recreation/deletion path was found; the active recipe is Edit-only.

In the **same session/camera**, restoring the exact v182 position/size at radius **4,600** reproduced the missing ridge: [diagnostic capture](ridge-old-distance-diagnostic-runtime.png). The first prepared representation at radius **2,900** also remained absent. Bringing that same representation closer and scaling all dimensions proportionately, with unchanged quality, material, face orientation, transparency and Automatic RenderFidelity, made it visible: [closer diagnostic](ridge-nearer-diagnostic-runtime.png), then [final valley](above-egg-valley-runtime.png).

Final center **(1148.0657,80.15355,1631.0120)**; size **(845.2438,121.6324,735.6573)**; approximately **2,012 studs from the saved camera**. [Exact transform and size](../../../assets/environment/exterior-grass/ridge-placement.json) override the preparation's earlier ridge transform in the active recipe. This changes only the scenic representation; the valley stays open.

The comparison establishes **distance/placement-dependent runtime visibility**, not missing replication, streaming or a deleted instance. It is consistent with distance-dependent rendering/culling under the current Automatic quality settings; the exact internal culling threshold and any quality-dependent mesh/terrain occlusion contribution remain unproven. RenderFidelity was not changed to Precise, and graphics requirements were not raised. This is a Studio client observation, not a published-client or all-device guarantee.

## Implemented assets and integration

- **Grass:** existing licensed Quaternius `Grass_Wispy_Short`, simplified **494→140 triangles per tuft**, atlas UVs retained. **1,216 tufts** combined into **16 fitted patch MeshParts**, avoiding 1,216 individual instances. Short blades approximately **1–1.9 studs**, irregular lobes and edge tufts, roots fitted to actual ground triangles. Patches occupy selected near foreground/woodland toes, with roots outside radius **375**. No interior grass, large transparent planes, wind scripts, interaction or physics. Existing nature atlas reused; zero part transparency and alpha cutout material. Green tint adjusted before capture. Some original taller golden grass clumps remain among older meadow props.
- **Ground:** same 64-tile inaccessible exterior; four local foothill grading fields strengthen selected mountain transitions. Continuous **2048²** meadow/woodland/soil map replaces **1024²** subtle map. No whole-world Terrain conversion, raised landscape shelf or global lighting/fog/glass change.
- **Rock:** original **1024²** mountain/buttress maps restored with mild saturation/contrast reduction, preserving structure. Removed the previous **256→512** blur/resampling treatment. Existing five sourced mountain meshes and seven buttresses retained; only the valley ridge received the additional runtime-validated placement.
- **Trees:** retain all original **102** trees and **88** original low props. Regroup recent WoodlandLink additions into uneven WoodlandPatch lobes; remove **28 redundant added trees** and use the existing lighter CanopyYoung asset for **12 recently added CanopyTwisted** placements. Final **168 trees**, down from 196, plus unchanged **192** meadow props. No indiscriminate vegetation removal.
- **Cleanup/source:** removed those 28 placements from the active layout, recorded in [removed-placements.json](../../../assets/environment/exterior-grass/removed-placements.json). Active paths are `ServerStorage.VesperTools.ExteriorCompositionBuilder` and `ExteriorIntegrationLayout`; new native library `ServerStorage.ExteriorGrassAssets`. Old grading/template libraries remain archived in ServerStorage, with no active duplicate scenery. Previously retired pyramid, waterfall, ring, backdrop and StrataCliff generators remain retired. No additional positively identified legacy assembly was removed in this pass.

[Sources, licenses, resource availability, preparation and actual imported IDs](../../../assets/environment/exterior-grass/README.md). Incorporated sources remain **CC0 Quaternius/KayKit, Innerscene and Poly Haven**. WindShake was inspected (MIT) but not used. The two supplied DevForum resources could not be source/license-verified because their pages returned verification screens; neither was installed or executed. Historical unresolved constituent rights remain unchanged and private originals remain private.

## Bounded verification and cost observations

One **143-second runtime session**, **2026-11-10 17:48:21–17:50:44 UTC**: ridge presence/visibility comparison and final five camera views. No navigation, mining, purchases, grants, rewards, lifecycle triggering, data manipulation, device changes or additional session. Existing Studio preview credits are unchanged preview behavior. Stopped in Edit. Final Edit images completed at approximately **17:52:33 UTC**.

Protected geometry: **14,767 parts**, unchanged signature **247828899**. Both canonical source comparisons match Studio; scoped StyLua/Selene validation passes. Player records, fixed generation **VesperDiscovery_FreshStart_20261110**, all runtime gameplay sources and dome/interior systems were untouched.

Exterior **466→454 BaseParts**, **1,226,210→1,196,205 estimated instantiated source triangles** (−30,005, approximately 2.4%). Added grass is 170,240 triangles; reduced tree placements/variants offset it. **92 active unique mesh IDs**, **four color texture IDs**. The new library reused **45** previous ground mesh IDs and introduced **19 changed ground +16 fitted grass** IDs. Repeated trees/massifs keep shared IDs; grass patches share the existing atlas but have individual fitted geometry. All scenery is anchored with collision/touch/query disabled; no new animation or active animation range. [Inventory](scene-inventory.json).

One readily available client Stats sample: frame **16.07 ms**, render CPU **10.96 ms**, render GPU **3.76 ms**; 22,249 reported primitives and 87,817 instances for the **whole running place**, not this exterior alone. These instantaneous values are not averages, before/after measurements, FPS guarantees or mobile evidence. Automatic quality remained unchanged. [Raw observations](runtime-observations.json).

## Remaining visible issues — frozen for review

- Grass is present and visible as **small stippled patches** in above-egg runtime views, but does not yet make the broad foreground read as richly grass-covered. Individual blades are subtle at these distances. The outside detail image proves asset appearance/seating only. The saved normal-floor view cannot show ground grass behind the current frontage; this is an explicit verification/presentation limitation, not a claimed success.
- Broad smooth lawn-like areas remain. Ground material variation is clearer in overviews than from inside. Some isolated groups/loose planting connections remain despite regrouping.
- Overhead/oblique views expose discrete mountain footprints and abrupt bases. The relocated low ridge has a conspicuous **rectangular source footprint/edge** from outside-overview angles; that edge is less apparent from the captured player view. Some distant planting appears detached around the moved-ridge area. No post-capture reseating/art correction was made.
- Rock structure is readable again, but snowy/high-contrast portions remain stronger and more realistic than the vegetation. The outer square ground boundary remains visible in distant Edit overviews. This is still scenery composed for the dome, not a finished playable outside world.
- Published-client ridge visibility, every reachable angle, other quality settings/devices, mobile performance, multiplayer, persistence and gameplay regressions remain unverified. No visual approval is claimed.

Gate/road, dome/interior/frontage, rooms, shop/UI/tree and progression/content work remain [deferred in the existing roadmap](../../DEVELOPMENT_PLAN.md).

## Recovery and publication

Private root: `C:\Users\BOSS\Desktop\egg\Backups\ExteriorGrass_20261110\`.

- `ComingSoon_94763223427049_before.rbxl`: **6,235,709 bytes**, SHA256 `807EBC8A19900CB3577647ECD6D3BAC2F060CA2F32D861631A84433950C9CC1A`.
- `ComingSoon_94763223427049_final.rbxl`: **6,618,914 bytes**, SHA256 `EF880EAEA68B41AB379AE4DBD92445711CB34063B3B20BD65CC9BF36DE36DB05`.
- `src-before/`, `src-final/`, `asset-records-before/`, `asset-records-final/`, `grading-before.blend`, `grass-ground-adapted.blend`, `exports/grass-ground.fbx`, material derivatives, full-window runtime screenshots and diagnostic captures.

Recovery files were never opened as another playable target. They are development backups, not player-progress backups.
