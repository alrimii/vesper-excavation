-- Read-only geometry/source fingerprint; excludes only the authorized scenery and lights.
local function hash(s)
	local h=5381
	for i=1,#s do h=(h*33+string.byte(s,i))%4294967296 end
	return string.format('%08x',h)
end
local lab=workspace.VesperLab
local excluded={DecorativeExterior=true,RetainedFixedPlanting=true,CompactCommons=true,IntegratedGreenery=true}
local out={geometry={},sources={},anchors={}}
for _,root in lab:GetChildren()do
	if not excluded[root.Name]then
		local rows={}
		for _,p in root:GetDescendants()do
			if p:IsA('BasePart')and p.Name~='FixedRimMoss'then
				table.insert(rows,p:GetFullName()..'|'..tostring(p.CFrame)..'|'..tostring(p.Size)..'|'..tostring(p.Color)..'|'..tostring(p.Material)..'|'..p.Transparency..'|'..tostring(p.CanCollide))
			end
		end
		table.sort(rows);out.geometry[root.Name]={count=#rows,hash=hash(table.concat(rows,'\n'))}
	end
end
for _,service in {game.ServerScriptService,game.ReplicatedStorage,game.StarterPlayer,game.StarterGui}do
	for _,s in service:GetDescendants()do if s:IsA('LuaSourceContainer')then out.sources[s:GetFullName()]=hash(s.Source)end end
end
for _,v in lab.FunctionalAnchors:GetDescendants()do if v:IsA('ObjectValue')then out.anchors[v:GetFullName()]=v.Value and v.Value:GetFullName()or'NONE'end end
return game.HttpService:JSONEncode(out)
