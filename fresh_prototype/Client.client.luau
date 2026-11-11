local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local p=Players.LocalPlayer
local net=game.ReplicatedStorage:WaitForChild("RideNetwork")
local action=net:WaitForChild("Action")
local gui=Instance.new("ScreenGui");gui.Name="RideHUD";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.Parent=p:WaitForChild("PlayerGui")
local function round(x)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=x end
local function frame(name,size,pos,parent)
    local f=Instance.new("Frame");f.Name=name;f.Size=size;f.Position=pos;f.BackgroundColor3=Color3.fromRGB(21,35,47);f.BackgroundTransparency=.08;f.Parent=parent or gui;round(f);return f
end
local function label(parent,name,text,size,height)
    local t=Instance.new("TextLabel");t.Name=name;t.Size=UDim2.new(1,-16,0,height);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=Color3.fromRGB(239,244,240)
    t.TextSize=size;t.TextWrapped=true;t.Font=Enum.Font.Gotham;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=parent;return t
end
local panel=frame("Overview",UDim2.new(.70,0,0,144),UDim2.fromOffset(12,12))
local limit=Instance.new("UISizeConstraint");limit.MaxSize=Vector2.new(430,144);limit.Parent=panel
local money=label(panel,"Money","Loading garage...",17,25);money.Position=UDim2.fromOffset(10,7)
local collection=label(panel,"Collection","3-van test collection",14,22);collection.Position=UDim2.fromOffset(10,35)
local status=label(panel,"Status","Approach a van and press Steal",15,76);status.Position=UDim2.fromOffset(10,61);status.TextColor3=Color3.fromRGB(255,221,127)
local hint=frame("Controls",UDim2.new(.94,0,0,38),UDim2.new(.03,0,1,-48))
local hintText=label(hint,"Text","W accelerate • S brake / reverse • A/D steer • Space handbrake",14,36);hintText.Position=UDim2.fromOffset(8,0)
local modal=frame("Trader",UDim2.new(.9,0,.68,0),UDim2.fromScale(.05,.22));modal.Visible=false
local max=Instance.new("UISizeConstraint");max.MaxSize=Vector2.new(560,470);max.Parent=modal
modal.AnchorPoint=Vector2.new(.5,.5);modal.Position=UDim2.fromScale(.5,.56)
local title=label(modal,"Title","GARAGE TRADER",21,32);title.Position=UDim2.fromOffset(12,8)
local list=Instance.new("ScrollingFrame");list.Name="List";list.Position=UDim2.fromOffset(12,94);list.Size=UDim2.new(1,-24,1,-150);list.BackgroundTransparency=1;list.BorderSizePixel=0
list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.ScrollBarThickness=5;list.Parent=modal
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,7);layout.Parent=list
local saveLabel=label(gui,"SaveStatus","Loading progress...",13,22)
saveLabel.Position=UDim2.fromOffset(22,160);saveLabel.Size=UDim2.fromOffset(300,22)
saveLabel.TextColor3=Color3.fromRGB(186,224,209)
local function refreshSave() saveLabel.Text=p:GetAttribute("SaveState") or "Loading progress..." end
p:GetAttributeChangedSignal("SaveState"):Connect(refreshSave)
refreshSave()
local Tutorial=require(net:WaitForChild("Tutorial"))
local tutorialContext={}
local tutorialCard=frame("FirstRideGuide",UDim2.new(.70,0,0,115),UDim2.fromOffset(12,198))
tutorialCard.Visible=false
local tutorialLimit=Instance.new("UISizeConstraint");tutorialLimit.MaxSize=Vector2.new(430,115);tutorialLimit.Parent=tutorialCard
local tutorialTitle=label(tutorialCard,"Title","",15,27);tutorialTitle.Position=UDim2.fromOffset(12,8);tutorialTitle.Font=Enum.Font.GothamBold;tutorialTitle.TextColor3=Color3.fromRGB(117,255,194)
local tutorialText=label(tutorialCard,"Instruction","",14,68);tutorialText.Position=UDim2.fromOffset(12,36)
local skip=Instance.new("TextButton");skip.Name="Skip";skip.Size=UDim2.fromOffset(42,24);skip.Position=UDim2.new(1,-48,0,8);skip.Text="Skip";skip.TextSize=12;skip.BackgroundTransparency=1;skip.TextColor3=Color3.fromRGB(215,223,225);skip.Parent=tutorialCard
tutorialTitle.Size=UDim2.new(1,-66,0,27)
local guideGlow=Instance.new("Highlight");guideGlow.Name="FirstRideTarget";guideGlow.FillColor=Color3.fromRGB(106,255,183);guideGlow.FillTransparency=.72;guideGlow.OutlineColor=Color3.fromRGB(185,255,217);guideGlow.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;guideGlow.Enabled=false;guideGlow.Parent=gui
local sprintBadge=frame("ReturnSprint",UDim2.fromOffset(265,38),UDim2.new(.5,-132,1,-195))
sprintBadge.Visible=false
local sprintText=label(sprintBadge,"Text","RETURN SPRINT • Get your next van!",14,36)
sprintText.Position=UDim2.fromOffset(8,0);sprintText.TextColor3=Color3.fromRGB(118,255,189)
local function refreshSprint() sprintBadge.Visible=p:GetAttribute("ReturnSprintActive")==true end
p:GetAttributeChangedSignal("ReturnSprintActive"):Connect(refreshSprint)
refreshSprint()
local data=nil
local function renderTutorial()
 if not data then return end
 local step=Tutorial.Resolve(tutorialContext,data)
 tutorialCard.Visible=step~=nil
 guideGlow.Enabled=false
 if not step then return end
 tutorialTitle.Text=step.step.."/4  "..step.title;tutorialText.Text=step.text
 local world=workspace:FindFirstChild("RidePrototype")
 local garage=world and world.Garages:FindFirstChild(tostring(data.garage))
 local target
 if world and step.target=="van" then target=world.Targets:FindFirstChild("Rusty")
 elseif garage and step.target=="cash" then target=garage:FindFirstChild("Collect")
 elseif garage and step.target=="trader" then target=garage:FindFirstChild("Trader")
 elseif world and step.target=="safe" then target=world:FindFirstChild("SafeLine") end
 guideGlow.Adornee=target;guideGlow.Enabled=target~=nil
