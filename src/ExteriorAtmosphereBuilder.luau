-- Edit-only, atmosphere-only replacement. Never rebuilds scenery or gameplay.
local B = {}
local Config = require(game.ReplicatedStorage.VesperShared.ExteriorAtmosphereConfig)

function B.Build()
	assert(
		game.PlaceId == 94763223427049 and not game:GetService("RunService"):IsRunning(),
		"Original Edit place only"
	)
	local exterior = workspace.VesperLab.DecorativeExterior
	local old = exterior:FindFirstChild("ValleyMist")
	if old then
		old:Destroy()
	end
	local mist = Instance.new("Model")
	mist.Name = "ValleyMist"
	mist:SetAttribute("AtmosphereRevision", 1)
	mist.Parent = exterior
	for index, d in Config.Ribbons do
		local host = Instance.new("Part")
		host.Name = "LowlandMist" .. index
		host.Size = Vector3.one
		host.CFrame = CFrame.new(d[1])
		host.Anchored = true
		host.Transparency = 1
		host.CanCollide = false
		host.CanTouch = false
		host.CanQuery = false
		host.CastShadow = false
		host:SetAttribute("RibbonIndex", index)
		local a, b = Instance.new("Attachment"), Instance.new("Attachment")
		a.Name = "MistStart"
		b.Name = "MistEnd"
		a.Position = -d[2]
		b.Position = d[2]
		a.Parent = host
		b.Parent = host
		local beam = Instance.new("Beam")
		beam.Name = "DriftingMist"
		beam.Attachment0 = a
		beam.Attachment1 = b
		beam.FaceCamera = true
		beam.Width0 = d[3]
		beam.Width1 = d[3] * 0.86
		beam.Segments = 16
		beam.Texture = Config.Texture
		beam.TextureMode = Enum.TextureMode.Wrap
		beam.TextureLength = d[2].Magnitude * 2
		beam.TextureSpeed = 0.008 + index * 0.0004
		beam.Color = ColorSequence.new(Color3.fromRGB(216, 225, 212))
		beam.LightInfluence = 0.15
		beam.LightEmission = 0
		beam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.18, 1 - d[4] * 0.72),
			NumberSequenceKeypoint.new(0.43, 1 - d[4]),
			NumberSequenceKeypoint.new(0.70, 1 - d[4] * 0.82),
			NumberSequenceKeypoint.new(1, 1),
		})
		beam.Parent = host
		host.Parent = mist
	end
	local lighting = game:GetService("Lighting")
	local atmosphere = assert(lighting:FindFirstChildOfClass("Atmosphere"))
	atmosphere.Density = Config.Density
	atmosphere.Offset = Config.Offset
	atmosphere.Haze = Config.Haze
	atmosphere.Color = Config.Color
	atmosphere.Decay = Config.Decay
	atmosphere.Glare = 0
	local clouds = assert(workspace.Terrain:FindFirstChildOfClass("Clouds"))
	clouds.Cover = Config.CloudCover
	clouds.Density = Config.CloudDensity
	clouds.Color = Config.CloudColor
	clouds.Enabled = true
	workspace.GlobalWind = Config.Wind
	return "Eight localized mist ribbons; native cloud wind; steady base atmosphere"
end

return B
