-- Free practice area. No calls to profiles, garage ownership or race rewards.
local Park={}
Park.Center=Vector3.new(-35,0,-195)
Park.Bounds={minX=-128,maxX=58,minZ=-278,maxZ=-112}
Park.Lobby=Vector3.new(-90,4,-45)
Park.Spawn=Vector3.new(-105,3.4,-250)
local function block(parent,name,size,position,color,collide,material)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=position;p.Anchored=true
 p.Color=color;p.CanCollide=collide==true;p.CanTouch=false;p.Material=material or Enum.Material.SmoothPlastic
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function label(parent,part,text,height)
 local b=Instance.new("BillboardGui");b.Size=UDim2.fromOffset(300,75);b.Adornee=part;b.StudsOffset=Vector3.new(0,height or 5,0);b.MaxDistance=140;b.Parent=parent
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextWrapped=true;t.Font=Enum.Font.GothamBold;t.TextSize=18;t.TextColor3=Color3.fromRGB(242,248,239);t.TextStrokeTransparency=.35;t.Parent=b
end
function Park.Build()
 local existing=workspace:FindFirstChild("PracticeYard");if existing then return existing end
 local m=Instance.new("Model");m.Name="PracticeYard"
 local concrete=Color3.fromRGB(137,156,158);local teal=Color3.fromRGB(51,190,178);local orange=Color3.fromRGB(255,159,75)
 block(m,"Foundation",Vector3.new(208,2,188),Vector3.new(-35,-.6,-195),Color3.fromRGB(57,81,86),true,Enum.Material.Concrete)
 block(m,"Deck",Vector3.new(194,1,174),Vector3.new(-35,0,-195),concrete,true,Enum.Material.Concrete)
 -- Painted loop evokes a skatepark bowl without requiring unsupported suspension.
 for i=1,64 do
  local a=(i-1)*math.pi*2/64;local b=i*math.pi*2/64
  for _,radius in ipairs({1,.67}) do
   local p1=Vector3.new(-35+79*radius*math.cos(a),.57,-195+66*radius*math.sin(a))
   local p2=Vector3.new(-35+79*radius*math.cos(b),.57,-195+66*radius*math.sin(b))
   local line=block(m,"LoopPaint",Vector3.new(.65,.04,(p2-p1).Magnitude+.1),(p1+p2)/2,radius==1 and teal or Color3.fromRGB(236,238,221))
   line.CFrame=CFrame.lookAt((p1+p2)/2,p2)
  end
 end
 for _,z in ipairs({-282,-108})do block(m,"Border",Vector3.new(196,3,1.5),Vector3.new(-35,1.5,z),teal,true)end
 for _,x in ipairs({-133,63})do block(m,"Border",Vector3.new(1.5,3,176),Vector3.new(x,1.5,-195),teal,true)end
 for i=0,4 do
  local pos=Vector3.new(-80+i*23,.8,-195+(i%2==0 and -8 or 8))
  block(m,"ConeBase",Vector3.new(2,.3,2),pos,Color3.fromRGB(47,62,67))
  local cone=block(m,"SlalomCone",Vector3.new(1.2,2.5,1.2),pos+Vector3.new(0,1.3,0),orange);cone.Shape=Enum.PartType.Cylinder
  block(m,"ConeStripe",Vector3.new(1.3,.35,1.3),pos+Vector3.new(0,1.7,0),Color3.fromRGB(247,240,214))
 end
 local brake=block(m,"BrakeZone",Vector3.new(22,.05,18),Vector3.new(30,.58,-250),orange)
 label(m,brake,"BRAKING ZONE\nTry Space for the handbrake",6)
 local slalom=block(m,"SlalomSign",Vector3.new(.2,.2,.2),Vector3.new(-35,1,-195),teal);slalom.Transparency=1
 label(m,slalom,"SLALOM\nWeave between the cones",8)
 local start=block(m,"StartGrid",Vector3.new(15,.05,13),Vector3.new(-105,.6,-250),teal)
 label(m,start,"FREE PRACTICE\nNo timer • No rewards • No lives lost",11)
 for i=1,6 do block(m,"BrakeGuide",Vector3.new(2,.04,8),Vector3.new(-85+i*15,.6,-250),Color3.fromRGB(236,238,221))end
 -- Seats, rails and planters are outside the driving deck.
 for _,x in ipairs({-110,-45,20})do
  block(m,"Bench",Vector3.new(12,1,3),Vector3.new(x,1.5,-289),Color3.fromRGB(188,142,96),true,Enum.Material.Wood)
  block(m,"BenchBack",Vector3.new(12,3,.5),Vector3.new(x,3,-290),teal,true)
 end
 local kiosk=block(m,"LobbyKiosk",Vector3.new(5,5,3),Vector3.new(-90,2.5,-46),teal,true)
 label(m,kiosk,"← PRACTICE YARD\nFREE loaner van",7)
 local prompt=Instance.new("ProximityPrompt");prompt.Name="EnterPractice";prompt.ActionText="Free practice";prompt.ObjectText="Loaner van • No risk"
 prompt.HoldDuration=0;prompt.MaxActivationDistance=14;prompt.RequiresLineOfSight=false;prompt.Parent=kiosk
 local vehicles=Instance.new("Folder");vehicles.Name="Vehicles";vehicles.Parent=m
 m.Parent=workspace;return m
end
return Park