end
skip.Activated:Connect(function()tutorialContext.done=true;renderTutorial()end)
p:GetAttributeChangedSignal("CollectedGarageCash"):Connect(function()
 tutorialContext.collected=p:GetAttribute("CollectedGarageCash")==true;renderTutorial()
end)
local function button(parent,name,text,fn)
    local b=Instance.new("TextButton");b.Name=name;b.Size=UDim2.new(1,-6,0,49);b.Text=text;b.TextSize=15;b.TextWrapped=true;b.Font=Enum.Font.GothamBold
    b.BackgroundColor3=Color3.fromRGB(38,107,112);b.TextColor3=Color3.new(1,1,1);b.Parent=parent;round(b);b.Activated:Connect(fn);return b
end
local function clear()for _,v in ipairs(list:GetChildren()) do if v~=layout then v:Destroy() end end end
local rendered=""
local traderTab="sell"
local tierConfirm=false
local sellTab,upgradeTab
local function renderTrade()
    if not data then return end
    clear()
    layout.SortOrder=Enum.SortOrder.LayoutOrder
    local function orderRows()
        local i=0
        for _,child in ipairs(list:GetChildren()) do
            if child:IsA("GuiObject") then i+=1;child.LayoutOrder=i end
        end
    end
    task.defer(orderRows)
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
        info("TierSummary","TIER "..u.tier.." / 5  •  "..u.name.."\n"..data.capacity.." / "..u.max.." slots unlocked  •  Cash $"..data.cash,66)
        if data.slotCost then
            button(list,"GarageSlot","Unlock slot "..(data.capacity+1).." • $"..data.slotCost..(data.cash<data.slotCost and "\nNot enough cash - collect earnings" or ""),function()action:FireServer("upgrade","slot")end)
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
            info("NextTier",n.name.." • $"..n.price.."\nIncludes "..n.included.." usable slots; expand to "..n.max..".\n"..n.description,90)
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
        label(list,"ConfirmText","Sell "..q.kind.." for $"..q.price.."?\nLose $"..q.loss.."/s. Discovery stays recorded.",17,88)
        button(list,"ConfirmSale","Confirm sale",function()action:FireServer("sell",q.token)end)
        button(list,"CancelSale","Keep this van",function()action:FireServer("cancel")end)
    else
        if #data.vans==0 then info("Empty","Bring a van home to earn income or sell it here.") end
        for _,v in ipairs(data.vans) do
            button(list,"Van_"..v.id,v.kind..(v.slot==0 and " • Arrival bay" or " • Slot "..v.slot).."\nSell $"..v.sale.." | earns $"..v.income.."/s",function()action:FireServer("quote",v.id)end)
        end
    end
