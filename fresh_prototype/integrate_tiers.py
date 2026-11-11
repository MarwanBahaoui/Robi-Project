import json
from pathlib import Path
p=Path(__file__).parent
old=json.loads((p/'garage_tiers_backup_2026-11-10.json').read_text(encoding='utf8'))
game=old['Game']
def rep(a,b):
 global game
 assert a in game,a[:100]
 game=game.replace(a,b,1)
rep('local G={}','local Tiers=require(script.Parent.GarageTiers)\nlocal Plots=require(script.Parent.GaragePlots)\nlocal G={}')
rep('    local world=W.Build()','    local world=W.Build()\n    Plots.Apply(world)')
rep('garagePosition=a and a.garage.Floor.Position','garagePosition=a and a.garage.Entrance.Position')
rep('return {schema=1,cash=a.cash,bank=a.bank,capacity=a.capacity,accel=a.accel,vans=vans,discovered=discoveries}', 'return {schema=2,tier=a.tier,cash=a.cash,bank=a.bank,capacity=a.capacity,accel=a.accel,vans=vans,discovered=discoveries}')
rep('slotCost=C.SlotCost,accelCost=C.AccelerationCost','slotCost=Tiers.SlotCost(a.tier,a.capacity),garageUpgrade=Tiers.Offer(a),accelCost=C.AccelerationCost')
rep('cash=0,bank=0,capacity=2,accel=0','cash=0,bank=0,tier=1,capacity=3,accel=0')
rep('a.cash=saved.cash;a.bank=saved.bank;a.capacity=saved.capacity;a.accel=saved.accel;a.discovered=saved.discovered','a.cash=saved.cash;a.bank=saved.bank;a.tier=saved.tier;a.capacity=saved.capacity;a.accel=saved.accel;a.discovered=saved.discovered')
rep('        for _,record in ipairs(saved.vans) do','        Plots.Refresh(a,p.DisplayName.."\'s GARAGE");garage=a.garage\n        for _,record in ipairs(saved.vans) do')
game=game.replace('"AVAILABLE GARAGE"','"WAITING FOR PLAYER"')
start=game.index('        elseif verb=="upgrade" and value=="slot" then')
end=game.index('        dirty(a);send(p)',start)
game=game[:start]+'''        elseif verb=="upgrade" and (value=="slot" or value=="tier") then
            local ok,message=Tiers.Buy(a,value)
            notice(a,message)
            if ok then
                local pending=a.arrival and a.vans[a.arrival]
                if pending then local slot=chooseSlot(a,pending.kind);if slot>0 then pending.slot=slot;a.arrival=nil end end
                Plots.Refresh(a,p.DisplayName.."'s GARAGE")
                for _,v in pairs(a.vans) do park(a,v) end
            end
        end
'''+game[end:]
rep('capacity=a.capacity,accel=a.accel}', 'capacity=a.capacity,tier=a.tier,accel=a.accel}')
profile=old['ProfileStore'].replace('ProfileStore.Schema=1','local Tiers=require(script.Parent.GarageTiers)\nProfileStore.Schema=2')
profile=profile.replace(' if type(data)~="table" or data.schema~=1 then return nil,"Unsupported save format" end', ''' if type(data)~="table" or (data.schema~=1 and data.schema~=2) then return nil,"Unsupported save format" end
 local legacy=data.schema==1
 if legacy then
  if data.capacity~=2 and data.capacity~=3 then return nil,"Invalid legacy capacity" end
  data=copy(data);data.schema=2;data.tier=1;data.capacity=3
  -- Refund the old paid third slot, now included free for all starters.
  if data.cash and number(data.cash,0,1e12) and data.accel~=nil then
   if data.capacity and legacy and select(1,true) then end
  end
 end
 local tier=Tiers.List[data.tier]
 if not tier then return nil,"Invalid garage tier" end''')
