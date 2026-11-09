-- Edit-time physical grips. The drill's -Z axis is its working direction.
local tool = game.ServerStorage.VesperKit.StarterDrill
local handle = tool.Handle
tool.Grip = CFrame.new(0, -0.2, 0)
tool:SetAttribute("HandlingRevision", "Stage2_TwoHanded")
local existing = tool:FindFirstChild("SupportHandle")
if existing then
	existing:Destroy()
end
local previous = handle:FindFirstChild("SupportGrip")
if previous then
	previous:Destroy()
end
local support = Instance.new("Model")
support.Name = "SupportHandle"
for index, spec in
	{
		{
			name = "RubberGrip",
			size = Vector3.new(0.56, 0.19, 0.19),
			x = -0.55,
			color = Color3.fromRGB(30, 39, 46),
			material = Enum.Material.SmoothPlastic,
		},
		{
			name = "MountCollar",
			size = Vector3.new(0.12, 0.28, 0.28),
			x = -0.26,
			color = Color3.fromRGB(105, 126, 137),
			material = Enum.Material.Metal,
		},
		{
			name = "EndCap",
			size = Vector3.new(0.07, 0.23, 0.23),
			x = -0.85,
			color = Color3.fromRGB(105, 126, 137),
			material = Enum.Material.Metal,
		},
	}
do
	local p = Instance.new("Part")
	p.Name, p.Shape, p.Size = spec.name, Enum.PartType.Cylinder, spec.size
	p.CFrame = handle.CFrame * CFrame.new(spec.x, 1.15, -0.45)
	p.Color, p.Material = spec.color, spec.material
	p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
	p.Massless = true
	p.Parent = support
	local weld = Instance.new("WeldConstraint")
	weld.Part0, weld.Part1, weld.Parent = handle, p, p
end
support.Parent = tool
local grip = Instance.new("Attachment")
grip.Name = "SupportGrip"
grip.CFrame = CFrame.new(-0.58, 1.15, -0.45) * CFrame.Angles(0, 0, math.pi * 0.5)
grip.Parent = handle
local old = game.ReplicatedStorage.VesperShared.EquipmentAssets:FindFirstChild("Drill")
if old then
	old:Destroy()
end
local preview = tool:Clone()
preview.Name = "Drill"
preview.Parent = game.ReplicatedStorage.VesperShared.EquipmentAssets
return {
	grip = tostring(tool.Grip),
	supportGrip = tostring(grip.CFrame),
	revision = tool:GetAttribute("HandlingRevision"),
}
