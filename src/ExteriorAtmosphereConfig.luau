-- Cosmetic exterior settings. Shared by the Edit recipe and local motion only.
return {
	Wind = Vector3.new(12, 0, 5),
	Density = 0.22,
	Offset = 0.15,
	Haze = 1.35,
	Color = Color3.fromRGB(218, 225, 216),
	Decay = Color3.fromRGB(171, 184, 179),
	CloudCover = 0.56,
	CloudDensity = 0.39,
	CloudColor = Color3.fromRGB(239, 242, 236),
	Texture = "rbxassetid://137322546799462", -- existing engine smoke mask, PNG alpha-normalized
	-- Lowland/foothill ribbons: center, horizontal half-span, height, opacity.
	Ribbons = {
		{ Vector3.new(255, 30, 100), Vector3.new(0, 0, 73), 58, 0.73 },
		{ Vector3.new(120, 26, 258), Vector3.new(82, 0, 0), 52, 0.70 },
		{ Vector3.new(-255, 31, -60), Vector3.new(0, 0, 81), 57, 0.69 },
		{ Vector3.new(-115, 29, -258), Vector3.new(86, 0, 0), 54, 0.75 },
		{ Vector3.new(355, 42, 340), Vector3.new(87, 0, -62), 76, 0.77 },
		{ Vector3.new(430, 49, 125), Vector3.new(23, 0, 95), 83, 0.69 },
		{ Vector3.new(-230, 43, 440), Vector3.new(100, 0, 35), 73, 0.72 },
		{ Vector3.new(-405, 44, -330), Vector3.new(88, 0, -56), 79, 0.79 },
		{ Vector3.new(260, 36, -440), Vector3.new(103, 0, 38), 66, 0.76 },
		{ Vector3.new(-450, 35, 140), Vector3.new(30, 0, 100), 65, 0.68 },
		{ Vector3.new(265, 30, 560), Vector3.new(100, 0, -30), 70, 0.70 },
		{ Vector3.new(-105, 35, -515), Vector3.new(100, 0, 28), 74, 0.68 },
	},
}
