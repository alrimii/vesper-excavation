-- Opt-in identity for the HUD and equipment slice. Other screens retain their routes.
local K = require(script.Parent.InterfaceKit)
local A = {
	Ink = Color3.fromRGB(20, 38, 70),
	White = Color3.fromRGB(255, 255, 255),
	Teal = Color3.fromRGB(15, 109, 139),
	Blue = Color3.fromRGB(45, 177, 233),
	Green = Color3.fromRGB(113, 226, 41),
	Gold = Color3.fromRGB(255, 196, 48),
	Pink = Color3.fromRGB(255, 75, 129),
	Purple = Color3.fromRGB(167, 91, 241),
}
function A.Letter(t, size, color)
	t.Font = Enum.Font.FredokaOne
	t.TextSize = size or t.TextSize
	t.TextColor3 = color or A.White
	t.TextStrokeColor3 = A.Ink
	t.TextStrokeTransparency = 0
	return t
end
function A.Text(parent, name, value, size, color)
	return A.Letter(K.Text(parent, name, value, size, color, true), size, color)
end
function A.Paint(o, color)
	o.BackgroundColor3 = color or A.Blue
	local edge = o:FindFirstChildOfClass("UIStroke") or K.Outline(o)
	edge.Color = A.Ink
	edge.Thickness = 3
	local grad = o:FindFirstChildOfClass("UIGradient") or K.Shine(o)
	grad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(170, 203, 228))
	grad.Rotation = 90
	if o:IsA("TextButton") then
		A.Letter(o, 22)
	end
	return o
end
function A.Card(parent, name, color)
	local f = A.Paint(K.Surface(parent, name, color), color)
	local rim = K.Make("Frame", f, {
		Name = "Inset",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(5, 5),
		Size = UDim2.new(1, -10, 1, -10),
		ZIndex = 1,
	})
	K.Round(rim, 12)
	local s = K.Outline(rim, A.White, 2)
	s.Transparency = 0.55
	return f
end
function A.Button(parent, name, label, callback, color)
	return A.Paint(K.Button(parent, name, label, callback), color or A.Green)
end
function A.State(b, on, label)
	K.Enabled(b, on, label)
	b.BackgroundColor3 = on and A.Green or Color3.fromRGB(87, 126, 151)
	A.Letter(b, b.TextSize, on and A.White or Color3.fromRGB(216, 232, 240))
end
function A.Nav(parent, name, label, key, callback, color)
	local b = K.Button(parent, name, "", callback, true)
	b.BackgroundTransparency = 1
	b:FindFirstChildOfClass("UIStroke").Enabled = false
	local disc = A.Card(b, "Badge", color or A.Blue)
	disc.Rotation = 12
	local icon = K.Icon(b, key)
	icon.ZIndex = 3
	local text = A.Text(b, "Label", label, 20)
	text.TextXAlignment = Enum.TextXAlignment.Center
	text.ZIndex = 4
	return { Button = b, Label = text, Icon = icon, Badge = disc }
end
function A.NavLayout(b, w, h)
	K.Rect(b.Badge, w * 0.14, h * 0.08, w * 0.72, h * 0.69)
	K.Rect(b.Icon, -w * 0.01, -h * 0.02, w * 1.02, h * 0.84)
	K.Rect(b.Label, -w * 0.15, h * 0.69, w * 1.3, h * 0.31)
end
function A.Pattern(parent)
	local holder = K.Make("Frame", parent, {
		Name = "Pattern",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 1,
	})
	K.Round(holder, 18)
	for y = 0, 5 do
		for x = 0, 11 do
			local d = K.Make("Frame", holder, {
				BackgroundColor3 = A.White,
				BackgroundTransparency = 0.965,
				BorderSizePixel = 0,
				Rotation = 45,
				Position = UDim2.new(x / 11, -16, y / 5, -16),
				Size = UDim2.fromOffset(35, 35),
			})
			K.Round(d, 7)
		end
	end
	return holder
end
return A