end
sellTab=button(modal,"SellTab","Sell vans",function()traderTab="sell";tierConfirm=false;renderTrade()end)
sellTab.Size=UDim2.new(.5,-18,0,36);sellTab.Position=UDim2.fromOffset(12,48)
upgradeTab=button(modal,"UpgradeTab","Garage upgrades",function()traderTab="upgrade";tierConfirm=false;action:FireServer("cancel");renderTrade()end)
upgradeTab.Size=UDim2.new(.5,-18,0,36);upgradeTab.Position=UDim2.new(.5,6,0,48)
local close=button(modal,"Close","Close",function()modal.Visible=false;action:FireServer("cancel")end)
close.Size=UDim2.new(1,-24,0,36);close.Position=UDim2.new(0,12,1,-44)
local garagePosition=nil
local garageMarker=nil
local nav=frame("GarageNavigation",UDim2.fromOffset(255,76),UDim2.new(1,-270,0,12))
nav.Visible=false
local arrow=label(nav,"Arrow","▲",34,44);arrow.Size=UDim2.fromOffset(46,44);arrow.Position=UDim2.fromOffset(7,14);arrow.TextXAlignment=Enum.TextXAlignment.Center
local destination=label(nav,"Destination","YOUR GARAGE",14,58);destination.Position=UDim2.fromOffset(60,9);destination.Size=UDim2.new(1,-68,0,58)
local routeDot=nil
local function markGarage()
 if not garagePosition or garageMarker then return end
 garageMarker=Instance.new("Part");garageMarker.Name="YourGarageMarker";garageMarker.Size=Vector3.one
 garageMarker.Anchored=true;garageMarker.Transparency=1;garageMarker.CanCollide=false;garageMarker.CanTouch=false;garageMarker.CanQuery=false
 garageMarker.Position=garagePosition+Vector3.new(-18,0,0);garageMarker.Parent=workspace
 local b=Instance.new("BillboardGui");b.Size=UDim2.fromOffset(220,65);b.StudsOffset=Vector3.new(0,23,0);b.AlwaysOnTop=true;b.Adornee=garageMarker;b.Parent=garageMarker
 local t=label(b,"Text","↓ YOUR GARAGE",23,65);t.TextXAlignment=Enum.TextXAlignment.Center;t.TextColor3=Color3.fromRGB(110,255,192);t.TextStrokeTransparency=.3
 routeDot=Instance.new("Part");routeDot.Name="ParkingRouteBeacon";routeDot.Size=Vector3.new(4,.08,4);routeDot.Anchored=true
 routeDot.CanCollide=false;routeDot.CanTouch=false;routeDot.CanQuery=false;routeDot.Material=Enum.Material.Neon;routeDot.Color=Color3.fromRGB(103,255,184);routeDot.Parent=workspace
end

local parkingReady=false
local parkingPosition=nil
local parkingMarker=nil
local exitButton=button(gui,"ExitVan","PARK FIRST",function() action:FireServer("exit") end)
exitButton.Size=UDim2.fromOffset(200,48);exitButton.AnchorPoint=Vector2.new(.5,1)
exitButton.Position=UDim2.new(.5,0,1,-100);exitButton.Visible=false
local down={};local driving=false;local lastDrive=false;local timer=0
local Driving=require(net:WaitForChild("Driving"))
local motion=net:WaitForChild("Motion")
local keyMap={[Enum.KeyCode.Space]="handbrake",[Enum.KeyCode.W]="forward",[Enum.KeyCode.Up]="forward",[Enum.KeyCode.S]="back",[Enum.KeyCode.Down]="back",[Enum.KeyCode.A]="left",[Enum.KeyCode.Left]="left",[Enum.KeyCode.D]="right",[Enum.KeyCode.Right]="right"}
UIS.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.KeyCode==Enum.KeyCode.E and driving then action:FireServer("exit") end
 if keyMap[input.KeyCode] then down[keyMap[input.KeyCode]]=true end
