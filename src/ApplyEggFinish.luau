-- Edit-time installer. Finish definitions remain separate from excavation rules.
assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local shared = game.ReplicatedStorage.VesperShared
local definition = shared.EggFinishes:Clone()
definition.Parent = shared
local profiles = require(definition)
local finish = profiles.Default
local egg = workspace.VesperLab.Egg
local changed = 0
local function apply(part, row)
	if not part:IsA("MeshPart") then
		return
	end
	local maps = finish.Rows[row]
	assert(maps, "Missing finish row " .. tostring(row))
	for _, child in part:GetChildren() do
		if child:IsA("SurfaceAppearance") then
			child:Destroy()
		end
	end
	part.TextureID = ""
	part.Color = Color3.new(1, 1, 1)
	part.Reflectance = 0
	part.Material = Enum.Material.SmoothPlastic
	local surface = Instance.new("SurfaceAppearance")
	surface.Name = "AncientNacre"
	surface.ColorMap = maps.Color
	surface.RoughnessMap = maps.Roughness
	surface.NormalMap = finish.Normal
	surface.MetalnessMap = finish.Metalness or ""
	surface.Color = maps.Tint or Color3.new(1, 1, 1)
	surface.AlphaMode = Enum.AlphaMode.Overlay
	surface.Parent = part
	part:SetAttribute("EggFinish", "Default")
	changed += 1
	if changed % 200 == 0 then
		task.wait()
	end
end
for _, section in egg.Sections:GetChildren() do
	if section:GetAttribute("Layer") == 1 then
		apply(section.Plate, section:GetAttribute("Row"))
	end
end
for _, container in { game.ServerStorage.EggPlateLibrary, shared.EggAssetPreload, shared.FractureLibrary } do
	for _, part in container:GetDescendants() do
		local row = part.Name:match("^L1_R(%d+)")
		if row and part:IsA("MeshPart") then
			apply(part, tonumber(row))
		end
	end
end
egg:SetAttribute("EggFinish", "Default")
egg:SetAttribute("FinishRevision", 3)
definition:Destroy()
local colors, roughness = {}, {}
for _, maps in finish.Rows do colors[maps.Color] = true roughness[maps.Roughness] = true end
local function count(items)
	local n = 0
	for _ in items do n += 1 end
	return n
end
return { updatedMeshes = changed, colorMaps = count(colors), roughnessMaps = count(roughness), normalMaps = 1 }
