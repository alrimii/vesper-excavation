from pathlib import Path
R=Path(__file__).resolve().parent
p=R/'DiscoveryHUD.luau';s=p.read_text(encoding='utf-8').replace('local Builder = require(Shared.SpecimenBuilder)','local Preview = require(Shared.SpecimenPreview)')
s=s.replace('\tlocal scan = button(gui, "Scan", "Q  /  SCAN", UDim2.fromOffset(142, 40), UDim2.new(1, -156, 0, 110))\n','')
a=s.index('\t\tlocal camera = Instance.new("Camera")');b=s.index('\n\t\tlocal name = text(',a);s=s[:a]+'\t\tlocal preview = Preview.Create(view, entry.Id, entry.Color)'+s[b:]
s=s.replace('entry = entry })','entry = entry, preview = preview })')
a=s.index('\tlocal lastScan =');b=s.index('\tUIS.InputBegan:Connect',a);s=s[:a]+s[b:]
s=s.replace('if input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonY then\n\t\t\tscanEgg()\n\t\telseif input.KeyCode == Enum.KeyCode.J','if input.KeyCode == Enum.KeyCode.J')
a=s.index('\t\tsignal.Visible =');b=s.index('\t\tlocal portrait =',a);s=s[:a]+s[b:]
a=s.index('\t\tscan.Position =');b=s.index('\t\trank.Position =',a);s=s[:a]+s[b:]
a=s.index('\t\tif os.clock() < scanUntil then');b=s.index('\n\t\tcontract.Objective.Position',a);s=s[:a]+s[b:]
s=s.replace('card.view.Visible = count > 0\n\t\t\t\tcard.view.ImageColor3 = count > 0 and Color3.new(1, 1, 1) or Color3.fromRGB(31, 43, 57)','card.preview:SetUnlocked(count > 0)')
s=s.replace('" / 6 species documented  |  "','" / " .. #Catalog.Specimens .. " species documented  |  "').replace('Q SCAN   ','').replace('updateArtwork(v, scan)','updateArtwork(v)')
p.write_text(s,encoding='utf-8')
p=R/'MenuArtwork.luau';s=p.read_text(encoding='utf-8').replace('Q scans nearby plates.','Accurate strikes deal extra damage.').replace('return function(viewport, scan)','return function(viewport)')
a=s.index('\n\t\tif enabled then\n\t\t\tscan.Size');b=s.index('\n\tend\nend\nreturn M',a);s=s[:a]+s[b:];p.write_text(s,encoding='utf-8')
p=R/'ExcavationClient.luau';s=p.read_text(encoding='utf-8')
s=s.replace('local shopOpen = false','local shopOpen = false\nlocal workshop = require(Shared.WorkshopUI).Build(gui, player, C, Action)',1)
s=s.replace('local yieldAmount = layerIndex and C.Layers[layerIndex].Yield or 1','local yieldAmount = (layerIndex and C.Layers[layerIndex].Yield or 1) + (player:GetAttribute("YieldBonus") or 0)')
a=s.index('\tfor name, _terminal in');b=s.index('\n\tif amount < cap then',a);s=s[:a]+s[b:]
s=s.replace('function(kind, a, b, c, d, e, damage, precise)','function(kind, a, b, c, d, e, damage, precise, critical)')
s=s.replace('(precise and "PRECISE  " or "") .. tostring(damage)','(critical and "CRITICAL  " or precise and "PRECISE  " or "") .. tostring(damage)')
s=s.replace('\telseif kind == "Collected" then','\telseif kind == "UpgradeBought" then\n\t\tnotice(C.Upgrades[a].Name .. " +" .. tostring(b) .. " levels")\n\telseif kind == "Collected" then')
s=s.replace('\tlocal nearby = root and (root.Position - Vector3.new(4, 3, -80)).Magnitude < 30\n','')
s=s.replace('\tDiscoveryHUD.Update(kind)','\tDiscoveryHUD.Update(kind)\n\tworkshop:Update(workspace.CurrentCamera.ViewportSize)')
p.write_text(s,encoding='utf-8')
p=R/'UIMotion.luau';s=p.read_text(encoding='utf-8').replace('SelectedObject = station.Power','SelectedObject = station.WorkshopContent.UpgradeList.Power.Buy');p.write_text(s,encoding='utf-8')