end)
UIS.InputEnded:Connect(function(input)if keyMap[input.KeyCode] then down[keyMap[input.KeyCode]]=nil end end)
UIS.WindowFocusReleased:Connect(function()table.clear(down);action:FireServer("drive",0,0,false)end)
local touch=Instance.new("Frame");touch.Name="TouchDrive";touch.BackgroundTransparency=1;touch.Size=UDim2.new(1,0,0,160);touch.Position=UDim2.new(0,0,1,-215);touch.Visible=false;touch.Parent=gui
for i,info in ipairs({{"left","◀",.04},{"right","▶",.19},{"back","BACK",.68},{"forward","GO",.83},{"handbrake","BRAKE",.44}}) do
    local b=button(touch,info[1],info[2],function()end);b.Size=UDim2.fromOffset(64,64);b.Position=UDim2.new(info[3],0,1,-70)
    b.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then down[info[1]]=true end end)
    b.InputEnded:Connect(function(input)if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then down[info[1]]=nil end end)
end
net.Update.OnClientEvent:Connect(function(d)
    if d.openTrader then modal.Visible=true;tutorialContext.traderVisited=true;renderTutorial();renderTrade();return end
    data=d;renderTutorial()
    local found=0;local names={}
    for _,v in ipairs(d.discoveries) do if v.found then found+=1 end;table.insert(names,(v.found and "✓ " or "○ ")..v.name) end
    money.Text="Cash $"..d.cash.."  |  Bank $"..d.bank.."  (+$"..d.rate.."/s)"
    collection.Text="Collection "..found.."/3 • Garage "..d.garage.." • "..(d.garageUpgrade and d.garageUpgrade.name or "Starter").." • "..d.capacity.." slots"
    status.Text=d.status
    local signature=(d.quote and d.quote.token or "")..":"..d.capacity..":"..d.accel..":"..(d.garageUpgrade and d.garageUpgrade.tier or 1)..":"..d.cash
    for _,v in ipairs(d.vans) do signature..=v.id..v.slot end
    if modal.Visible and signature~=rendered then renderTrade() end
    rendered=signature
end)

local speedPanel=frame("Speedometer",UDim2.fromOffset(195,86),UDim2.new(1,-210,1,-150))
speedPanel.Visible=false
local speedText=label(speedPanel,"Speed","0",30,40);speedText.Position=UDim2.fromOffset(12,6)
local gearText=label(speedPanel,"Gear","READY",13,26);gearText.Position=UDim2.fromOffset(12,50)
local model,original,predicted,definition,upgrade,offsets
local correction=Vector3.zero
local baseFov=70
local activeKind=nil
local function clearDrive()
 if original then
  for _,v in ipairs(original:GetDescendants()) do if v:IsA("BasePart") then v.LocalTransparencyModifier=0 end end
  local tag=original:FindFirstChild("Label");if tag then tag.Enabled=true end
 end
 if model then model:Destroy() end
 model=nil;original=nil;predicted=nil;activeKind=nil;driving=false
 speedPanel.Visible=false
 parkingReady=false;parkingPosition=nil;exitButton.Visible=false;nav.Visible=false
 if garageMarker then garageMarker:Destroy();garageMarker=nil end
 if routeDot then routeDot:Destroy();routeDot=nil end
 if parkingMarker then parkingMarker:Destroy();parkingMarker=nil end
 local cam=workspace.CurrentCamera;cam.CameraType=Enum.CameraType.Custom;cam.FieldOfView=baseFov
 local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then cam.CameraSubject=h end
 table.clear(down)
