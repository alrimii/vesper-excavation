-- Sole Edit-time recipe for Phase 4 tool models and their display copies.
local B = {}
local Shared = game.ReplicatedStorage.VesperShared
local Visuals = require(Shared.ToolVisuals)
local Kit = game.ServerStorage.VesperKit
local Assets = game.ServerStorage.ToolPresentationAssets
local function replace(tool, source, family, grip)
	local handle = tool.Handle
	for _, child in tool:GetChildren() do
		if child ~= handle then
			child:Destroy()
		end
	end
	handle:ClearAllChildren()
	handle.Size, handle.CFrame, handle.Transparency = Vector3.new(0.24, 0.45, 0.24), CFrame.identity, 1
	handle.Anchored, handle.Massless = false, true
	handle.CanCollide, handle.CanTouch, handle.CanQuery = false, false, false
	tool.Grip = grip
	tool:SetAttribute("ToolFamily", family)
	tool:SetAttribute(
		"ToolVisualRevision",
		family == "Pickaxe" and Visuals.PickaxeRevision
			or family == "Drill" and Visuals.DrillRevision
			or family == "Explosive" and Visuals.ChargeRevision
			or Visuals.Revision
	)
	for _, part in source:GetDescendants() do
		if part:IsA("BasePart") then
			local p = part:Clone()
			p.Anchored, p.Massless, p.CastShadow = false, true, false
			p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
			p.Parent = tool
			local weld = Instance.new("WeldConstraint")
			weld.Name, weld.Part0, weld.Part1, weld.Parent = "ToolAssembly", handle, p, p
		end
	end
end
function B.Previews(onlyFamily)
	for family, name in { Pickaxe = "StarterPickaxe", Drill = "StarterDrill", Explosive = "StarterExplosive" } do
		if onlyFamily and family ~= onlyFamily then
			continue
		end
		local old = Shared.EquipmentAssets:FindFirstChild(family)
		if old then
			old:Destroy()
		end
		local copy = Kit[name]:Clone()
		copy.Name = family
		copy.Parent = Shared.EquipmentAssets
	end
end
function B.Displays(onlyFamily)
	local shop = workspace.VesperLab.SharedWorkshop
	local g = shop.IntegratedWorkshop
	local cf = shop:GetPivot()
	for _, s in
		{
			{ "PickaxeDisplay", "StarterPickaxe", 15, 6.8, math.pi },
			{ "DrillDisplay", "StarterDrill", 0, 5.2, 0.8 },
			{ "ChargeDisplay", "StarterExplosive", -15, 3.4, 0.35 },
		}
	do
		if onlyFamily and Kit[s[2]]:GetAttribute("ToolFamily") ~= onlyFamily then
			continue
		end
		local old = g:FindFirstChild(s[1])
		if old then
			old:Destroy()
		end
		local model = Visuals.Clone(Kit[s[2]], s[1])
		local _, sz = model:GetBoundingBox()
		model:ScaleTo(model:GetScale() * s[4] / sz.Y)
		local box, size = model:GetBoundingBox()
		model:PivotTo(
			cf
				* CFrame.new(s[3], 5 + size.Y / 2, -1.7)
				* CFrame.Angles(0, s[5], 0)
				* box:Inverse()
				* model:GetPivot()
		)
		model.Parent = g
	end
end
function B.Pickaxe()
	assert(not game:GetService("RunService"):IsRunning(), "Edit-only tool recipe")
	local clips = require(Shared.MotionClips)
	replace(Kit.StarterPickaxe, Assets.RodinPickaxe, "Pickaxe", clips.PickaxeGrip)
	Kit.StarterPickaxe.TextureId = Visuals.PickaxeIcon
	local tip = Instance.new("Attachment")
	tip.Name = "StrikeTip"
	tip.Position = clips.PickaxeStrikeTip
	tip.Parent = Kit.StarterPickaxe.Handle
	B.Previews("Pickaxe")
	B.Displays("Pickaxe")
	return "Owner-supplied pickaxe updated; other tool assemblies unchanged"
end
function B.Drill()
	assert(not game:GetService("RunService"):IsRunning(), "Edit-only tool recipe")
	local drill = Kit.StarterDrill
	replace(drill, Assets.RodinDrill, "Drill", CFrame.identity)
	drill.TextureId = Visuals.DrillIcon
	drill:SetAttribute("HandlingRevision", "RodinRearAndAuxiliaryGrip")
	drill:SetAttribute("HoldOffset", Vector3.new(1.15, -0.1, -0.85))
	local handle = drill.Handle
	local support = Instance.new("Attachment")
	support.Name = "SupportGrip"
	support.CFrame = CFrame.new(-0.7955, -0.37, -1.95175) * CFrame.Angles(0, 0, -math.pi / 2)
	support.Parent = handle
	local working = Instance.new("Attachment")
	working.Name, working.Position, working.Parent = "WorkingTip", Vector3.new(0, 0.10175, -3.282065), handle
	local bit = assert(drill:FindFirstChild("RodinDrillBit"), "Supplied drill bit missing")
	bit.ToolAssembly:Destroy()
	local shaft = CFrame.new(0, 0.10175, -2.2755)
	local rotor = Instance.new("Motor6D")
	rotor.Name, rotor.Part0, rotor.Part1 = "DrillRotor", handle, bit
	rotor.C0, rotor.C1 = shaft, bit.CFrame:ToObjectSpace(shaft)
	rotor.Parent = handle
	B.Previews("Drill")
	B.Displays("Drill")
	return "Supplied Rodin drill fitted to rear and auxiliary grips in all destinations"
end
function B.Charge()
	assert(not game:GetService("RunService"):IsRunning(), "Edit-only tool recipe")
	local tool = Kit.StarterExplosive
	replace(
		tool,
		Assets.RodinCharge,
		"Explosive",
		CFrame.Angles(math.rad(-14), 0, 0) * CFrame.new(-0.10, 0.05, 0.10)
	)
	tool.TextureId = Visuals.ChargeIcon
	tool:SetAttribute("ChargeVisualRevision", 4)
	require(Shared.ChargePresentation).AddScreen(tool)
	B.Previews("Explosive")
	B.Displays("Explosive")
	return "Supplied sticky charge in all tool/preview/display destinations"
end
function B.Build()
	assert(not game:GetService("RunService"):IsRunning(), "Edit-only tool recipe")
	B.Pickaxe()
	B.Charge()
	B.Drill()
	B.Previews("Explosive")
	B.Displays("Explosive")
	return "One finished tool recipe applied to templates, previews and workshop"
end
return B
