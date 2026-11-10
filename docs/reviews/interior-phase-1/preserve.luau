-- Read-only signature capture; does not run systems, players or simulation.
local lab = workspace.VesperLab
local function hash(rows)
	table.sort(rows)
	local h = 0
	for _, row in rows do for i = 1, #row do h = (h * 31 + string.byte(row, i)) % 2147483647 end end
	return { count = #rows, signature = h }
end
local function geometry(root, exclude)
	local rows = {}
	for _, p in root:GetDescendants() do
		if p:IsA("BasePart") and not (exclude and exclude(p)) then
			local row = p:GetFullName() .. tostring(p.CFrame) .. tostring(p.Size) .. tostring(p.Color) .. tostring(p.Material) .. tostring(p.Transparency) .. tostring(p.CanCollide)
			if p:IsA("MeshPart") then row ..= p.MeshId end
			table.insert(rows, row)
		end
	end
	return hash(rows)
end
local out = { place = game.PlaceId, version = game.PlaceVersion, geometry = {}, scripts = {}, anchors = {}, rooms = {}, lighting = {}, atmosphere = {}, clouds = {} }
for _, root in { lab.Egg, lab.CentralPlatform, lab.Dome, lab.CrownDeliveryDock, lab.DecorativeExterior, lab.ResourceDepot, lab.Architecture.CompactFoundation, lab.ExcavationAccess.DeploymentSections } do
	out.geometry[root:GetFullName()] = geometry(root)
end
out.geometry.LadderRoute = geometry(lab.ExcavationAccess.AccessRevision4.LadderEntrance, function(p) return p.Name == "LandingColumn" or p.Name == "SignPost" or p.Name == "AccessSign" end)
for _, root in { game.ServerScriptService, game.ReplicatedStorage, game.StarterPlayer, game.ReplicatedFirst } do
	for _, p in root:GetDescendants() do if p:IsA("LuaSourceContainer") then out.scripts[p:GetFullName()] = hash({ p.Source }) end end
end
for _, room in lab.Rooms:GetChildren() do
	local facade = room:FindFirstChild("CompactFrontage")
	local roof = room:FindFirstChild("FinishedRoof")
	out.rooms[room.Name] = { id = room:GetAttribute("RoomNumber"), pivot = { room:GetPivot():GetComponents() }, spawn = tostring(room.RoomSpawn.CFrame), threshold = tostring(room.Threshold.CFrame), training = tostring(room.TrainingStation.PracticeEgg.CFrame), practiceRest = tostring(room.TrainingStation.PracticeEgg:GetAttribute("RestCFrame")), pressRest = tostring(room.TrainingStation.PressHead:GetAttribute("RestCFrame")), interior = geometry(room, function(p) return p.Name == "Ceiling" or p.Name == "OwnerSign" or p.Name == "NumberSign" or (facade and p:IsDescendantOf(facade)) or (roof and p:IsDescendantOf(roof)) end) }
end
for _, p in lab.FunctionalAnchors:GetChildren() do out.anchors[p.Name] = p.Value and p.Value:GetFullName() end
for _, k in { "ClockTime", "Brightness", "ExposureCompensation", "Ambient", "OutdoorAmbient", "EnvironmentDiffuseScale", "EnvironmentSpecularScale", "GeographicLatitude", "FogStart", "FogEnd", "FogColor" } do out.lighting[k] = tostring(game.Lighting[k]) end
for _, k in { "Density", "Haze", "Color", "Decay", "Glare", "Offset" } do out.atmosphere[k] = tostring(game.Lighting.Atmosphere[k]) end
out.atmosphere.Wind = tostring(workspace.GlobalWind)
for _, k in { "Cover", "Density", "Color" } do out.clouds[k] = tostring(workspace.Terrain.Clouds[k]) end
return game:GetService("HttpService"):JSONEncode(out)
