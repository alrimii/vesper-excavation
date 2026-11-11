-- Authoritative minimal bootstrap. Runtime InterfaceKit views own all visible menus.
local M = {}
function M.Build(parent)
	local old = parent:FindFirstChild("ExcavationHUD")
	if old then
		old:Destroy()
	end
	local K = require(game.ReplicatedStorage.VesperShared.InterfaceKit)
	local gui = K.Make(
		"ScreenGui",
		parent,
		{
			Name = "ExcavationHUD",
			ResetOnSpawn = false,
			DisplayOrder = 10,
			ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		}
	)
	K.Make(
		"Frame",
		gui,
		{ Name = "Station", Size = UDim2.new(), Visible = false, BackgroundTransparency = 1 }
	)
	local toast = K.Text(gui, "Toast", "", 16, K.Paper, true)
	toast.BackgroundColor3 = K.Dark
	toast.BackgroundTransparency = 0.1
	K.Round(toast)
	local cross = K.Text(gui, "Crosshair", "+", 18, K.Paper, true)
	cross.AnchorPoint = Vector2.new(0.5, 0.5)
	cross.Position = UDim2.fromScale(0.5, 0.5)
	cross.Size = UDim2.fromOffset(20, 20)
	cross.TextXAlignment = Enum.TextXAlignment.Center
	return gui
end
return M
