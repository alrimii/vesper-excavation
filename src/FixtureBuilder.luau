-- Fused hollow housings with recessed lenses; no overlapping bezel/end-cap faces.
local B = {}
local function part(parent, name, size, cf, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.Metal
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Parent = parent
	return p
end
function B.Build()
	local lab = workspace.VesperLab
	local lamps = {}
	for _, p in lab:GetDescendants() do
		if
			p:IsA("BasePart")
			and (
				p.Name == "CeilingFixture"
				or p.Name == "DeckLamp"
				or p.Name == "UpperShellLight"
				or p.Name == "HeaderLight"
			)
		then
			table.insert(lamps, p)
		end
	end
	local old = lab:FindFirstChild("FixtureHousings")
	if old then
		old:Destroy()
	end
	local folder = Instance.new("Model")
	folder.Name = "FixtureHousings"
	folder.Parent = lab
	local templates = {}
	local dark = Color3.fromRGB(76, 88, 94)
	local steel = Color3.fromRGB(133, 147, 153)
	for index, lamp in lamps do
		local mount = lamp:GetAttribute("FixtureMount") or lamp.CFrame
		lamp:SetAttribute("FixtureMount", mount)
		local size = lamp:GetAttribute("OriginalLensSize") or lamp.Size
		lamp:SetAttribute("OriginalLensSize", size)
		local w, d = size.X, size.Z
		local key = w .. ":" .. d
		if not templates[key] then
			local outer = part(
				game.ServerStorage,
				"HousingWork",
				Vector3.new(w + 1, 0.9, d + 0.9),
				CFrame.new(0, 0.4, 0),
				dark
			)
			local cutter = part(
				game.ServerStorage,
				"LensRecess",
				Vector3.new(w - 0.02, 0.64, d - 0.02),
				CFrame.new(0, 0.14, 0),
				dark
			)
			local housing =
				outer:SubtractAsync({ cutter }, Enum.CollisionFidelity.Box, Enum.RenderFidelity.Automatic)
			outer:Destroy()
			cutter:Destroy()
			housing.UsePartColor = true
			housing.Color = dark
			housing.Material = Enum.Material.Metal
			housing.CanCollide = false
			housing.CanQuery = false
			housing.CanTouch = false
			housing.CastShadow = false
			housing.Anchored = true
			templates[key] = housing
		end
		local m = Instance.new("Model")
		m.Name = "IndustrialLuminaire" .. index
		m.Parent = folder
		local cf = mount * CFrame.new(0, -0.8, 0)
		if lamp.Name == "DeckLamp" then
			cf = CFrame.lookAt(mount.Position + Vector3.new(0, 1, 0), Vector3.new(0, 8, 0))
				* CFrame.Angles(math.pi / 2, 0, 0)
		end
		lamp.Size = Vector3.new(w - 0.4, 0.12, math.max(0.16, d - 0.25))
		lamp.CFrame = cf * CFrame.new(0, 0.04, 0)
		local housing = templates[key]:Clone()
		housing.Name = "ContinuousHousing"
		housing.CFrame = cf * templates[key].CFrame
		housing.Parent = m
		for _, x in { -1, 1 } do
			if lamp.Name ~= "DeckLamp" then
				part(
					m,
					"Mount",
					Vector3.new(0.35, 0.36, math.max(0.3, d * 0.55)),
					cf * CFrame.new(x * w * 0.32, 1.03, 0),
					steel
				)
			end
			for _, z in { -1, 1 } do
				local bolt = part(
					m,
					"Fastener",
					Vector3.new(0.08, 0.15, 0.15),
					cf
						* CFrame.new(x * (w / 2 + 0.22), -0.09, z * (d / 2 + 0.16))
						* CFrame.Angles(0, 0, math.pi / 2),
					steel
				)
				bolt.Shape = Enum.PartType.Cylinder
			end
		end
		if lamp.Name == "DeckLamp" or lamp.Name == "UpperShellLight" then
			local a = lamp.Name == "DeckLamp" and mount.Position - Vector3.new(0, 0.3, 0)
				or mount.Position + Vector3.new(0, 1.2, 0)
			local b = cf:PointToWorldSpace(Vector3.new(0, 0.86, 0))
			part(
				m,
				"ConnectedSupport",
				Vector3.new(0.28, 0.28, (a - b).Magnitude),
				CFrame.lookAt((a + b) / 2, b),
				steel
			)
		end
		if index % 12 == 0 then
			task.wait()
		end
	end
	for _, t in templates do
		t:Destroy()
	end
	local repaired = 0
	for _, room in lab.Rooms:GetChildren() do
		if not room:GetAttribute("DoorWallOverlapFixed") then
			local jambs = {}
			for _, p in room:GetChildren() do
				if p.Name == "PortalJamb" then
					table.insert(jambs, p)
				end
			end
			for _, p in room:GetChildren() do
				if p.Name == "FrontPanel" then
					local nearest = jambs[1]
					for _, j in jambs do
						if
							(j.Position - p.Position).Magnitude < (nearest.Position - p.Position).Magnitude
						then
							nearest = j
						end
					end
					local side = math.sign((p.Position - nearest.Position):Dot(p.CFrame.RightVector))
					p.Size = Vector3.new(16.5, p.Size.Y, p.Size.Z)
					p.CFrame += p.CFrame.RightVector * (side * 0.75)
				elseif p.Name == "PortalHeader" then
					p.Size = Vector3.new(31, p.Size.Y, p.Size.Z)
				end
			end
			room:SetAttribute("DoorWallOverlapFixed", true)
			repaired += 1
		end
	end
	return { fixtures = #lamps, doorsRepaired = repaired, parts = #folder:GetDescendants() }
end
return B
