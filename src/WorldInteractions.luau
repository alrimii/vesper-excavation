-- Client presentation only. Purchases and training rewards retain server authority.
local M = {}
function M.Start(player, gui, action, openShop, isShopOpen)
	local UIS = game:GetService("UserInputService")
	local GuiService = game:GetService("GuiService")
	local elapsed, entered, reported = 0, false, nil
	local function menuBlocked()
		return isShopOpen() or gui.Station.Visible or GuiService.MenuIsOpen
			or UIS:GetFocusedTextBox() ~= nil or player:GetAttribute("CoreMenuOpen")
			or player:GetAttribute("SkillTreeOpen") or player:GetAttribute("MaterialBagOpen")
			or player:GetAttribute("EggResultsOpen") or player:GetAttribute("ResearchModal")
			or player:GetAttribute("DiscoveryCinematic")
	end
	player.CharacterAdded:Connect(function() entered = false end)
	game:GetService("RunService").Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.15 then return end
		elapsed = 0
		local blocked = not not menuBlocked()
		if reported ~= blocked then
			reported = blocked
			action:FireServer("WorldInteractionMenu", blocked)
		end
		local ch = player.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		local lab = workspace:FindFirstChild("VesperLab")
		local shop = lab and lab:FindFirstChild("SharedWorkshop")
		local zone = shop and shop:FindFirstChild("ApproachZone")
		if not root or not hum or hum.Health <= 0 or not zone then entered = false; return end
		local p = zone.CFrame:PointToObjectSpace(root.Position)
		local half = zone.Size / 2
		if math.abs(p.X) > half.X + 2 or math.abs(p.Z) > half.Z + 2 or math.abs(p.Y) > half.Y + 2 then
			entered = false
		elseif not entered and math.abs(p.X) <= half.X and math.abs(p.Z) <= half.Z and math.abs(p.Y) <= half.Y then
			-- Consume the entry even if another screen owns focus. Never queue a surprise menu.
			entered = true
			if not blocked and player:GetAttribute("LabReady") == true and not player:GetAttribute("Training") then
				openShop("TOOLS")
			end
		end
	end)
end
return M