end
local function beginDrive(kind,s)
 if activeKind then clearDrive() end
 original=workspace.RidePrototype.Targets:FindFirstChild(kind);if not original then return end
 activeKind=kind;driving=kind;baseFov=workspace.CurrentCamera.FieldOfView
 model=original:Clone();model.Name="LocalRideVisual"
 for _,v in ipairs(model:GetDescendants()) do
  if v:IsA("ProximityPrompt") or v:IsA("BillboardGui") then v:Destroy()
  elseif v:IsA("BasePart") then v.CanCollide=false;v.CanTouch=false;v.CanQuery=false end
 end
 model.Parent=workspace.CurrentCamera
 for _,v in ipairs(original:GetDescendants()) do if v:IsA("BasePart") then v.LocalTransparencyModifier=1 end end
 local tag=original:FindFirstChild("Label");if tag then tag.Enabled=false end
 offsets={}
 local base=model:GetPivot()
 for _,v in ipairs(model:GetDescendants()) do
  if v:IsA("BasePart") then
   local cf=base:ToObjectSpace(v.CFrame)
   offsets[v]={frame=cf,wheel=v.Name=="Wheel",front=cf.Position.X>0}
  end
 end
 for wheel,v in pairs(offsets) do
  if v.wheel then
   local spoke=Instance.new("Part");spoke.Name="WheelSpoke";spoke.Size=Vector3.new(.06,1.8,.16)
   spoke.Anchored=true;spoke.CanCollide=false;spoke.CanQuery=false;spoke.Material=Enum.Material.Metal
   spoke.Color=Color3.fromRGB(195,203,206);spoke.Parent=model
   v.spoke=spoke
  end
 end
 for _,z in ipairs({-1.7,1.7}) do
  local light=Instance.new("Part");light.Name="BrakeLight";light.Size=Vector3.new(.15,.6,.9);light.Anchored=true
  light.CanCollide=false;light.CanQuery=false;light.Color=Color3.fromRGB(105,20,14);light.Material=Enum.Material.Neon;light.Parent=model
  offsets[light]={frame=CFrame.new(-5.05,.1,z),brake=true}
 end
 predicted={pos=s.pos,yaw=s.yaw,speed=s.speed,steering=s.steering,wheel=s.wheel,throttle=0,steer=0}
 definition=s.definition;upgrade=s.upgrade;correction=Vector3.zero;lastDrive=false
 speedPanel.Visible=true
