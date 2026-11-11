local S={}
function S.Apply(world)
 local base=workspace:FindFirstChild("Baseplate")
 if base and base:IsA("BasePart") then
  base.Color=Color3.fromRGB(108,151,91);base.Material=Enum.Material.Grass
  for _,v in ipairs(base:GetChildren()) do if v:IsA("Texture") or v:IsA("Decal") then v.Transparency=1 end end
 end
 local oldSpawn=workspace:FindFirstChild("SpawnLocation")
 if oldSpawn and oldSpawn:IsA("SpawnLocation") then
  oldSpawn.Enabled=false;oldSpawn.Transparency=1;oldSpawn.CanCollide=false
  for _,v in ipairs(oldSpawn:GetChildren()) do if v:IsA("Decal") then v.Transparency=1 end end
 end
 local existing=world:FindFirstChild("Scenery")
 if existing and (existing:GetAttribute("Version") or 0)>=2 then return end
 if existing then existing:Destroy() end
 local folder=Instance.new("Folder");folder.Name="Scenery"
 local palette={
  asphalt=Color3.fromRGB(42,50,58), concrete=Color3.fromRGB(196,190,171), dark=Color3.fromRGB(27,42,52),
  teal=Color3.fromRGB(45,157,151), tealLight=Color3.fromRGB(104,217,202), safety=Color3.fromRGB(246,191,66),
  orange=Color3.fromRGB(220,112,61), grass=Color3.fromRGB(92,139,87), white=Color3.fromRGB(241,238,219),
 }
 local count=0
 local function block(name,size,pos,color,material,collide)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=typeof(pos)=="CFrame" and pos or CFrame.new(pos)
  p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=folder;count+=1;return p
 end
 local function surface(p,face,text,color)
  local gui=Instance.new("SurfaceGui");gui.Face=face;gui.CanvasSize=Vector2.new(900,180);gui.Parent=p
  local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=text
  label.Font=Enum.Font.GothamBold;label.TextScaled=true;label.TextColor3=color;label.Parent=gui
  local pad=Instance.new("UIPadding");pad.PaddingTop=UDim.new(0,20);pad.PaddingBottom=UDim.new(0,20);pad.PaddingLeft=UDim.new(0,20);pad.PaddingRight=UDim.new(0,20);pad.Parent=label
 end
 block("Island",Vector3.new(290,5,220),Vector3.new(-5,-2.6,0),palette.grass,Enum.Material.Grass,true)
 block("DepotApron",Vector3.new(64,.15,196),Vector3.new(99,.42,0),palette.concrete,Enum.Material.Concrete,true)
 for _,z in ipairs({-58,58}) do
  block("Sidewalk",Vector3.new(208,.3,6),Vector3.new(-36,.55,z),palette.concrete,Enum.Material.Concrete,true)
  for x=-130,60,10 do block("PavingSeam",Vector3.new(.08,.03,5.8),Vector3.new(x,.72,z),Color3.fromRGB(151,151,139)) end
 end
 -- A clean charcoal road outline creates a readable route without changing the driving surface.
 for _,z in ipairs({-52.7,52.7}) do block("RoadEdge",Vector3.new(240,.05,.28),Vector3.new(-20,.59,z),palette.tealLight,Enum.Material.Neon) end
 for _,z in ipairs({-108,108}) do
  block("BorderWall",Vector3.new(286,4,2),Vector3.new(-5,2,z),palette.concrete,Enum.Material.Concrete,true)
  block("BorderCap",Vector3.new(288,.5,2.6),Vector3.new(-5,4.2,z),palette.dark,nil,true)
  block("Fence",Vector3.new(284,7,.45),Vector3.new(-5,7.7,z),palette.dark,Enum.Material.Metal,true)
  for x=-147,137,12 do block("FencePost",Vector3.new(.7,11,.7),Vector3.new(x,5.5,z),palette.teal,nil,true) end
 end
 for _,x in ipairs({-148,138}) do
  block("BorderWall",Vector3.new(2,4,218),Vector3.new(x,2,0),palette.concrete,Enum.Material.Concrete,true)
  block("BorderCap",Vector3.new(2.6,.5,220),Vector3.new(x,4.2,0),palette.dark,nil,true)
  block("Fence",Vector3.new(.45,7,216),Vector3.new(x,7.7,0),palette.dark,Enum.Material.Metal,true)
  for z=-108,108,12 do block("FencePost",Vector3.new(.7,11,.7),Vector3.new(x,5.5,z),palette.teal,nil,true) end
 end
 -- Loading-bay facades make the target area feel like a vehicle depot while staying clear of active lanes.
 local function bollard(x,z)
  block("SafetyBollard",Vector3.new(.65,3,.65),Vector3.new(x,1.8,z),palette.safety,Enum.Material.Metal)
  block("BollardCap",Vector3.new(.82,.25,.82),Vector3.new(x,3.4,z),palette.dark,Enum.Material.Metal)
 end
 for _,z in ipairs({-32,0,32}) do
  block("LoadingFacade",Vector3.new(8,15,22),Vector3.new(-123,7.5,z),palette.dark,Enum.Material.Concrete,true)
  block("LoadingDoor",Vector3.new(.18,8,12),Vector3.new(-118.85,6,z),Color3.fromRGB(72,91,101),Enum.Material.Metal)
  block("LoadingBand",Vector3.new(.3,1.1,18),Vector3.new(-118.65,12.4,z),palette.teal,Enum.Material.Neon)
  for _,offset in ipairs({-12,12}) do bollard(-117,z+offset) end
 end
 for _,x in ipairs({-99,-72,-45}) do
  block("LaneArrowStem",Vector3.new(5,.05,.75),Vector3.new(x,.61,0),palette.white,Enum.Material.Neon)
  local tip=block("LaneArrowTip",Vector3.new(2.4,.05,2.4),Vector3.new(x+3.1,.61,0),palette.white,Enum.Material.Neon);tip.Shape=Enum.PartType.Wedge
 end
 -- Chevron strips frame the escape transition; SafeLine itself remains untouched.
 for z=-46,46,8 do
  local stripe=block("EscapeChevron",Vector3.new(3,.04,1.1),CFrame.new(60.5,.61,z)*CFrame.Angles(0,0,math.rad(28)),palette.safety,Enum.Material.Neon)
 end
 -- Low props remain beyond the sidewalk so they cannot obstruct driving or parking paths.
 for _,data in ipairs({{-76,-75},{-42,-75},{-8,75},{26,75}}) do
  local x,z=data[1],data[2]
  block("CargoCrate",Vector3.new(5,4,5),Vector3.new(x,2,z),palette.orange,Enum.Material.Wood)
  block("CargoBand",Vector3.new(5.2,.38,5.2),Vector3.new(x,3,z),palette.safety,Enum.Material.Metal)
 end
 folder.Parent=world;task.wait()
 local function tree(x,z,scale)
  local trunk=block("TreeTrunk",Vector3.new(1.4,7,1.4)*scale,Vector3.new(x,3.5*scale,z),Color3.fromRGB(107,85,61),Enum.Material.Wood)
  local leaf=block("TreeCrown",Vector3.new(9,10,9)*scale,Vector3.new(x,10*scale,z),Color3.fromRGB(53,119,81),Enum.Material.Grass);leaf.Shape=Enum.PartType.Ball
  local top=block("TreeCrownLight",Vector3.new(6,7,6)*scale,Vector3.new(x-1,14*scale,z),Color3.fromRGB(84,150,90),Enum.Material.Grass);top.Shape=Enum.PartType.Ball
  block("TreePlanter",Vector3.new(9,.5,9)*scale,Vector3.new(x,.15,z),Color3.fromRGB(87,124,74),Enum.Material.Grass)
 end
 for _,z in ipairs({-81,81}) do for x=-125,45,34 do tree(x,z,1+((x+125)%3)*.1) end end
 local function lamp(x,z)
  block("LampBase",Vector3.new(2,.6,2),Vector3.new(x,.8,z),palette.concrete)
  block("LampPost",Vector3.new(.5,14,.5),Vector3.new(x,7.5,z),palette.dark,Enum.Material.Metal)
  block("LampArm",Vector3.new(4,.4,.4),Vector3.new(x+1.6,14,z),palette.dark,Enum.Material.Metal)
  local light=block("Lamp",Vector3.new(3,.3,1.5),Vector3.new(x+2.5,13.7,z),Color3.fromRGB(255,237,190),Enum.Material.Neon)
  local glow=Instance.new("PointLight");glow.Brightness=.7;glow.Range=18;glow.Color=light.Color;glow.Parent=light
 end
 for _,z in ipairs({-62,62}) do for x=-115,55,42 do lamp(x,z) end end
 -- Ornamental distant hills frame the map without occupying gameplay routes.
 for i=1,9 do
  local x=-180+(i-1)*44
  for _,z in ipairs({-145,145}) do
   local hill=block("BackdropHill",Vector3.new(65,32+(i%3)*13,50),Vector3.new(x,3,z),Color3.fromRGB(96+i*3,139+i*2,96),Enum.Material.Grass)
   hill.Shape=Enum.PartType.Ball
  end
 end
 task.wait()
 -- Garage architecture is owned by GaragePlots so tier rebuilds remain self-contained.
 -- Arrival plaza landmark: visible on spawn, outside vehicle starts and driving lanes.
 for _,z in ipairs({-18,18}) do
  block("EntryPillar",Vector3.new(2.4,15,2.4),Vector3.new(-111,7.5,z),palette.dark,Enum.Material.Concrete,true)
  block("EntryPillarLight",Vector3.new(1.1,3.5,1.1),Vector3.new(-111,13.5,z),palette.tealLight,Enum.Material.Neon)
 end
 local entry=block("EntrySign",Vector3.new(1.2,4.5,39),Vector3.new(-111,15.7,0),palette.teal,Enum.Material.Metal)
 surface(entry,Enum.NormalId.Right,"VEHICLE DEPOT  •  STEAL / ESCAPE / PARK",palette.white)
 for _,z in ipairs({-51,51}) do block("DepotArchPillar",Vector3.new(2,20,2),Vector3.new(-137,10,z),palette.dark,nil,true) end
 local header=block("DepotHeader",Vector3.new(2,5,104),Vector3.new(-137,21,0),palette.teal)
 surface(header,Enum.NormalId.Right,"STEAL A RIDE  /  VEHICLE DEPOT",Color3.fromRGB(255,241,198))
 for _,z in ipairs({-51,51}) do
  block("SafeGatePillar",Vector3.new(1.3,17,1.3),Vector3.new(65,8.5,z),palette.dark)
  block("SafeGateLight",Vector3.new(1.5,3,1.5),Vector3.new(65,16,z),palette.tealLight,Enum.Material.Neon)
 end
 local lighting=game:GetService("Lighting")
 lighting.ClockTime=15.7;lighting.Brightness=2.8
 lighting.Ambient=Color3.fromRGB(103,113,124);lighting.OutdoorAmbient=Color3.fromRGB(151,158,158)
 lighting.EnvironmentDiffuseScale=.72;lighting.EnvironmentSpecularScale=.42;lighting.ShadowSoftness=.42
 local grade=lighting:FindFirstChild("RideColorGrade") or Instance.new("ColorCorrectionEffect")
 grade.Name="RideColorGrade";grade.Saturation=.05;grade.Contrast=.1;grade.TintColor=Color3.fromRGB(255,248,230);grade.Parent=lighting
 local bloom=lighting:FindFirstChild("RideBloom") or Instance.new("BloomEffect")
 bloom.Name="RideBloom";bloom.Intensity=.08;bloom.Size=18;bloom.Threshold=1.7;bloom.Parent=lighting
 local atmosphere=lighting:FindFirstChild("RideAtmosphere") or Instance.new("Atmosphere")
 atmosphere.Name="RideAtmosphere";atmosphere.Density=.25;atmosphere.Offset=.05;atmosphere.Color=Color3.fromRGB(199,221,228);atmosphere.Decay=Color3.fromRGB(106,143,151);atmosphere.Parent=lighting
 local base=workspace:FindFirstChild("Baseplate")
 if base and base:IsA("BasePart") then base.Color=palette.grass;base.Material=Enum.Material.Grass end
 folder:SetAttribute("Version",2);folder:SetAttribute("Parts",count)
 return count
end
return S
