local M = {}
function M.new(gui, shared)
	local rules = require(shared.ProgressionRules)
	local K = require(shared.InterfaceKit)
	local screen = K.Make(
		"Frame",
		gui,
		{ Name = "DispatchCinema", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false }
	)
	local caption = K.Surface(screen, "TransferCaption", K.Dark)
	caption.AnchorPoint = Vector2.new(0.5, 1)
	caption.Position = UDim2.new(0.5, 0, 1, -20)
	caption.Size = UDim2.new(1, -32, 0, 104)
	K.Make("UISizeConstraint", caption, { MaxSize = Vector2.new(640, 104) })
	local heading = K.Text(caption, "Heading", "SPECIMEN TRANSFER", 11, K.Gold, true)
	K.Rect(heading, 18, 8, 300, 18)
	local name = K.Text(caption, "Name", "", 28, K.Paper)
	name.Font = K.Title
	name.Position = UDim2.fromOffset(18, 28)
	name.Size = UDim2.new(1, -36, 0, 36)
	local detail = K.Text(caption, "Detail", "", 14, K.Line)
	detail.Position = UDim2.fromOffset(18, 68)
	detail.Size = UDim2.new(1, -36, 0, 28)
	local track = K.Surface(screen, "SelectionTrack", K.Dark)
	track.AnchorPoint = Vector2.new(0.5, 1)
	track.Position = UDim2.new(0.5, 0, 1, -134)
	track.Size = UDim2.new(1, -32, 0, 132)
	track.ClipsDescendants = true
	K.Make("UISizeConstraint", track, { MaxSize = Vector2.new(620, 132) })
	local cards = {}
	for i = 1, 5 do
		local card = K.Surface(track, "Egg" .. i, K.Ink)
		card.AnchorPoint = Vector2.new(0.5, 0.5)
		card.Size = UDim2.new(0.32, 0, 1, -12)
		local title = K.Text(card, "Name", "", 13, K.Paper, true)
		title.Position = UDim2.fromOffset(5, 73)
		title.Size = UDim2.new(1, -10, 0, 22)
		title.TextXAlignment = Enum.TextXAlignment.Center
		local rarity = K.Text(card, "Rarity", "", 11, K.Line)
		rarity.Position = UDim2.fromOffset(5, 98)
		rarity.Size = UDim2.new(1, -10, 0, 17)
		rarity.TextXAlignment = Enum.TextXAlignment.Center
		cards[i] = { frame = card, title = title, rarity = rarity }
	end
	K.Make("Frame", track, {
		Name = "SelectedMark",
		Position = UDim2.new(0.5, -1, 0, 0),
		Size = UDim2.fromOffset(2, 132),
		BackgroundColor3 = K.Gold,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		ZIndex = 5,
	})
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
	function api:Update(status, age, selected, sample, present)
		screen.Visible = present == true and (status == "Selecting" or status == "Delivering")
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
		local progress = game.Players.LocalPlayer:GetAttribute("ReducedMotion") and destination
			or destination * (1 - (1 - t) ^ 3)
		local whole = math.floor(progress + 0.5)
		for offset = -2, 2 do
			local index = whole + offset
			-- A card keeps its identity while crossing the track. Recycle only offscreen.
			local card = cards[index % #cards + 1]
			local entry = rules.Eggs[index % #rules.Eggs + 1]
			card.frame.Position = UDim2.fromScale(0.5 + (index - progress) * 0.34, 0.5)
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
