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
	local dark, gold = Color3.fromRGB(35, 44, 54), Color3.fromRGB(183, 192, 196)
	local access = require(script.Parent.AccessRetraction).new(workspace.VesperLab)
	local dispatch = require(script.Parent.DispatchUI).new(gui, script.Parent)
	local impact = require(script.Parent.CradleImpact).new(folder)
	local hoist = require(script.Parent.DeliveryHoist).new(
		folder,
		workspace.VesperLab:FindFirstChild("CrownDeliveryDock")
	)
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
		hoist:Update(delivery, sample)
	end)
end
return M
