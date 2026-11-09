local UI={}
local C=require(game.ReplicatedStorage.VesperShared.ExcavationConfig)
local navy=Color3.fromRGB(15,24,37) local edge=Color3.fromRGB(9,16,26) local teal=Color3.fromRGB(42,139,130) local gold=Color3.fromRGB(255,213,138)
function UI.Build(parent)
 local old=parent:FindFirstChild("ExcavationHUD") if old then old:Destroy() end
 local gui=Instance.new("ScreenGui") gui.Name="ExcavationHUD" gui.ResetOnSpawn=false gui.DisplayOrder=10 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=parent
 local function card(parent,name,size,pos,color)
  local f=Instance.new("Frame") f.Name=name f.Size=size f.Position=pos f.BackgroundColor3=color or navy f.BorderSizePixel=0 f.Parent=parent
  local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,13) corner.Parent=f
  local stroke=Instance.new("UIStroke") stroke.Thickness=2 stroke.Color=edge stroke.Parent=f return f
 end
 local function label(parent,name,value,size,pos,fontSize)
  local t=Instance.new("TextLabel") t.Name=name t.Text=value t.Size=size t.Position=pos t.BackgroundTransparency=1 t.Font=Enum.Font.GothamBold t.TextSize=fontSize or 15 t.TextColor3=Color3.fromRGB(242,247,250) t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=parent return t
 end
 local function button(parent,name,value,size,pos,color)
  local b=Instance.new("TextButton") b.Name=name b.Text=value b.Size=size b.Position=pos b.BackgroundColor3=color or teal b.TextColor3=Color3.fromRGB(250,253,255) b.TextSize=16 b.Font=Enum.Font.GothamBold b.BorderSizePixel=0 b.AutoButtonColor=true b.Parent=parent
  local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,11) corner.Parent=b
  local stroke=Instance.new("UIStroke") stroke.Name="Border" stroke.Color=edge stroke.Thickness=2 stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Parent=b return b
 end
 local function icon(parent,name,id,size,pos)
  local i=Instance.new("ImageLabel") i.Name=name i.Image=C.Icons[id] i.BackgroundTransparency=1 i.Size=size i.Position=pos i.ScaleType=Enum.ScaleType.Fit i.Parent=parent return i
 end
 local status=Instance.new("Frame") status.Name="Status" status.Size=UDim2.fromScale(1,1) status.BackgroundTransparency=1 status.Parent=gui
 local wallet=card(status,"Wallet",UDim2.fromOffset(220,57),UDim2.fromOffset(16,12),Color3.fromRGB(30,104,84)) icon(wallet,"Icon","Cash",UDim2.fromOffset(39,39),UDim2.fromOffset(10,9))
 label(status,"Cash","$0",UDim2.fromOffset(157,36),UDim2.fromOffset(71,22),26)
 local bag=card(status,"BagCard",UDim2.fromOffset(220,60),UDim2.fromOffset(16,78)) icon(bag,"Icon","Bucket",UDim2.fromOffset(34,34),UDim2.fromOffset(10,8))
 label(status,"Bucket","0 / 40",UDim2.fromOffset(153,25),UDim2.fromOffset(68,87),18)
 local track=card(status,"BucketTrack",UDim2.fromOffset(192,7),UDim2.fromOffset(30,121),Color3.fromRGB(12,21,31)) track.UIStroke:Destroy()
 local fill=card(track,"Fill",UDim2.fromScale(0,1),UDim2.new(),gold) fill.UIStroke:Destroy()
 local progress=card(status,"EggCard",UDim2.fromOffset(340,68),UDim2.new(.5,-170,0,12))
 local title=label(status,"Round","SPECIMEN 01",UDim2.fromOffset(314,22),UDim2.new(.5,-157,0,19),14) title.TextXAlignment=Enum.TextXAlignment.Center
 local progressTrack=card(status,"ProgressTrack",UDim2.fromOffset(304,13),UDim2.new(.5,-152,0,51),Color3.fromRGB(9,19,29)) progressTrack.UIStroke:Destroy()
 local progressFill=card(progressTrack,"Fill",UDim2.fromScale(0,1),UDim2.new(),teal) progressFill.UIStroke:Destroy()
 local progressText=label(status,"Progress","0% EXCAVATED",UDim2.fromOffset(304,17),UDim2.new(.5,-152,0,48),11) progressText.TextXAlignment=Enum.TextXAlignment.Center
 label(status,"Contents","Shell 0   Membrane 0   Matrix 0",UDim2.fromOffset(280,24),UDim2.fromOffset(18,141),12).Visible=false
 label(status,"Contribution","Mining 0",UDim2.fromOffset(260,24),UDim2.fromOffset(18,165),12).Visible=false
 label(status,"Equipped","",UDim2.fromOffset(1,1),UDim2.new(),10).Visible=false
 button(gui,"Bag","BAG",UDim2.fromOffset(70,36),UDim2.new(1,-88,0,65),navy)
 button(gui,"Shop","UPGRADES",UDim2.fromOffset(142,44),UDim2.new(1,-160,0,12),Color3.fromRGB(174,112,31))
 button(gui,"Help","HELP",UDim2.fromOffset(62,36),UDim2.new(1,-158,0,65),navy)
 local tools=card(gui,"Tools",UDim2.fromOffset(180,84),UDim2.new(.5,-90,1,-112),Color3.fromRGB(13,22,34)) tools.Active=true
 for index,name in {"Pickaxe","Bucket"} do
  local b=button(tools,name,"",UDim2.fromOffset(80,72),UDim2.fromOffset(6+(index-1)*88,6),navy)
  icon(b,"Icon",name,UDim2.fromOffset(46,46),UDim2.fromOffset(17,3))
  local t=label(b,"Label",name:upper(),UDim2.new(1,0,0,17),UDim2.fromOffset(0,50),10) t.TextXAlignment=Enum.TextXAlignment.Center
  label(b,"Key",tostring(index),UDim2.fromOffset(15,18),UDim2.fromOffset(6,4),12)
  b.Border.Name="Selection" b.Selection.Thickness=3
 end
 button(gui,"Use","STRIKE",UDim2.fromOffset(105,65),UDim2.new(1,-122,1,-201),teal)
 local tutorial=card(gui,"Tutorial",UDim2.fromOffset(268,101),UDim2.fromOffset(16,151)) tutorial.Active=true
 label(tutorial,"Heading","FIRST SHIFT  1 / 7",UDim2.new(1,-66,0,19),UDim2.fromOffset(12,7),11).TextColor3=gold
 local text=label(tutorial,"Instruction","Equip your pickaxe to get started.",UDim2.new(1,-24,0,43),UDim2.fromOffset(12,30),13) text.TextWrapped=true text.TextYAlignment=Enum.TextYAlignment.Top
 button(tutorial,"Skip","SKIP",UDim2.fromOffset(44,22),UDim2.new(1,-52,0,5),navy).TextSize=10
 icon(tutorial,"Arrow","Sell",UDim2.fromOffset(18,18),UDim2.fromOffset(11,77)).Visible=false
 label(tutorial,"Objective","",UDim2.new(1,-42,0,18),UDim2.fromOffset(35,77),11).TextColor3=gold
 local guidance=label(gui,"Guidance","1 / 2 select     Hold click or E to use     F interact",UDim2.new(.95,0,0,20),UDim2.new(.025,0,1,-25),11) guidance.TextXAlignment=Enum.TextXAlignment.Center
 local toast=label(gui,"Toast","",UDim2.new(.8,0,0,38),UDim2.new(.1,0,.21,0),18) toast.TextXAlignment=Enum.TextXAlignment.Center toast.TextWrapped=true toast.TextColor3=gold
 local cross=label(gui,"Crosshair","+",UDim2.fromOffset(20,20),UDim2.fromScale(.5,.5),18) cross.AnchorPoint=Vector2.new(.5,.5) cross.TextXAlignment=Enum.TextXAlignment.Center
 local shop=card(gui,"Station",UDim2.fromOffset(388,410),UDim2.fromScale(.5,.5)) shop.AnchorPoint=Vector2.new(.5,.5) shop.Visible=false shop.Active=true shop.ZIndex=20
 local scale=Instance.new("UIScale") scale.Name="Fit" scale.Parent=shop
 label(shop,"Title","EQUIPMENT BAY",UDim2.new(1,-60,0,29),UDim2.fromOffset(18,14),23)
 label(shop,"Subtitle","Upgrade your next expedition",UDim2.new(1,-36,0,22),UDim2.fromOffset(18,44),13).TextColor3=Color3.fromRGB(162,184,195)
 button(shop,"Close","X",UDim2.fromOffset(32,32),UDim2.new(1,-44,0,12),Color3.fromRGB(159,64,60))
 for index,name in {"Power","Speed","Capacity"} do
  local b=button(shop,name,"",UDim2.new(1,-32,0,73),UDim2.fromOffset(16,77+(index-1)*81),Color3.fromRGB(39,56,72))
  icon(b,"Icon",name,UDim2.fromOffset(43,43),UDim2.fromOffset(10,14))
  label(b,"Title",name=="Speed" and "SWING SPEED" or name=="Capacity" and "BUCKET SIZE" or "STRIKING POWER",UDim2.fromOffset(170,23),UDim2.fromOffset(65,9),13)
  label(b,"Detail","Level 0",UDim2.fromOffset(170,24),UDim2.fromOffset(65,35),12).TextColor3=Color3.fromRGB(180,199,207)
  label(b,"Price","$0",UDim2.fromOffset(79,35),UDim2.new(1,-89,0,20),19).TextColor3=gold
 end
 button(shop,"Sell","SELL BUCKET",UDim2.fromOffset(170,39),UDim2.fromOffset(16,325),teal)
 button(shop,"NextRound","NEXT SPECIMEN",UDim2.fromOffset(178,39),UDim2.fromOffset(194,325),Color3.fromRGB(63,82,103)).TextSize=13
 label(shop,"Hint","Visit the depot to purchase upgrades.",UDim2.new(1,-32,0,28),UDim2.fromOffset(16,372),12).TextXAlignment=Enum.TextXAlignment.Center
 require(game.ReplicatedStorage.VesperShared.HUDLayout).Style(gui)
 require(game.ReplicatedStorage.VesperShared.HUDLayout).Update(gui,workspace.CurrentCamera.ViewportSize,false)
 return gui
end
return UI
