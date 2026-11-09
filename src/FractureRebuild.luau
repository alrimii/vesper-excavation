-- Bake once in Studio using native Voronoi fragmentation; no runtime CSG cost.
local shared = game.ReplicatedStorage.VesperShared
local archive = game.ServerStorage.RoomRebuildArchive
local library = shared.FractureLibrary
local old = library:Clone()
old.Name = "FracturesBeforeVoronoi"
old.Parent = archive
local geometry = game:GetService("GeometryService")
local count, failed = 0, 0
for li = 1, 3 do
	for row = 10, 39 do
		local section =
			workspace.VesperLab.Egg.Sections:FindFirstChild(string.format("L%d_R%02d_C00", li, row))
		local p = section and section:FindFirstChild("Plate")
		if p then
			local normal = Vector3.new(p.Position.X, (p.Position.Y - 41.8) * 0.5, p.Position.Z).Unit
			local side = Vector3.yAxis:Cross(normal)
			side = side.Magnitude > 0.01 and side.Unit or Vector3.xAxis
			local up = normal:Cross(side).Unit
			local function extent(axis)
				return (
					math.abs(axis:Dot(p.CFrame.RightVector)) * p.Size.X
					+ math.abs(axis:Dot(p.CFrame.UpVector)) * p.Size.Y
					+ math.abs(axis:Dot(p.CFrame.LookVector)) * p.Size.Z
				) * 0.5
			end
			local width, height = extent(side), extent(up)
			local sites = { p.Position + side * width * 0.09 + up * height * 0.05 }
			for i = 1, 5 do
				local theta = i * math.pi * 2 / 5 + row * 0.17
				table.insert(
					sites,
					p.Position + side * math.cos(theta) * width * 0.62 + up * math.sin(theta) * height * 0.62
				)
			end
			local ok, result = pcall(function()
				return geometry:FragmentAsync(p, sites, { SplitApart = true })
			end)
			if ok and #result >= 3 then
				local name = string.format("L%d_R%02d", li, row)
				local model = Instance.new("Folder")
				model.Name = name
				for i, item in result do
					local piece = item.Instance or item
					piece.Name = name .. "_F" .. i
					piece.Anchored = true
					piece.CanCollide = false
					piece.CanTouch = false
					piece.CanQuery = false
					piece.CastShadow = false
					piece.Transparency = 0
					piece.Material = p.Material
					piece.MaterialVariant = p.MaterialVariant
					piece.Color = p.Color
					piece:SetAttribute("RelativeCFrame", p.CFrame:ToObjectSpace(piece.CFrame))
					local delta = piece.Position - p.Position
					delta -= normal * delta:Dot(normal)
					local direction = delta.Magnitude > 0.001 and delta.Unit or side
					piece:SetAttribute("FractureDirection", p.CFrame:VectorToObjectSpace(direction))
					piece:SetAttribute("SurfaceNormal", p.CFrame:VectorToObjectSpace(normal))
					piece:SetAttribute("RestHeight", 0.2)
					piece.Parent = model
				end
				local previous = library:FindFirstChild(name)
				if previous then
					previous:Destroy()
				end
				model.Parent = library
				count += 1
			else
				failed += 1
				if ok then
					for _, item in result do
						(item.Instance or item):Destroy()
					end
				end
			end
		end
		library:SetAttribute("VoronoiTemplates", count)
		library:SetAttribute("VoronoiFailures", failed)
		task.wait()
	end
end
library:SetAttribute("VoronoiReady", true)
return { templates = count, failures = failed }