# Capture legacy paid capacity before conversion; migration is committed atomically by Load.
profile=profile.replace('  data=copy(data);data.schema=2;data.tier=1;data.capacity=3\n  -- Refund the old paid third slot, now included free for all starters.\n  if data.cash and number(data.cash,0,1e12) and data.accel~=nil then\n   if data.capacity and legacy and select(1,true) then end\n  end', '  local paidThird=data.capacity==3\n  data=copy(data);data.schema=2;data.tier=1;data.capacity=3\n  if paidThird and number(data.cash,0,1e12-180) then data.cash+=180 end')
profile=profile.replace(' if data.capacity~=2 and data.capacity~=3 then return nil,"Invalid capacity" end',' if not number(data.capacity,tier.included,tier.max) or data.capacity%1~=0 then return nil,"Invalid capacity" end')
profile=profile.replace('key>4 or count>4','key>data.capacity+1 or count>data.capacity+1')
profile=profile.replace('return {schema=1,cash=0,bank=0,capacity=2,accel=0,vans={},discovered={}}','return {schema=2,tier=1,cash=0,bank=0,capacity=3,accel=0,vans={},discovered={}}')
driving=old['Driving'].replace('garageArea and -96 or -48,garageArea and 96 or 48','garageArea and -294 or -48,garageArea and 294 or 48').replace('garageArea and 117 or 70','garageArea and 299 or 70')
world=old['World'].replace('require(script.Parent.Scenery).Apply(workspace.RidePrototype)','require(script.Parent.Scenery).Apply(workspace.RidePrototype)\n        require(script.Parent.GaragePlots).Apply(workspace.RidePrototype)').replace('require(script.Parent.Scenery).Apply(world)','require(script.Parent.Scenery).Apply(world)\n    require(script.Parent.GaragePlots).Apply(world)')
client=old['Client']
# Expand trader layout with persistent tabs.
client=client.replace('UDim2.fromOffset(12,48);list.Size=UDim2.new(1,-24,1,-104)','UDim2.fromOffset(12,94);list.Size=UDim2.new(1,-24,1,-150)')
client=client.replace('local rendered=""','local rendered=""\nlocal traderTab="sell"\nlocal tierConfirm=false\nlocal sellTab,upgradeTab')
start=client.index('local function renderTrade()');end=client.index('local close=',start)
client=client[:start]+'''local function renderTrade()
    if not data then return end
    clear()
    if sellTab then
        sellTab.BackgroundColor3=traderTab=="sell" and Color3.fromRGB(43,145,135) or Color3.fromRGB(42,63,74)
        upgradeTab.BackgroundColor3=traderTab=="upgrade" and Color3.fromRGB(43,145,135) or Color3.fromRGB(42,63,74)
    end
    local function info(name,message,height)
        local t=label(list,name,message,15,height or 58);t.TextColor3=Color3.fromRGB(206,222,221);return t
    end
    if traderTab=="upgrade" then
        local u=data.garageUpgrade
        if not u then info("Loading","Loading upgrades...");return end
        info("TierSummary","TIER "..u.tier.." / 5  •  "..u.name.."\\n"..data.capacity.." / "..u.max.." slots unlocked  •  Cash $"..data.cash,66)
        if data.slotCost then
            button(list,"GarageSlot","Unlock slot "..(data.capacity+1).." • $"..data.slotCost..(data.cash<data.slotCost and "\\nNot enough cash - collect earnings" or ""),function()action:FireServer("upgrade","slot")end)
        else info("SlotsMax","All "..u.max.." slots unlocked",32) end
        if u.nextTier then
            local n=u.nextTier
            -- Preview the next architectural theme with the actual procedural builder's tier palette.
            local themes={Color3.fromRGB(75,159,144),Color3.fromRGB(79,148,198),Color3.fromRGB(221,159,61),Color3.fromRGB(159,116,210),Color3.fromRGB(230,200,112)}
            local preview=Instance.new("ViewportFrame");preview.Name="GaragePreview";preview.Size=UDim2.new(1,-8,0,125);preview.BackgroundColor3=Color3.fromRGB(15,26,35);preview.Parent=list
            local wm=Instance.new("WorldModel");wm.Parent=preview
            local function shape(size,pos,color)
                local p=Instance.new("Part");p.Anchored=true;p.Size=size;p.Position=pos;p.Color=color;p.Parent=wm
            end
            local depth=10+n.tier*4;local accent=themes[n.tier]
            shape(Vector3.new(depth,1,15),Vector3.zero,Color3.fromRGB(95,112,118))
            shape(Vector3.new(1,8,15),Vector3.new(depth/2,4,0),Color3.fromRGB(32,47,60))
            shape(Vector3.new(depth,.5,15),Vector3.new(0,8,0),accent)
            for _,z in ipairs({-7,7}) do shape(Vector3.new(.5,8,.5),Vector3.new(-depth/2,4,z),accent) end
            for x=-depth/2+3,depth/2-2,5 do for z=-5,5,5 do shape(Vector3.new(3,.1,3),Vector3.new(x,.6,z),accent) end end
            local cam=Instance.new("Camera");cam.CFrame=CFrame.lookAt(Vector3.new(-depth,18,24),Vector3.new(0,2,0));cam.Parent=preview;preview.CurrentCamera=cam
            info("NextTier",n.name.." • $"..n.price.."\\nIncludes "..n.included.." usable slots; expand to "..n.max..".\\n"..n.description,90)
            if not u.canTier then info("TierLocked","Unlock all "..u.max.." slots first. You do not need to fill them.",52)
            elseif data.cash<n.price then info("TierCash","Need $"..(n.price-data.cash).." more for this building.",36)
            elseif tierConfirm then
                button(list,"ConfirmTier","Confirm "..n.name.." • $"..n.price,function()tierConfirm=false;action:FireServer("upgrade","tier")end)
                button(list,"CancelTier","Keep current garage",function()tierConfirm=false;renderTrade()end)
            else button(list,"PreviewTier","Upgrade to "..n.name,function()tierConfirm=true;renderTrade()end) end
        else info("MaxTier","ELITE GARAGE • Maximum tier reached",44) end
        if data.accel==0 then button(list,"Acceleration","Acceleration +30% • $"..data.accelCost,function()action:FireServer("upgrade","accel")end)
        else info("AccelerationOwned","Acceleration upgrade • Purchased",36) end
    elseif data.quote then
        local q=data.quote
        label(list,"ConfirmText","Sell "..q.kind.." for $"..q.price.."?\\nLose $"..q.loss.."/s. Discovery stays recorded.",17,88)
        button(list,"ConfirmSale","Confirm sale",function()action:FireServer("sell",q.token)end)
        button(list,"CancelSale","Keep this van",function()action:FireServer("cancel")end)
    else
        if #data.vans==0 then info("Empty","Bring a van home to earn income or sell it here.") end
        for _,v in ipairs(data.vans) do
            button(list,"Van_"..v.id,v.kind..(v.slot==0 and " • Arrival bay" or " • Slot "..v.slot).."\\nSell $"..v.sale.." | earns $"..v.income.."/s",function()action:FireServer("quote",v.id)end)
        end
    end
end
sellTab=button(modal,"SellTab","Sell vans",function()traderTab="sell";tierConfirm=false;renderTrade()end)
sellTab.Size=UDim2.new(.5,-18,0,36);sellTab.Position=UDim2.fromOffset(12,48)
upgradeTab=button(modal,"UpgradeTab","Garage upgrades",function()traderTab="upgrade";tierConfirm=false;action:FireServer("cancel");renderTrade()end)
upgradeTab.Size=UDim2.new(.5,-18,0,36);upgradeTab.Position=UDim2.new(.5,6,0,48)
'''+client[end:]
client=client.replace('local signature=(d.quote and d.quote.token or "")..":"..d.capacity..":"..d.accel','local signature=(d.quote and d.quote.token or "")..":"..d.capacity..":"..d.accel..":"..(d.garageUpgrade and d.garageUpgrade.tier or 1)..":"..d.cash')
client=client.replace('" • "..d.capacity.." earning slots"','" • "..(d.garageUpgrade and d.garageUpgrade.name or "Starter").." • "..d.capacity.." slots"')
out={'Game':game,'ProfileStore':profile,'Driving':driving,'World':world,'Client':client}
for key in ['GarageTiers','GaragePlots']:out[key]=(p/(key+'.luau')).read_text(encoding='utf8')
(p/'garage_tiers_sources.json').write_text(json.dumps(out),encoding='utf8')
print('Prepared tier integration and schema migration')
