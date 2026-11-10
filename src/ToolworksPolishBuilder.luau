-- Historical recipe: protected against restoring superseded map geometry.
assert(not (workspace:FindFirstChild("VesperLab") and workspace.VesperLab:GetAttribute("MapCleanupRevision")), "Historical recipe retired; use MapCleanupBuilder for the current map")
assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local lab = workspace.VesperLab
local hall = lab.SharedWorkshop
assert(not hall:FindFirstChild("ArchitecturalFinish"), "Already polished")
local backup = Instance.new("Folder")
backup.Name = "BeforeToolworksPolish_20261109"
hall:Clone().Parent = backup
backup.Parent = game.ServerStorage
local finish = Instance.new("Model")
finish.Name = "ArchitecturalFinish"
local origin = hall:GetPivot()
local dark = Color3.fromRGB(25, 34, 43)
local steel = Color3.fromRGB(84, 97, 106)
local enamel = Color3.fromRGB(172, 182, 186)
local amber = Color3.fromRGB(224, 160, 68)
local mint = Color3.fromRGB(113, 210, 190)
local function part(name, size, pos, color, material, collide)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, origin * CFrame.new(pos)
	p.Color, p.Material = color, material or Enum.Material.Metal
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, collide == true, false, false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = finish
	return p
end
-- Preserve the open roof and the complete entrance width.
hall.Floor.Color = Color3.fromRGB(68, 78, 86)
hall.Floor.Material = Enum.Material.Concrete
hall.BackWall.Color = dark
for _, p in hall:GetChildren() do
	if p:IsA("BasePart") then
		if p.Name == "SideWall" then
			p.Color = dark
		elseif p.Name == "RoofWing" then
			p.Color = steel
			p.Material = Enum.Material.Metal
		elseif p.Name == "FrontPier" then
			p.Color = enamel
			p.Material = Enum.Material.Metal
		elseif p.Name == "WallRail" then
			p.Color = mint
		elseif p.Name == "DisplayPlinth" then
			p.Color = steel
			p.Material = Enum.Material.Metal
		elseif p.Name == "DisplayTrim" then
			p.Material = Enum.Material.Metal
			p.Color = dark
		end
	end
end
for _, x in { -30, 30 } do
	part("PortalFoot", Vector3.new(3.4, 0.7, 3.4), Vector3.new(x, 0.75, 25), steel)
	part("PortalInset", Vector3.new(0.32, 12, 0.15), Vector3.new(x, 8, 26.08), dark)
	part("PortalMarker", Vector3.new(0.18, 3, 0.08), Vector3.new(x, 12, 26.2), amber, Enum.Material.Neon)
	part("RoofFascia", Vector3.new(20, 1.8, 0.45), Vector3.new(x, 20.6, 26.3), enamel)
	part("EaveSupport", Vector3.new(1.4, 1.4, 50), Vector3.new(x, 19, 0), steel)
end
part("EntryHeader", Vector3.new(62, 1.2, 2.4), Vector3.new(0, 21, 25), steel)
part("SignFrame", Vector3.new(59, 6, 0.45), Vector3.new(0, 18, 24.45), steel)
hall.ShopSign.Color = dark
hall.EntryLight.Color = amber
for _, x in { -38.7, 38.7 } do
	part("InteriorSkirting", Vector3.new(0.18, 1.2, 48), Vector3.new(x, 1.1, 0), steel)
	for _, z in { -18, -6, 6, 18 } do
		part("WallRib", Vector3.new(0.22, 16, 0.5), Vector3.new(x, 10, z), steel)
	end
end
local rules = require(game.ReplicatedStorage.VesperShared.ProgressionRules)
for i, id in rules.ToolOrder do
	local x = (i - 2) * 24
	local color = rules.Tools[id].Color
	part("DisplayBackdrop", Vector3.new(21, 15, 0.25), Vector3.new(x, 8.8, -24.55), steel)
	part("DisplayRecess", Vector3.new(19.8, 13.8, 0.15), Vector3.new(x, 8.8, -24.3), dark)
	local label = hall[id .. "Label"]
	label.CFrame = origin * CFrame.new(x, 13, -24.05)
	for _, dx in { -9.4, 9.4 } do
		part("DisplayUpright", Vector3.new(0.22, 9, 0.25), Vector3.new(x + dx, 6.4, -24.05), enamel)
	end
	part("DisplayEdge", Vector3.new(16, 0.14, 0.15), Vector3.new(x, 1.98, -9.9), color, Enum.Material.Neon)
	part("DisplayCanopy", Vector3.new(20, 0.5, 11), Vector3.new(x, 16.2, -19), steel)
	local light = part(
		"DisplayLuminaire",
		Vector3.new(12, 0.12, 1.1),
		Vector3.new(x, 15.86, -17),
		Color3.fromRGB(244, 232, 212),
		Enum.Material.Neon
	)
	local source = Instance.new("SurfaceLight")
	source.Face = Enum.NormalId.Bottom
	source.Range, source.Angle, source.Brightness = 20, 110, 0.8
	source.Color, source.Shadows, source.Parent = Color3.fromRGB(244, 232, 212), false, light
	-- Visible knees connect the display canopy to its back wall.
	for _, dx in { -8.8, 8.8 } do
		local a = Vector3.new(x + dx, 13.7, -24.05)
		local b = Vector3.new(x + dx, 15.9, -20.5)
		local bracket = part("CanopyKnee", Vector3.new(0.22, 0.22, (b - a).Magnitude), Vector3.zero, steel)
		bracket.CFrame = origin * CFrame.lookAt((a + b) / 2, b)
	end
end
for _, name in { "Console", "UpgradeConsole" } do
	local console = hall[name]
	local pos = origin:PointToObjectSpace(console.Position)
	console.Color = dark
	console.Material = Enum.Material.Metal
	part(
		"ConsolePlinth",
		Vector3.new(console.Size.X + 0.8, 0.25, console.Size.Z + 0.8),
		Vector3.new(pos.X, 0.54, pos.Z),
		steel
	)
	part(
		"ConsoleTop",
		Vector3.new(console.Size.X + 0.5, 0.18, console.Size.Z + 0.4),
		Vector3.new(pos.X, pos.Y + console.Size.Y / 2 + 0.12, pos.Z),
		steel
	)
	for _, side in { -1, 1 } do
		part(
			"ConsoleCheek",
			Vector3.new(0.22, 3.3, 0.3),
			Vector3.new(pos.X + side * (console.Size.X / 2 - 0.3), pos.Y, pos.Z + console.Size.Z / 2 + 0.18),
			enamel
		)
	end
	local display = console:FindFirstChildOfClass("SurfaceGui")
	if display then
		display.MaxDistance = 200
	end
end
for _, g in hall:GetDescendants() do
	if g:IsA("SurfaceGui") then
		g.MaxDistance = 300
		g.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
		g.CanvasSize = Vector2.new(g.Parent.Name == "ShopSign" and 1160 or 760, 200)
	end
end
finish.Parent = hall
return { parts = #finish:GetChildren(), addedDisplayLights = 3, existingPromptsPreserved = true }
