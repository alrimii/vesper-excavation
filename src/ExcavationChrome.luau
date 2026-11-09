-- New HUD primitives. Flat illustration silhouettes, tactile circular controls, restrained depth.
local C = {}
C.Ink = Color3.fromRGB(26, 29, 67)
C.White = Color3.fromRGB(255, 253, 248)
C.Blue = Color3.fromRGB(37, 183, 244)
C.Orange = Color3.fromRGB(255, 149, 55)
C.Purple = Color3.fromRGB(147, 94, 245)
C.Gold = Color3.fromRGB(255, 216, 69)
function C.Make(class, parent, props)
	local o = Instance.new(class)
	for k, v in props do
		o[k] = v
	end
	o.Parent = parent
	return o
end
function C.Rect(o, x, y, w, h)
	o.Position, o.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(w, h)
end
function C.Surface(o, color, radius)
	o.BackgroundColor3, o.BackgroundTransparency, o.BorderSizePixel = color, 0, 0
	C.Make("UICorner", o, { CornerRadius = UDim.new(0, radius or 20) })
	C.Make("UIStroke", o, { Color = C.Ink, Thickness = 2.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end
function C.Text(parent, name, value, size, light)
	return C.Make(
		"TextLabel",
		parent,
		{
			Name = name,
			Text = value,
			TextSize = size,
			Font = Enum.Font.FredokaOne,
			TextColor3 = light and C.White or C.Ink,
			BackgroundTransparency = 1,
			ZIndex = 8,
			TextWrapped = false,
		}
	)
end
function C.Icon(parent, key)
	return C.Make(
		"ImageLabel",
		parent,
		{
			Name = "Illustration",
			Image = require(script.Parent.ExcavationArt)[key],
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 7,
		}
	)
end
function C.Button(parent, name, callback, color, radius)
	local b = C.Make(
		"TextButton",
		parent,
		{ Name = name, Text = "", AutoButtonColor = false, Selectable = true, ZIndex = 6 }
	)
	C.Surface(b, color, radius)
	if callback then
		b.Activated:Connect(callback)
	end
	local base = color
	b.MouseEnter:Connect(function()
		b.BackgroundColor3 = base:Lerp(Color3.new(1, 1, 1), 0.12)
	end)
	b.MouseLeave:Connect(function()
		b.BackgroundColor3 = base
	end)
	b.InputBegan:Connect(function(i)
		if
			i.UserInputType == Enum.UserInputType.Touch
			or i.UserInputType == Enum.UserInputType.MouseButton1
		then
			b.BackgroundColor3 = base:Lerp(C.Ink, 0.12)
		end
	end)
	b.InputEnded:Connect(function()
		b.BackgroundColor3 = base
	end)
	return b
end
return C
