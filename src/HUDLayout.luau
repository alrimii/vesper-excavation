-- One responsive layout path shared by construction and the runtime HUD.
local L = {}
function L.Style(gui)
	local p = gui.Status
	if p:FindFirstChild("Cash") then
		p.Cash.Parent = p.Wallet
	end
	if p:FindFirstChild("Bucket") then
		p.Bucket.Parent = p.BagCard
	end
	if p:FindFirstChild("BucketTrack") then
		p.BucketTrack.Parent = p.BagCard
	end
	for _, card in { p.Wallet, p.BagCard } do
		if not card:FindFirstChild("Caption") then
			local label = Instance.new("TextLabel")
			label.Name = "Caption"
			label.BackgroundTransparency = 1
			label.Text = card == p.Wallet and "CREDITS" or "COLLECTION"
			label.TextSize = 9
			label.Font = Enum.Font.GothamBold
			label.TextColor3 = Color3.fromRGB(142, 172, 181)
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Position = UDim2.fromOffset(53, 5)
			label.Size = UDim2.new(1, -61, 0, 12)
			label.Parent = card
		end
	end
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	for _, o in gui:GetDescendants() do
		if o:IsA("UICorner") then
			o.CornerRadius = UDim.new(0, 7)
		elseif o:IsA("UIStroke") and o.Name ~= "Selection" then
			o.Thickness = 1
			o.Color = Color3.fromRGB(66, 85, 94)
		elseif o:IsA("Frame") and o.BackgroundTransparency == 0 then
			if o.Name ~= "Fill" then
				o.BackgroundColor3 = Color3.fromRGB(18, 29, 37)
				o.BackgroundTransparency = 0.08
			end
		elseif o:IsA("TextLabel") then
			o.Font = Enum.Font.GothamMedium
		end
	end
	gui.Status.Wallet.Cash.Font = Enum.Font.GothamBold
	gui.Status.Round.TextColor3 = Color3.fromRGB(236, 205, 145)
	gui.Status.Progress.TextColor3 = Color3.fromRGB(207, 227, 229)
	gui.Status.BagCard.BucketTrack.Fill.BackgroundColor3 = Color3.fromRGB(223, 175, 93)
	gui.Status.ProgressTrack.Fill.BackgroundColor3 = Color3.fromRGB(57, 139, 144)
	gui.Shop.BackgroundColor3 = Color3.fromRGB(178, 125, 53)
	gui.Use.BackgroundColor3 = Color3.fromRGB(38, 122, 130)
	gui.Tutorial.Heading.TextColor3 = Color3.fromRGB(224, 179, 99)
	gui.Tools.Size = UDim2.fromOffset(204, 88)
	gui.Tools.Position = UDim2.new(0.5, -102, 1, -110)
	for i, name in { "Pickaxe", "Bucket" } do
		local button = gui.Tools[name]
		button.Size = UDim2.fromOffset(92, 76)
		button.Position = UDim2.fromOffset(6 + (i - 1) * 100, 6)
		button.Icon.Size = UDim2.fromOffset(50, 50)
		button.Icon.Position = UDim2.fromOffset(21, 1)
		button.Label.Position = UDim2.fromOffset(0, 55)
	end
