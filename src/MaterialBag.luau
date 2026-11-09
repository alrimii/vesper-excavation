local M = {}
function M.Value(player)
	return math.floor(
		(player:GetAttribute("BucketBaseValue") or 0) * (player:GetAttribute("SaleMultiplier") or 1) + 0.5
	)
end
function M.Attach(gui, player, remote, counter)
	local config = require(script.Parent.ExcavationConfig)
	local panel = Instance.new("Frame")
	panel.Name, panel.Size = "MaterialBag", UDim2.fromOffset(340, 326)
	panel.BackgroundColor3, panel.BorderSizePixel = Color3.fromRGB(15, 27, 39), 0
	panel.Visible, panel.ZIndex, panel.Parent = false, 55, gui
	local round = Instance.new("UICorner")
	round.CornerRadius, round.Parent = UDim.new(0, 14), panel
	local scale = Instance.new("UIScale")
	scale.Parent = panel
	local function text(name, value, y, height, size, color)
		local t = Instance.new("TextLabel")
		t.Name, t.Text = name, value
		t.Size, t.Position = UDim2.new(1, -36, 0, height), UDim2.fromOffset(18, y)
		t.BackgroundTransparency, t.Font, t.TextSize = 1, Enum.Font.GothamMedium, size
		t.TextColor3 = color or Color3.fromRGB(235, 243, 249)
		t.TextXAlignment, t.TextWrapped = Enum.TextXAlignment.Left, true
		t.ZIndex, t.Parent = 56, panel
		return t
	end
	text("Title", "MATERIAL BAG", 15, 28, 19)
	local capacity = text("Capacity", "", 48, 24, 12, Color3.fromRGB(113, 236, 210))
	local track = Instance.new("Frame")
	track.Position, track.Size = UDim2.fromOffset(18, 80), UDim2.new(1, -36, 0, 6)
	track.BackgroundColor3, track.BorderSizePixel, track.ZIndex, track.Parent =
		Color3.fromRGB(45, 61, 76), 0, 56, panel
	local fill = track:Clone()
	fill.Position, fill.Size, fill.BackgroundColor3, fill.Parent =
		UDim2.new(), UDim2.fromScale(0, 1), Color3.fromRGB(113, 236, 210), track
	local rows = {}
	for i, layer in config.Layers do
		rows[layer.Id] = text(layer.Id, "", 100 + (i - 1) * 31, 27, 13, layer.Color)
	end
	local total = text("Total", "", 200, 25, 18, Color3.fromRGB(255, 213, 138))
	text(
		"Note",
		"Sale total includes egg value and your active value upgrade.",
		229,
		32,
		11,
		Color3.fromRGB(157, 180, 193)
	)
	local function button(parent, name, value, pos, size)
		local b = Instance.new("TextButton")
		b.Name, b.Text, b.Position, b.Size = name, value, pos, size
		b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(113, 236, 210), Color3.fromRGB(15, 27, 39)
		b.Font, b.TextSize, b.BorderSizePixel, b.ZIndex = Enum.Font.GothamBold, 13, 0, 57
		b.Parent = parent
		local c = Instance.new("UICorner")
		c.CornerRadius, c.Parent = UDim.new(0, 8), b
		return b
	end
	local close = button(panel, "Close", "X", UDim2.new(1, -44, 0, 12), UDim2.fromOffset(30, 30))
	local sell = button(panel, "Sell", "SELL MATERIALS", UDim2.fromOffset(18, 272), UDim2.new(1, -36, 0, 38))
	local hit = button(counter, "OpenBag", "", UDim2.new(), UDim2.fromScale(1, 1))
	hit.BackgroundTransparency, hit.ZIndex = 1, 5
	local function toggle(open)
		panel.Visible = open
		player:SetAttribute("MaterialBagOpen", open)
		local service = game:GetService("GuiService")
		if open and game:GetService("UserInputService").PreferredInput == Enum.PreferredInput.Gamepad then
			service.SelectedObject = close
		elseif not open and (service.SelectedObject == close or service.SelectedObject == sell) then
			service.SelectedObject = hit
		end
	end
	hit.Activated:Connect(function()
		toggle(not panel.Visible)
	end)
	close.Activated:Connect(function()
		toggle(false)
	end)
	local input = game:GetService("UserInputService").InputBegan:Connect(function(key, processed)
		if
			not processed
			and panel.Visible
			and (key.KeyCode == Enum.KeyCode.Escape or key.KeyCode == Enum.KeyCode.ButtonB)
		then
			toggle(false)
		end
	end)
	local lastSell = 0
	sell.Activated:Connect(function()
		if os.clock() - lastSell < 0.4 or M.Value(player) <= 0 then
			return
		end
		lastSell = os.clock()
		remote:FireServer("Sell")
	end)
	gui.Destroying:Connect(function()
		input:Disconnect()
		player:SetAttribute("MaterialBagOpen", false)
	end)
	local api = {}
	function api.Update(blocked)
		if blocked then
			if panel.Visible then
				toggle(false)
			end
			return
		end
		if not panel.Visible then
			return
		end
		local size = gui.AbsoluteSize
		local fit = math.min(1, (size.X - 24) / 340, (size.Y - 24) / 326)
		scale.Scale = fit
		panel.Position = UDim2.fromOffset(
			size.X >= 760 and 186 or math.max(12, size.X - 340 * fit - 12),
			math.min(72, math.max(12, size.Y - 326 * fit - 12))
		)
		local used, cap =
			player:GetAttribute("BucketUsed") or 0, math.max(1, player:GetAttribute("BucketCapacity") or 40)
		capacity.Text = string.format(
			"%d / %d stored  /  %s",
			used,
			cap,
			used >= cap and "FULL" or tostring(cap - used) .. " free"
		)
		fill.Size = UDim2.fromScale(math.clamp(used / cap, 0, 1), 1)
		fill.BackgroundColor3 = used >= cap and Color3.fromRGB(255, 141, 91) or Color3.fromRGB(113, 236, 210)
		for _, layer in config.Layers do
			rows[layer.Id].Text =
				string.format("%s   x%d", layer.Name, player:GetAttribute("Bucket_" .. layer.Id) or 0)
		end
		local value = M.Value(player)
		total.Text = string.format("TOTAL SALE VALUE  $%d", value)
		sell.Text, sell.Interactable = value > 0 and ("SELL ALL / $" .. value) or "BAG EMPTY", value > 0
	end
	return api
end
return M
