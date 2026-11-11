-- Original illustrated skills shared by map and inspector.
local Art = {}
local keys = {
	"fault_survey",
	"charged_swing",
	"steady_aim",
	"batch_unload",
	"sale_latch",
	"precision_relay",
	"chain_lightning",
	"core_drill",
}
function Art.Apply(image, id, branch)
	local i = table.find(keys, id:match("%.(.+)$") or id)
	if not i then
		i = branch == "Collection" and 4 or branch == "Technique" and 7 or 2
	end
	i -= 1
	image.Image = "rbxassetid://82521932688624"
	image.ImageRectOffset = Vector2.new(i % 4 * 256, math.floor(i / 4) * 256)
	image.ImageRectSize = Vector2.new(256, 256)
	image.ImageColor3 = Color3.new(1, 1, 1)
end
return Art
