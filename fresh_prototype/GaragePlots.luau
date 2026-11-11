local T=require(script.Parent.GarageTiers)
local M={}
local function part(parent,name,size,pos,color,material,collide)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Anchored=true
 p.Material=material or Enum.Material.SmoothPlastic;p.CanCollide=collide==true;p.CanTouch=false
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function text(parent,adornee,message,offset)
 local b=Instance.new("BillboardGui");b.Name="Label";b.Size=UDim2.fromOffset(300,55);b.StudsOffset=offset or Vector3.new(0,9,0);b.Adornee=adornee;b.MaxDistance=110;b.Parent=parent
 local t=Instance.new("TextLabel");t.Name="Text";t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=message;t.TextSize=18;t.TextColor3=Color3.fromRGB(236,244,233);t.TextStrokeTransparency=.3;t.Font=Enum.Font.GothamBold;t.Parent=b
end
local function prompt(p,name,action,label)
 local v=Instance.new("ProximityPrompt");v.Name=name;v.ActionText=action;v.ObjectText=label;v.MaxActivationDistance=13;v.RequiresLineOfSight=false;v.Parent=p
end
function M.Build(index,tier,capacity,owner)
 local d=T.List[tier];local z=(index-2.5)*152
 local m=Instance.new("Model");m.Name=tostring(index);m:SetAttribute("Tier",tier);m:SetAttribute("Capacity",capacity)
 local width=d.rows*14+12
 local floor=part(m,"Floor",Vector3.new(d.depth,1,width),Vector3.new(76+d.depth/2,0,z),Color3.fromRGB(87,107,111),tier>=4 and Enum.Material.Marble or Enum.Material.Concrete,true);m.PrimaryPart=floor
 local entrance=part(m,"Entrance",Vector3.new(2,.15,14),Vector3.new(77,.6,z),d.color,Enum.Material.Neon)
 text(m,floor,owner or "WAITING FOR PLAYER",Vector3.new(-d.depth/2+8,15,0))
 -- Shared materials keep every player plot part of the same depot district.
 floor.Color=Color3.fromRGB(75,91,96)
 local decor=Instance.new("Folder");decor.Name="Architecture";decor.Parent=m
 local facade=Color3.fromRGB(31,47,60)
 part(decor,"BackWall",Vector3.new(1,16,width),Vector3.new(76+d.depth,8,z),facade,nil,true)
 -- Shared industrial frontage: procedural, readable at every tier, and outside parking pads.
 part(decor,"FrontBeam",Vector3.new(2,2,width+4),Vector3.new(77,15,z),Color3.fromRGB(26,41,51),Enum.Material.Metal,true)
 part(decor,"FrontBand",Vector3.new(2.2,.5,width+5),Vector3.new(76.8,16.5,z),d.color,Enum.Material.Neon)
 for _,side in ipairs({-1,1}) do
  part(decor,"FrontBeacon",Vector3.new(1.3,2.8,1.3),Vector3.new(77,13,z+side*(width/2+1)),d.color,Enum.Material.Neon)
  part(decor,"LoadingBollard",Vector3.new(.6,2.4,.6),Vector3.new(82,1.5,z+side*(width/2-2)),Color3.fromRGB(242,188,65),Enum.Material.Metal)
 end
 for _,side in ipairs({-1,1}) do
  part(decor,"SideTrim",Vector3.new(d.depth,.2,1),Vector3.new(76+d.depth/2,.7,z+side*width/2),d.color,Enum.Material.Neon)
  part(decor,"SideWall",Vector3.new(d.depth,5,1),Vector3.new(76+d.depth/2,2.5,z+side*width/2),Color3.fromRGB(43,63,74),nil,true)
  for x=80,76+d.depth,24 do part(decor,"Pillar",Vector3.new(1,18,1),Vector3.new(x,9,z+side*width/2),d.color,Enum.Material.Metal) end
 end
 local header=part(decor,"TierSign",Vector3.new(2,4,width),Vector3.new(78,18,z),d.color)
 text(decor,header,"GARAGE "..index.."  •  TIER "..tier.."  •  "..d.name:upper(),Vector3.new(0,1,0))
 for x=90,76+d.depth-4,36 do
  part(decor,"RoofBeam",Vector3.new(1,1,width),Vector3.new(x,18,z),Color3.fromRGB(42,60,72),Enum.Material.Metal)
  part(decor,"RoofCap",Vector3.new(15,.45,width+2),Vector3.new(x,18.5,z),Color3.fromRGB(27,42,52),Enum.Material.Metal)
  if tier>=2 then
   local light=part(decor,"OverheadLight",Vector3.new(1,.2,10),Vector3.new(x,17.3,z),Color3.fromRGB(255,241,195),Enum.Material.Neon)
   local point=Instance.new("PointLight");point.Range=25;point.Brightness=.5;point.Parent=light
  end
 end
 if tier==1 then
  for _,side in ipairs({-1,1}) do part(decor,"Timber",Vector3.new(1,8,1),Vector3.new(78,4,z+side*width/2),Color3.fromRGB(131,94,67),Enum.Material.Wood) end
 elseif tier==2 then
  for i=1,8 do part(decor,"ShutterSlat",Vector3.new(.2,.4,width-4),Vector3.new(76+d.depth-.6,3+i,z),Color3.fromRGB(115,139,156),Enum.Material.Metal) end
 elseif tier>=4 then
  for _,side in ipairs({-1,1}) do
   local glass=part(decor,"ShowroomGlass",Vector3.new(d.depth-6,8,.2),Vector3.new(76+d.depth/2,9,z+side*width/2),Color3.fromRGB(164,220,224),Enum.Material.Glass);glass.Transparency=.65
  end
 end
 for slot=1,d.max do
  local col=math.floor((slot-1)/d.rows);local row=(slot-1)%d.rows
  local pos=Vector3.new(112+col*48,.65,z+(row-(d.rows-1)/2)*14)
  local pad=part(m,"Slot"..slot,Vector3.new(17,.15,11),pos,slot<=capacity and Color3.fromRGB(89,140,130) or Color3.fromRGB(60,68,75))
  pad:SetAttribute("Slot",slot);pad:SetAttribute("Unlocked",slot<=capacity)
  for _,side in ipairs({-1,1}) do part(decor,"ParkingLine",Vector3.new(17,.05,.15),pos+Vector3.new(0,.12,5.5*side),slot<=capacity and d.color or Color3.fromRGB(112,117,120)) end
  text(decor,pad,slot<=capacity and tostring(slot) or ("LOCKED "..slot),Vector3.new(0,.6,0))
  if tier==5 then part(decor,"DisplayLight",Vector3.new(17,.05,.2),pos+Vector3.new(0,.15,-5),d.color,Enum.Material.Neon) end
 end
 local arrival=part(m,"Arrival",Vector3.new(17,.15,11),Vector3.new(88,.65,z+22),Color3.fromRGB(220,161,54));text(decor,arrival,"ARRIVAL",Vector3.new(0,1,0))
 local cash=part(m,"Collect",Vector3.new(3,1.2,3),Vector3.new(85,1.2,z-22),Color3.fromRGB(64,195,131));prompt(cash,"Collect","Collect","Garage income")
 local trader=Instance.new("Model");trader.Name="Trader";trader.Parent=m
 local torso=part(trader,"Torso",Vector3.new(2,2,1),Vector3.new(86,3,z),d.color);trader.PrimaryPart=torso
 part(trader,"Head",Vector3.new(1.5,1.5,1.5),Vector3.new(86,4.8,z),Color3.fromRGB(221,182,138))
 for _,dx in ipairs({-.55,.55}) do part(trader,"Leg",Vector3.new(.8,2,1),Vector3.new(86+dx,1,z),Color3.fromRGB(34,45,59)) end
 prompt(torso,"Trade","Garage services","Sell / Garage upgrades");text(trader,torso,"GARAGE SERVICES",Vector3.new(0,5,0))
 m:SetAttribute("PlotCenterZ",z)
 return m
