-- Client-only machinery and animation. Every egg/result is chosen by the server.
local M = {}
function M.Start(gui, state, egg)
	local Run = game:GetService("RunService")
	local Sequence = require(script.Parent.DeliverySequence)
	local Phase = require(script.Parent.ExpeditionPhase)
	local Rules = require(script.Parent.ProgressionRules)
	local folder = Instance.new("Folder")
	folder.Name = "LocalExpeditionPresentation"
	folder.Parent = workspace
	local function part(name, size, cf, color, material)
		local p = Instance.new("Part")
		p.Name, p.Size, p.CFrame = name, size, cf
		p.Color, p.Material = color, material or Enum.Material.Metal
		p.Anchored = true
		p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
		p.CastShadow = name:find("Yoke") ~= nil or name:find("UpperArm") ~= nil or name:find("Forearm") ~= nil
		p.Parent = folder
		return p
	end
	local dark, gold = Color3.fromRGB(35, 44, 54), Color3.fromRGB(183, 192, 196)
	local access = require(script.Parent.AccessRetraction).new(workspace.VesperLab)
	local dispatch = require(script.Parent.DispatchUI).new(gui, script.Parent)
	local impact = require(script.Parent.CradleImpact).new(folder)
	local yokeX = part("MovingYokeX", Vector3.new(48, 3, 4), CFrame.new(), gold)
	local yokeFront = part("MovingYokeFront", Vector3.new(4, 3, 22), CFrame.new(), gold)
	local yokeBack = part("MovingYokeBack", Vector3.new(4, 3, 22), CFrame.new(), gold)
	local arms = {}
	for i = 1, 4 do
		local a = {}
		for _, name in
			{
				"UpperArm",
				"Forearm",
				"Cable",
				"Grip",
				"Shoulder",
				"Elbow",
				"PistonBarrel",
				"PistonRod",
				"ArmInset",
			}
		do
			a[name] = part(name .. i, Vector3.one, CFrame.new(), name == "Cable" and dark or gold)
		end
		a.Shoulder.Shape, a.Elbow.Shape = Enum.PartType.Cylinder, Enum.PartType.Cylinder
		a.Shoulder.Size, a.Elbow.Size = Vector3.new(4.6, 5.6, 5.6), Vector3.new(4.4, 5, 5)
		a.Grip.Size = Vector3.new(8, 7, 2.6)
		a.Grip.Color = Color3.fromRGB(22, 27, 32)
		a.Grip.Material = Enum.Material.SmoothPlastic
		a.UpperArm.Color = dark
		a.PistonBarrel.Color = dark
		a.PistonRod.Color = Color3.fromRGB(164, 176, 184)
		a.PistonRod.Reflectance = 0.05
		a.ArmInset.Color = Color3.fromRGB(214, 156, 68)
		arms[i] = a
	end
	local function link(p, a, b, width)
		p.Size = Vector3.new(width, width, math.max(0.01, (b - a).Magnitude))
		p.CFrame = CFrame.lookAt((a + b) / 2, b)
	end
	local proxy = require(script.Parent.DeliverySurface).Build(egg)
	proxy.Parent = folder
	local lastActive, lastVariant, lastLift
	local banner = Instance.new("Frame")
	banner.Name = "ExpeditionBanner"
	banner.AnchorPoint, banner.Position = Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -30)
	banner.Size = UDim2.new(0.8, 0, 0, 110)
	banner.BackgroundColor3, banner.BackgroundTransparency = dark, 0.08
	banner.ZIndex, banner.Visible = 60, false
	banner.Parent = gui
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(620, 110)
	limit.Parent = banner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = banner
	local stroke = Instance.new("UIStroke")
	stroke.Color = gold
	stroke.Thickness = 1.5
	stroke.Parent = banner
	local function label(y, h, fs)
		local t = Instance.new("TextLabel")
		t.Size, t.Position = UDim2.new(1, -24, 0, h), UDim2.fromOffset(12, y)
		t.BackgroundTransparency, t.TextColor3, t.TextSize = 1, gold, fs
		t.Font, t.ZIndex = Enum.Font.GothamBold, 61
		t.Parent = banner
		return t
	end
	local eyebrow, title, detail = label(10, 20, 11), label(34, 36, 25), label(76, 20, 12)
	require(script.Parent.MembraneMotion).Start(egg.ContainedSpecimen, state)
	require(script.Parent.DeliveryCamera).Start(game.Players.LocalPlayer, state, gui)
	local connection
	gui.Destroying:Connect(function()
		if connection then
			connection:Disconnect()
		end
		access:Update(0)
		folder:Destroy()
	end)
	connection = Run.RenderStepped:Connect(function()
		local status, phaseStarted, transitionStarted = Phase.Read(state)
		local now = workspace:GetServerTimeNow()
		local age = math.max(0, now - phaseStarted)
		impact:Update(status, phaseStarted, age, game.Players.LocalPlayer:GetAttribute("ReducedMotion"))
		local entry = Rules.Egg(state:GetAttribute("EggId"))
		banner.Visible = status == "Hatching"
		if status == "Selecting" then
			local tick = math.floor(math.min(age, 3.4) * 9 - math.min(age, 3.4) ^ 2)
			local shown = age < 3.4 and Rules.Eggs[tick % #Rules.Eggs + 1]
				or Rules.Egg(state:GetAttribute("NextEggId"))
			eyebrow.Text, title.Text = "CONTAINMENT DISPATCH / NEXT EXPEDITION", shown.Name
			title.TextColor3, stroke.Color = shown.Color, shown.Color
			detail.Text = age < 3.4 and "Scanning the incoming specimen manifest..."
				or shown.Rarity .. " / TRANSFER AUTHORIZED"
		elseif status == "Delivering" then
			eyebrow.Text, title.Text =
				"KEEP THE CENTRAL CRADLE CLEAR", Rules.Egg(state:GetAttribute("NextEggId")).Name
			detail.Text = Sequence.Sample(age).label
			title.TextColor3, stroke.Color = Rules.Egg(state:GetAttribute("NextEggId")).Color, gold
		elseif status == "Hatching" then
			eyebrow.Text, title.Text, detail.Text =
				"CONTAINMENT BREACH", "SOMETHING IS WAKING", "Final membrane rupturing..."
			title.TextColor3 = entry.Glow
		end
		local delivery = status == "Delivering"
		local selecting = status == "Selecting"
		local active = delivery or selecting
		local sample = Sequence.Sample(delivery and age or 0)
		local player = game.Players.LocalPlayer
		local arrival = player:GetAttribute("GameplayArrivalAt")
		local present = player:GetAttribute("LabReady") == true and arrival and transitionStarted > arrival
		dispatch:Update(status, age, Rules.Egg(state:GetAttribute("NextEggId")), sample, present)
		access:Update(selecting and 110 * Sequence.Ease(age / 2.9) or delivery and sample.accessDrop or 0)
		if proxy then
			local selected = Rules.Egg(state:GetAttribute("NextEggId"))
			if delivery ~= lastActive or selected.Id ~= lastVariant then
				for _, surface in proxy:GetChildren() do
					surface.Color = selected.Color
					local finish = surface:FindFirstChildOfClass("SurfaceAppearance")
					if finish then
						finish.Color = selected.Color
					end
					surface.Transparency = delivery and 0 or 1
				end
				lastActive, lastVariant = delivery, selected.Id
			end
			if active and lastLift ~= sample.eggLift then
				proxy:PivotTo(proxy:GetAttribute("RestCFrame") + Vector3.yAxis * sample.eggLift)
				lastLift = sample.eggLift
			end
		end
		local lift = active and sample.rigLift or Sequence.Lift
		local opened = active and (selecting and 0 or sample.open) or 1
		yokeX.CFrame = CFrame.new(0, 110 + lift, 0)
		yokeFront.CFrame = CFrame.new(0, 110 + lift, -13)
		yokeBack.CFrame = CFrame.new(0, 110 + lift, 13)
		for i, a in arms do
			local theta = (i - 1) * math.pi / 2
			local radial = Vector3.new(math.cos(theta), 0, math.sin(theta))
			local shoulder = radial * 22 + Vector3.yAxis * (110 + lift)
			local elbow = radial * (46 + opened * 6) + Vector3.yAxis * (88 + lift)
			local tip = radial * (35.4 + opened * 18) + Vector3.yAxis * (64 + lift)
			link(a.UpperArm, shoulder:Lerp(elbow, 0.055), elbow:Lerp(shoulder, 0.055), 2.8)
			link(a.Forearm, elbow:Lerp(tip, 0.06), tip:Lerp(elbow, 0.045), 2.3)
			link(a.Cable, radial * 22 + Vector3.yAxis * 189, shoulder, 0.35)
			local hingeAxis = radial:Cross(Vector3.yAxis)
			a.Shoulder.CFrame = CFrame.fromMatrix(shoulder, hingeAxis, Vector3.yAxis)
			a.Elbow.CFrame = CFrame.fromMatrix(elbow, hingeAxis, Vector3.yAxis)
			local tangent = radial:Cross(Vector3.yAxis) * 2.1
			local mount = shoulder:Lerp(elbow, 0.25) + tangent
			local rodEnd = elbow:Lerp(tip, 0.6) + tangent
			local joint = mount:Lerp(rodEnd, 0.55)
			link(a.PistonBarrel, mount, joint, 1.4)
			link(a.PistonRod, joint:Lerp(mount, 0.035), rodEnd, 0.65)
			link(a.ArmInset, shoulder:Lerp(elbow, 0.2) + tangent, shoulder:Lerp(elbow, 0.7) + tangent, 0.35)
			a.Grip.CFrame = CFrame.lookAt(tip, Vector3.new(0, tip.Y, 0))
		end
	end)
end
return M
