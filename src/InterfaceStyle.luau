-- Shared surface and interaction treatment. Layout remains owned by each screen.
local S = {}
local Tween = game:GetService("TweenService")
function S.Surface(object, top, bottom)
	local gradient = object:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(top, bottom)
	gradient.Rotation = 90
	gradient.Parent = object
	return gradient
end
function S.Button(button)
	if button:GetAttribute("StyledInteraction") then
		return
	end
	button:SetAttribute("StyledInteraction", true)
	button.AutoButtonColor = false
	button.Selectable = true
	S.Surface(button, Color3.new(1, 1, 1), Color3.fromRGB(217, 232, 243))
	local scale = button:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", button)
	local hovering, pressed, tween = false, false, nil
	local function update()
		if tween then
			tween:Cancel()
		end
		local player = game:GetService("Players").LocalPlayer
		local reduced = player and player:GetAttribute("ReducedMotion")
		local target = reduced and 1 or pressed and 0.97 or hovering and 1.025 or 1
		tween = Tween:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Scale = target })
		tween:Play()
	end
	button.MouseEnter:Connect(function()
		hovering = true
		update()
	end)
	button.MouseLeave:Connect(function()
		hovering, pressed = false, false
		update()
	end)
	button.SelectionGained:Connect(function()
		hovering = true
		update()
	end)
	button.SelectionLost:Connect(function()
		hovering, pressed = false, false
		update()
	end)
	button.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			pressed = true
			update()
		end
	end)
	button.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			pressed = false
			update()
		end
	end)
end
function S.Icon(parent, kind, color)
	local root = Instance.new("Frame")
	root.Name = "NavigationIcon"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromOffset(24, 24)
	root.Position = UDim2.new(0, 12, 0.5, -12)
	root.Parent = parent
	local function shape(x, y, w, h, rotation, radius)
		local p = Instance.new("Frame")
		p.AnchorPoint = Vector2.new(0.5, 0.5)
		p.Position = UDim2.fromOffset(x, y)
		p.Size = UDim2.fromOffset(w, h)
		p.Rotation = rotation or 0
		p.BorderSizePixel = 0
		p.BackgroundColor3 = color
		p.Parent = root
		local corner = Instance.new("UICorner", p)
		corner.CornerRadius = UDim.new(0, radius or 2)
	end
	if kind == "Equipment" then
		shape(12, 14, 4, 22, 38)
		shape(13, 6, 22, 5, 25)
	elseif kind == "Creatures" then
		shape(12, 13, 17, 21, 0, 9)
		shape(9, 12, 2, 3, 0, 1)
	elseif kind == "Home" then
		shape(12, 8, 16, 16, 45)
		shape(12, 17, 19, 12)
	end
	return root
end
return S