end
function M.Apply(world)
 if world:GetAttribute("GarageTierLayout")==true then return end
 local old=world:FindFirstChild("Garages");if old then old:Destroy() end
 local garages=Instance.new("Folder");garages.Name="Garages";garages.Parent=world
 for i=1,4 do local m=M.Build(i,1,3);m.Parent=garages end
 -- Replace only the scenery generated by our previous builder.
 local scenery=world:FindFirstChild("Scenery")
 if scenery then
 -- Legacy pre-tier scenery used these names. New garage architecture lives in each plot and is rebuilt by Refresh.
  local remove={GarageCornice=true,GarageCanopy=true,GaragePillar=true,GarageSideTrim=true,GarageNumber=true,ParkingStripe=true,SlotNumber=true,ArrivalStripe=true,CashDisplay=true,TraderAwning=true,BorderWall=true,BorderCap=true,Fence=true,FencePost=true,DepotApron=true}
  for _,v in ipairs(scenery:GetChildren()) do if remove[v.Name] or v:IsA("BasePart") and v.Name=="BackdropHill" and v.Position.X>65 then v:Destroy() end end
 end
 local env=Instance.new("Folder");env.Name="GarageDistrict";env.Parent=world
 part(env,"Apron",Vector3.new(244,1,600),Vector3.new(186,0,0),Color3.fromRGB(63,78,84),Enum.Material.Asphalt,true)
 for _,z in ipairs({-304,304}) do part(env,"Border",Vector3.new(458,12,2),Vector3.new(80,6,z),Color3.fromRGB(35,67,71),nil,true) end
 for _,x in ipairs({-149,309}) do part(env,"Border",Vector3.new(2,12,610),Vector3.new(x,6,0),Color3.fromRGB(35,67,71),nil,true) end
 for _,z in ipairs({-152,0,152}) do part(env,"PlotGap",Vector3.new(226,.1,22),Vector3.new(194,.55,z),Color3.fromRGB(92,145,98),Enum.Material.Grass) end
 world.SafeLine.Size=Vector3.new(1,.12,600)
 world:SetAttribute("GarageTierLayout",true)
end
function M.Refresh(a,owner)
 local old=a.garage;local fresh=M.Build(a.index,a.tier,a.capacity,owner)
 fresh.Parent=old.Parent
 for _,v in pairs(a.vans) do
  v.model.Parent=fresh
  local pad=v.slot==0 and fresh.Arrival or fresh["Slot"..v.slot]
  v.model:PivotTo(CFrame.new(pad.Position.X,3.4,pad.Position.Z))
 end
 a.garage=fresh;old:Destroy()
end
return M
