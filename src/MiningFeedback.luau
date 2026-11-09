-- Receipts are presentation only. No client calculation or mutation of rewards.
local M = {}
-- No suitable permission-verified mining audio exists in the inspected project.
-- Leave empty until supplied/approved; never substitute a jump/landing sound.
local soundIds = { Hit = "", Break = "", Collection = "" }
function M.Start(folder, roundState)
	local Players = game:GetService("Players")
	local Tween = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local player = Players.LocalPlayer
	local hits, receipts, receiptOrder, popups = {}, {}, {}, {}
	local liveSounds = 0
	local function anchor(position)
		local part = Instance.new("Part")
		part.Name, part.Size = "MiningReceipt", Vector3.one * 0.05
		part.Transparency, part.Anchored = 1, true
		part.CanCollide, part.CanTouch, part.CanQuery, part.CastShadow = false, false, false, false
		part.Position, part.Parent = position, folder
		return part
	end
	local function sound(kind, position)
		local id = soundIds[kind]
		local camera = workspace.CurrentCamera
		if id == "" or liveSounds >= 6 or not camera or (camera.CFrame.Position - position).Magnitude > 65 then return end
		liveSounds += 1
		local holder = anchor(position)
		local audio = Instance.new("Sound")
		audio.SoundId, audio.RollOffMinDistance, audio.RollOffMaxDistance = id, 6, 65
		audio.Volume = 0.18 * (player:GetAttribute("SFXVolume") or 1)
		audio.Parent = holder
		audio:Play()
		Debris:AddItem(holder, 2)
		task.delay(2, function() liveSounds -= 1 end)
	end
	local function popup(position, text, color, award)
		local group = award and "Award" or "Damage"
		local count, oldest = 0, nil
		for i, entry in popups do
			if entry.group == group then count += 1; oldest = oldest or i end
		end
		local limit = award and 2 or 4
		if count >= limit and oldest then
			popups[oldest].part:Destroy()
			table.remove(popups, oldest)
		end
		-- Older labels occupy compact rows; newest damage stays nearest contact.
		for _, entry in popups do
			if entry.group == group then
				entry.row = math.min(entry.row + 1, limit - 1)
				entry.gui.StudsOffsetWorldSpace = Vector3.new(0, (award and 3 or 0.6) + entry.row * 0.42, 0)
			end
		end
		local part = anchor(position)
		local gui = Instance.new("BillboardGui")
		gui.Name, gui.Size = group, UDim2.fromOffset(230, 36)
		gui.MaxDistance, gui.AlwaysOnTop = 80, true
		gui.StudsOffsetWorldSpace = Vector3.new(0, award and 3 or 0.6, 0)
		gui.Adornee, gui.Parent = part, part
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
		label.Font, label.TextSize = Enum.Font.GothamBold, award and 17 or 21
		label.TextColor3, label.TextStrokeTransparency = color, 0.25
		label.Text, label.Parent = text, gui
		local entry = { part = part, gui = gui, group = group, row = 0 }
		table.insert(popups, entry)
		local life = award and 1.2 or 0.75
		if not player:GetAttribute("ReducedMotion") then
			Tween:Create(part, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = position + Vector3.yAxis * 0.6 }):Play()
		end
		Tween:Create(label, TweenInfo.new(0.22, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, life - 0.22),
			{ TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		Debris:AddItem(part, life + 0.05)
		task.delay(life, function()
			local index = table.find(popups, entry)
			if index then table.remove(popups, index) end
			part:Destroy()
		end)
	end
	roundState:GetAttributeChangedSignal("RoundId"):Connect(function()
		table.clear(hits)
		for _, entry in popups do entry.part:Destroy() end
		table.clear(popups)
	end)
	Players.PlayerRemoving:Connect(function(p) hits[p.UserId] = nil end)
	local controller = {}
	function controller:AcceptHit(userId, sequence, result)
		if typeof(result) ~= "table" or result.RoundId ~= roundState:GetAttribute("RoundId") then return false end
		if typeof(sequence) ~= "number" or sequence <= (hits[userId] or 0) then return false end
		hits[userId] = sequence
		return true
	end
	function controller:Hit(userId, position, damage, precise, critical, result)
		sound(result.Broken and "Break" or "Hit", position)
		if userId ~= player.UserId then return end
		local prefix = result.Broken and "BREAK  " or critical and "CRITICAL  " or precise and "PRECISE  " or ""
		popup(position, prefix .. tostring(damage), result.Broken and Color3.fromRGB(160, 243, 204)
			or (precise or critical) and Color3.fromRGB(255, 218, 145) or Color3.fromRGB(246, 241, 224), false)
	end
	function controller:Award(amount, receipt)
		if typeof(receipt) ~= "table" or typeof(amount) ~= "number" or amount <= 0
			or typeof(receipt.Position) ~= "Vector3" or typeof(receipt.ResourceName) ~= "string" then return end
		local key = tostring(receipt.RoundId) .. ":" .. tostring(receipt.Sequence)
		if receipts[key] then return end
		receipts[key] = true
		table.insert(receiptOrder, key)
		if #receiptOrder > 64 then receipts[table.remove(receiptOrder, 1)] = nil end
		-- Final receipts remain valid even if next-round replication overtakes them.
		popup(receipt.Position, "+" .. tostring(amount) .. " " .. receipt.ResourceName,
			Color3.fromRGB(160, 243, 204), true)
		sound("Collection", receipt.Position)
	end
	return controller
end
return M
