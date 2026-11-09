-- Client presentation only. Sound/contact/charge events cannot apply damage or rewards.
local M = {}
function M.Start(folder, state)
	local Players = game:GetService("Players")
	local Tween = game:GetService("TweenService")
	local C = require(script.Parent.ExcavationConfig)
	local player = Players.LocalPlayer
	local audio = C.MiningAudio
	local loops, sounds, charges, flashes, seen, order = {}, {}, {}, {}, {}, {}
	local api = {}
	local function count(t) local n = 0 for _ in t do n += 1 end return n end
	local function near(point)
		local camera = workspace.CurrentCamera
		return camera and (camera.CFrame.Position - point).Magnitude <= audio.MaxDistance
	end
	local function part(name, point)
		local p = Instance.new("Part")
		p.Name, p.Size, p.Position = name, Vector3.one * 0.05, point
		p.Anchored, p.Transparency, p.CastShadow = true, 1, false
		p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
		p.Parent = folder
		return p
	end
	local function stopSound(entry)
		if entry then
			entry.sound:Stop()
			entry.part:Destroy()
			sounds[entry] = nil
		end
	end
	local function play(kind, point, loop)
		if not near(point) or count(sounds) >= audio.MaxSounds then return end
		local p = part("ToolAudio", point)
		local s = Instance.new("Sound")
		s.SoundId, s.Looped = audio[kind], loop
		s.RollOffMinDistance, s.RollOffMaxDistance = audio.MinDistance, audio.MaxDistance
		s.RollOffMode = Enum.RollOffMode.InverseTapered
		local gain = kind == "Explosive" and 0.24 or kind == "Drill" and 0.14 or 0.18
		s.Volume = gain * (player:GetAttribute("SFXVolume") or 1)
		s.Parent = p
		local entry = { part = p, sound = s, gain = gain, expires = not loop and os.clock() + 3.2 or nil }
		sounds[entry] = true
		s:Play()
		return entry
	end
	function api:StopDrill(userId)
		local entry = loops[userId]
		if entry then stopSound(entry.audio); loops[userId] = nil end
	end
	function api:Cancel(userId, sequence)
		if not sequence then self:StopDrill(userId) end
		local charge = charges[userId]
		if charge and (not sequence or charge.sequence == sequence) then
			charge.part:Destroy()
			charges[userId] = nil
		end
	end
	function api:Hit(userId, point, section, result)
		if result.Family == "Pickaxe" then play("Pickaxe", point, false) end
		if result.Family ~= "Drill" then return end
		if result.Broken then self:StopDrill(userId); return end
		if not near(point) then return end
		local owner = Players:GetPlayerByUserId(userId)
		local character = owner and owner.Character
		local tool = character and character:FindFirstChildOfClass("Tool")
		if not tool or tool:GetAttribute("ToolFamily") ~= "Drill" then return end
		local entry = loops[userId]
		if not entry then
			if count(loops) >= audio.MaxLoops then return end
			local playing = play("Drill", point, true)
			if not playing then return end
			entry = { audio = playing, character = character, tool = tool }
			loops[userId] = entry
		end
		entry.section, entry.round = section, result.RoundId
		entry.expires = os.clock() + math.min(0.55, result.Interval + C.Tools.Drill.ContactLeaseGrace)
		if entry.audio then entry.audio.part.Position = point end
	end
	function api:Charge(userId, sequence, point, normal, round, started)
		self:Cancel(userId)
		if round ~= state:GetAttribute("RoundId") or not near(point) or count(charges) >= 8 then return end
		if workspace:GetServerTimeNow() - started >= C.Tools.Explosive.Fuse then return end
		local p = part("ChargeCue", point + normal * 0.12)
		p.Shape, p.Size, p.Transparency = Enum.PartType.Ball, Vector3.one * 0.24, 0.1
		p.Material, p.Color = Enum.Material.SmoothPlastic, Color3.fromRGB(255, 191, 96)
		local gui = Instance.new("BillboardGui")
		gui.Size, gui.StudsOffsetWorldSpace = UDim2.fromOffset(110, 26), Vector3.new(0, 0.8, 0)
		gui.MaxDistance, gui.AlwaysOnTop, gui.Parent = 70, false, p
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
		label.Text, label.Font, label.TextSize = "CHARGE", Enum.Font.GothamBold, 14
		label.TextColor3, label.TextStrokeTransparency, label.Parent = p.Color, 0.3, gui
		local owner = Players:GetPlayerByUserId(userId)
		charges[userId] = { part = p, sequence = sequence, round = round, started = started,
			character = owner and owner.Character }
	end
	function api:Blast(userId, sequence, point, normal, round)
		self:Cancel(userId, sequence)
		if round ~= state:GetAttribute("RoundId") then return false end
		local key = tostring(round) .. ":" .. userId .. ":" .. sequence
		if seen[key] then return false end
		seen[key] = true; table.insert(order, key)
		if #order > 128 then seen[table.remove(order, 1)] = nil end
		play("Explosive", point, false)
		if not near(point) or count(flashes) >= 3 then return true end
		local reduced = player:GetAttribute("ReducedMotion") == true
		local p = part("BlastAccent", point + normal * 0.12)
		p.Shape, p.Material, p.Color = Enum.PartType.Ball, Enum.Material.SmoothPlastic, Color3.fromRGB(255, 207, 128)
		p.Size, p.Transparency = Vector3.one * (reduced and 0.8 or 0.3), 0.55
		Tween:Create(p, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = Vector3.one * (reduced and 0.8 or C.Tools.Explosive.Radius * 2), Transparency = 1 }):Play()
		flashes[p] = os.clock() + 0.24
		return true
	end
	function api:Step(localRunning, localSection)
		local now, round = os.clock(), state:GetAttribute("RoundId")
		local active = state:GetAttribute("Status") == "Excavating"
		for userId, entry in loops do
			local owner = Players:GetPlayerByUserId(userId)
			local hum = owner and owner.Character and owner.Character:FindFirstChildOfClass("Humanoid")
			if not active or entry.round ~= round or now >= entry.expires or not hum or hum.Health <= 0
				or owner.Character ~= entry.character or entry.tool.Parent ~= entry.character
				or not entry.section.Parent or not entry.section:GetAttribute("Intact")
				or (userId == player.UserId and (not localRunning or localSection ~= entry.section)) then
				self:StopDrill(userId)
			end
		end
		for userId, entry in charges do
			local owner = Players:GetPlayerByUserId(userId)
			local hum = owner and owner.Character and owner.Character:FindFirstChildOfClass("Humanoid")
			local tool = owner and owner.Character and owner.Character:FindFirstChildOfClass("Tool")
			if not active or round ~= entry.round or not hum or hum.Health <= 0 or owner.Character ~= entry.character
				or not tool or tool:GetAttribute("ToolFamily") ~= "Explosive"
				or workspace:GetServerTimeNow() - entry.started > C.Tools.Explosive.Fuse + 0.2 then
				entry.part:Destroy(); charges[userId] = nil
			end
		end
		for entry in sounds do
			if not entry.part.Parent or (entry.expires and now >= entry.expires) then stopSound(entry)
			else entry.sound.Volume = entry.gain * (player:GetAttribute("SFXVolume") or 1) end
		end
		for p, expiry in flashes do if now >= expiry then p:Destroy(); flashes[p] = nil end end
	end
	function api:Clear()
		for userId in loops do self:StopDrill(userId) end
		for userId, entry in charges do entry.part:Destroy(); charges[userId] = nil end
		for entry in sounds do stopSound(entry) end
		for p in flashes do p:Destroy(); flashes[p] = nil end
	end
	folder.Destroying:Connect(function() api:Clear() end)
	return api
end
return M
