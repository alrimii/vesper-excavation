-- Equipment presentation only. Prices, ownership and mutations remain server-owned.
local M={}
function M.Build(screen,player,base,remote,feedback,close)
	local S=require(script.Parent.OutfitterComponents)
	local Art=require(script.Parent.OutfitterArt)
	local Rules=require(script.Parent.ProgressionRules)
	local E=require(script.Parent.UpgradeEconomy)
	local P=require(script.Parent.UpgradePresentation)
	local Http=game:GetService("HttpService")
	local UIS=game:GetService("UserInputService")
	local root=S.Surface(screen,"Outfitter",S.Paper,18);S.Edge(root,S.Ink,3)
	root.AnchorPoint=Vector2.new(.5,.5);root.Position=UDim2.fromScale(.5,.5)
	local emblem=S.Icon(root,"WorkshopEmblem",Art.Emblem)
	local title=S.Text(root,"Title","THE OUTFITTER",29,S.Ink,true)
	local subtitle=S.Text(root,"Subtitle","Tools for your next discovery",15,S.Muted)
	local walletIcon=S.Icon(root,"Credits",Art.Credits)
	local wallet=S.Text(root,"Balance","",20,S.Ink,true)
	local exit=S.Button(root,"Close","Close",S.Wood);exit.Activated:Connect(close)
	local equipment=S.Button(root,"Equipment","Equipment",S.Green)
	local upgrades=S.Button(root,"Upgrades","Upgrades",S.Wood)
	local body=S.Make("Frame",root,{Name="Content",BackgroundTransparency=1,ClipsDescendants=true})
	local status=S.Text(root,"Receipt","",16,S.Muted)
	local page,selected,quantity="TOOLS","Pickaxe",1
	local pending,dirty,lastSize=nil,true,Vector2.zero
	local entries,upgradeRows={},{}
	local mobile=false
	local roles={Pickaxe="Deliberate strikes",Drill="Continuous focused contact",Explosive="A controlled area blast"}
	local short={Pickaxe="Pickaxe",Drill="Drill",Explosive="Charge"}
	local descriptions={Power="Hit harder.",Speed="Attack more often.",Capacity="Carry more before selling.",Precision="Make accurate hits count.",Yield="Collect extra from your share.",Value="Earn more when you sell.",Critical="Chance for a 1.5× hit."}
	local names={Power="Impact",Speed="Tempo",Capacity="Storage",Precision="Precision",Yield="Extraction",Value="Refining",Critical="Resonance"}
	local function attr(k) return player:GetAttribute(k) end
	local function number(n) local s=tostring(math.floor(n or 0));return s:reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","") end
	local function place(o,x,y,w,h) o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(w,h) end
	local function send(kind,a,b)
		if pending then return end
		pending={id=Http:GenerateGUID(false),at=os.clock()};status.Text="Working…";status.TextColor3=S.Muted
		remote:FireServer(kind,a,b,pending.id,selected);dirty=true
	end
	feedback.OnClientEvent:Connect(function(kind,id,ok,message)
		if kind=="ShopReceipt" and pending and id==pending.id then
			pending=nil;status.Text=message or (ok and "Done." or "Please try again.")
			status.TextColor3=ok and S.Green or S.Error;dirty=true
		end
	end)
	player.AttributeChanged:Connect(function() dirty=true end)
	equipment.Activated:Connect(function() page="TOOLS";dirty=true end)
	upgrades.Activated:Connect(function() page="RIG";dirty=true end)
	local productHost=S.Make("Frame",body,{Name="Products",BackgroundTransparency=1})
	for _,id in Rules.ToolOrder do
		local card=S.Surface(productHost,id,S.Pale,13);local edge=S.Edge(card,S.Sand,2)
		local view=S.Preview(card,script.Parent.EquipmentAssets[id])
		local name=S.Text(card,"Name",short[id],25,S.Ink,true)
		local role=S.Text(card,"Role",roles[id],15,S.Muted)
		local state=S.Text(card,"State","",16,S.Green,true)
		local choose=S.Make("TextButton",card,{Name="Select",Text="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Selectable=true,ZIndex=4})
		choose.Activated:Connect(function() selected=id;dirty=true end)
		entries[id]={card=card,view=view,name=name,role=role,state=state,edge=edge}
	end
	local detail=S.Surface(body,"SelectedEquipment",S.Sand,12)
	local detailName=S.Text(detail,"Name","",23,S.Ink,true)
	local stats=S.Text(detail,"Stats","",18,S.Ink)
	local hint=S.Text(detail,"Reason","",15,S.Muted)
	local action=S.Button(detail,"PrimaryAction","Equip")
	action.Activated:Connect(function()
		if attr("OwnsTool_"..selected) then send("EquipTool",selected) else send("BuyTool",selected) end
	end)
	local trial=S.Button(detail,"Trial","Try drill · 90s",S.Wood)
	trial.Activated:Connect(function() if not pending then remote:FireServer("TryDrill");dirty=true end end)
	local list=S.Make("ScrollingFrame",body,{Name="UpgradeCards",BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,ScrollBarImageColor3=S.Wood,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y})
	local qtyHost=S.Make("Frame",body,{Name="Quantity",BackgroundTransparency=1})
	local qtyLabel=S.Text(qtyHost,"Label","Buy ranks",15,S.Muted)
	local qtyButtons={}
	for i,v in {1,5,"Max"} do local b=S.Button(qtyHost,"Quantity"..tostring(v),tostring(v),S.Wood);qtyButtons[i]=b;b.Activated:Connect(function() quantity=v;dirty=true end) end
	local function effect(key,rank,config)
		if key=="Power" then local d=math.floor((config.Mining.Power+rank*config.Upgrades.Power.Step)*(attr("PowerBonus") or 1));return number(d)..(selected=="Drill" and " / tick" or selected=="Explosive" and " at center" or " / strike") end
		if key=="Speed" then return string.format("%.3fs",math.max(config.Mining.MinimumCooldown,config.Mining.Cooldown-rank*config.Upgrades.Speed.Step)) end
		if key=="Yield" then return "+"..rank.." at full share" end
		return E.Effect(key,rank,config)
	end
	for _,key in E.Order do
		local row=S.Surface(list,key,S.Pale,12);S.Edge(row,S.Sand,1)
		local icon=S.Icon(row,"Effect",Art[key]);local name=S.Text(row,"Name",names[key],21,S.Ink,true)
		local rank=S.Text(row,"Rank","",14,S.Muted)
		local value=S.Text(row,"Comparison","",17,S.Ink)
		local why=S.Text(row,"Benefit",descriptions[key],14,S.Muted)
		local buy=S.Button(row,"Upgrade","",S.Green);buy.TextSize=17
		buy.Activated:Connect(function() send("Upgrade",key,quantity) end)
		upgradeRows[key]={row=row,icon=icon,name=name,rank=rank,value=value,why=why,buy=buy}
	end
	local api={Root=root}
	function api:Select(p) page=p=="RIG" and "RIG" or "TOOLS";selected=attr("ToolFamily") or "Pickaxe";dirty=true end
	function api:Update()
		if not root.Visible then return end
		local available=screen.AbsoluteSize
		if available~=lastSize then dirty=true;lastSize=available end
		if pending and os.clock()-pending.at>12 then status.Text="Still waiting for your purchase result. No repeat request sent." end
		if not dirty then return end;dirty=false
		mobile=UIS.TouchEnabled or available.Y<560 or available.X<760
		local w=math.min(1100,available.X-24);local h=math.min(680,available.Y-20)
		root.Size=UDim2.fromOffset(w,h)
		local header=mobile and 98 or 132
		place(emblem,14,9,mobile and 48 or 65,mobile and 48 or 65)
		place(title,mobile and 70 or 88,12,w-340,mobile and 26 or 34);title.TextSize=mobile and 23 or 29
		subtitle.Visible=not mobile;place(subtitle,88,49,w-380,23)
		place(exit,w-86,12,72,42);place(walletIcon,w-260,14,34,34);place(wallet,w-220,14,124,34)
		wallet.Text=attr("Cash")~=nil and number(attr("Cash")) or "Loading…"
		local tabY=mobile and 56 or 84
		place(equipment,16,tabY,150,36);place(upgrades,176,tabY,150,36)
		equipment.BackgroundColor3=page=="TOOLS" and S.Green or S.Wood;upgrades.BackgroundColor3=page=="RIG" and S.Green or S.Wood
		place(body,16,header,w-32,h-header-42);place(status,20,h-37,w-40,30)
		local bw,bh=w-32,h-header-42
		local cash=attr("Cash") or 0;local owned=attr("OwnsTool_"..selected)==true
		local equipped=attr("ToolFamily")==selected
		local ready=attr("LabReady")==true and attr("Cash")~=nil
		local config=Rules.ToolConfig(selected,base)
		local pw,cd=P.ToolStats(selected,player,Rules,base)
		local toolPrice=Rules.Tools[selected].Cost
		detailName.Text=Rules.Tools[selected].Name
		stats.Text=selected=="Drill" and string.format("%s damage / tick\n%.3fs interval · %.1f DPS",number(pw),cd,pw/cd)
			or selected=="Explosive" and string.format("%s center damage · %.2fs cooldown\n%g stud blast · %d%% edge damage",number(pw),cd,base.Tools.Explosive.Radius,base.Tools.Explosive.EdgeMultiplier*100)
			or string.format("%s damage / strike\n%.2fs between swings",number(pw),cd)
		hint.Text=not ready and "Equipment is still loading."
			or page=="RIG" and (equipped and "Each tool keeps its own upgrades." or owned and "Equip this tool to upgrade it." or "Own this tool before upgrading.")
			or not owned and (cash<toolPrice and "Need "..number(toolPrice-cash).." more credits." or "Purchase once. Upgrades stay with this tool.")
			or "Strength and creature bonuses included."
		action.Text=pending and "Working…" or not ready and "Loading…" or equipped and "Equipped" or owned and "Equip tool" or "Buy · "..number(toolPrice)
		action.Interactable=ready and not pending and not equipped and (owned or cash>=toolPrice)
		action.BackgroundColor3=action.Interactable and S.Green or S.Muted
		trial.Visible=page=="TOOLS" and selected=="Drill" and not owned and not attr("DrillTrialUsed") and ready
		trial.Interactable=not pending
		list.Visible=page=="RIG";qtyHost.Visible=page=="RIG"
		local compactCards=mobile or page=="RIG"
		local rail=mobile and 118 or 240
		local cardW=compactCards and rail or (bw-24)/3
		local cardH=compactCards and (mobile and 44 or 70) or bh-154
		place(productHost,0,0,compactCards and rail or bw,compactCards and cardH*3+16 or cardH)
		for i,id in Rules.ToolOrder do local e=entries[id]
			place(e.card,compactCards and 0 or (i-1)*(cardW+12),compactCards and (i-1)*(cardH+(mobile and 4 or 8)) or 0,cardW,cardH)
			e.edge.Color=id==selected and S.Green or S.Sand;e.edge.Thickness=id==selected and 3 or 1
			e.view.Visible=not compactCards
			e.name.TextSize=compactCards and (mobile and 17 or 21) or 25
			place(e.name,compactCards and 10 or 18,compactCards and 4 or cardH-84,cardW-20,compactCards and 25 or 30)
			e.role.Visible=not compactCards;place(e.role,18,cardH-51,cardW-36,20)
			e.state.Text=attr("ToolFamily")==id and "EQUIPPED" or attr("OwnsTool_"..id) and "OWNED" or cash>=Rules.Tools[id].Cost and "BUY · "..number(Rules.Tools[id].Cost) or "LOCKED · "..number(Rules.Tools[id].Cost)
			e.state.TextSize=compactCards and (mobile and 11 or 14) or 16
			place(e.state,compactCards and 10 or 18,compactCards and cardH-23 or cardH-28,cardW-20,20)
			place(e.view,12,8,cardW-24,math.max(10,cardH-98))
		end
		-- Mobile equipment: three choices, large selected tool, separate readable action column.
		local oldPreview=detail:FindFirstChild("SelectedPortrait")
		if oldPreview then oldPreview:Destroy() end
		if page=="TOOLS" and not mobile then
			place(detail,0,bh-142,bw,142);place(detailName,18,10,bw-300,28);place(stats,18,43,bw-310,52);place(hint,18,103,bw-320,28)
			place(action,bw-282,20,262,48);place(trial,bw-282,80,262,44)
		elseif page=="TOOLS" then
			local dx=rail+12;place(detail,dx,0,bw-dx,bh)
			local dw=bw-dx;local portrait=math.min(170,dw*.35)
			local v=S.Preview(detail,script.Parent.EquipmentAssets[selected]);v.Name="SelectedPortrait";place(v,6,36,portrait-12,bh-48)
			place(detailName,12,6,dw-24,29);place(stats,portrait+8,40,dw-portrait-20,58);stats.TextSize=16
			place(hint,portrait+8,102,dw-portrait-20,42);hint.TextSize=14
			place(action,portrait+8,bh-52,dw-portrait-20,44)
			place(trial,portrait+8,bh-100,dw-portrait-20,40)
		else
			local dh=mobile and 48 or math.max(100,bh-(cardH+8)*3-58)
			place(detail,0,mobile and bh-48 or (cardH+8)*3,rail,dh);detailName.Visible=false;stats.Visible=false;hint.Visible=not mobile
			place(hint,8,4,rail-16,math.max(32,dh-54));hint.TextSize=mobile and 12 or 15
			place(action,8,dh-48,rail-16,40);action.TextSize=mobile and 14 or 18
			place(qtyHost,mobile and rail+14 or 0,mobile and 0 or bh-48,mobile and bw-rail-14 or rail,48);qtyLabel.Visible=not mobile;place(qtyLabel,0,0,rail,18)
			for i,b in qtyButtons do place(b,(i-1)*(rail/3),mobile and 3 or 20,rail/3-5,mobile and 42 or 28);b.TextSize=16;b.BackgroundColor3=quantity==({1,5,"Max"})[i] and S.Green or S.Wood end
			local lx=rail+14;local lw=bw-lx
			if mobile then
				place(qtyHost,lx,0,132,44)
				for i,b in qtyButtons do place(b,(i-1)*44,0,40,44) end
				place(detail,lx+140,0,lw-140,44);place(action,0,0,lw-140,44)
			end
			place(list,lx,mobile and 50 or 0,lw,mobile and bh-50 or bh)
			local columns=mobile and 1 or 2;local rw=(lw-10-(columns-1)*12)/columns;local rh=mobile and 154 or 174
			for i,key in E.Order do local r=upgradeRows[key];local level=attr("ToolLevel_"..selected.."_"..key) or 0;local max=config.Upgrades[key].MaxLevel
				local count,cost=E.Quote(key,level,cash,quantity,config);local nextRank=math.min(max,level+math.max(1,count));local price=E.Price(key,level,config)
				place(r.row,2+((i-1)%columns)*(rw+12),2+math.floor((i-1)/columns)*(rh+10),rw,rh)
				place(r.icon,8,8,60,60);place(r.name,76,8,rw-88,27);place(r.rank,76,37,rw-88,22)
				place(r.value,12,72,rw-24,28);place(r.why,12,101,rw-24,20)
				r.why.Visible=not mobile;place(r.buy,12,rh-44,rw-24,36)
				r.rank.Text="Rank "..level.." / "..max
				r.value.Text=effect(key,level,config)..(level<max and "  →  "..effect(key,nextRank,config) or "")
				r.value.TextSize=mobile and 16 or 15
				r.buy.Text=level>=max and "Fully upgraded" or not equipped and "Equip this tool first" or count==0 and "Need "..number(price-cash).." more credits" or pending and "Working…" or "+"..count.." rank · "..number(cost).." credits"
				-- Trial attribute is numeric (0 when inactive), not a boolean.
				r.buy.Interactable=ready and owned and equipped and not pending and count>0 and level<max and (attr("DrillTrialEndsAt") or 0)<=workspace:GetServerTimeNow()
				r.buy.BackgroundColor3=r.buy.Interactable and S.Green or S.Muted
			end
			list.CanvasSize=UDim2.fromOffset(0,math.ceil(#E.Order/columns)*(rh+10)+4)
		end
		if page=="TOOLS" then hint.Visible=true;detailName.Visible=true;stats.Visible=true;stats.TextSize=mobile and 16 or 18;hint.TextSize=mobile and 14 or 15;action.TextSize=mobile and 17 or 19 end
	end
	return api
end
return M
