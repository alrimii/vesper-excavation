-- Cosmetic exterior settings. Shared by the Edit recipe and local motion only.
return {
	Wind = Vector3.new(7, 0, 3),
	Density = 0.205,
	Offset = 0.15,
	Haze = 1.2,
	Color = Color3.fromRGB(218, 225, 216),
	Decay = Color3.fromRGB(171, 184, 179),
	CloudCover = 0.52,
	CloudDensity = 0.39,
	CloudColor = Color3.fromRGB(239, 242, 236),
	Texture = "rbxassetid://137322546799462", -- existing engine smoke mask, PNG alpha-normalized
	-- Lowland/foothill ribbons: center, horizontal half-span, height, opacity.
	Ribbons = {
		{ Vector3.new(610, 42, 890), Vector3.new(260, 0, -155), 58, 0.42 },
		{ Vector3.new(850, 47, 1220), Vector3.new(290, 0, -170), 72, 0.55 },
		{ Vector3.new(1110, 111, 1630), Vector3.new(250, 0, -140), 56, 0.40 },
		{ Vector3.new(1450, 152, 370), Vector3.new(130, 0, 270), 76, 0.45 },
		{ Vector3.new(-510, 195, 1380), Vector3.new(310, 0, 75), 70, 0.45 },
		{ Vector3.new(-1120, 107, -1010), Vector3.new(210, 0, -175), 64, 0.42 },
		{ Vector3.new(760, 47, -1460), Vector3.new(270, 0, 115), 60, 0.42 },
		{ Vector3.new(-820, 29, 100), Vector3.new(90, 0, 230), 46, 0.35 },
	},
}