end
function L.Update(gui, viewport, contentsVisible)
	if gui.AbsoluteSize.X > 0 then
		viewport = gui.AbsoluteSize
	end
	local p = gui.Status
	local narrow = viewport.X < 800
	local w = narrow and math.min(160, (viewport.X - 36) / 2) or 190
	p.Wallet.Position = UDim2.fromOffset(14, 12)
	p.Wallet.Size = UDim2.fromOffset(w, 49)
	p.Wallet.Cash.Position = UDim2.fromOffset(67, 18)
	p.Wallet.Cash.TextSize = 23
	p.BagCard.Size = UDim2.fromOffset(w, 55)
	p.BagCard.Position = narrow and UDim2.new(1, -w - 14, 0, 12) or UDim2.fromOffset(14, 68)
	p.BagCard.Bucket.Position = narrow and UDim2.new(1, -w + 37, 0, 20) or UDim2.fromOffset(65, 76)
	p.BagCard.Bucket.TextSize = 16
	p.BagCard.BucketTrack.Position = narrow and UDim2.new(1, -w - 2, 0, 54) or UDim2.fromOffset(26, 110)
	p.BagCard.BucketTrack.Size = UDim2.fromOffset(w - 24, 5)
	local top = narrow and 77 or 12
	local cardWidth = math.min(332, viewport.X - 28)
	p.EggCard.Size = UDim2.fromOffset(cardWidth, 62)
	p.EggCard.Position = UDim2.new(0.5, -cardWidth / 2, 0, top)
	p.Round.Size = UDim2.fromOffset(cardWidth - 24, 22)
	p.Round.Position = UDim2.new(0.5, -cardWidth / 2 + 12, 0, top + 7)
	p.ProgressTrack.Size = UDim2.fromOffset(cardWidth - 30, 12)
	p.ProgressTrack.Position = UDim2.new(0.5, -cardWidth / 2 + 15, 0, top + 38)
	p.Progress.Size = UDim2.fromOffset(cardWidth - 30, 17)
	p.Progress.Position = UDim2.new(0.5, -cardWidth / 2 + 15, 0, top + 35)
	gui.Tutorial.Position = narrow and UDim2.fromOffset(12, 151) or UDim2.new(0, 14, 1, -170)
	gui.Tutorial.Size = UDim2.fromOffset(narrow and math.min(235, viewport.X - 130) or 278, 108)
	gui.Tutorial.Instruction.Size = UDim2.new(1, -24, 0, 48)
	gui.Tutorial.Objective.Position = UDim2.fromOffset(35, 84)
	gui.Tutorial.Arrow.Position = UDim2.fromOffset(11, 84)
	gui.Shop.Position = UDim2.new(1, narrow and -116 or -156, 0, narrow and 151 or 12)
	gui.Shop.Size = UDim2.fromOffset(narrow and 104 or 142, 42)
	gui.Shop.TextSize = narrow and 12 or 15
	gui.Help.Position = UDim2.new(1, narrow and -74 or -156, 0, narrow and 201 or 64)
	gui.Bag.Position = UDim2.new(1, -82, 0, narrow and 246 or 64)
	gui.Bag.Size = UDim2.fromOffset(68, 36)
	gui.Use.Position = UDim2.new(1, -120, 1, -154)
	gui.Use.Size = UDim2.fromOffset(104, 62)
	gui.Station.Fit.Scale = math.min(1, (viewport.X - 24) / 388, (viewport.Y - 30) / 410)
	if contentsVisible and narrow then
		gui.Tutorial.Position += UDim2.fromOffset(0, 48)
	end
	local short = viewport.Y < 450
	gui.Tools.Size = UDim2.fromOffset(short and 172 or 204, short and 64 or 88)
	gui.Tools.Position = UDim2.new(0.5, short and -86 or -102, 1, short and -82 or -110)
	for i, name in { "Pickaxe", "Bucket" } do
		local b = gui.Tools[name]
		b.Size = UDim2.fromOffset(short and 76 or 92, short and 54 or 76)
		b.Position = UDim2.fromOffset(6 + (i - 1) * (short and 84 or 100), 5)
		b.Icon.Size = UDim2.fromOffset(short and 34 or 50, short and 34 or 50)
		b.Icon.Position = UDim2.fromOffset(short and 21 or 21, 1)
		b.Label.Position = UDim2.fromOffset(0, short and 35 or 55)
	end
	if short then
		p.Wallet.Size = UDim2.fromOffset(144, 45)
		p.BagCard.Size = UDim2.fromOffset(144, 49)
		p.BagCard.Position = UDim2.new(1, -158, 0, 12)
		p.BagCard.Bucket.Position = UDim2.new(1, -107, 0, 20)
		p.BagCard.BucketTrack.Position = UDim2.new(1, -146, 0, 52)
		p.BagCard.BucketTrack.Size = UDim2.fromOffset(120, 5)
		local cw = math.clamp(viewport.X - 350, 200, 290)
		p.EggCard.Size = UDim2.fromOffset(cw, 52)
		p.EggCard.Position = UDim2.new(0.5, -cw / 2, 0, 12)
		p.Round.Size = UDim2.fromOffset(cw - 20, 20)
		p.Round.Position = UDim2.new(0.5, -cw / 2 + 10, 0, 17)
		p.Round.TextSize = 10
		p.ProgressTrack.Size = UDim2.fromOffset(cw - 24, 10)
		p.ProgressTrack.Position = UDim2.new(0.5, -cw / 2 + 12, 0, 44)
		p.Progress.Position = UDim2.new(0.5, -cw / 2 + 12, 0, 40)
		p.Progress.Size = UDim2.fromOffset(cw - 24, 17)
		gui.Tutorial.Position = UDim2.fromOffset(14, 84)
		gui.Tutorial.Size = UDim2.fromOffset(190, 94)
		gui.Tutorial.Instruction.TextSize = 11
		gui.Tutorial.Heading.TextSize = 9
		gui.Shop.Position = UDim2.new(1, -126, 0, 73)
		gui.Shop.Size = UDim2.fromOffset(112, 34)
		gui.Shop.TextSize = 11
		gui.Help.Position = UDim2.new(1, -126, 0, 113)
		gui.Help.Size = UDim2.fromOffset(112, 32)
		gui.Bag.Position = UDim2.new(1, -126, 0, 151)
		gui.Bag.Size = UDim2.fromOffset(52, 32)
		gui.Use.Position = UDim2.new(1, -230, 1, -82)
		gui.Use.Size = UDim2.fromOffset(96, 54)
		p.Contents.Position = UDim2.new(0.5, -150, 1, -112)
		p.Contribution.Visible = false
	else
		p.Round.TextSize = 14
		if narrow then
			gui.Use.Position = UDim2.new(1, -120, 1, -132)
		end
		gui.Help.Size = UDim2.fromOffset(62, 36)
		gui.Tutorial.Instruction.TextSize = 13
		gui.Tutorial.Heading.TextSize = 11
		p.Contents.Position = UDim2.fromOffset(18, 141)
	end
	p.Wallet.Cash.Position = UDim2.fromOffset(53, 18)
	p.Wallet.Cash.Size = UDim2.new(1, -61, 0, 27)
	p.Wallet.Cash.TextSize = 21
	p.Wallet.Cash.TextScaled = true
	if not p.Wallet.Cash:FindFirstChildOfClass("UITextSizeConstraint") then
		local c = Instance.new("UITextSizeConstraint", p.Wallet.Cash)
		c.MinTextSize = 12
		c.MaxTextSize = 21
	end
	p.BagCard.Bucket.Position = UDim2.fromOffset(53, 18)
	p.BagCard.Bucket.Size = UDim2.new(1, -61, 0, 23)
	p.BagCard.Bucket.TextSize = 13
	p.BagCard.BucketTrack.Position = UDim2.new(0, 12, 1, -10)
	p.BagCard.BucketTrack.Size = UDim2.new(1, -24, 0, 4)
	-- Keep the PC wallet and collection together; the illustrated menu owns the right edge.
	if viewport.X >= 640 then
		p.BagCard.Position = UDim2.fromOffset(14, 68)
	end
	if not short then
		p.Contents.Position = UDim2.fromOffset(18, 162)
	end
	gui.Tools.Bucket.Visible = false
	gui.Tools.Size = UDim2.fromOffset(short and 88 or 104, short and 64 or 88)
	gui.Tools.Position = UDim2.new(0.5, short and -44 or -52, 1, short and -82 or -110)
end
return L
