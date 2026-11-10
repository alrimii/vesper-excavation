-- Read-only preservation signatures; no simulation or gameplay execution.
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
local out = { place = game.PlaceId, geometry = {}, scripts = {}, anchors = {}, rooms = {}, lighting = {}, atmosphere = {}, clouds = {} }
out.geometry.OutsideRooms = geometry(lab, function(p) return p:IsDescendantOf(lab.Rooms) end)
for _, root in { game.ServerScriptService, game.ReplicatedStorage, game.StarterPlayer, game.ReplicatedFirst } do
	for _, p in root:GetDescendants() do if p:IsA("LuaSourceContainer") then out.scripts[p:GetFullName()] = hash({ p.Source }) end end
end
for _, room in lab.Rooms:GetChildren() do
	local structural = {}
	for _, name in { "LeftWall", "RightWall", "BackWall", "RoomSpawn", "Threshold", "OwnerSign" } do
		local p = room[name]
		table.insert(structural, name .. tostring(p.CFrame) .. tostring(p.Size) .. tostring(p.Color) .. tostring(p.Material))
	end
	out.rooms[room.Name] = { id = room:GetAttribute("RoomNumber"), pivot = { room:GetPivot():GetComponents() }, structural = hash(structural), frontage = geometry(room.CompactFrontage), roof = geometry(room.FinishedRoof) }
end
for _, p in lab.FunctionalAnchors:GetChildren() do out.anchors[p.Name] = p.Value and p.Value:GetFullName() end
for _, k in { "ClockTime", "Brightness", "ExposureCompensation", "Ambient", "OutdoorAmbient", "EnvironmentDiffuseScale", "EnvironmentSpecularScale", "GeographicLatitude", "FogStart", "FogEnd", "FogColor" } do out.lighting[k] = tostring(game.Lighting[k]) end
for _, k in { "Density", "Haze", "Color", "Decay", "Glare", "Offset" } do out.atmosphere[k] = tostring(game.Lighting.Atmosphere[k]) end
out.atmosphere.Wind = tostring(workspace.GlobalWind)
for _, k in { "Cover", "Density", "Color" } do out.clouds[k] = tostring(workspace.Terrain.Clouds[k]) end
return game:GetService("HttpService"):JSONEncode(out)
