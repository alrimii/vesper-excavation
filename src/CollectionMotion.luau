-- Cosmetic collection only; the server awards the full yield at the final hit.
local M = {}
function M.Start(folder, shell, roundState)
	local Players = game:GetService("Players")
	local library = game.ReplicatedStorage.VesperShared.FractureLibrary
	local flights, seen = {}, {}
	roundState:GetAttributeChangedSignal("RoundId"):Connect(function()
		for _, f in flights do
			f.part:Destroy()
		end
		table.clear(flights)
		table.clear(seen)
	end)
	local controller = {}
	function controller:Burst(from, destination, layer, data)
		if typeof(data) ~= "table" or data.RoundId ~= roundState:GetAttribute("RoundId") then
			return
		end
		if typeof(data.SectionId) ~= "string" or seen[data.SectionId] then
			return
		end
		seen[data.SectionId] = true
		local poses = shell:Detach(data.SectionId)
		local camera = workspace.CurrentCamera
		if not camera or (camera.CFrame.Position - from).Magnitude > 110 then
			return
		end
		local source = library:FindFirstChild(data.Template or "")
		if not source then
			return
		end
		local collector = Players:GetPlayerByUserId(data.CollectorUserId)
		local reduced = Players.LocalPlayer:GetAttribute("ReducedMotion")
		local templates = {}
		for _, child in source:GetChildren() do
			if child:IsA("BasePart") and typeof(child:GetAttribute("RelativeCFrame")) == "CFrame"
				and not child:GetAttribute("CrackInterior") then
				table.insert(templates, child)
			end
		end
		table.sort(templates, function(a, b)
			return a.Name < b.Name
		end)
		local budget = reduced and 2 or 8
		local stride = math.max(1, math.ceil(#templates / budget))
		for index = 1, math.min(#templates, budget * stride), stride do
			local template = templates[index]
			-- Rapid one-hit breaks must still show a shatter. Retire the oldest
			-- cosmetic flight rather than dropping the newly broken plate.
			if #flights >= 48 then
				flights[1].part:Destroy()
				table.remove(flights, 1)
			end
			local part = template:Clone()
			part.Name = "CollectedShell"
			part.Anchored = true
			part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
			part.CastShadow = false
			part.LocalTransparencyModifier, part.Transparency = 0, 0
			local original = workspace.VesperLab.Egg.Sections:FindFirstChild(data.SectionId)
			if original and original:FindFirstChild("Plate") then
				part.Color = original.Plate.Color
				if layer == 1 then
					part.Material = original.Plate.Material
					part.MaterialVariant = original.Plate.MaterialVariant
					part.Reflectance = original.Plate.Reflectance
					part.CastShadow = original.Plate.CastShadow
					part.TextureID = original.Plate.TextureID
					local previous = part:FindFirstChildOfClass("SurfaceAppearance")
					if previous then
						previous:Destroy()
					end
					local finish = original.Plate:FindFirstChildOfClass("SurfaceAppearance")
					if finish then
						finish:Clone().Parent = part
					end
				end
			end
			part.CFrame = poses and poses[part.Name]
				or poses and poses[template.Name]
				or data.CFrame * template:GetAttribute("RelativeCFrame")
			local normal =
				data.CFrame:VectorToWorldSpace(template:GetAttribute("SurfaceNormal") or Vector3.zAxis)
			local lateral = data.CFrame:VectorToWorldSpace((template:GetAttribute("FractureDirection") or Vector3.xAxis))
			local pivotFrame = part:GetPivot()
			local start = pivotFrame.Position
			part.Parent = folder
			table.insert(flights, {
				part = part,
				size = part.Size,
				start = start,
				rotation = pivotFrame.Rotation,
				pivotOffset = part.PivotOffset,
				peel = start + normal * 0.65 + lateral * 0.12,
				normal = normal,
				lateral = lateral,
				collector = collector,
				destination = destination + Vector3.yAxis,
				time = 0,
				organic = layer > 1,
				reduced = reduced,
				delay = math.floor((index - 1) / stride) * 0.012,
			})
		end
	end
	function controller:Step(dt)
		for i = #flights, 1, -1 do
			local f = flights[i]
			f.time += dt
			local time = math.max(0, f.time - f.delay)
			if time >= 1.05 then
				f.part:Destroy()
				table.remove(flights, i)
				continue
			end
			if f.reduced then
				f.part.Transparency = math.clamp(time / 0.35, 0, 1)
				if time >= 0.35 then
					f.part:Destroy()
					table.remove(flights, i)
				end
				continue
			end
			local position, rotation = f.start, f.rotation
			if time < 0.16 then
				local t = time / 0.16
				local ease = t * t * (3 - 2 * t)
				position = f.start:Lerp(f.peel, ease)
				rotation *= CFrame.Angles(0.12 * ease, 0, 0.06 * ease)
			elseif time < 0.38 then
				local t = (time - 0.16) / 0.22
				position = f.peel
					+ f.normal * (t * 0.9)
					+ f.lateral * (t * 0.3)
					+ Vector3.yAxis * (0.35 * t - 1.6 * t * t)
				rotation *= CFrame.Angles(t * 0.45, t * 0.3, t * 0.14)
				if f.organic then
					f.part.Size = f.size * Vector3.new(1 + t * 0.12, 1 - t * 0.18, 1 + t * 0.06)
				end
			else
				local t = (time - 0.38) / 0.67
				local travel = t * t * (3 - 2 * t)
				local character = f.collector and f.collector.Character
				local human = character and character:FindFirstChildOfClass("Humanoid")
				local root = human and human.Health > 0 and character:FindFirstChild("HumanoidRootPart")
				local destination = root and root.Position + Vector3.yAxis * 0.35 or f.destination
				if (destination - f.start).Magnitude > 40 then
					destination = f.destination
				end
				local release = f.peel + f.normal * 0.9 + f.lateral * 0.3 - Vector3.yAxis * 1.25
				local control = release + f.normal * 1.2 + Vector3.yAxis * 1.4
				position = release * (1 - travel) ^ 2
					+ control * (2 * (1 - travel) * travel)
					+ destination * travel ^ 2
				rotation *= CFrame.Angles(0.12 + travel * 0.45, travel * 0.35, 0.06)
				f.part.Size = f.size * (1 - 0.94 * travel)
				f.part.PivotOffset = CFrame.new(f.pivotOffset.Position * (1 - 0.94 * travel))
					* f.pivotOffset.Rotation
				f.part.Transparency = math.clamp((t - 0.86) / 0.14, 0, 1)
			end
			f.part:PivotTo(CFrame.new(position) * rotation)
		end
	end
	return controller
end
return M
