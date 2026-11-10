-- Modal router. The shop has exactly Equipment/Upgrades; unrelated menus remain isolated.
local W={}
function W.Build(gui,player,base,remote,feedback,close)
 local S=require(script.Parent.OutfitterComponents)
 local gate=gui.Station
 gate:ClearAllChildren();gate.BackgroundTransparency=1;gate.BorderSizePixel=0
 gate.Size=UDim2.fromScale(1,1);gate.Position=UDim2.new();gate.AnchorPoint=Vector2.zero;gate.Active=false;gate.Visible=false
 local screen=S.Make("ScreenGui",gui.Parent,{Name="OutfitterScreen",ResetOnSpawn=false,DisplayOrder=55,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Enabled=false})
 S.Make("TextButton",screen,{Name="Backdrop",Text="",AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(31,24,20),BackgroundTransparency=.25,BorderSizePixel=0,Size=UDim2.fromScale(1,1),Active=true,Selectable=false})
 local shop=require(script.Parent.OutfitterUI).Build(screen,player,base,remote,feedback,close)
 local secondary,secondaryRoot
 local page="TOOLS"
 local api={}
 function api:Select(p)
  page=p
  if p=="TOOLS" or p=="RIG" then shop:Select(p) else
   if not secondary then
    secondaryRoot=S.Surface(screen,"Station",S.Paper,18)
    secondaryRoot.AnchorPoint=Vector2.new(.5,.5);secondaryRoot.Position=UDim2.fromScale(.5,.5)
    S.Make("UIScale",secondaryRoot,{Name="Fit"})
    local exit=S.Button(secondaryRoot,"Close","×",S.Wood);exit.Activated:Connect(close)
    secondary=require(script.Parent.SecondaryMenus).Build(screen,player,base,remote)
   end
   secondary:Select(p)
  end
 end
 function api:SetVisible(visible)
  gate.Visible=visible;screen.Enabled=visible
  shop.Root.Visible=visible and (page=="TOOLS" or page=="RIG")
  if secondaryRoot then secondaryRoot.Visible=visible and not shop.Root.Visible end
 end
 function api:Update()
  if not screen.Enabled then return end
  shop:Update()
  if secondaryRoot and secondaryRoot.Visible then secondary:Update() end
 end
 return api
end
return W