end
motion.OnClientEvent:Connect(function(s)
 if s.ended then clearDrive();return end
 if not activeKind or activeKind~=s.kind then beginDrive(s.kind,s) end
 parkingReady=s.parkingReady==true;parkingPosition=s.parkingPosition
 tutorialContext.escaped=s.escaped;renderTutorial()
 garagePosition=s.garagePosition;markGarage();nav.Visible=true
 if predicted then predicted.escaped=s.escaped end
 exitButton.Visible=s.escaped==true
 exitButton.Text=parkingReady and "PARKED - EXIT VAN [E]" or "PARK IN THE AMBER BAY"
 exitButton.BackgroundColor3=parkingReady and Color3.fromRGB(39,165,91) or Color3.fromRGB(130,94,39)
 if parkingPosition and not parkingMarker then
  parkingMarker=Instance.new("Part");parkingMarker.Name="YourParkingMarker";parkingMarker.Anchored=true
  parkingMarker.Transparency=1;parkingMarker.CanCollide=false;parkingMarker.CanTouch=false;parkingMarker.CanQuery=false
  parkingMarker.Size=Vector3.one;parkingMarker.Position=parkingPosition;parkingMarker.Parent=workspace.CurrentCamera
  local billboard=Instance.new("BillboardGui");billboard.Size=UDim2.fromOffset(230,60);billboard.StudsOffset=Vector3.new(0,9,0)
  billboard.AlwaysOnTop=true;billboard.Adornee=parkingMarker;billboard.Parent=parkingMarker
  local t=Instance.new("TextLabel");t.Name="Text";t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1
  t.Font=Enum.Font.GothamBold;t.TextSize=20;t.TextStrokeTransparency=.25;t.Parent=billboard
 end
 if parkingMarker then
  local t=parkingMarker.BillboardGui.Text
  t.Text=parkingReady and "PARKED ✓\nYou can get out" or "↓ YOUR PARKING BAY"
  t.TextColor3=parkingReady and Color3.fromRGB(100,255,155) or Color3.fromRGB(255,205,94)
 end
 if not predicted then return end
 local error=s.pos-predicted.pos
 if error.Magnitude>15 then predicted.pos=s.pos;correction=Vector3.zero else correction=error end
 local angle=math.atan2(math.sin(s.yaw-predicted.yaw),math.cos(s.yaw-predicted.yaw))
 predicted.yaw+=angle*.18
 predicted.speed+=(s.speed-predicted.speed)*.3
 definition=s.definition;upgrade=s.upgrade
end)
p.CharacterRemoving:Connect(clearDrive)
local analogSteer=0;local analogGas=0;local analogBrake=0
UIS.WindowFocusReleased:Connect(function() analogSteer=0;analogGas=0;analogBrake=0 end)
UIS.InputChanged:Connect(function(input)
 if input.KeyCode==Enum.KeyCode.Thumbstick1 then analogSteer=math.abs(input.Position.X)>.12 and input.Position.X or 0
 elseif input.KeyCode==Enum.KeyCode.ButtonR2 then analogGas=input.Position.Z
 elseif input.KeyCode==Enum.KeyCode.ButtonL2 then analogBrake=input.Position.Z end
end)
Run.RenderStepped:Connect(function(dt)
 dt=math.min(dt,.05)
 local camera=workspace.CurrentCamera
 if predicted and model and original and original.Parent then
  local throttle=math.clamp((down.forward and 1 or 0)-(down.back and 1 or 0)+analogGas-analogBrake,-1,1)
  local steer=math.clamp((down.right and 1 or 0)-(down.left and 1 or 0)+analogSteer,-1,1)
  predicted.throttle=throttle;predicted.steer=steer;predicted.handbrake=down.handbrake==true
  Driving.Step(predicted,definition,dt,upgrade)
  local amount=1-math.exp(-8*dt)
  predicted.pos+=correction*amount;correction*=1-amount
  local cf=Driving.Frame(predicted)
  model:PivotTo(cf)
  for part,v in pairs(offsets) do
   if v.wheel then
    local rest=v.frame
    local rot=rest-rest.Position
    part.CFrame=cf*CFrame.new(rest.Position)*CFrame.Angles(0,v.front and -(predicted.turnAngle or 0) or 0,0)*rot*CFrame.Angles(predicted.wheel,0,0)
    if v.spoke then v.spoke.CFrame=part.CFrame*CFrame.new(v.frame.Position.Z>0 and -.43 or .43,0,0) end
   elseif v.brake then
    part.CFrame=cf*v.frame
    part.Color=predicted.braking and Color3.fromRGB(255,52,31) or Color3.fromRGB(95,18,12)
   end
  end
  local forward=Vector3.new(math.cos(predicted.yaw),0,-math.sin(predicted.yaw))
  local ratio=math.clamp(math.abs(predicted.speed)/definition.speed,0,1)
  local focus=predicted.pos+Vector3.new(0,3,0)+forward*5
  local desired=predicted.pos-forward*(17+ratio*2)+Vector3.new(0,8.5+ratio,0)
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
  params.FilterDescendantsInstances={model,original,p.Character};params.RespectCanCollide=true
  local hit=workspace:Raycast(focus,desired-focus,params)
  if hit then desired=hit.Position+hit.Normal*.8 end
  local target=CFrame.lookAt(desired,focus+forward*(ratio*4))
  camera.CameraType=Enum.CameraType.Scriptable
  camera.CFrame=lastDrive and camera.CFrame:Lerp(target,1-math.exp(-10*dt)) or target
  camera.FieldOfView+=(baseFov+ratio*8-camera.FieldOfView)*(1-math.exp(-4*dt))
  if garagePosition then
   local goal=parkingPosition or Vector3.new(65,3.4,predicted.pos.Z)
   local waypoint=goal
   if predicted.pos.X<65 then waypoint=Vector3.new(68,3.4,predicted.pos.Z)
   elseif math.abs(predicted.pos.Z-goal.Z)>8 then waypoint=Vector3.new(78,3.4,goal.Z) end
   local delta=waypoint-predicted.pos
   local cameraDirection=camera.CFrame:VectorToObjectSpace(Vector3.new(delta.X,0,delta.Z))
   arrow.Rotation=math.deg(math.atan2(cameraDirection.X,-cameraDirection.Z))
   arrow.Text=parkingReady and "✓" or "▲"
   if parkingReady then arrow.Rotation=0 end
   destination.Text=parkingReady and "PARKED!\nPress E to exit" or ("YOUR GARAGE "..(data and data.garage or "").."\n"..math.floor((goal-predicted.pos).Magnitude).." studs • "..(cameraDirection.Z>math.abs(cameraDirection.X)*.6 and "Turn around toward the arrow" or parkingPosition and "Follow the amber bay" or "Cross the green line"))
   if routeDot then routeDot.Position=Vector3.new(waypoint.X,.85,waypoint.Z);routeDot.Transparency=parkingReady and 1 or .25 end
  end
  speedText.Text=string.format("%02d  KM/H",math.floor(math.abs(predicted.speed)*1.008+.5))
  gearText.Text=predicted.handbrake and "HANDBRAKE" or predicted.braking and "BRAKING" or predicted.speed < -.5 and "REVERSE" or "DRIVE  •  "..activeKind:upper()
  timer+=dt
  if timer>.04 then timer=0;action:FireServer("drive",throttle,steer,predicted.handbrake) end
  lastDrive=true
 end
 touch.Visible=UIS.TouchEnabled and activeKind~=nil
end)
action:FireServer("snapshot")
