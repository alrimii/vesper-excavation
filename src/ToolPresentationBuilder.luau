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
	tool:SetAttribute("ToolVisualRevision", Visuals.Revision)
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
function B.Previews()
	for family, name in { Pickaxe = "StarterPickaxe", Drill = "StarterDrill", Explosive = "StarterExplosive" } do
		local old = Shared.EquipmentAssets:FindFirstChild(family)
		if old then
			old:Destroy()
		end
		local copy = Kit[name]:Clone()
		copy.Name = family
		copy.Parent = Shared.EquipmentAssets
	end
end
function B.Displays()
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
function B.Build()
	assert(not game:GetService("RunService"):IsRunning(), "Edit-only tool recipe")
	local clips = require(Shared.MotionClips)
	replace(Kit.StarterPickaxe, Assets.FieldPickaxe, "Pickaxe", clips.PickaxeGrip)
	local tip = Instance.new("Attachment")
	tip.Name = "StrikeTip"
	tip.Position = clips.PickaxeStrikeTip
	tip.Parent = Kit.StarterPickaxe.Handle
	replace(
		Kit.StarterExplosive,
		Assets.SurveyDynamite,
		"Explosive",
		CFrame.new(0, -0.15, 0) * CFrame.Angles(0, 0, math.rad(-8))
	)
	local drill = Kit.StarterDrill
	drill:SetAttribute("ToolFamily", "Drill")
	drill:SetAttribute("ToolVisualRevision", Visuals.Revision)
	for _, root in { drill, game.ServerStorage.HelixDrillSource } do
		for _, p in root:GetDescendants() do
			if p:IsA("MeshPart") and p.Name == "body_geom" then
				p.TextureID = Assets:GetAttribute("DrillBodyTexture")
			end
		end
	end
	local bit = drill:FindFirstChild("drill bit_geom", true)
	local rotor = drill:FindFirstChild("DrillRotor", true)
	assert(bit and rotor, "Drill rotor dependency missing")
	bit.Size = Vector3.new(0.20372286, 0.07962221, 0.56)
	rotor.C0 = CFrame.new(0.003, 1.2125, -1.24)
	bit.CFrame = drill.Handle.CFrame * rotor.C0 * rotor.C1:Inverse()
	local working = drill.Handle:FindFirstChild("WorkingTip") or Instance.new("Attachment")
	working.Name = "WorkingTip"
	working.Position = Vector3.new(0.003, 1.2125, -1.52)
	working.Parent = drill.Handle
	B.Previews()
	B.Displays()
	return "One finished tool recipe applied to templates, previews and workshop"
end
return B
