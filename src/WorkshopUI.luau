-- One modal route for equipment, collection, room and preferences.
local W = {}
function W.Build(gui, player, base, remote, feedback, close)
	local K = require(script.Parent.InterfaceKit)
	local gate = gui.Station
	gate:ClearAllChildren()
	gate.Visible = false
	gate.BackgroundTransparency = 1
	gate.Size = UDim2.new()
	gate.Active = false
	local shell = K.Shell(player, "FieldWorkshop", "Equipment", nil, function()
		gate.Visible = false
		close()
	end)
	local shop = require(script.Parent.OutfitterUI).Build(shell, player, base, remote, feedback)
	local secondary = require(script.Parent.SecondaryMenus).Build(shell, player, base, remote, feedback)
	local api = {}
	function api:Select(p)
		shell.HeightCap = p == "TOOLS" and 610 or 700
		shell.WidthCap = p == "OPTIONS" and 700 or 1040
		shop.Root.Visible = p == "TOOLS" or p == "RIG"
		secondary.Root.Visible = not shop.Root.Visible
		if shop.Root.Visible then
			shop:Select(p)
		else
			secondary:Select(p)
		end
		shell:Layout()
	end
	function api:SetVisible(v)
		gate.Visible = v
		shell:SetOpen(v)
	end
	function api:Update()
		if not shell.Open then
			return
		end
		if shop.Root.Visible then
			shop:Update()
		else
			secondary:Update()
		end
	end
	return api
end
return W
