-- Cosmetic exterior settings. Shared by the Edit recipe and local motion only.
return {
	Wind = Vector3.new(12, 0, 5),
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
		{ Vector3.new(350, 45, 440), Vector3.new(220, 0, -155), 120, 0.94 },
		{ Vector3.new(500, 58, 420), Vector3.new(180, 0, -140), 105, 0.84 },
		{ Vector3.new(230, 45, 630), Vector3.new(200, 0, -90), 100, 0.84 },
		{ Vector3.new(670, 65, 80), Vector3.new(40, 0, 180), 120, 0.88 },
		{ Vector3.new(-300, 65, 590), Vector3.new(210, 0, 95), 110, 0.9 },
		{ Vector3.new(-470, 55, -420), Vector3.new(170, 0, -150), 110, 0.88 },
		{ Vector3.new(350, 50, -590), Vector3.new(200, 0, 120), 110, 0.87 },
		{ Vector3.new(-590, 48, 80), Vector3.new(50, 0, 190), 105, 0.84 },
	},
}
