# Phase 4 replacement ledger

Single active place: **94763223427049**. Native recovery is private; no retired scenery/tool model was hidden or parked elsewhere in Workspace.

| Superseded path / implementation | Replacement or migration |
|---|---|
| `ServerStorage.VesperKit.StarterPickaxe.ForgedPickaxe` and old handle/strike-tip placement | Finished `PickGrip`, `PickTimber`, `PickSteel`; existing Tool/Handle identity retained; measured `StrikeTip`, canonical grip and contact pose |
| `ServerStorage.VesperKit.StarterExplosive.FinishedCharge` six-part assembly | Finished `SurveyDynamite` mesh, proper held scale/orientation; existing Tool/Handle identity retained |
| `ServerStorage.VesperBlenderAssets.Pickaxe` | Deleted; `ToolPresentationAssets.FieldPickaxe` is the selected replacement source |
| `ServerStorage.CompactInteriorAssets.ChargeBundle` and its nested assembly | Deleted; `ToolPresentationAssets.SurveyDynamite` is the selected replacement source |
| Unused `ServerStorage.AssetReview.StorePickaxe` | Deleted from the active place |
| `ReplicatedStorage.VesperShared.EquipmentAssets.{Pickaxe,Drill,Explosive}` | Replaced from the current functional templates; no separate outdated preview models |
| `Workspace.VesperLab.SharedWorkshop.IntegratedWorkshop.{PickaxeDisplay,DrillDisplay,ChargeDisplay}` | Replaced from the same templates; original mounts, counter, interactions and architecture preserved. All display-only welds removed |
| Drill body texture `135244070369997` on functional/source/preview/display copies | Exact recovered pixels republished as `100714057797210`; no unrelated texture changes |
| Old local charge ball/countdown and large `BlastAccent` sphere | One server-authorized placed model; single deduplicated flash/dust/chips/smoke presentation, existing sound settings |
| Additional central blast `ImpactFX.Emit` call | Removed to avoid stacking central explosion effects; existing per-section fracture/impact behavior retained |
| Independent `LabInteriorBuilder.Tools`, `AssetIntegration.Tools`, `QualityBuilder.Tools` recipes | Forward to `ServerStorage.VesperTools.ToolPresentationBuilder.Build` |
| Old local `LabInteriorBuilder.displayTool` helper | Removed; workshop uses `ToolPresentationBuilder.Displays` |
| `RefineDrillGrip.luau`, `PreviewDrillGrip.luau` authoring commands | Forward to the current recipe; obsolete drill transform recipes removed |
| `src/models/refine_pickaxe.py`, pickaxe branch of `build_tools.py` | Former removed; latter retains only the unchanged bucket authoring path. Old mesh importer now explicitly accepts Bucket only |
| Compact-interior charge import/export branches | Removed from `prepare_assets.py` and `finish_exports.py`; historical source inspection/metadata is not an active generator |

Functional `ToolKind`, owner assignment, equipment lifecycle and server stats remain under the existing equipment service. The new `ToolFamily`/revision metadata selects presentation only. CollectionBucket is unchanged. Drill `DrillRotor` remains a Motor6D; its rest position and bit length were updated together, and `Handle.WorkingTip` records the working end. No room, world-interaction, training, mining or delivery anchor moved.

`ToolVisuals.Clone` explicitly strips `WeldConstraint`, `JointInstance`, other constraints, scripts and effects before placement/display parenting. The runtime follow-up caught and corrected the distinction between Roblox WeldConstraint and Constraint; the final placed model has no weld to the held tool. Existing equipped tools keep their necessary assembly joints.

One server placement record owns its model and connections. Cancellation destroys the model and disconnects support listeners; stale callbacks cannot create it later. Destroyed support removes the model while preserving the pre-existing authorized blast position/layer rule. Existing tool-switch cancellation of a pending charge was retained, not changed into a new persistence mechanic.

Final static checks found no active references to the rejected pickaxe mesh, former charge assembly's primary mesh or old drill texture; exact retired source folders are absent. All preview camera/setup/observer/correction scripts and the temporary standing platform existed only in runtime and are absent from Edit.
