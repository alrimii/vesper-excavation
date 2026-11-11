local M = {}
function M.Value(player)
	return math.floor(
		(player:GetAttribute("BucketBaseValue") or 0) * (player:GetAttribute("SaleMultiplier") or 1) + 0.5
	)
end
function M.Attach(_gui, player, remote, counter)
	local K = require(script.Parent.InterfaceKit)
	local shell = K.Shell(player, "FieldMaterials", "Material bag", "MaterialBagOpen", nil, 640)
	local scroll = K.Scroll(shell.Body, "Contents")
	scroll.Size = UDim2.fromScale(1, 1)
	K.Stack(scroll, 14)
	local capacity = K.Paragraph(scroll, "Capacity", "", 30, K.Ink)
	capacity.Font = K.Title
	local rows = {}
	for _, layer in require(script.Parent.ExcavationConfig).Layers do
		rows[layer.Id] = K.Paragraph(scroll, layer.Id, "", 18, K.Green)
	end
	local value = K.Paragraph(scroll, "SaleValue", "", 32, K.Ink)
	K.Paragraph(
		scroll,
		"Pending",
		"Pending materials refill free space after a sale. They keep their original egg value.",
		15,
		K.Muted
	)
	local last = 0
	local sell = K.Button(scroll, "Sell", "Sell materials", function()
		if os.clock() - last > 0.4 and M.Value(player) > 0 then
			last = os.clock()
			remote:FireServer("Sell")
		end
	end)
	sell.Size = UDim2.new(1, -8, 0, 44)
	local hit = K.Button(counter, "OpenBag", "", function()
		shell:SetOpen(not shell.Open)
	end)
	hit.BackgroundTransparency = 1
	hit:FindFirstChild("Outline"):Destroy()
	hit.Size = UDim2.fromScale(1, 1)
	hit.ZIndex = 8
	return {
		Update = function(blocked)
			if blocked then
				shell:SetOpen(false)
				return
			end
			if not shell.Open then
				return
			end
			capacity.Text = string.format(
				"%d / %d stored · %d pending",
				player:GetAttribute("BucketUsed") or 0,
				player:GetAttribute("BucketCapacity") or 40,
				player:GetAttribute("PendingMaterials") or 0
			)
			for _, layer in require(script.Parent.ExcavationConfig).Layers do
				rows[layer.Id].Text = string.format(
					"%s   ×%d  ·  %d pending",
					layer.Name,
					player:GetAttribute("Bucket_" .. layer.Id) or 0,
					player:GetAttribute("Pending_" .. layer.Id) or 0
				)
			end
			value.Text = K.Number(M.Value(player)) .. " credits total"
			K.Enabled(
				sell,
				M.Value(player) > 0,
				M.Value(player) > 0 and "Sell all · " .. K.Number(M.Value(player)) .. " credits"
					or "Bag empty"
			)
		end,
	}
end
return M
