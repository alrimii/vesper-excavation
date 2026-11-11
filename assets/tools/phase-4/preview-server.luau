-- Temporary, authorized memory-only Studio verification setup. Never installed in Edit.
assert(game:GetService('RunService'):IsStudio() and game:GetService('RunService'):IsRunning())
local p=game.Players:GetPlayers()[1]
assert(p and p:GetAttribute('SaveStatus')=='STUDIO PREVIEW' and p:GetAttribute('StudioTestUnlocks'))
local evidence={started=workspace:GetServerTimeNow(),requests={},hp={},charges={}}
_G.Phase4ServerEvidence=evidence
local function stamp() return workspace:GetServerTimeNow()-evidence.started end
local section=workspace.VesperLab.Egg.Sections.L1_R14_C51
evidence.target=section.Name;evidence.initialHP=section:GetAttribute('HP')
section:GetAttributeChangedSignal('HP'):Connect(function() table.insert(evidence.hp,{time=stamp(),hp=section:GetAttribute('HP')}) end)
game.ReplicatedStorage.VesperShared.Remotes.Action.OnServerEvent:Connect(function(who,kind,a,b,c,d)
 if who==p and table.find({'Mine','Swing','EquipTool','Cancel','DrillStop'},kind) then
  table.insert(evidence.requests,{time=stamp(),kind=kind,target=typeof(a)=='Instance' and a.Name or a,sequence=d})
 end
end)
workspace.PlacedExcavationCharges.ChildAdded:Connect(function(charge)
 local r={time=stamp(),count=#workspace.PlacedExcavationCharges:GetChildren(),sequence=charge:GetAttribute('Sequence'),position=tostring(charge:GetPivot().Position),look=tostring(charge:GetPivot().LookVector)}
 table.insert(evidence.charges,r)
 charge.Destroying:Connect(function() r.removed=stamp() end)
end)
-- A small preview-only standing platform beside an actual intact shell plate.
local platform=Instance.new('Part');platform.Name='Phase4PreviewStandingPlatform'
platform.Size=Vector3.new(8,0.5,7);platform.Position=Vector3.new(0,17,44.5)
platform.Anchored=true;platform.Material=Enum.Material.Metal;platform.Color=Color3.fromRGB(64,75,75);platform.Parent=workspace
p.Character:PivotTo(CFrame.lookAt(Vector3.new(0,20.5,43.7),Vector3.new(0,20.5,39)))
p.Character.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero
return {preview=p:GetAttribute('SaveStatus'),target=section.Name,hp=evidence.initialHP}
