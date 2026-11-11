local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local Prompts=game:GetService("ProximityPromptService")
local C=require(script.Parent.Config)
local W=require(script.Parent.World)
local Driving=require(game.ReplicatedStorage.RideNetwork.Driving)
local Parking=require(game.ReplicatedStorage.RideNetwork.Parking)
local ProfileStore=require(script.Parent.ProfileStore)
local ReturnSprint=require(script.Parent.ReturnSprint)
local Tiers=require(script.Parent.GarageTiers)
local Plots=require(script.Parent.GaragePlots)
local G={}
function G.Start()
    local world=W.Build()
    Plots.Apply(world)
    local network=game.ReplicatedStorage:WaitForChild("RideNetwork")
    local action=network.Action
    local update=network.Update
    local motion=network:WaitForChild("Motion")
    local accounts,active,guards,garageOwners={},{},{},{}
    local function telemetry(p,r,a)
        motion:FireClient(p,r and {kind=r.kind,pos=r.pos,yaw=r.yaw,speed=r.speed,steering=r.steering or 0,wheel=r.wheel or 0,acceleration=r.acceleration or 0,yawRate=r.yawRate or 0,braking=r.braking,impact=r.impact or 0,definition=r.definition,upgrade=a and a.accel,escaped=r.escaped,parkingReady=r.parkingReady,parkingPosition=r.parkingPad and r.parkingPad.Position,garagePosition=a and a.garage.Entrance.Position} or {ended=true})
    end
    local defs={}
    for _,def in ipairs(C.Vans) do defs[def.id]=def end
    local storeName=Run:IsStudio() and "RideProfiles_Studio_v1" or "RideProfiles_Live_v1"
    local store=game:GetService("DataStoreService"):GetDataStore(storeName)
    local profiles=ProfileStore.new(store,game.JobId..":"..Http:GenerateGUID(false),defs)
    local closing=false
    local loading=0
    local savesInFlight=0
    local function snapshot(a)
        local vans={}
        for id,v in pairs(a.vans) do table.insert(vans,{id=id,kind=v.kind,slot=v.slot}) end
        table.sort(vans,function(x,y)return x.id<y.id end)
        local discoveries={};for kind,value in pairs(a.discovered) do discoveries[kind]=value end
        return {schema=2,tier=a.tier,cash=a.cash,bank=a.bank,capacity=a.capacity,accel=a.accel,vans=vans,discovered=discoveries}
    end
    local function save(p,a,release)
        if not a or a.released then return false end
        savesInFlight+=1
        p:SetAttribute("SaveState","Saving...")
        local ok,err=profiles:Save(tostring(p.UserId),snapshot(a),release)
        savesInFlight-=1
        if ok then
            a.lastSave=os.clock();a.dirty=false
            if release then a.released=true end
            p:SetAttribute("SaveState","Progress saved")
        else
            p:SetAttribute("SaveState","Save delayed - retrying")
            warn("Ride save failed for "..p.UserId..": "..tostring(err))
            if not profiles:Owns(tostring(p.UserId)) and p.Parent then
                a.closing=true
                p:Kick("Your save session could not be kept open. Please rejoin to protect your progress.")
            end
        end
        return ok
    end
    local function dirty(a) a.dirty=true end
    for _,def in ipairs(C.Vans) do
        local m=world.Guards[def.id]
        guards[def.id]={model=m,home=m:GetPivot(),mode="idle",time=0}
    end
    local function notice(a,text) a.status=text end
    local function income(a)
        local n=0
        for _,v in pairs(a.vans) do if v.slot>0 then n+=defs[v.kind].income end end
        return n
    end
    local function send(p)
        local a=accounts[p];if not a then return end
        local vans,discoveries={},{}
        for id,v in pairs(a.vans) do table.insert(vans,{id=id,kind=v.kind,slot=v.slot,income=v.slot>0 and defs[v.kind].income or 0,sale=defs[v.kind].sale}) end
        table.sort(vans,function(x,y)return x.id<y.id end)
        for _,d in ipairs(C.Vans) do table.insert(discoveries,{name=d.label,found=a.discovered[d.id]==true}) end
        update:FireClient(p,{cash=a.cash,bank=math.floor(a.bank),rate=income(a),capacity=a.capacity,
            accel=a.accel,arrival=a.arrival,status=a.status,vans=vans,discoveries=discoveries,
            driving=a.run and a.run.kind or false,garage=a.garage.Name,quote=a.quote,
            slotCost=Tiers.SlotCost(a.tier,a.capacity),garageUpgrade=Tiers.Offer(a),accelCost=C.AccelerationCost})
    end
    local function root(p)
        local char=p.Character;local h=char and char:FindFirstChildOfClass("Humanoid")
        return h and h.Health>0 and char:FindFirstChild("HumanoidRootPart"),h
    end
    local function release(p,a)
        local rec=a.rider
        if rec then
            a.rider=nil
            p:SetAttribute("DrivingVan",nil)
            telemetry(p,nil)
            if rec.h.Parent then rec.h.PlatformStand=rec.platform;rec.h.AutoRotate=rec.rotate end
            if rec.root.Parent then rec.root.Anchored=rec.anchored;rec.root.AssemblyLinearVelocity=Vector3.zero end
            for part,old in pairs(rec.parts) do if part.Parent then part.Transparency=old.transparency;part.CanCollide=old.collide end end
        end
    end
    local function endRecovery(a)
        local rec=a.recovery;a.recovery=nil
        if rec and rec.h.Parent then rec.h.WalkSpeed=rec.speed;rec.h.PlatformStand=false end
    end
    local function resetTarget(kind)
        local m=world.Targets[kind]
        local index=table.find(C.Vans,defs[kind])
        m:PivotTo(CFrame.new(C.StartX,3.4,C.Lanes[index]))
        m:SetAttribute("RideSpeed",0)
        m.Body.Steal.Enabled=true;active[kind]=nil
        local g=guards[kind];g.mode="return";g.model.Label.Text.Text="BACK TO POST"
    end
    local function clearParking(r)
        if r and r.parkingPad then
            r.parkingPad.Color=r.padColor;r.parkingPad.Material=r.padMaterial
            r.parkingPad:SetAttribute("ParkingState",nil)
        end
    end
    local function abort(p,captured)
        local a=accounts[p];if not a or not a.run then return end
        local kind=a.run.kind;clearParking(a.run);a.run=nil
        release(p,a);resetTarget(kind)
        local r,h=root(p)
        if captured and r then
            endRecovery(a)
            local rec={h=h,speed=h.WalkSpeed,char=p.Character,ready=false,expires=os.clock()+7}
            a.recovery=rec
            r.CFrame=CFrame.new(-92,5,C.Lanes[table.find(C.Vans,defs[kind])]);h.PlatformStand=true
            r.AssemblyLinearVelocity=Vector3.new(10,18,0)
            notice(a,"CAUGHT! Your collection is safe. Up you get!")
            task.delay(.8,function()
                if a.recovery~=rec or p.Character~=rec.char or not h.Parent then return end
                h.PlatformStand=false;h.WalkSpeed=30;rec.ready=true;rec.expires=os.clock()+6
                notice(a,"Sprint back or try another van! Starting a theft ends the boost.");send(p)
                task.delay(6,function()if a.recovery==rec then endRecovery(a);send(p) end end)
            end)
        else notice(a,"Attempt ended. Your secured vans are safe.") end
        send(p)
    end
    local function chooseSlot(a,kind)
        local used={}
        for _,v in pairs(a.vans) do if v.slot>0 then used[v.slot]=true end end
        for i=1,a.capacity do if not used[i] then return i end end
        return 0
    end
    local function park(a,v)
        local pad=v.slot==0 and a.garage.Arrival or a.garage["Slot"..v.slot]
        v.model:PivotTo(CFrame.new(pad.Position.X,3.4,pad.Position.Z))
        v.model:SetAttribute("EarningSlot",v.slot)
    end
    local function secure(p)
        local a=accounts[p];local r=a and a.run
        if not r or not r.parkingReady or not r.parkingPad then return end
        local valid=Parking.Check(r.pos,r.yaw,r.speed,r.parkingPad.Position,r.parkingPad.Size)
        if not valid or chooseSlot(a,r.kind)~=r.parkingSlot then return end
        local kind=r.kind;local def=defs[kind]
        local exitPosition=Vector3.new(r.parkingPad.Position.X-8,5,r.parkingPad.Position.Z)
        clearParking(r);a.run=nil;release(p,a)
        local id=Http:GenerateGUID(false)
        local m=W.Van(a.garage,def,CFrame.new(0,0,0),"Owned_"..id)
        m:SetAttribute("Owner",p.UserId)
        for _,part in ipairs(m:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end
        local v={kind=kind,model=m,slot=chooseSlot(a,kind)};a.vans[id]=v;park(a,v)
        if v.slot==0 then a.arrival=id end
        a.discovered[kind]=true -- Automatic after correctly parking and exiting; no discovery claim button.
        resetTarget(kind)
        local r=root(p)
        if r then r.CFrame=CFrame.new(exitPosition);r.AssemblyLinearVelocity=Vector3.zero;ReturnSprint.Arm(p,a,exitPosition) end
        local n=0;for _ in pairs(a.discovered) do n+=1 end
        notice(a,v.slot==0 and "Secured! Arrival bay full: visit your trader." or ("Secured! Discovery "..n.."/3. Your van now earns $"..def.income.."/s."))
        if n==3 then notice(a,"3/3 TEST COLLECTION COMPLETE! Keep earning, sell duplicates, or upgrade.") end
        dirty(a);send(p)
    end
    local function steal(p,kind)
        local a=accounts[p];local def=defs[kind];local r,h=root(p)
        if not a or a.closing or not def or not r or a.run then return end
        if a.arrival then notice(a,"Clear your arrival bay at the trader first.");send(p);return end
        if active[kind] then notice(a,"Another player is stealing that van. Pick another.");send(p);return end
        if a.recovery and not a.recovery.ready then return end
        local m=world.Targets[kind]
        if (r.Position-m.Body.Position).Magnitude>17 then return end
        ReturnSprint.Clear(p,a,true)
        endRecovery(a)
        local rec={root=r,h=h,anchored=r.Anchored,platform=h.PlatformStand,rotate=h.AutoRotate,parts={}}
        for _,v in ipairs(p.Character:GetDescendants()) do if v:IsA("BasePart") then rec.parts[v]={transparency=v.Transparency,collide=v.CanCollide};v.Transparency=1;v.CanCollide=false end end
        a.rider=rec;r.Anchored=true;h.PlatformStand=true;h.AutoRotate=false
        local run={kind=kind,pos=m.Body.Position,yaw=0,speed=0,throttle=0,steer=0,time=0,lastInput=os.clock(),definition={speed=def.speed,accel=def.accel},steering=0,wheel=0}
        a.run=run;active[kind]=p;m.Body.Steal.Enabled=false
        p:SetAttribute("DrivingVan",kind)
        telemetry(p,run,a)
        local g=guards[kind];g.model:PivotTo(g.home);g.mode="alert";g.time=0;g.model.Label.Text.Text="HEY! MY VAN!"
        notice(a,"STOLEN! Hold forward and drive to the green line!");send(p)
    end
    local function near(p,position,distance)
        local r=root(p);return r and (r.Position-position).Magnitude<=distance
    end
    local function addPlayer(p)
        if closing then return end
        local index
        for i=1,C.MaxPlayers do if not garageOwners[i] then index=i;break end end
        if not index then p:Kick("All prototype garages are occupied. Please try another server.");return end
        garageOwners[index]=p
        local garage=world.Garages[tostring(index)]
        garage.Label.Text.Text=p.DisplayName.."'s GARAGE"
        local a={cash=0,bank=0,tier=1,capacity=3,accel=0,vans={},discovered={},garage=garage,index=index,status="Pick a van. Approach freely; guards react only when you steal."}
        p:SetAttribute("SaveState","Loading progress...")
        loading+=1
        local saved,error=profiles:Load(tostring(p.UserId))
        loading-=1
        if not saved then
            garageOwners[index]=nil;garage.Label.Text.Text="WAITING FOR PLAYER"
            warn("Ride load failed for "..p.UserId..": "..tostring(error))
            if p.Parent then p:Kick("Your progress could not load safely. Please wait a moment and rejoin. No saved progress was replaced.") end
            return
        end
        a.cash=saved.cash;a.bank=saved.bank;a.tier=saved.tier;a.capacity=saved.capacity;a.accel=saved.accel;a.discovered=saved.discovered
        a.lastSave=os.clock();a.dirty=false
        if not p.Parent or closing then
            profiles:Save(tostring(p.UserId),saved,true)
            garageOwners[index]=nil;garage.Label.Text.Text="WAITING FOR PLAYER"
            return
        end
        Plots.Refresh(a,p.DisplayName.."'s GARAGE");garage=a.garage
        for _,record in ipairs(saved.vans) do
            local model=W.Van(garage,defs[record.kind],CFrame.new(),"Owned_"..record.id)
            model:SetAttribute("Owner",p.UserId)
            for _,part in ipairs(model:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end
            local v={kind=record.kind,slot=record.slot,model=model}
            a.vans[record.id]=v;park(a,v)
            if record.slot==0 then a.arrival=record.id end
        end
        accounts[p]=a
        p:SetAttribute("SaveState","Progress loaded")
        if a.arrival then notice(a,"Welcome back! Clear your saved arrival bay at the trader.") end
        p.RespawnLocation=world.PrototypeSpawn
        p.CharacterRemoving:Connect(function() ReturnSprint.Clear(p,a,true);abort(p,false);endRecovery(a) end)
        p.CharacterAdded:Connect(function(char)
            local r=char:WaitForChild("HumanoidRootPart",10)
            if r then r.CFrame=CFrame.new(-92,5,0) end
            send(p)
        end)
        local r=root(p);if r then r.CFrame=CFrame.new(-92,5,0) end
        send(p)
    end
    Prompts.PromptTriggered:Connect(function(prompt,p)
        local a=accounts[p];if not a or a.closing then return end
        if prompt.Name=="Steal" and prompt.Parent.Parent.Parent==world.Targets then steal(p,prompt.Parent.Parent.Name)
        elseif prompt==a.garage.Collect.Collect and near(p,a.garage.Collect.Position,16) then
            local n=math.floor(a.bank);a.bank-=n;a.cash+=n;if n>0 then p:SetAttribute("CollectedGarageCash",true) end;dirty(a);notice(a,"Collected $"..n..". Your vans stay parked.");send(p)
        elseif prompt==a.garage.Trader.Torso.Trade and near(p,a.garage.Trader.Torso.Position,16) then send(p);update:FireClient(p,{openTrader=true}) end
    end)
    action.OnServerEvent:Connect(function(p,verb,value,second,brake)
        local a=accounts[p];if not a or a.closing then return end
        if verb=="drive" then
            if not a.run or typeof(value)~="number" or typeof(second)~="number" or value~=value or second~=second or math.abs(value)==math.huge or math.abs(second)==math.huge then return end
            a.run.throttle=math.clamp(value,-1,1);a.run.steer=math.clamp(second,-1,1);a.run.handbrake=brake==true;a.run.lastInput=os.clock();return
        end
        if verb=="exit" then
            if a.run and a.run.parkingReady then secure(p)
            elseif a.run then notice(a,"Park in your marked bay and wait for green before exiting.");send(p) end
            return
        end
        if a.lastAction and os.clock()-a.lastAction<.15 then return end
        a.lastAction=os.clock()
        if verb=="snapshot" then send(p);return end
        if verb=="cancel" then a.quote=nil;send(p);return end
        if not near(p,a.garage.Trader.Torso.Position,20) then notice(a,"Move closer to your trader.");send(p);return end
        if verb=="quote" and typeof(value)=="string" and a.vans[value] then
            local v=a.vans[value]
            a.quote={id=value,token=Http:GenerateGUID(false),expires=os.clock()+20,kind=v.kind,price=defs[v.kind].sale,loss=v.slot>0 and defs[v.kind].income or 0}
        elseif verb=="sell" and typeof(value)=="string" then
            local q=a.quote
            if not q or q.token~=value or os.clock()>q.expires then return end
            a.quote=nil;local v=a.vans[q.id];if not v then return end
            a.vans[q.id]=nil;a.cash+=defs[v.kind].sale;v.model:Destroy()
            if a.arrival==q.id then a.arrival=nil end
            local pending=a.arrival and a.vans[a.arrival]
            if pending then local slot=chooseSlot(a,pending.kind);if slot>0 then pending.slot=slot;a.arrival=nil;park(a,pending) end end
            notice(a,"Sold! Discovery stays in your collection.")
        elseif verb=="upgrade" and value=="accel" then
            if a.accel==0 and a.cash>=C.AccelerationCost then a.cash-=C.AccelerationCost;a.accel=1;notice(a,"Acceleration upgraded by 30%!") else notice(a,"Acceleration already owned or not enough cash.") end
        elseif verb=="upgrade" and (value=="slot" or value=="tier") then
            local ok,message=Tiers.Buy(a,value)
            notice(a,message)
            if ok then
                local pending=a.arrival and a.vans[a.arrival]
                if pending then local slot=chooseSlot(a,pending.kind);if slot>0 then pending.slot=slot;a.arrival=nil end end
                Plots.Refresh(a,p.DisplayName.."'s GARAGE")
                for _,v in pairs(a.vans) do park(a,v) end
            end
        end
        dirty(a);send(p)
    end)
    local elapsed=0
    Run.Heartbeat:Connect(function(dt)
        local step=math.min(dt,.1);elapsed+=dt
        for p,a in pairs(accounts) do
            if a.closing then ReturnSprint.Clear(p,a,true);continue end
            local walkRoot,walkHum=root(p)
            ReturnSprint.Step(p,a,walkRoot,walkHum,C.SafeX,world.SafeLine.Size.Z/2,C.ReturnSprintSpeed)
            a.bank+=income(a)*dt
            local r=a.run
            if r then
                local hrp=root(p)
                if not hrp then abort(p,false) else
                    local d=defs[r.kind];r.time+=step
                    if os.clock()-r.lastInput>.5 then r.throttle=0;r.steer=0;r.handbrake=false end
                    Driving.Step(r,d,step,a.accel)
                    local target=world.Targets[r.kind]
                    target:PivotTo(Driving.Frame(r))
                    target:SetAttribute("RideSpeed",r.speed)
                    r.motionTime=(r.motionTime or 0)+step
                    if r.motionTime>=.06 then r.motionTime=0;telemetry(p,r,a) end
                    hrp.CFrame=CFrame.new(r.pos+Vector3.new(2,2,0))
                    local guard=guards[r.kind]
                    if not r.escaped and r.pos.X>=C.SafeX then
                        r.escaped=true;r.parkingSlot=chooseSlot(a,r.kind)
                        r.parkingPad=r.parkingSlot==0 and a.garage.Arrival or a.garage["Slot"..r.parkingSlot]
                        r.padColor=r.parkingPad.Color;r.padMaterial=r.parkingPad.Material
                        guard.mode="return";guard.model.Label.Text.Text="BACK TO POST"
                        notice(a,"SAFE! Drive to your amber parking bay. Stop fully inside, then exit when green.")
                    end
                    if r.escaped then
                        local valid,message=Parking.Check(r.pos,r.yaw,r.speed,r.parkingPad.Position,r.parkingPad.Size)
                        r.parkTime=valid and ((r.parkTime or 0)+step) or 0
                        r.parkingReady=r.parkTime>=Parking.HoldTime
                        r.parkingPad.Color=r.parkingReady and Color3.fromRGB(62,235,130) or Color3.fromRGB(255,183,58)
                        r.parkingPad.Material=Enum.Material.Neon
                        r.parkingPad:SetAttribute("ParkingState",r.parkingReady and "Ready" or "Align")
                        local wanted=r.parkingReady and "PARKED! Green bay - press E or Exit van to get out."
                            or ("Garage "..a.garage.Name.." / "..(r.parkingSlot==0 and "Arrival bay" or "Slot "..r.parkingSlot)..": "..message)
                        notice(a,wanted)
                    elseif r.time>=d.reaction then
                        guard.mode="chase";guard.model.Label.Text.Text="STOP THAT VAN!"
                        local pos=guard.model.PrimaryPart.Position
                        local deltaPos=Vector3.new(r.pos.X,pos.Y,r.pos.Z)-pos
                        if deltaPos.Magnitude>0.1 then
                            local nextPos=pos+deltaPos.Unit*math.min(deltaPos.Magnitude,d.guardSpeed*step)
                            guard.model:PivotTo(CFrame.lookAt(nextPos,Vector3.new(r.pos.X,nextPos.Y,r.pos.Z)))
                        end
                        if deltaPos.Magnitude<4.5 and not a.recovery then abort(p,true) end
                    end
                end
            end
        end
        for _,g in pairs(guards) do
            if g.mode=="return" then
                local pos=g.model:GetPivot().Position;local delta=g.home.Position-pos
                if delta.Magnitude<.4 then g.model:PivotTo(g.home);g.mode="idle";g.model.Label.Text.Text="SECURITY"
                else g.model:PivotTo(CFrame.lookAt(pos+delta.Unit*math.min(delta.Magnitude,18*step),g.home.Position)) end
            end
        end
        if elapsed>=.4 then elapsed=0;for p in pairs(accounts) do send(p) end end
    end)
    Players.PlayerAdded:Connect(function(p)task.spawn(addPlayer,p)end)
    for _,p in ipairs(Players:GetPlayers()) do task.spawn(addPlayer,p) end
    task.spawn(function()
        while not closing do
            task.wait(5)
            for p,a in pairs(accounts) do
                if not a.closing and not a.saving and (os.clock()-a.lastSave>=ProfileStore.AutosaveSeconds or a.dirty and os.clock()-a.lastSave>=10) then
                    a.saving=true
                    task.spawn(function()save(p,a,false);a.saving=false end)
                end
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(p)
        local a=accounts[p];if not a then return end
        a.closing=true
        ReturnSprint.Clear(p,a,true)
        abort(p,false);endRecovery(a)
        while a.saving do task.wait(.05) end
        save(p,a,true)
        for _,v in pairs(a.vans) do v.model:Destroy() end
        a.garage.Label.Text.Text="WAITING FOR PLAYER";garageOwners[a.index]=nil;accounts[p]=nil
    end)

    game:BindToClose(function()
        closing=true
        for p,a in pairs(accounts) do
            if not a.closing then
                a.closing=true
                task.spawn(function()
                    while a.saving do task.wait(.05) end
                    save(p,a,true)
                end)
            end
        end
        local deadline=os.clock()+25
        task.wait(.1)
        while os.clock()<deadline do
            local pending=loading>0 or savesInFlight>0
            for _,a in pairs(accounts) do if not a.released then pending=true end end
            if not pending then break end
            task.wait(.1)
        end
    end)

    -- Server-only inspection interface for local acceptance tests. No debug remote.
    function G.Inspect(p)
        local a=accounts[p];if not a then return nil end
        local n=0;for _ in pairs(a.discovered) do n+=1 end
        local v={};for id,item in pairs(a.vans) do table.insert(v,{id=id,kind=item.kind,slot=item.slot}) end
        return {cash=a.cash,bank=a.bank,rate=income(a),discoveries=n,vans=v,arrival=a.arrival,status=a.status,driving=a.run~=nil,capacity=a.capacity,tier=a.tier,accel=a.accel}
    end
end
return G
