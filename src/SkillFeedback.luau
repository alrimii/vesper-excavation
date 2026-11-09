-- Bounded local presentation; never grants damage, XP, points or materials.
local M = {}
function M.Start(player, gui, targeter)
	local Shared = script.Parent
	local C = require(Shared.SkillCatalog)
	local Http = game:GetService("HttpService")
	local Run = game:GetService("RunService")
	local Debris = game:GetService("Debris")
	local folder = Instance.new("Folder")
	folder.Name = "LocalSkillEffects"
	folder.Parent = workspace
	local accents, seen = {}, {}
	local survey = {}
	for i = 1, 4 do
		local h = Instance.new("Highlight")
		h.Name = "FaultSurvey" .. i
		h.DepthMode = Enum.HighlightDepthMode.Occluded
		h.FillTransparency = 1
		h.OutlineColor = Color3.fromRGB(255, 203, 116)
		h.Enabled = false
		h.Parent = folder
		survey[i] = h
	end
	local function clear()
		for _, item in accents do
			item:Destroy()
		end
		table.clear(accents)
		table.clear(seen)
		for _, h in survey do
			h.Enabled = false
		end
	end
	local function segment(a, b)
		if (a - b).Magnitude < 0.01 then
			return
		end
		while #accents >= 12 do
			table.remove(accents, 1):Destroy()
		end
		local part = Instance.new("Part")
		part.Name = "ConfirmedArc"
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(124, 242, 235)
		part.Size = Vector3.new(0.055, 0.055, (a - b).Magnitude)
		part.CFrame = CFrame.lookAt((a + b) / 2, b)
		part.Parent = folder
		table.insert(accents, part)
		Debris:AddItem(part, 0.18)
		task.delay(0.18, function()
			local index = table.find(accents, part)
			if index then
				table.remove(accents, index)
			end
		end)
	end
	Shared.RoundState:GetAttributeChangedSignal("RoundId"):Connect(clear)
	player.CharacterRemoving:Connect(clear)
	Shared.Remotes.Feedback.OnClientEvent:Connect(function(kind, uid, round, sequence, points)
		if
			kind ~= "SkillLightning"
			or round ~= Shared.RoundState:GetAttribute("RoundId")
			or type(points) ~= "table"
		then
			return
		end
		local key = tostring(uid) .. ":" .. tostring(sequence)
		if seen[key] then
			return
		end
		seen[key] = true
		task.delay(10, function()
			seen[key] = nil
		end)
		local camera = workspace.CurrentCamera
		if not camera or not points[1] or (camera.CFrame.Position - points[1]).Magnitude > 90 then
			return
		end
		local reduced = player:GetAttribute("ReducedEffects") or player:GetAttribute("ReducedMotion")
		if #points == 1 or reduced then
			for i = 1, math.min(#points, 3) do
				segment(points[i] - Vector3.yAxis * 0.10, points[i] + Vector3.yAxis * 0.10)
			end
		else
			for i = 2, math.min(#points, 3) do
				local a, b = points[i - 1], points[i]
				local mid = (a + b) / 2 + Vector3.yAxis * 0.16
				segment(a, mid)
				segment(mid, b)
			end
		end
	end)
	local elapsed = 0
	Run.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.25 then
			return
		end
		elapsed = 0
		for _, h in survey do
			h.Enabled = false
		end
		if player:GetAttribute("SkillTreeOpen") or player:GetAttribute("CoreMenuOpen") then
			return
		end
		local ok, ranks = pcall(Http.JSONDecode, Http, player:GetAttribute("SkillRanks") or "{}")
		local rank = ok and ranks["impact.fault_survey"] or 0
		if rank == 0 then
			return
		end
		local target, point = targeter:Get()
		local ch = player.Character
		local head = ch and ch:FindFirstChild("Head")
		if not target or not head then
			return
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { ch, folder }
		local candidates = {}
		for _, section in workspace.VesperLab.Egg.Sections:GetChildren() do
			local hp, maxHP, center =
				section:GetAttribute("HP"), section:GetAttribute("MaxHP"), section:GetAttribute("Center")
			if
				section ~= target
				and section:GetAttribute("Exposed")
				and section:GetAttribute("Intact")
				and not section:GetAttribute("Permanent")
				and type(hp) == "number"
				and type(maxHP) == "number"
				and maxHP > 0
				and hp > 0
				and hp / maxHP <= 0.35
				and typeof(center) == "Vector3"
				and (center - point).Magnitude <= (rank == 1 and 8 or 12)
			then
				local delta = center - head.Position
				local ray = delta.Magnitude > 0.01
					and workspace:Raycast(head.Position, delta.Unit * (delta.Magnitude + 0.7), params)
				if ray and ray.Instance.Parent == section then
					table.insert(candidates, { section = section, fraction = hp / maxHP })
				end
			end
		end
		table.sort(candidates, function(a, b)
			if a.fraction == b.fraction then
				return a.section.Name < b.section.Name
			end
			return a.fraction < b.fraction
		end)
		for i = 1, math.min(rank == 1 and 2 or 4, #candidates) do
			survey[i].Adornee = candidates[i].section
			survey[i].Enabled = true
		end
	end)
end
return M
