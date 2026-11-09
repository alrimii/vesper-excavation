local M = {}
function M.Attach(journal, cards, player)
	local Catalog = require(script.Parent.DiscoveryCatalog)
	local teal, muted = Color3.fromRGB(113, 236, 210), Color3.fromRGB(157, 180, 193)
	local active = "RESEARCH"
	local pages, tabs = {}, {}
	local function round(object)
		local c = Instance.new("UICorner")
		c.CornerRadius, c.Parent = UDim.new(0, 10), object
	end
	local function text(parent, name, y, height, size, color)
		local t = Instance.new("TextLabel")
		t.Name, t.Position, t.Size = name, UDim2.fromOffset(16, y), UDim2.new(1, -32, 0, height)
		t.BackgroundTransparency, t.Font, t.TextSize = 1, Enum.Font.GothamMedium, size
		t.TextColor3, t.TextXAlignment = color or muted, Enum.TextXAlignment.Left
		t.TextWrapped, t.ZIndex, t.Parent = true, 43, parent
		return t
	end
	for i, name in { "RESEARCH", "SPECIES" } do
		local tab = Instance.new("TextButton")
		tab.Name, tab.Text = name .. "Tab", name
		tab.Size, tab.Position = UDim2.new(0.5, -28, 0, 34), UDim2.new((i - 1) * 0.5, 24, 0, 115)
		tab.Font, tab.TextSize, tab.BorderSizePixel = Enum.Font.GothamBold, 12, 0
		tab.ZIndex, tab.Parent = 43, journal
		round(tab)
		local page = Instance.new("ScrollingFrame")
		page.Name, page.Position, page.Size =
			name .. "Page", UDim2.fromOffset(24, 161), UDim2.new(1, -48, 1, -181)
		page.BackgroundTransparency, page.BorderSizePixel = 1, 0
		page.ScrollBarThickness, page.ScrollBarImageColor3 = 4, teal
		page.ScrollingDirection, page.ZIndex, page.Parent = Enum.ScrollingDirection.Y, 42, journal
		page.CanvasSize = UDim2.fromOffset(0, 0)
		tab.Activated:Connect(function()
			active = name
		end)
		pages[name], tabs[name] = page, tab
	end
	local function block(name, y, height)
		local f = Instance.new("Frame")
		f.Name, f.Position, f.Size = name, UDim2.fromOffset(0, y), UDim2.new(1, -8, 0, height)
		f.BackgroundColor3, f.BorderSizePixel = Color3.fromRGB(23, 39, 52), 0
		f.ZIndex, f.Parent = 42, pages.RESEARCH
		round(f)
		return f
	end
	local function bar(parent, y)
		local track = Instance.new("Frame")
		track.Position, track.Size = UDim2.fromOffset(16, y), UDim2.new(1, -32, 0, 7)
		track.BackgroundColor3, track.BorderSizePixel = Color3.fromRGB(40, 59, 73), 0
		track.ZIndex, track.Parent = 43, parent
		round(track)
		local fill = track:Clone()
		fill.Position, fill.Size, fill.BackgroundColor3 = UDim2.fromOffset(0, 0), UDim2.fromScale(0, 1), teal
		fill.Parent = track
		return fill
	end
	local rank = block("RankProgress", 0, 112)
	local rankTitle = text(rank, "Rank", 12, 25, 20, teal)
	local xpText = text(rank, "XP", 42, 20, 12)
	local xpBar = bar(rank, 72)
	text(rank, "Hint", 83, 18, 10).Text = "Contracts and expedition contributions earn research XP."
	local current = block("CurrentContract", 124, 190)
	local label = text(current, "Label", 12, 18, 11, teal)
	local title = text(current, "Title", 36, 28, 19, Color3.fromRGB(240, 246, 251))
	local hint = text(current, "Instruction", 68, 36, 12)
	local progress = text(current, "Progress", 111, 22, 12)
	local progressBar = bar(current, 140)
	local payout = text(current, "Payout", 155, 22, 13, Color3.fromRGB(255, 213, 138))
	local upcoming = {}
	for i = 1, 3 do
		local row = block("Upcoming" .. i, 326 + (i - 1) * 82, 70)
		upcoming[i] = { title = text(row, "Title", 10, 23, 14), reward = text(row, "Reward", 36, 22, 11) }
	end
	pages.RESEARCH.CanvasSize = UDim2.fromOffset(0, 572)
	for _, card in cards do
		card.root.Parent = pages.SPECIES
		card.root.ZIndex = 42
		for _, object in card.root:GetDescendants() do
			if object:IsA("GuiObject") then
				object.ZIndex = 43
			end
		end
	end
	local hints = {
		Break = "Finish breaking plates on the active egg layer. Partial hits do not count.",
		Collect = "Break plates to collect their materials automatically. Keep space in your bag.",
		Sell = "Sell a non-empty load of materials through the equipment menu.",
		Upgrade = "Buy upgrade levels for your equipped tool. Buying a tool is a separate action.",
	}
	local api = {}
	function api.Update()
		if not journal.Visible then
			return
		end
		journal.Title.Text = "Your research journal"
		local xp = player:GetAttribute("ResearchXP") or 0
		local level = Catalog.Level(xp)
		local floorXP, nextXP = 60 * (level - 1) ^ 2, 60 * level ^ 2
		rankTitle.Text = "RESEARCHER " .. level
		xpText.Text = string.format(
			"%d / %d XP this rank  /  %d XP to rank %d",
			xp - floorXP,
			nextXP - floorXP,
			nextXP - xp,
			level + 1
		)
		xpBar.Size = UDim2.fromScale(math.clamp((xp - floorXP) / (nextXP - floorXP), 0, 1), 1)
		local index = player:GetAttribute("ContractIndex") or 1
		local contract = Catalog.Contract(index)
		local done = math.clamp(player:GetAttribute("ContractProgress") or 0, 0, contract.Goal)
		label.Text, title.Text, hint.Text =
			"ACTIVE CONTRACT / " .. index, contract.Title, hints[contract.Kind] or ""
		progress.Text = string.format("%d / %d complete", done, contract.Goal)
		progressBar.Size = UDim2.fromScale(done / contract.Goal, 1)
		payout.Text = string.format("+%d credits  /  +30 XP  /  Awarded automatically", contract.Reward)
		for i, row in upcoming do
			local nextContract = Catalog.Contract(index + i)
			row.title.Text = "NEXT " .. i .. "  /  " .. nextContract.Title
			row.reward.Text = string.format(
				"+%d credits / +30 XP / Unlocks after the previous contract",
				nextContract.Reward
			)
		end
		for name, page in pages do
			page.Visible = name == active
			tabs[name].BackgroundColor3 = name == active and teal or Color3.fromRGB(27, 51, 65)
			tabs[name].TextColor3 = name == active and Color3.fromRGB(14, 24, 36) or muted
		end
		for i, card in cards do
			card.root.Position, card.root.Size = UDim2.fromOffset(0, (i - 1) * 286), UDim2.new(1, -8, 0, 274)
			card.view.Position, card.view.Size = UDim2.fromOffset(16, 5), UDim2.new(1, -32, 0, 208)
			card.name.Position, card.count.Position = UDim2.fromOffset(16, 218), UDim2.fromOffset(16, 246)
		end
		pages.SPECIES.CanvasSize = UDim2.fromOffset(0, #cards * 286)
	end
	return api
end
return M
