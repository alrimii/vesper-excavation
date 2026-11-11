-- Read-only behavior observers and a temporary capture camera; runtime Studio only.
assert(game:GetService('RunService'):IsStudio() and game:GetService('RunService'):IsRunning())
local p=game.Players.LocalPlayer
assert(p:GetAttribute('SaveStatus')=='STUDIO PREVIEW')
local r={started=workspace:GetServerTimeNow(),feedback={},samples={},input={}}
_G.Phase4ClientEvidence=r
p:SetAttribute('CenteredAim',true)
local point=Vector3.new(0,20.04132,39.84445)
local cameraScript=Instance.new('LocalScript');cameraScript.Name='Phase4CaptureCamera'
cameraScript:SetAttribute('Pose',CFrame.lookAt(Vector3.new(8,23,51),point))
cameraScript.Source=[[local s=script;game:GetService('RunService'):BindToRenderStep('Phase4Capture',Enum.RenderPriority.Last.Value+100,function() local c=workspace.CurrentCamera;c.CameraType=Enum.CameraType.Scriptable;c.FieldOfView=48;c.CFrame=s:GetAttribute('Pose') end)]]
cameraScript.Parent=p.PlayerScripts
game.ReplicatedStorage.VesperShared.Remotes.Feedback.OnClientEvent:Connect(function(kind,a,b,c,d,e,f,g,h)
 if table.find({'Windup','Charge','ChargeCancel','Blast','Hit','Miss','Cancel','Notice'},kind) then
  local function value(v) if typeof(v)=='Instance' then return v:GetFullName() elseif typeof(v)=='Vector3' then return tostring(v) elseif type(v)=='table' then return v else return v end end
  table.insert(r.feedback,{time=workspace:GetServerTimeNow()-r.started,kind=kind,a=value(a),b=value(b),c=value(c),d=value(d),e=value(e),f=value(f),g=value(g),h=value(h)})
 end
end)
game:GetService('UserInputService').InputBegan:Connect(function(input,processed)
 if table.find({Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.E},input.KeyCode) then table.insert(r.input,{time=workspace:GetServerTimeNow()-r.started,key=input.KeyCode.Name,processed=processed}) end
end)
local last=0
game:GetService('RunService').Heartbeat:Connect(function()
 local now=workspace:GetServerTimeNow()
 if now-last<0.05 then return end;last=now
 local ch=p.Character;local tool=ch and ch:FindFirstChildOfClass('Tool');if not tool then return end
 local tip=tool:FindFirstChild('StrikeTip',true) or tool:FindFirstChild('WorkingTip',true)
 local rotor=tool:FindFirstChild('DrillRotor',true)
 local sounds,bursts=0,0
 local effects=workspace:FindFirstChild('LocalResourceVisuals')
 if effects then for _,s in effects:GetDescendants() do if s:IsA('Sound') and s.Playing then sounds+=1 elseif s.Name=='ExcavationBurst' then bursts+=1 end end end
 table.insert(r.samples,{time=now-r.started,family=tool:GetAttribute('ToolFamily'),tip=tip and tostring(tip.WorldPosition),distance=tip and (tip.WorldPosition-point).Magnitude,rotor=rotor and tostring(rotor.Transform),charges=workspace:FindFirstChild('PlacedExcavationCharges') and #workspace.PlacedExcavationCharges:GetChildren(),sounds=sounds,bursts=bursts})
end)
return {camera='fixed side/front shell contact',preview=p:GetAttribute('SaveStatus')}
