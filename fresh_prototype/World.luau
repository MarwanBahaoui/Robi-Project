local C=require(script.Parent.Config)
local W={}
local function part(parent,name,size,cf,color,material)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
    p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
    return p
end
local function sign(parent,adornee,text,color,offset)
    local g=Instance.new("BillboardGui");g.Name="Label";g.Adornee=adornee;g.Size=UDim2.fromOffset(260,64)
    g.StudsOffset=offset or Vector3.new(0,5,0);g.MaxDistance=105;g.Parent=parent
    local t=Instance.new("TextLabel");t.Name="Text";t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1
    t.Font=Enum.Font.GothamBold;t.TextSize=17;t.TextWrapped=true;t.TextColor3=color or Color3.new(1,1,1);t.TextStrokeTransparency=.35;t.Text=text;t.Parent=g
    return t
end
local function prompt(parent,name,action,object)
    local p=Instance.new("ProximityPrompt");p.Name=name;p.ActionText=action;p.ObjectText=object
    p.HoldDuration=0;p.MaxActivationDistance=13;p.RequiresLineOfSight=false;p.Parent=parent
    return p
end
function W.Van(parent,def,cf,name)
    local m=Instance.new("Model");m.Name=name or def.id;m:SetAttribute("VanType",def.id)
    local body=part(m,"Body",Vector3.new(10,3.4,5),cf*CFrame.new(0,2.8,0),def.color)
    m.PrimaryPart=body
    part(m,"Cabin",Vector3.new(3.3,2.1,4.7),cf*CFrame.new(3,5,0),def.color)
    part(m,"Cargo",Vector3.new(6.5,2.1,4.7),cf*CFrame.new(-1.9,5,0),def.color:Lerp(Color3.new(1,1,1),.10))
    part(m,"Windshield",Vector3.new(.12,1.5,3.9),cf*CFrame.new(4.72,5.1,0),Color3.fromRGB(113,196,211),Enum.Material.Glass)
    for _,z in ipairs({-2.42,2.42}) do
        part(m,"SideWindow",Vector3.new(2.4,1.4,.12),cf*CFrame.new(3,5,z),Color3.fromRGB(113,196,211),Enum.Material.Glass)
        part(m,"Stripe",Vector3.new(9,.25,.12),cf*CFrame.new(0,3.3,z*1.04),Color3.fromRGB(237,226,198))
        for _,x in ipairs({-3.1,3.1}) do
            local tire=part(m,"Wheel",Vector3.new(.8,2.5,2.5),cf*CFrame.new(x,1.4,z)*CFrame.Angles(0,math.pi/2,0),Color3.fromRGB(26,31,39))
            tire.Shape=Enum.PartType.Cylinder
        end
    end
    for _,z in ipairs({-1.7,1.7}) do part(m,"Headlight",Vector3.new(.15,.7,.9),cf*CFrame.new(5.1,3,z),Color3.fromRGB(255,244,195),Enum.Material.Neon) end
    m:SetAttribute("OriginToBody",2.8)
    m.Parent=parent
    return m
