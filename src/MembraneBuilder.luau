-- Native CSG from uploaded mesh assets. No EditableMesh or upload permission required.
local M = {}
local shared = game.ReplicatedStorage.VesperShared
local G = require(shared.ExcavationConfig).Geometry
local center = G.Base + Vector3.yAxis * G.Height / 2
local template
local function sector(layer, lining)
	local inputs = {}
	local library = shared:WaitForChild("EggAssetPreload")
	-- One rotational sector is reused eight times, rather than rebuilding the full egg.
	for row = 0, G.Rows - 1 do
		local source = library:WaitForChild(string.format("L%d_R%02d", layer, row))
		for col = 0, (lining and 8 or 16) do
			local p = source:Clone()
			for _, child in p:GetChildren() do
				if child:IsA("SurfaceAppearance") then
					child:Destroy()
				end
			end
			p.TextureID, p.MaterialVariant = "", ""
			p.Color = Color3.new(1, 1, 1)
			if lining then
				p.Size *= Vector3.new(1.015, 1.025, (G.Columns / 72) * 1.035)
			end
			local rotation = CFrame.new(G.Base)
				* CFrame.Angles(0, (col + (row % 2) * 0.5) * math.pi * 2 / (lining and 72 or G.Columns), 0)
				* CFrame.new(-G.Base)
			p.CFrame = rotation * p.CFrame
			if lining then
				p.Position = center + (p.Position - center) * 0.985
				p.Size *= 0.985
			end
			table.insert(inputs, p)
		end
		if row % 8 == 0 then
			task.wait()
		end
	end
	local first = table.remove(inputs, 1)
	local ok, result = pcall(function()
		return game:GetService("GeometryService"):UnionAsync(first, inputs, {
			SplitApart = false,
			CollisionFidelity = Enum.CollisionFidelity.Hull,
			RenderFidelity = Enum.RenderFidelity.Precise,
		})
	end)
	first:Destroy()
	for _, p in inputs do
		p:Destroy()
	end
	assert(ok, tostring(result))
	assert(#result == 1, "Native membrane sector construction failed")
	local p = result[1]
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
	p.Material, p.Color = Enum.Material.SmoothPlastic, Color3.fromRGB(81, 57, 83)
	p.Transparency = 0
	return p
end
function M.Make()
	if not template then
		local generated, failure, remaining = {}, nil, 2
		for layer, key in { [1] = "delivery", [3] = "lining" } do
			task.spawn(function()
				local ok, result = pcall(sector, layer, layer == 3)
				if ok then
					generated[key] = result
				else
					failure = tostring(result)
				end
				remaining -= 1
			end)
		end
		while remaining > 0 do
			task.wait(0.1)
		end
		if failure then
			for _, p in generated do
				p:Destroy()
			end
			error(failure)
		end
		local veil = Instance.new("Model")
		veil.Name = "HatchingVeil"
		local seal = Instance.new("Model")
		seal.Name = "Seal"
		seal.Parent = veil
		local delivery = Instance.new("Model")
		delivery.Name = "DeliveryShell"
		veil.WorldPivot = CFrame.new(center)
		seal.WorldPivot = CFrame.new(center)
		delivery.WorldPivot = CFrame.new(center)
		delivery:SetAttribute("RestCFrame", CFrame.new(center))
		for i = 0, 7 do
			local turn = CFrame.new(center) * CFrame.Angles(0, i * math.pi / 4, 0) * CFrame.new(-center)
			local p = generated.lining:Clone()
			p.Name = "Petal" .. i
			p.CFrame = turn * p.CFrame
			p:SetAttribute("RestCFrame", p.CFrame)
			p:SetAttribute("RestSize", p.Size)
			local outward = Vector3.new(p.ExtentsCFrame.Position.X, 0, p.ExtentsCFrame.Position.Z).Unit
			p:SetAttribute("Angle", math.atan2(outward.Z, outward.X))
			local shell = p:Clone()
			shell.Name = "Seal" .. i
			shell.CanCollide = true
			shell.Parent = seal
			p.Transparency = 1
			p.Parent = veil
		end
		-- Four exact 17-column quarters: no scale change at the playable-shell handoff.
		for i = 0, 3 do
			local turn = CFrame.new(center) * CFrame.Angles(0, i * math.pi / 2, 0) * CFrame.new(-center)
			local d = generated.delivery:Clone()
			d.Name = "Surface" .. i
			d.CFrame = turn * d.CFrame
			d.Parent = delivery
		end
		for _, p in generated do
			p:Destroy()
		end
		local old = shared:FindFirstChild("DeliveryShell")
		if old then
			old:Destroy()
		end
		delivery.Parent = shared
		template = veil
	end
	return template:Clone()
end
return M
