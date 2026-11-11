-- Edit-only temporary render using the real production views and isolated display values.
assert(not game:GetService('RunService'):IsRunning())
local old=game.StarterGui:FindFirstChild('PlayfulSlice') if old then old:Destroy() end
local oldModules=game.ServerStorage:FindFirstChild('PlayfulSliceModules') if oldModules then oldModules:Destroy() end
local S=game.ReplicatedStorage.VesperShared:Clone()
S.Name='PlayfulSliceModules';S.Parent=game.ServerStorage
local K=require(S.InterfaceKit)
local g=K.Make('ScreenGui',game.StarterGui,{Name='PlayfulSlice',ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,DisplayOrder=80})
local size=workspace.CurrentCamera.ViewportSize
local hud=require(S.FieldHUD).Build(g,{Progression=function()end})
hud.Root.Visible=true;hud:Layout(size.X,size.Y,false)
hud.Cash.Value.Text='12,450';hud.Relics.Value.Text='280';hud.Bucket.Value.Text='24/100'
hud.Progress.Label.Text='LV 12';hud.XP.Text='840 / 1,200 XP';hud.Egg.Label.Text='FOSSIL EGG';hud.EggPercent.Text='68%';hud.Points.Text='3'
hud.Guide.Visible=false;hud.Training.Button.Visible=false;hud.Charged.Button.Visible=false;hud.Use.Visible=false;hud.Flow.Visible=false
local panel=K.Surface(g,'EquipmentSlice',K.Paper)
K.Rect(panel,370,148,math.min(900,size.X-400),math.min(510,size.Y-180))
local title=K.Text(panel,'Title','TOOL SHED',30,K.Ink,true);K.Rect(title,18,6,500,40)
local body=K.Make('Frame',panel,{Name='Body',BackgroundTransparency=1});body.Position=UDim2.fromOffset(18,56);body.Size=UDim2.new(1,-36,1,-74)
local ev=Instance.new('BindableEvent');ev.Parent=g
local attrs={Cash=12450,OwnsTool_Pickaxe=true,ToolFamily='Pickaxe',LabReady=true}
local player={GetAttribute=function(_,k)return attrs[k] end,AttributeChanged=ev.Event}
local shell={Body=body,Title=title}
local ui=require(S.OutfitterUI).Build(shell,player,require(S.ExcavationConfig),{FireServer=function()end},{OnClientEvent=ev.Event})
task.wait();ui:Update()
local b=K.Button(g,'SkillSlice','',nil,true);K.Rect(b,175,270,90,90);b.BackgroundColor3=K.Gold
local art=K.Make('ImageLabel',b,{BackgroundTransparency=1,Image='rbxassetid://82521932688624',ImageRectOffset=Vector2.zero,ImageRectSize=Vector2.new(256,256)})
K.Rect(art,8,6,74,74)
local label=K.Text(b,'Name','FAULT SURVEY',16,K.Card,true);K.Rect(label,-32,94,156,26);label.TextXAlignment=Enum.TextXAlignment.Center
return 'Temporary Edit-only slice built from production components'