end
function W.Guard(parent,cf,name)
    local m=Instance.new("Model");m.Name=name
    local torso=part(m,"Torso",Vector3.new(2,2.2,1.2),cf*CFrame.new(0,3.1,0),Color3.fromRGB(32,58,88));m.PrimaryPart=torso
    local head=part(m,"Head",Vector3.new(1.5,1.5,1.5),cf*CFrame.new(0,5,0),Color3.fromRGB(224,183,138))
    part(m,"Cap",Vector3.new(1.9,.35,1.8),cf*CFrame.new(0,5.9,0),Color3.fromRGB(24,43,66))
    part(m,"Badge",Vector3.new(.4,.5,.1),cf*CFrame.new(-.45,3.45,-.66),Color3.fromRGB(255,203,64),Enum.Material.Metal)
    for _,x in ipairs({-.55,.55}) do part(m,"Leg",Vector3.new(.85,2,1),cf*CFrame.new(x,1,0),Color3.fromRGB(27,35,48)) end
    for _,x in ipairs({-1.4,1.4}) do part(m,"Arm",Vector3.new(.7,2,1),cf*CFrame.new(x,3.1,0),Color3.fromRGB(32,58,88)) end
    local lens=part(m,"Flashlight",Vector3.new(.45,.45,1.4),cf*CFrame.new(1.4,2.5,-1),Color3.fromRGB(31,35,41))
    local light=Instance.new("SpotLight");light.Face=Enum.NormalId.Front;light.Range=26;light.Angle=46;light.Brightness=2;light.Shadows=true;light.Color=Color3.fromRGB(255,239,190);light.Parent=lens
    part(m,"Lens",Vector3.new(.4,.4,.06),lens.CFrame*CFrame.new(0,0,-.72),Color3.fromRGB(255,239,190),Enum.Material.Neon)
    for _,p in ipairs(m:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false;p.CanTouch=false end end
    sign(m,head,"SECURITY",Color3.fromRGB(255,216,112),Vector3.new(0,2,0))
    m.Parent=parent;return m
end
function W.Build()
    if workspace:FindFirstChild("RidePrototype") then
        require(script.Parent.Scenery).Apply(workspace.RidePrototype)
        require(script.Parent.GaragePlots).Apply(workspace.RidePrototype)
        return workspace.RidePrototype
    end
    local world=Instance.new("Folder");world.Name="RidePrototype"
    local targets=Instance.new("Folder");targets.Name="Targets";targets.Parent=world
    local guards=Instance.new("Folder");guards.Name="Guards";guards.Parent=world
    local garages=Instance.new("Folder");garages.Name="Garages";garages.Parent=world
    part(world,"Road",Vector3.new(240,1,108),CFrame.new(-20,0,0),Color3.fromRGB(47,59,69),Enum.Material.Asphalt)
    for _,z in ipairs({-54,54}) do part(world,"Curb",Vector3.new(240,1,1),CFrame.new(-20,.6,z),Color3.fromRGB(189,203,204)) end
    for _,z in ipairs(C.Lanes) do for x=-90,50,20 do part(world,"RoadMark",Vector3.new(7,.08,.65),CFrame.new(x,.55,z),Color3.fromRGB(236,206,101)) end end
    for i,def in ipairs(C.Vans) do
        local z=C.Lanes[i]
        part(world,"TargetPad",Vector3.new(18,.2,16),CFrame.new(C.StartX,.65,z),def.color:Lerp(Color3.new(),.25))
        local van=W.Van(targets,def,CFrame.new(C.StartX,.6,z),def.id)
        prompt(van.Body,"Steal","Steal",def.label.." | $"..def.income.."/s")
        sign(van,van.Body,def.label.."\n$"..def.income.."/s  •  Sell $"..def.sale,Color3.fromRGB(255,230,150))
        W.Guard(guards,CFrame.new(C.StartX-7,.6,z+10),def.id)
    end
    part(world,"SafeLine",Vector3.new(1,.12,108),CFrame.new(C.SafeX,.65,0),Color3.fromRGB(93,236,172),Enum.Material.Neon)
    local safe=part(world,"SafeSign",Vector3.new(.1,.1,.1),CFrame.new(C.SafeX,1,0),Color3.fromRGB(93,236,172));safe.Transparency=1;safe.CanCollide=false
    sign(world,safe,"GARAGES →\nCross the green line to escape",Color3.fromRGB(123,255,191),Vector3.new(0,11,0))
    for i=1,C.MaxPlayers do
        local z=(i-1)*48-72
        local garage=Instance.new("Model");garage.Name=tostring(i);garage.Parent=garages
        local floor=part(garage,"Floor",Vector3.new(48,1,42),CFrame.new(100,0,z),Color3.fromRGB(63,88,91));garage.PrimaryPart=floor
        part(garage,"BackWall",Vector3.new(1,10,42),CFrame.new(124,5,z),Color3.fromRGB(38,58,69))
        sign(garage,floor,"AVAILABLE GARAGE",Color3.fromRGB(145,235,213),Vector3.new(0,11,0))
        for slot=1,3 do
            local pad=part(garage,"Slot"..slot,Vector3.new(17,.15,11),CFrame.new(108,.65,z+(slot-2)*11),Color3.fromRGB(95,127,126))
            pad:SetAttribute("Slot",slot)
        end
        part(garage,"Arrival",Vector3.new(17,.15,11),CFrame.new(88,.65,z+11),Color3.fromRGB(174,132,48))
        local cash=part(garage,"Collect",Vector3.new(3,1.2,3),CFrame.new(86,1.2,z-13),Color3.fromRGB(67,186,128));prompt(cash,"Collect","Collect","Garage income")
        local trader=W.Guard(garage,CFrame.new(87,.6,z-3),"Trader")
        trader.Torso.Color=Color3.fromRGB(45,139,128);trader.Label.Text.Text="GARAGE TRADER"
        prompt(trader.Torso,"Trade","Open trader","Sell vans / upgrades")
    end
    local spawn=Instance.new("SpawnLocation");spawn.Name="PrototypeSpawn";spawn.Size=Vector3.new(8,1,8);spawn.CFrame=CFrame.new(-92,1,0)
    spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0;spawn.Color=Color3.fromRGB(86,180,174);spawn.Parent=world
    local banner=part(world,"Welcome",Vector3.new(.1,.1,.1),CFrame.new(-98,2,0),Color3.new());banner.Transparency=1;banner.CanCollide=false
    sign(world,banner,"STEAL A RIDE\nPick a van • Steal • Escape",Color3.fromRGB(255,235,172),Vector3.new(0,13,0))
    world.Parent=workspace
    require(script.Parent.Scenery).Apply(world)
    require(script.Parent.GaragePlots).Apply(world)
    return world
end
return W
