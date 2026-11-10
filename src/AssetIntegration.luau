-- Original Blender props imported by the creator; shared gameplay and joints remain intact.
local A = {}
function A.Tools()
	local kit = game.ServerStorage.VesperKit
	local sources = game.ServerStorage.VesperBlenderAssets
	for kind, name in { Pickaxe = "StarterPickaxe", Bucket = "CollectionBucket" } do
		local tool = kit[name]
		local handle = tool.Handle
		for _, p in tool:GetChildren() do
			if
				p:IsA("BasePart")
				and p ~= handle
				and not (kind == "Bucket" and (p.Name == "Fill" or p:GetAttribute("ContentIndex")))
			then
				p:Destroy()
			end
		end
		handle.CFrame = CFrame.identity
		handle.Transparency = 1
		local mesh = sources[kind]:Clone()
		mesh.Name = kind == "Pickaxe" and "ForgedPickaxe" or "BucketVessel"
		mesh.Parent = tool
		for _, p in tool:GetChildren() do
			if p:IsA("BasePart") then
				p.Anchored = false
				p.Massless = true
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
				p.CastShadow = false
				if p:IsA("MeshPart") then
					p.CollisionFidelity = Enum.CollisionFidelity.Box
					p.RenderFidelity = Enum.RenderFidelity.Automatic
				end
				if p ~= handle and not p:FindFirstChild("AssemblyJoint") then
					local w = Instance.new("Weld")
					w.Name = "AssemblyJoint"
					w.Part0 = handle
					w.Part1 = p
					w.C0 = p.CFrame
					w.Parent = p
				end
			end
		end
		if kind == "Pickaxe" then
			local tip = handle:FindFirstChild("StrikeTip")
			if tip then
				tip.Position = Vector3.new(1.63, 1, 0)
			end
		end
	end
end
function A.Lighting()
	error("Obsolete independent fixture placement retired; use LabInteriorBuilder")
end
return A
