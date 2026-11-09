-- Receipts are presentation only. No client calculation or mutation of rewards.
local M = {}
-- ToolFeedback owns distinct tool audio; receipts remain presentation-only.
function M.Start(folder, roundState)
	local Players = game:GetService("Players")
	local Tween = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local player = Players.LocalPlayer
	local hits, receipts, receiptOrder, popups = {}, {}, {}, {}
	local function anchor(position)
		local part = Instance.new("Part")
		part.Name, part.Size = "MiningReceipt", Vector3.one * 0.05
		part.Transparency, part.Anchored = 1, true
		part.CanCollide, part.CanTouch, part.CanQuery, part.CastShadow = false, false, false, false
		part.Position, part.Parent = position, folder
		return part
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
		gui.Name, gui.Size = group, UDim2.fromOffset(award and 290 or 230, award and 48 or 36)
		gui.MaxDistance, gui.AlwaysOnTop = 80, true
		gui.StudsOffsetWorldSpace = Vector3.new(0, award and 3 or 0.6, 0)
		gui.Adornee, gui.Parent = part, part
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
		label.Font, label.TextSize = Enum.Font.GothamBold, award and 14 or 21
		label.TextWrapped = award
		label.TextColor3, label.TextStrokeTransparency = color, 0.25
		label.Text, label.Parent = text, gui
		local entry = { part = part, gui = gui, group = group, row = 0 }
		table.insert(popups, entry)
		local life = award and 1.8 or 0.75
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
		if typeof(sequence) ~= "number" or typeof(result.SectionId) ~= "string" then return false end
		local previous = hits[userId]
		if previous and sequence < previous.sequence then return false end
		if not previous or sequence > previous.sequence then
			previous = { sequence = sequence, sections = {} }; hits[userId] = previous
		end
		if previous.sections[result.SectionId] then return false end
		previous.sections[result.SectionId] = true
		return true
	end
	function controller:Hit(userId, position, damage, precise, critical, result)
		if userId ~= player.UserId then return end
		local prefix = result.Broken and "BREAK  " or critical and "CRITICAL  " or precise and "PRECISE  " or ""
		popup(position, prefix .. tostring(damage), result.Broken and Color3.fromRGB(160, 243, 204)
			or (precise or critical) and Color3.fromRGB(255, 218, 145) or Color3.fromRGB(246, 241, 224), false)
	end
	function controller:Award(amount, receipt)
		if typeof(receipt) ~= "table" or typeof(amount) ~= "number" or amount < 0
			or typeof(receipt.Position) ~= "Vector3" or typeof(receipt.ResourceName) ~= "string" then return end
		local key = tostring(receipt.RoundId) .. ":" .. tostring(receipt.Sequence) .. ":" .. tostring(receipt.SectionId)
		if receipts[key] then return end
		receipts[key] = true
		table.insert(receiptOrder, key)
		if #receiptOrder > 64 then receipts[table.remove(receiptOrder, 1)] = nil end
		-- Final receipts remain valid even if next-round replication overtakes them.
		local delivered, pending = receipt.Delivered or amount, receipt.Pending or 0
		local caption = amount == 0 and (receipt.ResourceName .. ": 0 units (rounded share)")
			or string.format("%s: +%d bucket / +%d pending", receipt.ResourceName, delivered, pending)
		local position = receipt.Position
		local camera = workspace.CurrentCamera
		if camera and (camera.CFrame.Position - position).Magnitude > 60 then
			-- Contributors may have moved away before settlement; keep their receipt visible.
			position = camera.CFrame.Position + camera.CFrame.LookVector * 12
		end
		popup(position, caption,
			Color3.fromRGB(160, 243, 204), true)
	end
	return controller
end
return M
