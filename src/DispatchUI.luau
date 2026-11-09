local M = {}
function M.new(gui, shared)
	local rules = require(shared.ProgressionRules)
	local screen = Instance.new("Frame")
	screen.Name = "DispatchCinema"
	screen.Size = UDim2.fromScale(1, 1)
	screen.BackgroundTransparency = 1
	screen.Visible = false
	screen.Parent = gui
	local function text(parent, value, size, pos, fontSize, color)
		local t = Instance.new("TextLabel")
		t.Text = value
		t.Size = size
		t.Position = pos
		t.TextSize = fontSize
		t.Font = Enum.Font.GothamBold
		t.TextColor3 = color or Color3.fromRGB(235, 240, 243)
		t.BackgroundTransparency = 1
		t.Parent = parent
		return t
	end
	for _, bottom in { false, true } do
		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, 0, 0, bottom and 108 or 48)
		bar.Position = bottom and UDim2.new(0, 0, 1, -108) or UDim2.new()
		bar.BackgroundColor3 = Color3.fromRGB(13, 18, 25)
		bar.BackgroundTransparency = 0.12
		bar.BorderSizePixel = 0
		bar.Parent = screen
	end
	local heading = text(
		screen,
		"VESPER / SPECIMEN TRANSFER",
		UDim2.new(1, -40, 0, 24),
		UDim2.fromOffset(20, 12),
		12,
		Color3.fromRGB(211, 170, 103)
	)
	local name = text(screen, "", UDim2.new(1, -32, 0, 32), UDim2.new(0, 16, 1, -92), 23)
	local detail = text(
		screen,
		"",
		UDim2.new(1, -32, 0, 22),
		UDim2.new(0, 16, 1, -54),
		12,
		Color3.fromRGB(161, 177, 188)
	)
	local track = Instance.new("Frame")
	track.AnchorPoint = Vector2.new(0.5, 1)
	track.Position = UDim2.new(0.5, 0, 1, -119)
	track.Size = UDim2.new(0.75, 0, 0, 132)
	track.BackgroundColor3 = Color3.fromRGB(16, 23, 31)
	track.BorderSizePixel = 0
	track.ClipsDescendants = true
	track.Parent = screen
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(620, 132)
	limit.Parent = track
	local cards = {}
	for i = 1, 5 do
		local card = Instance.new("Frame")
		card.AnchorPoint = Vector2.new(0.5, 0.5)
		card.Size = UDim2.new(0.32, 0, 1, -12)
		card.BackgroundColor3 = Color3.fromRGB(32, 43, 54)
		card.BorderSizePixel = 0
		card.Parent = track
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 9)
		corner.Parent = card
		local title = text(card, "", UDim2.new(1, -10, 0, 22), UDim2.fromOffset(5, 73), 12)
		local rarity = text(
			card,
			"",
			UDim2.new(1, -10, 0, 17),
			UDim2.fromOffset(5, 98),
			9,
			Color3.fromRGB(177, 188, 198)
		)
		cards[i] = { frame = card, title = title, rarity = rarity }
	end
	local pointer = text(
		track,
		"▼",
		UDim2.fromOffset(26, 22),
		UDim2.new(0.5, -13, 0, 0),
		18,
		Color3.fromRGB(246, 189, 89)
	)
	pointer.ZIndex = 5
	local function previews()
		local source = shared:FindFirstChild("DeliveryShell")
		if not source or not shared:GetAttribute("PresentationReady") then
			return
		end
		for _, card in cards do
			if not card.model then
				local view = Instance.new("ViewportFrame")
				view.BackgroundTransparency = 1
				view.Size = UDim2.new(1, -12, 0, 67)
				view.Position = UDim2.fromOffset(6, 6)
				view.Ambient = Color3.fromRGB(155, 164, 178)
				view.LightColor = Color3.fromRGB(255, 240, 216)
				view.LightDirection = Vector3.new(-1, -1, -1)
				view.Parent = card.frame
				local model = source:Clone()
				model:PivotTo(CFrame.new())
				model.Parent = view
				local camera = Instance.new("Camera")
				camera.CFrame = CFrame.lookAt(Vector3.new(90, 45, -180), Vector3.zero)
				camera.FieldOfView = 35
				camera.Parent = view
				view.CurrentCamera = camera
				card.model = model
				card.entryId = nil
			end
		end
	end
	local api = {}
	function api:Update(status, age, selected, sample)
		screen.Visible = status == "Selecting" or status == "Delivering"
		if not screen.Visible then
			return
		end
		track.Visible = status == "Selecting"
		name.Text = status == "Selecting" and age < 3.5 and "NEXT EXPEDITION" or selected.Name
		name.TextColor3 = selected.Color
		detail.Text = status == "Selecting"
				and (age < 3.5 and "ASSIGNING THE NEXT EXPEDITION" or selected.Rarity .. " / TRANSFER CONFIRMED")
			or sample.label
		if status ~= "Selecting" then
			return
		end
		previews()
		local selectedIndex = 1
		for i, v in rules.Eggs do
			if v.Id == selected.Id then
				selectedIndex = i
			end
		end
		local destination = #rules.Eggs * 2 + selectedIndex - 1
		local t = math.clamp(age / 3.5, 0, 1)
		local progress = destination * (1 - (1 - t) ^ 3)
		local whole = math.floor(progress + 0.5)
		for offset = -2, 2 do
			local index = whole + offset
			-- A card keeps its identity while crossing the track. Recycle only offscreen.
			local card = cards[index % #cards + 1]
			local entry = rules.Eggs[index % #rules.Eggs + 1]
			card.frame.Position = UDim2.new(0.5 + (index - progress) * 0.34, 0, 0.5, 0)
			if card.entryId == entry.Id then
				continue
			end
			card.entryId = entry.Id
			card.title.Text, card.title.TextColor3 = entry.Name, entry.Color
			card.rarity.Text = entry.Rarity
			if card.model then
				for _, p in card.model:GetChildren() do
					p.Color = entry.Color
					p.Transparency = 0
				end
			end
		end
	end
	return api
end
return M
