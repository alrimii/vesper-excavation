-- One layout owner for the visible HUD. Legacy widgets remain only as data adapters.
local M = {}
function M.Build(gui, player, remote, openEquipment, equip)
	local Tween = game:GetService("TweenService")
	local Run = game:GetService("RunService")
	local shared = script.Parent
	local Style = require(shared.InterfaceStyle)
	local Art = require(shared.NavigationArtwork)
	local palette = {
		ink = Color3.fromRGB(26, 39, 66),
		paper = Color3.fromRGB(245, 249, 255),
		mint = Color3.fromRGB(72, 221, 160),
		blue = Color3.fromRGB(81, 168, 248),
		gold = Color3.fromRGB(255, 199, 72),
		purple = Color3.fromRGB(174, 125, 246),
	}
	local root = Instance.new("Frame")
	root.Name = "SimulatorHUD"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.Parent = gui
	local function corner(p, r)
		local v = Instance.new("UICorner")
		v.CornerRadius = UDim.new(0, r)
		v.Parent = p
	end
	local function stroke(p, c, w)
		local v = Instance.new("UIStroke")
		v.Color = c
		v.Thickness = w
		v.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		v.Parent = p
	end
	local function text(p, name, value, size, pos, fs, color)
		local v = Instance.new("TextLabel")
		v.Name = name
		v.Text = value
		v.Size = size
		v.Position = pos
		v.BackgroundTransparency = 1
		v.Font = Enum.Font.GothamBold
		v.TextSize = fs
		v.TextColor3 = color or palette.ink
		v.TextXAlignment = Enum.TextXAlignment.Left
		v.Parent = p
		return v
	end
	local function panel(name, color)
		local v = Instance.new("Frame")
		v.Name = name
		v.BackgroundColor3 = color
		v.BorderSizePixel = 0
		v.Parent = root
		corner(v, 16)
		stroke(v, Color3.fromRGB(88, 112, 142), 1)
		Style.Surface(v, Color3.new(1, 1, 1), Color3.fromRGB(230, 239, 250))
		return v
	end
	local function button(name, label, color, fn)
		local b = Instance.new("TextButton")
		b.Name = name
		b.Text = label
		b.Font = Enum.Font.GothamBlack
		b.TextSize = 15
		b.TextColor3 = palette.ink
		b.BackgroundColor3 = color
		b.BorderSizePixel = 0
		b.Parent = root
		corner(b, 14)
		stroke(b, palette.ink, 2)
		Style.Button(b)
		b.Activated:Connect(fn)
		return b
	end
	local money = panel("Wallet", palette.paper)
	local coin = Instance.new("Frame")
	coin.Size = UDim2.fromOffset(32, 32)
	coin.Position = UDim2.fromOffset(10, 10)
	coin.BackgroundColor3 = palette.gold
	coin.Parent = money
	corner(coin, 30)
	stroke(coin, Color3.fromRGB(206, 145, 36), 2)
	local symbol = text(coin, "Symbol", "$", UDim2.fromScale(1, 1), UDim2.new(), 22)
	symbol.TextXAlignment = Enum.TextXAlignment.Center
	coin.BackgroundTransparency = 1
	coin:FindFirstChildOfClass("UIStroke").Enabled = false
	symbol.Visible = false
	local coinArt = Art.Icon(coin, "Coins")
	coinArt.Position, coinArt.Size = UDim2.fromOffset(-5, -5), UDim2.fromOffset(42, 42)
	local credits = text(money, "Credits", "0", UDim2.new(1, -54, 0, 25), UDim2.fromOffset(51, 5), 22)
	text(
		money,
		"Caption",
		"COINS",
		UDim2.new(1, -54, 0, 15),
		UDim2.fromOffset(52, 30),
		10,
		Color3.fromRGB(108, 123, 148)
	)
	local bag = panel("Bag", palette.paper)
	local bagTitle = text(
		bag,
		"Caption",
		"MATERIALS",
		UDim2.new(1, -20, 0, 16),
		UDim2.fromOffset(10, 6),
		10,
		Color3.fromRGB(108, 123, 148)
	)
	local bagValue = text(bag, "Amount", "0 / 40", UDim2.new(1, -20, 0, 24), UDim2.fromOffset(10, 22), 19)
	local materialBag = require(shared.MaterialBag).Attach(gui, player, remote, bag)
	local egg = panel("EggProgress", palette.ink)
	local eggTitle = text(
		egg,
		"Title",
		"THE ANCIENT EGG",
		UDim2.new(1, -28, 0, 21),
		UDim2.fromOffset(14, 9),
		15,
		palette.paper
	)
	local eggSub =
		text(egg, "Subtitle", "", UDim2.new(1, -28, 0, 16), UDim2.fromOffset(14, 33), 10, palette.gold)
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -28, 0, 6)
	track.Position = UDim2.fromOffset(14, 55)
	track.BackgroundColor3 = Color3.fromRGB(59, 77, 105)
	track.BorderSizePixel = 0
	track.Parent = egg
	corner(track, 8)
	local fill = track:Clone()
	fill.Name = "Fill"
	fill.Position = UDim2.new()
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = palette.gold
	fill.Parent = track
	Style.Button(gui.Use)
	gui.Use.TextTransparency = 1
	local strikeArt = Art.Icon(gui.Use, "Equipment")
	strikeArt.Position, strikeArt.Size = UDim2.fromOffset(2, 2), UDim2.new(0.42, 0, 1, -4)
	local strikeLabel = text(
		gui.Use,
		"ActionCaption",
		"STRIKE",
		UDim2.new(0.58, -6, 1, 0),
		UDim2.new(0.42, 0, 0, 0),
		15,
		Color3.fromRGB(244, 249, 250)
	)
	strikeLabel.TextXAlignment = Enum.TextXAlignment.Center
	strikeLabel.ZIndex = gui.Use.ZIndex + 3
	Style.Surface(gui.Use, Color3.fromRGB(47, 126, 127), Color3.fromRGB(20, 53, 69))
	local gear = button("Equipment", "EQUIPMENT", palette.mint, function()
		openEquipment("TOOLS")
	end)
	local pets = button("Creatures", "CREATURES", palette.purple, function()
		openEquipment("ARCHIVE")
	end)
	local home = button("Home", "MY ROOM", palette.blue, function()
		remote:FireServer("Home")
	end)
	for _, nav in { gear, pets, home } do
		local caption = text(
			nav,
			"Caption",
			nav.Text,
			UDim2.new(1, -4, 0, 20),
			UDim2.new(0, 2, 1, -23),
			11,
			Color3.fromRGB(249, 244, 231)
		)
		caption.TextXAlignment = Enum.TextXAlignment.Center
		caption.TextStrokeColor3, caption.TextStrokeTransparency = palette.ink, 0.35
		caption.ZIndex = nav.ZIndex + 3
		nav.Text = ""
		nav.BackgroundColor3 = Color3.new(1, 1, 1)
		local top = nav == gear and Color3.fromRGB(37, 101, 109)
			or nav == pets and Color3.fromRGB(94, 57, 137)
			or Color3.fromRGB(42, 78, 119)
		Style.Surface(nav, top, Color3.fromRGB(19, 30, 49))
		nav:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(124, 164, 180)
		local icon = Art.Icon(nav, nav.Name)
		icon.Position, icon.Size = UDim2.fromScale(0.06, -0.07), UDim2.new(0.88, 0, 1, -17)
		local rim = Instance.new("Frame")
		rim.Name, rim.BorderSizePixel = "TopHighlight", 0
		rim.Position, rim.Size = UDim2.new(0.18, 0, 0, 2), UDim2.new(0.64, 0, 0, 1)
		rim.BackgroundColor3, rim.BackgroundTransparency = Color3.fromRGB(199, 229, 231), 0.4
		rim.Parent = nav
	end
	local sell = button("Sell", "SELL", palette.gold, function()
		remote:FireServer("Sell")
	end)
	sell.TextTransparency = 1
	local sellArt = Art.Icon(sell, "Coins")
	sellArt.Position, sellArt.Size = UDim2.fromOffset(3, 1), UDim2.new(0, 38, 1, -2)
	local sellLabel =
		text(sell, "Caption", "SELL", UDim2.new(1, -48, 1, 0), UDim2.fromOffset(43, 0), 14, palette.ink)
	sellLabel.TextXAlignment = Enum.TextXAlignment.Center
	local training = button("AutoTrain", "START AUTO TRAIN", palette.mint, function()
		remote:FireServer("Training")
	end)
	local trainingInfo = text(
		training,
		"Hint",
		"Tap once. Train automatically.",
		UDim2.new(1, -12, 0, 16),
		UDim2.new(0, 6, 1, -19),
		10
	)
	trainingInfo.TextXAlignment = Enum.TextXAlignment.Center
	local trainText =
		text(training, "Title", "START AUTO TRAIN", UDim2.new(1, -12, 0, 25), UDim2.fromOffset(6, 8), 17)
	trainText.TextXAlignment = Enum.TextXAlignment.Center
	training.Text = ""
	local trainingArt = Art.Icon(training, "Equipment")
	trainingArt.Position, trainingArt.Size = UDim2.fromOffset(3, 1), UDim2.fromOffset(60, 60)
	trainText.Position, trainText.Size = UDim2.fromOffset(66, 8), UDim2.new(1, -72, 0, 25)
	trainingInfo.Position, trainingInfo.Size = UDim2.new(0, 66, 1, -21), UDim2.new(1, -72, 0, 18)
	local guide = panel("Guide", palette.paper)
	local guideTitle = text(
		guide,
		"Heading",
		"YOUR FIRST DISCOVERY",
		UDim2.new(1, -60, 0, 16),
		UDim2.fromOffset(12, 10),
		10,
		Color3.fromRGB(74, 137, 159)
	)
	local guideText = text(guide, "Instruction", "", UDim2.new(1, -24, 0, 22), UDim2.fromOffset(12, 29), 13)
	guideText.TextWrapped = true
	guideText.TextYAlignment = Enum.TextYAlignment.Top
	local skip = Instance.new("TextButton")
	skip.Size = UDim2.fromOffset(44, 44)
	skip.Position = UDim2.new(1, -48, 0, 0)
	skip.Text = "SKIP"
	skip.Font = Enum.Font.GothamBold
	skip.TextSize = 9
	skip.TextColor3 = palette.ink
	skip.BackgroundTransparency = 1
	skip.Parent = guide
	skip.Activated:Connect(function()
		remote:FireServer("GuideSkip")
	end)
	local trial =
		text(root, "Trial", "", UDim2.fromOffset(270, 24), UDim2.new(0.5, -135, 1, -137), 13, palette.gold)
	trial.TextXAlignment = Enum.TextXAlignment.Center
	local world = Instance.new("Folder")
	world.Name = "LocalGuidedRoute"
	world.Parent = workspace
	local highlight = Instance.new("Highlight")
	highlight.FillColor = palette.mint
	highlight.FillTransparency = 0.87
	highlight.OutlineColor = palette.mint
	highlight.OutlineTransparency = 0.12
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = world
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.Transparency = 1
	anchor.Size = Vector3.one * 0.1
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Parent = world
	local marker = Instance.new("BillboardGui")
	marker.Size = UDim2.fromOffset(170, 36)
	marker.MaxDistance = 110
	marker.AlwaysOnTop = false
	marker.StudsOffset = Vector3.new(0, 4, 0)
	marker.Adornee = anchor
	marker.Parent = gui
	local arrow =
		text(marker, "Arrow", "FOLLOW THE PATH", UDim2.fromScale(1, 1), UDim2.new(), 15, palette.mint)
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	arrow.TextStrokeTransparency = 0.25
	local route = {}
	for i = 1, 16 do
		local p = Instance.new("Part")
		p.Name = "RouteDash"
		p.Size = Vector3.new(0.8, 0.12, 2.2)
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Material = Enum.Material.Neon
		p.Color = palette.mint
		p.Transparency = 1
		p.Parent = world
		route[i] = p
	end
	local guidedRoute = require(shared.GuidedRoute).new(route, world)
	gui.Destroying:Connect(function()
		world:Destroy()
	end)
	local lastRoute = 0
	local function room()
		for _, r in workspace.VesperLab.Rooms:GetChildren() do
			if r:GetAttribute("OwnerUserId") == player.UserId then
				return r
			end
		end
	end
	local function fmt(n)
		if n >= 1e6 then
			return string.format("%.1fM", n / 1e6)
		elseif n >= 1000 then
			return string.format("%.1fK", n / 1000)
		end
		return tostring(math.floor(n))
	end
	local api = {}
	function api:Update()
		local available = gui.AbsoluteSize
		local w, h = available.X, available.Y
		local small = w < 760
		local short = h < 500 and w >= 600
		local modal = gui.Station.Visible
			or player:GetAttribute("ResearchModal")
			or player:GetAttribute("DiscoveryCinematic")
		root.Visible = not modal
		materialBag.Update(modal)
		for _, name in { "Status", "Shop", "Help", "Bag", "Tools", "Tutorial", "Guidance" } do
			gui[name].Visible = false
		end
		local bw = small and 126 or 162
		money.Size = UDim2.fromOffset(bw, 52)
		money.Position = UDim2.fromOffset(12, 12)
		bag.Size = UDim2.fromOffset(bw, 52)
		bag.Position = small and UDim2.new(1, -bw - 12, 0, 12) or UDim2.fromOffset(12, 72)
		egg.Size = UDim2.fromOffset(small and math.min(300, w - 28) or 330, 70)
		egg.AnchorPoint = Vector2.new(0.5, 0)
		egg.Position = UDim2.new(0.5, 0, 0, small and 76 or 12)
		credits.Text = fmt(player:GetAttribute("Cash") or 0)
		bagValue.Text = fmt(player:GetAttribute("BucketUsed") or 0)
			.. " / "
			.. fmt(player:GetAttribute("BucketCapacity") or 40)
		bagTitle.Text = (player:GetAttribute("BucketUsed") or 0)
					>= (player:GetAttribute("BucketCapacity") or 40)
				and "BAG FULL / OPEN"
			or "MATERIALS / OPEN"
		local state = shared.RoundState
		local left, total = state:GetAttribute("LayerRemaining") or 0, state:GetAttribute("LayerTotal") or 1
		eggTitle.Text = state:GetAttribute("EggName") or "ANCIENT EGG"
		eggSub.Text = string.format(
			"LAYER %d OF 3   /   %s PLATES LEFT",
			state:GetAttribute("ActiveLayer") or 1,
			fmt(left)
		)
		fill.Size = UDim2.fromScale(math.clamp(1 - left / math.max(total, 1), 0, 1), 1)
		local startY = small and 161 or 142
		local navW = small and 132 or 164
		for i, b in { gear, pets, home } do
			b.Size = UDim2.fromOffset(navW, 46)
			b.Position = UDim2.fromOffset(12, startY + (i - 1) * 55)
			b.TextSize = small and 11 or 13
		end
		sell.Size = UDim2.fromOffset(bw, 38)
		sell.Position = small and UDim2.fromOffset(12, startY + 165) or UDim2.fromOffset(12, 130)
		if small then
			sell.Size = UDim2.fromOffset(navW, 38)
		end
		if not small then
			startY = 184
			for i, b in { gear, pets, home } do
				b.Position = UDim2.fromOffset(12, startY + (i - 1) * 55)
			end
		end
		sell.Visible = (player:GetAttribute("BucketUsed") or 0) > 0
		local ch = player.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		local own = room()
		local device = own and own:FindFirstChild("TrainingStation")
		local near = device and hrp and (hrp.Position - device.TrainingSpot.Position).Magnitude < 18
		local running = player:GetAttribute("Training") == true
		training.Visible = not modal and (near or running)
		training.Size = UDim2.fromOffset(math.min(300, w - 28), 64)
		training.AnchorPoint = Vector2.new(0.5, 1)
		training.Position = UDim2.new(0.5, 0, 1, -20)
		trainText.Text = running and "STOP TRAINING" or "START AUTO TRAIN"
		training.BackgroundColor3 = running and palette.gold or palette.mint
		trainingInfo.Text = running and "Equipped tool practice / tap to stop"
			or "Tap once. Train automatically."
		gui.Use.Visible = not modal and not training.Visible
		gui.Use.Size = UDim2.fromOffset(small and 112 or 150, 64)
		gui.Use.Position = UDim2.new(1, small and -126 or -166, 1, small and -174 or -90)
		gui.Use.BackgroundColor3 = Color3.new(1, 1, 1)
		strikeLabel.Text = gui.Use.Text
		strikeLabel.TextSize = small and 12 or 15
		gui.Use.TextColor3 = palette.ink
		gui.Use.Font = Enum.Font.GothamBlack
		gui.Use.TextSize = 20
		local toolbelt = gui:FindFirstChild("Toolbelt")
		if toolbelt then
			toolbelt.Visible = not modal and not training.Visible and player:GetAttribute("LabReady") == true
		end
		local expires = player:GetAttribute("DrillTrialEndsAt")
		trial.Text = expires
				and "HELIX TRIAL / " .. math.max(0, math.ceil(expires - workspace:GetServerTimeNow())) .. "s"
			or ""
		local stage = player:GetAttribute("IntroStage") or 1
		for _, b in { gear, sell } do
			local edge = b:FindFirstChildOfClass("UIStroke")
			local active = (b == gear and stage == 4) or (b == sell and stage == 3)
			edge.Color = active and palette.gold or palette.ink
			edge.Thickness = active and (2.5 + 0.5 * math.sin(os.clock() * 4)) or 2
		end
		guide.Visible = stage < 5 and not running and player:GetAttribute("LabReady") == true
		guide.Size = UDim2.fromOffset(small and math.min(230, w - 150) or 270, 60)
		guide.AnchorPoint = Vector2.new(1, 0)
		guide.Position = UDim2.new(1, -12, 0, small and 161 or 98)
		guideTitle.Text = "NEXT / " .. stage .. " OF 4"
		guideText.Text = ({
			"Train once in your room",
			"Break a plate / collect materials",
			"Sell your collected materials",
			player:GetAttribute("OwnsTool_Drill") and "Equip your drill" or "Try the drill at the shop",
		})[stage] or ""
		guideText.TextScaled = small
		if short then
			-- Landscape phones need a separate arrangement, not the portrait stack.
			money.Size = UDim2.fromOffset(136, 52)
			bag.Size = UDim2.fromOffset(136, 52)
			bag.Position = UDim2.new(1, -148, 0, 12)
			egg.Size = UDim2.fromOffset(math.min(330, w - 328), 70)
			egg.Position = UDim2.new(0.5, 0, 0, 12)
			for i, b in { gear, pets, home } do
				b.Size = UDim2.fromOffset(136, 44)
				b.Position = UDim2.new(1, -148, 0, 74 + (i - 1) * 49)
			end
			sell.Size, sell.Position = UDim2.fromOffset(136, 44), UDim2.fromOffset(12, 74)
			guide.Size = UDim2.fromOffset(190, 70)
			guide.AnchorPoint, guide.Position = Vector2.zero, UDim2.fromOffset(12, 180)
			guideText.Size = UDim2.new(1, -24, 0, 34)
			gui.Use.Size = UDim2.fromOffset(112, 54)
			gui.Use.Position = UDim2.new(1, -126, 1, -100)
		else
			guideText.Size = UDim2.new(1, -24, 0, 22)
		end
		local navSize = short and 76 or small and 82 or 96
		for i, nav in { gear, pets, home } do
			nav.Size = UDim2.fromOffset(navSize, navSize + 8)
			nav.Position = short and UDim2.new(0.5, -124 + (i - 1) * 86, 0, 86)
				or UDim2.fromOffset(16, (small and 162 or 184) + (i - 1) * (navSize + 20))
			nav.Caption.TextSize = short and 9 or small and 10 or 11
		end
		if small and not short then
			sell.Size, sell.Position = UDim2.fromOffset(126, 44), UDim2.new(1, -138, 0, 234)
		end
		local status = gui:FindFirstChild("TargetStatus")
		if status then
			status.Position = UDim2.new(0.5, 0, 1, -112)
			status.Visible = status.Visible and not modal and not training.Visible
		end
		if os.clock() - lastRoute < 0.12 then
			return
		end
		lastRoute = os.clock()
		local target, targetPart
		if
			own
			and hrp
			and stage < 5
			and not running
			and not modal
			and player:GetAttribute("LabReady") == true
		then
			if stage == 1 then
				targetPart = device and device.Control
			elseif stage == 2 then
				local delta = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
				local radial = delta.Magnitude > 1 and delta.Unit or Vector3.zAxis
				target = radial * 51 + Vector3.new(0, 2, 0)
				local localPos = own:GetPivot():PointToObjectSpace(hrp.Position)
				if math.abs(localPos.X) < 43 and math.abs(localPos.Z) < 36 then
					target = own:GetPivot():PointToWorldSpace(Vector3.new(0, 2, -46))
				end
			elseif stage == 4 then
				local workshop = workspace.VesperLab:FindFirstChild("SharedWorkshop")
				targetPart = workshop and workshop:FindFirstChild("Console")
			end
		end
		target = targetPart and targetPart.Position or target
		highlight.Adornee = targetPart
		highlight.Enabled = targetPart ~= nil
			and hrp ~= nil
			and (targetPart.Position - hrp.Position).Magnitude < 35
		marker.Enabled = target ~= nil
		local goal = target
		if target and hrp then
			anchor.Position = target
			local name = stage == 1 and "PRACTICE" or stage == 4 and "TOOLWORKS" or "EXCAVATE"
			arrow.Text = name .. " / " .. math.floor((target - hrp.Position).Magnitude) .. " studs"
			marker.StudsOffset = Vector3.new(0, 3, 0)
			-- Route to the accessible front of a terminal, never inside its solid body.
			if targetPart then
				goal = (targetPart.CFrame * CFrame.new(0, 0, 5)).Position
			end
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { ch, world }
			params.RespectCanCollide = true
			local floor = workspace:Raycast(goal + Vector3.yAxis * 8, -Vector3.yAxis * 24, params)
			goal = floor and floor.Position or goal
		end
		guidedRoute:Update(hrp, goal, ch, player:GetAttribute("ReducedMotion"))
	end
	return api
end
return M
