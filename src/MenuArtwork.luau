local M = {}
function M.Attach(gui)
	for _, name in { "FieldGuide", "FieldGuidePanel" } do
		local old = gui:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end
	local buttons = { gui.Shop, gui.Help, gui.Bag }
	local names = { "UPGRADES", "JOURNAL", "BAG" }
	local art = {}
	for i, b in buttons do
		for _, name in { "IllustratedIcon", "ArtCaption" } do
			local old = b:FindFirstChild(name)
			if old then
				old:Destroy()
			end
		end
		local icon = Instance.new("ImageLabel")
		icon.Name = "IllustratedIcon"
		icon.BackgroundTransparency = 1
		icon.Image = "rbxassetid://122676131205756"
		icon.ImageRectSize = Vector2.new(512, 512)
		icon.ImageRectOffset = Vector2.new((i - 1) % 2 * 512, math.floor((i - 1) / 2) * 512)
		icon.Size = UDim2.fromOffset(66, 66)
		icon.Position = UDim2.fromOffset(9, 0)
		icon.Parent = b
		local title = Instance.new("TextLabel")
		title.Name = "ArtCaption"
		title.BackgroundTransparency = 1
		title.Size = UDim2.new(1, 0, 0, 18)
		title.Position = UDim2.fromOffset(0, 65)
		title.Text = names[i]
		title.TextColor3 = Color3.fromRGB(244, 222, 173)
		title.TextSize = 11
		title.Font = Enum.Font.GothamBold
		title.Parent = b
		art[i] = { icon, title }
		if not b:FindFirstChildOfClass("UICorner") then
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
		end
	end
	return function(viewport)
		local player = game:GetService("Players").LocalPlayer
		local enabled = viewport.X >= 640
			and not (player and (player:GetAttribute("DiscoveryCinematic") or player:GetAttribute(
				"ResearchModal"
			)))
			and not gui.Station.Visible
		local compact = viewport.Y < 600
		local size = compact and 64 or 84
		for i, b in buttons do
			art[i][1].Visible = enabled
			art[i][2].Visible = enabled
			b.TextTransparency = enabled and 1 or 0
			if enabled then
				b.Size = UDim2.fromOffset(size, size)
				b.Position = UDim2.new(1, -size - 16, 0, 12 + (i - 1) * (size + 10))
				art[i][1].Size = UDim2.fromOffset(size - 18, size - 18)
				art[i][2].Position = UDim2.fromOffset(0, size - 19)
				b.BackgroundColor3 = Color3.fromRGB(19, 34, 43)
				b.BackgroundTransparency = 0.14
			end
		end
	end
end
return M
