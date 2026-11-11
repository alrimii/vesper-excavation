-- Client presentation only. Sound/contact/charge events cannot apply damage or rewards.
local M = {}
function M.Start(folder, state)
	local Players = game:GetService("Players")
	local Tween = game:GetService("TweenService")
	local C = require(script.Parent.ExcavationConfig)
	local player = Players.LocalPlayer
	local audio = C.MiningAudio
	local loops, sounds, flashes, seen, order = {}, {}, {}, {}, {}
	local api = {}
	local function count(t)
		local n = 0
		for _ in t do
			n += 1
		end
		return n
	end
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
		if not near(point) or count(sounds) >= audio.MaxSounds then
			return
		end
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
		if entry then
			stopSound(entry.audio)
			loops[userId] = nil
		end
	end
	function api:Cancel(userId, sequence)
		if not sequence then
			self:StopDrill(userId)
		end
	end
	function api:Hit(userId, point, section, result)
		if result.Family == "Pickaxe" then
			play("Pickaxe", point, false)
		end
		if result.Family ~= "Drill" then
			return
		end
		if result.Broken then
			self:StopDrill(userId)
			return
		end
		if not near(point) then
			return
		end
		local owner = Players:GetPlayerByUserId(userId)
		local character = owner and owner.Character
		local tool = character and character:FindFirstChildOfClass("Tool")
		if not tool or tool:GetAttribute("ToolFamily") ~= "Drill" then
			return
		end
		local entry = loops[userId]
		if not entry then
			if count(loops) >= audio.MaxLoops then
				return
			end
			local playing = play("Drill", point, true)
			if not playing then
				return
			end
			entry = { audio = playing, character = character, tool = tool }
			loops[userId] = entry
		end
		entry.section, entry.round = section, result.RoundId
		entry.expires = os.clock() + math.min(0.55, result.Interval + C.Tools.Drill.ContactLeaseGrace)
		if entry.audio then
			entry.audio.part.Position = point
		end
	end
	function api:Charge(userId)
		-- The server's replicated model is the only placed charge representation.
		self:StopDrill(userId)
	end
	function api:Blast(userId, sequence, point, normal, round)
		self:Cancel(userId, sequence)
		if round ~= state:GetAttribute("RoundId") then
			return false
		end
		local key = tostring(round) .. ":" .. userId .. ":" .. sequence
		if seen[key] then
			return false
		end
		seen[key] = true
		table.insert(order, key)
		if #order > 128 then
			seen[table.remove(order, 1)] = nil
		end
		play("Explosive", point, false)
		if not near(point) or count(flashes) >= 3 then
			return true
		end
		local reduced = player:GetAttribute("ReducedMotion") == true
		local p = part("ExcavationBurst", point + normal * 0.08)
		p.CFrame = CFrame.lookAt(p.Position, p.Position + normal)
		local function particles(name, texture, color, size, life, speed, amount)
			local e = Instance.new("ParticleEmitter")
			e.Name = name
			e.Texture = texture
			e.Color = ColorSequence.new(color)
			e.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, size * 0.25),
				NumberSequenceKeypoint.new(0.35, size),
				NumberSequenceKeypoint.new(1, size * 0.8),
			})
			e.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.22),
				NumberSequenceKeypoint.new(0.3, 0.45),
				NumberSequenceKeypoint.new(1, 1),
			})
			e.Lifetime = NumberRange.new(life * 0.7, life)
			e.Speed = NumberRange.new(speed * 0.4, speed)
			e.EmissionDirection = Enum.NormalId.Front
			e.SpreadAngle = Vector2.new(65, 65)
			e.Drag = 6
			e.Rate = 0
			e.Rotation = NumberRange.new(0, 360)
			e.RotSpeed = NumberRange.new(-15, 15)
			e.LightInfluence = 0.65
			e.Parent = p
			e:Emit(reduced and math.max(1, math.floor(amount * 0.35)) or amount)
		end
		particles(
			"ContactFlash",
			"rbxasset://textures/particles/sparkles_main.dds",
			Color3.fromRGB(255, 214, 137),
			reduced and 0.7 or 1.5,
			0.12,
			1,
			2
		)
		particles(
			"ShellDust",
			"rbxasset://textures/particles/smoke_main.dds",
			Color3.fromRGB(177, 159, 128),
			1.8,
			0.65,
			7,
			12
		)
		particles(
			"AfterSmoke",
			"rbxasset://textures/particles/smoke_main.dds",
			Color3.fromRGB(105, 111, 107),
			1.1,
			0.9,
			2,
			3
		)
		if not reduced then
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(255, 201, 113)
			light.Brightness = 1.5
			light.Range = 7
			light.Shadows = false
			light.Parent = p
			Tween:Create(light, TweenInfo.new(0.12), { Brightness = 0 }):Play()
			local right = p.CFrame.RightVector
			local up = p.CFrame.UpVector
			for i = 1, 6 do
				local chip = Instance.new("WedgePart")
				chip.Name = "ShellChip"
				chip.Size = Vector3.new(0.16, 0.10, 0.23)
				chip.Material = Enum.Material.Limestone
				chip.Color = Color3.fromRGB(183, 173, 151)
				chip.CFrame = p.CFrame * CFrame.Angles(i * 0.8, i, 0)
				chip.Anchored = true
				chip.CastShadow = false
				chip.CanCollide, chip.CanTouch, chip.CanQuery = false, false, false
				chip.Parent = p
				local direction = normal * (1.2 + i * 0.16)
					+ right * math.cos(i * 2.4) * 1.4
					+ up * math.sin(i * 2.4)
				Tween:Create(
					chip,
					TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Position = point + direction, Transparency = 1 }
				):Play()
			end
		end
		flashes[p] = os.clock() + 1.05
		return true
	end
	function api:Step(localRunning, localSection)
		local now, round = os.clock(), state:GetAttribute("RoundId")
		local active = state:GetAttribute("Status") == "Excavating"
		for userId, entry in loops do
			local owner = Players:GetPlayerByUserId(userId)
			local hum = owner and owner.Character and owner.Character:FindFirstChildOfClass("Humanoid")
			if
				not active
				or entry.round ~= round
				or now >= entry.expires
				or not hum
				or hum.Health <= 0
				or owner.Character ~= entry.character
				or entry.tool.Parent ~= entry.character
				or not entry.section.Parent
				or not entry.section:GetAttribute("Intact")
				or (userId == player.UserId and (not localRunning or localSection ~= entry.section))
			then
				self:StopDrill(userId)
			end
		end
		for entry in sounds do
			if not entry.part.Parent or (entry.expires and now >= entry.expires) then
				stopSound(entry)
			else
				entry.sound.Volume = entry.gain * (player:GetAttribute("SFXVolume") or 1)
			end
		end
		for p, expiry in flashes do
			if now >= expiry then
				p:Destroy()
				flashes[p] = nil
			end
		end
	end
	function api:Clear()
		for userId in loops do
			self:StopDrill(userId)
		end
		for entry in sounds do
			stopSound(entry)
		end
		for p in flashes do
			p:Destroy()
			flashes[p] = nil
		end
	end
	folder.Destroying:Connect(function()
		api:Clear()
	end)
	return api
end
return M
