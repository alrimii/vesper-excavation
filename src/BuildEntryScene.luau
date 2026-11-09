-- Edit-time title set using the actual outer egg meshes; no runtime CSG.
assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local scene = Instance.new("Model")
scene.Name = "EntryScene"
local count = 0
for _, section in workspace.VesperLab.Egg.Sections:GetChildren() do
	if section:GetAttribute("Layer") == 1 then
		local source = section:FindFirstChild("Plate")
		if source then
			local p = source:Clone()
			p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
			p.Transparency, p.LocalTransparencyModifier = 0, 0
			p.Color = Color3.fromRGB(211, 174, 106)
			local surface = p:FindFirstChildOfClass("SurfaceAppearance")
			if surface then
				surface.Color = p.Color
			end
			p.Parent = scene
			count += 1
			if count % 500 == 0 then
				task.wait()
			end
		end
	end
end
local function part(name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Color, p.Material = color, material or Enum.Material.Metal
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = scene
	return p
end
local dark = Color3.fromRGB(28, 44, 62)
part("Floor", Vector3.new(1200, 2, 1200), CFrame.new(0, -18, 0), Color3.fromRGB(17, 28, 43))
local pedestal =
	part("Cradle", Vector3.new(7, 112, 112), CFrame.new(0, -14, 0) * CFrame.Angles(0, 0, math.pi / 2), dark)
pedestal.Shape = Enum.PartType.Cylinder
for i = 0, 31 do
	local angle = i * math.pi / 16
	local cf = CFrame.new(math.cos(angle) * 56, -10.6, math.sin(angle) * 56) * CFrame.Angles(0, -angle, 0)
	part("CradleLight", Vector3.new(0.5, 0.14, 9.8), cf, Color3.fromRGB(83, 226, 229), Enum.Material.Neon)
end
for _, x in { -64, 64 } do
	for _, z in { -64, 64 } do
		part("Tower", Vector3.new(5, 126, 5), CFrame.new(x, 45, z), dark)
		part("TowerFoot", Vector3.new(11, 4, 11), CFrame.new(x, -14, z), dark)
	end
end
for _, z in { -64, 64 } do
	part("Gantry", Vector3.new(133, 5, 5), CFrame.new(0, 108, z), dark)
	part(
		"GantryLight",
		Vector3.new(115, 0.6, 0.3),
		CFrame.new(0, 106, z + 2.6),
		Color3.fromRGB(83, 226, 229),
		Enum.Material.Neon
	)
end
local old = game.ReplicatedFirst:FindFirstChild("EntryScene")
if old then
	old:Destroy()
end
scene.Parent = game.ReplicatedFirst
return count
