-- Original illustrated atlas, preserved at assets/ui/stage30/navigation-atlas.png.
local M = {}
M.Image = "rbxassetid://136029899303945"
local cells = {
	Equipment = Vector2.new(0, 0),
	Creatures = Vector2.new(1, 0),
	Home = Vector2.new(0, 1),
	Coins = Vector2.new(1, 1),
}
function M.Icon(parent, kind)
	local image = Instance.new("ImageLabel")
	image.Name = "NavigationArtwork"
	image.BackgroundTransparency = 1
	image.Image = M.Image
	-- Roblox serves the uploaded atlas at 1024 x 1024.
	image.ImageRectSize = Vector2.new(512, 512)
	image.ImageRectOffset = cells[kind] * 512
	image.ScaleType = Enum.ScaleType.Fit
	image.ZIndex = parent.ZIndex + 2
	image.Parent = parent
	return image
end
return M
