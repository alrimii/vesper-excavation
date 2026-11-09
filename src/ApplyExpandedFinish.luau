-- Edit-time Blender finish, applied after ExpandedAccess.luau.
local data=game.HttpService:JSONDecode([====[[{"name": "Access_0_Deck", "center": [1.535634994506836, 12.64985466003418, -2.1581058502197266], "size": [113.45487594604492, 18.61372661590576, 109.70822525024414]}, {"name": "Access_0_Trim", "center": [1.533578872680664, 14.200838088989258, -2.168489456176758], "size": [113.59048843383789, 21.231678247451782, 109.82744216918945]}, {"name": "Access_1_Deck", "center": [-0.1905803680419922, 30.959991455078125, -0.1689929962158203], "size": [118.41648483276367, 18.613412857055664, 118.42260360717773]}, {"name": "Access_1_Trim", "center": [-0.19538116455078125, 32.510826110839844, -0.16927146911621094], "size": [118.5500259399414, 21.231657028198242, 118.5650749206543]}, {"name": "Access_2_Deck", "center": [0.8387279510498047, 49.27006912231445, 1.144887924194336], "size": [116.35393905639648, 18.613525390625, 114.37472915649414]}, {"name": "Access_2_Trim", "center": [0.8401279449462891, 50.820892333984375, 1.145172119140625], "size": [116.49726486206055, 21.23178482055664, 114.51533508300781]}, {"name": "Access_3_Deck", "center": [2.0722122192382812, 67.58018493652344, 2.420320510864258], "size": [104.7295913696289, 18.614036560058594, 100.22548294067383]}, {"name": "Access_3_Trim", "center": [2.0786380767822266, 69.13107299804688, 2.430675506591797], "size": [104.87090682983398, 21.23215103149414, 100.34451293945312]}, {"name": "Access_4_Deck", "center": [4.017610549926758, 85.89073181152344, 5.25368595123291], "size": [81.10754776000977, 18.615867614746094, 71.52953147888184]}, {"name": "Access_4_Trim", "center": [4.045003890991211, 87.44189453125, 5.295815467834473], "size": [81.23160934448242, 21.23377227783203, 71.54399681091309]}]
]====])
local source=game.ServerStorage.ExpansionV3AccessAssets
local access=workspace.VesperLab.ExcavationAccess
local old=access:FindFirstChild("BlenderAccessFinish") if old then old:Destroy() end
local visual=Instance.new("Model") visual.Name="BlenderAccessFinish" visual.Parent=access
for _,t in data do
 local p=source:FindFirstChild(t.name,true):Clone()
 p.Size=Vector3.new(unpack(t.size)) p.CFrame=CFrame.new(unpack(t.center))*CFrame.Angles(0,math.pi,0)
 p.PivotOffset=CFrame.identity p.Anchored=true p.CanCollide=false p.CanQuery=false p.CanTouch=false
 for _,c in p:GetChildren() do c:Destroy() end
 local trim=t.name:find("Trim")
 p.Material=trim and Enum.Material.Metal or Enum.Material.DiamondPlate
 p.Color=trim and Color3.fromRGB(184,145,80) or Color3.fromRGB(41,53,64)
 p.Parent=visual
end
for _,p in access:GetChildren() do
 if p.Name=="ContinuousRamp" then p.Transparency=1
 elseif p.Name=="OuterHandrail" or p.Name=="EdgeBand" or p.Name=="RailPost" then p:Destroy() end
end
return "Blender finish applied"
