-- Original stress-and-release presentation. spr (MIT) drives bounded local impulses.
local S = {}
function S.Start(egg, config)
	local Run = game:GetService("RunService")
	local shared = game.ReplicatedStorage.VesperShared
	local spr = require(shared.Packages.spr)
	local library = shared:WaitForChild("FractureLibrary")
	local folder = Instance.new("Folder")
	folder.Name = "LocalShellReactions"
	folder.Parent = workspace
	local tracked, active, membranes, detached = {}, {}, {}, {}
	local released = {}
	local resetting = {}
	local roundState = shared:WaitForChild("RoundState")
	local Phase = require(shared.ExpeditionPhase)
	local A = config.Appearance
	local function snapshot(state)
		local poses = {}
		for _, part in state.model:GetChildren() do
			if part:IsA("BasePart") and not part:GetAttribute("CrackInterior") then
				poses[part.Name] = part.CFrame
			end
		end
		return poses
	end
	local function remove(p, remember)
		local state = active[p]
		if state then
			if remember then
				detached[state.info.section.Name] = { poses = snapshot(state), expires = os.clock() + 1 }
			end
			spr.stop(state.stress)
			spr.stop(state.impulse)
			state.model:Destroy()
			active[p] = nil
		end
		p.LocalTransparencyModifier = released[p] and 1 or 0
		if tracked[p] then
			p.CastShadow = tracked[p].castShadow
		end
	end
	local function fill(state, fractured)
		local restFrame = state.info.cf
		local previousWhole = not state.fractured and state.model:FindFirstChild("Plate")
		if state.info.layer == 1 and previousWhole then
			restFrame = previousWhole.CFrame
		end
		for _, part in state.model:GetChildren() do
			if part:IsA("BasePart") then
				part:Destroy()
			end
		end
		state.fractured = fractured
		state.lastStress, state.lastImpulse = nil, nil
		local source = library:FindFirstChild(state.info.template)
		local pieces = fractured and source and source:GetChildren() or { state.info.part }
		for _, part in pieces do
			local copy = part:Clone()
			copy.Anchored = true
			copy.CanCollide = false
			copy.CanTouch = false
			copy.CanQuery = false
			copy.LocalTransparencyModifier = 0
			copy.Transparency = 0
			copy.CastShadow = false
			if state.info.layer == 1 then
				local original = state.info.part
				copy.Color = original.Color
				copy.Material = original.Material
				copy.MaterialVariant = original.MaterialVariant
				copy.Reflectance = original.Reflectance
				copy.CastShadow = false
				if copy:IsA("MeshPart") and original:IsA("MeshPart") then
					copy.TextureID = original.TextureID
				end
				local finish = original:FindFirstChildOfClass("SurfaceAppearance")
				local previous = copy:FindFirstChildOfClass("SurfaceAppearance")
				if previous then
					previous:Destroy()
				end
				if finish then
					finish:Clone().Parent = copy
				end
			end
			copy.CFrame = fractured and restFrame * copy:GetAttribute("RelativeCFrame") or restFrame
			copy.Parent = state.model
		end
	end
	local function ensure(p, fractured)
		local state = active[p]
		local info = tracked[p]
		if not state then
			local model = Instance.new("Model")
			model.Name = "Stress_" .. info.section.Name
			model:SetAttribute("SectionId", info.section.Name)
			local stress = Instance.new("NumberValue")
			stress.Name = "Stress"
			stress.Parent = model
			local impulse = Instance.new("NumberValue")
			impulse.Name = "Impulse"
			impulse.Parent = model
			state = { info = info, model = model, stress = stress, impulse = impulse, expires = 0 }
			active[p] = state
			fill(state, fractured)
			model.Parent = folder
		elseif fractured and not state.fractured then
			fill(state, true)
		end
		p.LocalTransparencyModifier = 1
		if info.layer == 1 then
			p.CastShadow = false
		end
		return state
	end
	local function update(p)
		local info = tracked[p]
		if not info then
			return
		end
		local phase = Phase.Read(roundState)
		if phase == "Selecting" or phase == "Delivering" then
			remove(p, false)
			membranes[p] = nil
			info.presentationHidden = true
			p.LocalTransparencyModifier = 1
			return
		elseif info.presentationHidden then
			info.presentationHidden = nil
			p.LocalTransparencyModifier = released[p] and 1 or 0
		end
		local section = info.section
		info.maxHealth = section:GetAttribute("MaxHP") or config.Layers[info.layer].Durability
		local hp = section:GetAttribute("HP") or info.maxHealth
		local exposed = section:GetAttribute("Exposed")
		if resetting[p] then
			if hp < info.maxHealth or section:GetAttribute("Intact") ~= true then
				return
			end
			resetting[p] = nil
			released[p] = nil
			p.LocalTransparencyModifier = 0
		end
		if released[p] or hp <= 0 or section:GetAttribute("Intact") == false then
			released[p] = true
			membranes[p] = nil
			p.LocalTransparencyModifier = 1
			local pending = active[p]
			if pending then
				pending.awaitingRelease = pending.awaitingRelease or os.clock() + 0.35
			end
			return
		end
		if not exposed then
			remove(p, false)
			return
		end
		if hp >= info.maxHealth and active[p] then
			remove(p, false)
		elseif (info.layer == 1 and hp < info.maxHealth) or hp / info.maxHealth <= A.LightCrackHealth then
			local camera = workspace.CurrentCamera
			if not camera or (camera.CFrame.Position - p.Position).Magnitude > 95 then
				return
			end
			local count = 0
			for _ in active do
				count += 1
			end
			if count >= 96 and not active[p] then
				return
			end
			local state = ensure(p, true)
			local target = 1 - hp / info.maxHealth
			state.firstDamageFraction = state.firstDamageFraction or target
			if state.targetStress ~= target then
				state.targetStress = target
				spr.target(state.stress, 1, A.StressFrequency, { Value = target })
			end
		end
		if info.layer > 1 then
			membranes[p] = info
		end
		-- Damage opens the real fracture surfaces; the baked finish never swaps.
	end
	local function register(p)
		if not p:IsA("BasePart") or not p.Parent or p.Parent.Parent ~= egg.Sections or tracked[p] then
			return
		end
		local section = p.Parent
		local li = section:GetAttribute("Layer")
		if not config.Layers[li] then
			return
		end
		local delta = p.Position - (config.Geometry.Base + Vector3.new(0, config.Geometry.Height * 0.5, 0))
		local normal = Vector3.new(delta.X, delta.Y * 0.5, delta.Z)
		local info = {
			part = p,
			section = section,
			cf = p.CFrame,
			color = p.Color,
			castShadow = p.CastShadow,
			layer = li,
			maxHealth = section:GetAttribute("MaxHP") or config.Layers[li].Durability,
			template = string.format("L%d_R%02d", li, section:GetAttribute("Row")),
			normal = normal.Magnitude > 0.001 and normal.Unit or Vector3.yAxis,
			connections = {},
		}
		tracked[p] = info
		if li > 1 then
			info.outerName = string.format(
				"L%d_R%02d_C%02d",
				li - 1,
				section:GetAttribute("Row"),
				section:GetAttribute("Column")
			)
			info.phase = (
				section:GetAttribute("Row") * 0.13
				+ section:GetAttribute("Column") * 0.055
				+ li * 0.21
			) % 1
			local outer = egg.Sections:FindFirstChild(info.outerName)
			local function refreshPulse()
				if outer and outer:GetAttribute("Intact") == false and not released[p] then
					membranes[p] = info
				else
					membranes[p] = nil
					-- Color is owned by the current server egg variant.
				end
			end
			if outer then
				table.insert(
					info.connections,
					outer:GetAttributeChangedSignal("Intact"):Connect(refreshPulse)
				)
			end
			refreshPulse()
		end
		for _, attribute in { "HP", "Exposed", "Intact" } do
			table.insert(
				info.connections,
				section:GetAttributeChangedSignal(attribute):Connect(function()
					update(p)
				end)
			)
		end
		update(p)
	end
	for _, section in egg.Sections:GetChildren() do
		local p = section:FindFirstChild("Plate")
		if p then
			register(p)
		end
	end
	egg.Sections.DescendantAdded:Connect(register)
	egg.Sections.DescendantRemoving:Connect(function(p)
		local info = tracked[p]
		if not info then
			return
		end
		remove(p, false)
		for _, c in info.connections do
			c:Disconnect()
		end
		released[p] = nil
		tracked[p] = nil
		membranes[p] = nil
	end)
	local lastPulse = 0
	Run.Heartbeat:Connect(function(dt)
		local now = os.clock()
		for id, item in detached do
			if now > item.expires then
				detached[id] = nil
			end
		end
		for p, state in active do
			local info = state.info
			if state.awaitingRelease then
				if now >= state.awaitingRelease then
					remove(p, true)
				end
				continue
			end
			if not p.Parent or p.Transparency >= 1 then
				released[p] = true
				remove(p, true)
				continue
			end
			if
				not state.fractured
				and not state.organic
				and now > state.expires
				and math.abs(state.impulse.Value) < 0.001
			then
				remove(p, false)
				continue
			end
			local stress = math.clamp(state.stress.Value, 0, 1)
			local impulse = state.impulse.Value
			if
				not state.organic
				and now > (state.crackSettlingUntil or 0)
				and state.lastStress
				and math.abs(stress - state.lastStress) < 0.0001
				and math.abs(impulse - (state.lastImpulse or 0)) < 0.0001
			then
				continue
			end
			state.lastStress, state.lastImpulse = stress, impulse
			local loosen = math.clamp((stress - 0.55) / 0.45, 0, 1)
			local displacement = info.normal
				* math.clamp(state.impulse.Value, -A.RippleAmplitude * 2, A.RippleAmplitude)
			for _, piece in state.model:GetChildren() do
				if piece:IsA("BasePart") then
					if info.layer == 1 then
						-- One pivot for the shell and its cut surfaces, including the
						-- impact recoil. Damage remains after this recoil reaches zero.
						local plateFrame = (info.cf + displacement)
							* CFrame.Angles(impulse * 0.07, 0, -impulse * 0.055)
						if state.fractured then
							local direction = piece:GetAttribute("FractureDirection")
							local localNormal = piece:GetAttribute("SurfaceNormal") or Vector3.zAxis
							local center = piece:GetAttribute("FractureCenter") or Vector3.zero
							local seed = piece:GetAttribute("CrackSeed") or 0.5
							local origin = state.firstImpact or Vector3.zero
							local distance = (center - origin).Magnitude
								/ math.max(info.part.Size.Magnitude * 0.55, 0.1)
							local threshold = 0.015 + math.clamp(distance, 0, 1) * 0.48 + seed * 0.12
							local localDamage =
								math.max(stress, (state.crackBias and state.crackBias[piece.Name]) or 0)
							local target = math.clamp((localDamage - threshold) / 0.34, 0, 1)
							if state.hitSites and state.hitSites[piece.Name] then
								target = math.max(target, 0.16 + stress * 0.35)
							end
							state.crackGrowth = state.crackGrowth or {}
							local previous = state.crackGrowth[piece.Name] or 0
							local opening = previous
								+ (math.max(previous, target) - previous) * (1 - math.exp(-dt * 24))
							state.crackGrowth[piece.Name] = opening
							local gap = (0.025 * opening + 0.075 * localDamage * opening)
								* math.min(1, info.part.Size.Magnitude / 2)
							local cf = plateFrame * piece:GetAttribute("RelativeCFrame")
							local axis = localNormal:Cross(direction)
							local pivot = piece:GetAttribute("FragmentPivot") or Vector3.zero
							if axis.Magnitude > 0.001 then
								cf *= CFrame.new(pivot) * CFrame.fromAxisAngle(
									axis.Unit,
									math.rad(3.5) * loosen * opening
								) * CFrame.new(-pivot)
							end
							piece.CFrame = cf + plateFrame:VectorToWorldSpace(direction) * gap
							piece.Color = info.part.Color
						else
							piece.CFrame = plateFrame
							piece.Color = info.part.Color
						end
						continue
					end
					local cf = info.cf
					if state.fractured then
						local direction = piece:GetAttribute("FractureDirection")
						local localNormal = piece:GetAttribute("SurfaceNormal") or Vector3.zAxis
						local axis = localNormal:Cross(direction)
						cf = info.cf * piece:GetAttribute("RelativeCFrame")
						if axis.Magnitude > 0.001 then
							cf *= CFrame.fromAxisAngle(axis.Unit, math.rad(A.StressTilt) * loosen)
						end
						local gap = A.CrackGap * stress * stress
						cf += info.cf:VectorToWorldSpace(direction) * gap
					end
					local organic = 0
					if state.organic then
						local t = workspace:GetServerTimeNow() * 1.6 - info.phase * 2
						organic = (math.sin(t) * 0.5 + 0.5) ^ 6 * 0.24 + math.sin(t * 2.1) * 0.035
					end
					piece.CFrame = (cf + displacement + info.normal * organic)
						* CFrame.Angles(impulse * 0.07, 0, -impulse * 0.055)
					piece.Color = info.part.Color
				end
			end
		end
		if now - lastPulse >= 0.08 then
			lastPulse = now
			local camera = workspace.CurrentCamera
			local visibleCount = 0
			for p, info in membranes do
				local visible = p.Parent
					and not released[p]
					and camera
					and (camera.CFrame.Position - info.cf.Position).Magnitude < 65
					and not game.Players.LocalPlayer:GetAttribute("ReducedMotion")
				if visible and visibleCount < 36 then
					visibleCount += 1
					local state = ensure(p, false)
					state.organic = true
				elseif active[p] and active[p].organic then
					active[p].organic = false
					if not active[p].fractured then
						remove(p, false)
					end
				end
			end
		end
	end)
	roundState:GetAttributeChangedSignal("PhaseSnapshot"):Connect(function()
		for p in tracked do
			update(p)
		end
	end)
	roundState:GetAttributeChangedSignal("RoundId"):Connect(function()
		for p in active do
			remove(p, false)
		end
		table.clear(detached)
		for p in tracked do
			local info = tracked[p]
			-- Color is owned by the current server egg variant.
			membranes[p] = nil
			resetting[p] = true
			update(p)
		end
	end)
	local controller = {}
	function controller:Detach(id)
		if not id then
			return
		end
		local section = egg.Sections:FindFirstChild(id)
		local p = section and section:FindFirstChild("Plate")
		if p then
			released[p] = true
			remove(p, true)
		end
		local item = detached[id]
		detached[id] = nil
		return item and item.poses
	end
	function controller:Impact(section, hitPosition, damage)
		local phase = Phase.Read(roundState)
		if phase == "Selecting" or phase == "Delivering" then
			return
		end
		if not section then
			return
		end
		local row, col, li =
			section:GetAttribute("Row"), section:GetAttribute("Column"), section:GetAttribute("Layer")
		local center = section:GetAttribute("Center")
		if not row or not col or not center then
			return
		end
		local camera = workspace.CurrentCamera
		if not camera or (camera.CFrame.Position - center).Magnitude > 100 then
			return
		end
		if li == 1 then
			local p = section:FindFirstChild("Plate")
			if p and tracked[p] and not released[p] and section:GetAttribute("Intact") then
				local state = ensure(p, true)
				local position = typeof(hitPosition) == "Vector3" and hitPosition or center
				local origin = state.info.cf:PointToObjectSpace(position)
				state.firstImpact = state.firstImpact or origin
				state.crackBias = state.crackBias or {}
				state.hitSites = state.hitSites or {}
				local fraction = math.clamp((tonumber(damage) or 0) / state.info.maxHealth, 0, 1)
				local scale = math.max(p.Size.Magnitude * 0.45, 0.1)
				local nearest = {}
				for _, piece in state.model:GetChildren() do
					if piece:IsA("BasePart") and not piece:GetAttribute("CrackInterior") then
						local point = piece:GetAttribute("FractureCenter") or Vector3.zero
						local influence = 0.55 + 1.2 * math.exp(-(point - origin).Magnitude / scale)
						table.insert(nearest, { name = piece.Name, distance = (point - origin).Magnitude })
						state.crackBias[piece.Name] =
							math.min(1.4, (state.crackBias[piece.Name] or 0) + fraction * influence)
					end
				end
				table.sort(nearest, function(a, b)
					return a.distance < b.distance
				end)
				for i = 1, math.min(3, #nearest) do
					state.hitSites[nearest[i].name] = true
				end
				state.crackSettlingUntil = os.clock() + 0.45
				state.lastStress = nil
			end
		end
		if game:GetService("Players").LocalPlayer:GetAttribute("ReducedMotion") then
			return
		end
		local candidates = {}
		for dr = -2, 2 do
			for dc = -2, 2 do
				local neighbor = egg.Sections:FindFirstChild(
					string.format("L%d_R%02d_C%02d", li, row + dr, (col + dc) % config.Geometry.Columns)
				)
				local p = neighbor and neighbor:FindFirstChild("Plate")
				if
					p
					and tracked[p]
					and not released[p]
					and neighbor:GetAttribute("Intact")
					and neighbor:GetAttribute("Exposed")
				then
					local distance = (neighbor:GetAttribute("Center") - center).Magnitude
					if distance <= A.RippleRadius then
						table.insert(candidates, { part = p, distance = distance })
					end
				end
			end
		end
		table.sort(candidates, function(a, b)
			return a.distance < b.distance
		end)
		for i = 1, math.min(#candidates, A.RippleMaxPlates) do
			local c = candidates[i]
			local atRound = roundState:GetAttribute("RoundId")
			task.delay(c.distance * 0.018, function()
				local phase = Phase.Read(roundState)
				if
					phase == "Selecting"
					or phase == "Delivering"
					or roundState:GetAttribute("RoundId") ~= atRound
					or released[c.part]
					or not c.part.Parent
				then
					return
				end
				local state = ensure(c.part, false)
				local weight = c.distance < 0.01 and 1.4 or 0.65 * (1 - c.distance / A.RippleRadius)
				state.expires = os.clock() + A.RippleDuration
				state.impulse.Value = -A.RippleAmplitude * weight
				spr.target(state.impulse, li == 1 and 0.38 or 0.24, li == 1 and 8 or 3.8, { Value = 0 })
			end)
		end
	end
	return controller
end
return S
