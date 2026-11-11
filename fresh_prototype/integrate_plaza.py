import json
from pathlib import Path
p=Path(__file__).parent;o=json.loads((p/'plaza_backup_2026-11-10.json').read_text(encoding='utf8'))
plots=o['GaragePlots'].replace('local M={}','local L=require(script.Parent.PlazaLayout)\nlocal M={}')
plots=plots.replace('local col=math.floor((slot-1)/d.rows);local row=(slot-1)%d.rows','local col=math.floor((slot-1)/d.rows);local order=(slot-1)%d.rows\n  local row=order%2==0 and (d.rows/2+order/2) or (d.rows/2-1-(order-1)/2)')
plots=plots.replace('Vector3.new(88,.65,z+22)','Vector3.new(88,.65,z+width/2-8)')
plots=plots.replace('Vector3.new(85,1.2,z-22)','Vector3.new(85,1.2,z-width/2+7)')
plots=plots.replace('Vector3.new(86,3,z)','Vector3.new(86,3,z-width/2+16)').replace('Vector3.new(86,4.8,z)','Vector3.new(86,4.8,z-width/2+16)').replace('Vector3.new(86+dx,1,z)','Vector3.new(86+dx,1,z-width/2+16)')
plots=plots.replace(' m:SetAttribute("PlotCenterZ",z)',''' local transform=L.LocalToWorld(index)
 for _,v in ipairs(m:GetDescendants()) do
  if v:IsA("BasePart") then v.CFrame=transform*v.CFrame end
 end
 -- Position the ownership sign over the actual entrance, not over an axis-aligned floor offset.
 m.Label.Adornee=entrance;m.Label.StudsOffset=Vector3.new(0,17,0)
 m:SetAttribute("PlotCenterZ",entrance.Position.Z)''')
plots=plots.replace('if world:GetAttribute("GarageTierLayout")==true then return end','if world:GetAttribute("GaragePlazaLayout")==true then return end')
plots=plots.replace(' local env=Instance.new("Folder");env.Name="GarageDistrict";env.Parent=world',''' local previous=world:FindFirstChild("GarageDistrict");if previous then previous:Destroy() end
 local env=Instance.new("Folder");env.Name="GarageDistrict";env.Parent=world''')
start=plots.index(' part(env,"Apron"');end=plots.index('\nend\nfunction M.Refresh',start)
plots=plots[:start]+''' part(env,"ArrivalPlaza",Vector3.new(550,1,880),Vector3.new(335,0,0),Color3.fromRGB(66,83,89),Enum.Material.Asphalt,true)
 for _,z in ipairs({-450,450}) do part(env,"Border",Vector3.new(762,12,2),Vector3.new(230,6,z),Color3.fromRGB(35,67,71),nil,true) end
 for _,x in ipairs({-149,611}) do part(env,"Border",Vector3.new(2,12,902),Vector3.new(x,6,0),Color3.fromRGB(35,67,71),nil,true) end
 for i=1,4 do
  local entry=L.Entrance(i)
  local approach=(entry*CFrame.new(-38,0,0)).Position
  -- Neutral edge markings; personal navigation overlays one route during a delivery.
  for _,side in ipairs({-1,1}) do
   local p=part(env,"EntranceEdge",Vector3.new(55,.08,.35),Vector3.zero,Color3.fromRGB(204,214,200))
   p.CFrame=entry*CFrame.new(-24,.59,side*13)
  end
  local walk=part(env,"PedestrianApproach",Vector3.new(60,.08,5),Vector3.zero,Color3.fromRGB(108,155,137))
  walk.CFrame=entry*CFrame.new(-27,.60,-31)
 end
 if scenery then
  for _,v in ipairs(scenery:GetChildren()) do
   if v:IsA("BasePart") and v.Position.X>65 then v:Destroy() end
  end
 end
 world.SafeLine.Size=Vector3.new(1,.12,108)
 world:SetAttribute("GarageTierLayout",true)
 world:SetAttribute("GaragePlazaLayout",true)'''+plots[end:]
plots=plots.replace('v.model:PivotTo(CFrame.new(pad.Position.X,3.4,pad.Position.Z))','v.model:PivotTo(L.ParkingFrame(pad))')
game=o['Game'].replace('local G={}','local Layout=require(script.Parent.PlazaLayout)\nlocal G={}')
game=game.replace('garagePosition=a and a.garage.Entrance.Position','garagePosition=a and a.garage.Entrance.Position,garageFrame=a and a.garage.Entrance.CFrame,parkingFrame=r.parkingPad and r.parkingPad.CFrame')
game=game.replace('v.model:PivotTo(CFrame.new(pad.Position.X,3.4,pad.Position.Z))','v.model:PivotTo(Layout.ParkingFrame(pad))')
game=game.replace('r.parkingPad.Position,r.parkingPad.Size','r.parkingPad.CFrame,r.parkingPad.Size')
game=game.replace('local exitPosition=Vector3.new(r.parkingPad.Position.X-8,5,r.parkingPad.Position.Z)','local exitPosition=(r.parkingPad.CFrame*CFrame.new(-9,5-r.parkingPad.Position.Y,0)).Position')
game=game.replace('local used={}\n        for _,v', 'local used={}\n        for _,v',1)
# choose accessible front-to-back, center-out slots based on the stable order defined in Build.
driving=o['Driving'].replace('garageArea and -294 or -48,garageArea and 294 or 48','garageArea and -438 or -48,garageArea and 438 or 48').replace('garageArea and 299 or 70','garageArea and 595 or 70')
parking=o['Parking'].replace('function P.Check(position,yaw,speed,padPosition,padSize)','''function P.Check(position,yaw,speed,padFrame,padSize)
 if typeof(padFrame)=="Vector3" then padFrame=CFrame.new(padFrame) end
 local localPosition=padFrame:PointToObjectSpace(position)
 local forward=padFrame:VectorToObjectSpace(Vector3.new(math.cos(yaw),0,-math.sin(yaw)))
 yaw=math.atan2(-forward.Z,forward.X)''').replace('local x=math.abs(position.X-padPosition.X);local z=math.abs(position.Z-padPosition.Z)','local x=math.abs(localPosition.X);local z=math.abs(localPosition.Z)')
client=o['Client'].replace('local garagePosition=nil','local garagePosition=nil\nlocal garageFrame=nil\nlocal parkingFrame=nil\nlocal routeParts={}\nlocal routePoints={}\nlocal routeKey=nil\nlocal routeIndex=1')
client=client.replace('garageMarker.Position=garagePosition+Vector3.new(-18,0,0)','garageMarker.Position=garagePosition')
client=client.replace(' if routeDot then routeDot:Destroy();routeDot=nil end',' if routeDot then routeDot:Destroy();routeDot=nil end\n for _,v in ipairs(routeParts) do v:Destroy() end;routeParts={};routePoints={};routeKey=nil;routeIndex=1')
client=client.replace('garagePosition=s.garagePosition;markGarage();nav.Visible=true','garagePosition=s.garagePosition;garageFrame=s.garageFrame;parkingFrame=s.parkingFrame;markGarage();nav.Visible=true')
start=client.index('   local goal=parkingPosition or Vector3.new(65,3.4,predicted.pos.Z)');end=client.index('   local delta=waypoint-predicted.pos',start)
client=client[:start]+'''   local goal=parkingPosition or garagePosition
   local key=tostring(parkingPosition)..tostring(garagePosition)
   if key~=routeKey and garageFrame then
    routeKey=key;routeIndex=1;routePoints={}
    for _,v in ipairs(routeParts) do v:Destroy() end;routeParts={}
    local entry=garageFrame.Position
    local forward=garageFrame.RightVector
    local start=Vector3.new(68,.8,predicted.pos.Z)
    local finish=entry-forward*38;finish=Vector3.new(finish.X,.8,finish.Z)
    local control1=start+Vector3.new(85,0,0)
    local control2=finish-forward*65
    for i=0,16 do
     local t=i/16;local u=1-t
     table.insert(routePoints,start*u*u*u+control1*3*u*u*t+control2*3*u*t*t+finish*t*t*t)
    end
    table.insert(routePoints,Vector3.new(entry.X,.8,entry.Z))
    if parkingFrame then
     local align=(parkingFrame*CFrame.new(-22,0,0)).Position
     table.insert(routePoints,Vector3.new(align.X,.8,align.Z))
     table.insert(routePoints,Vector3.new(goal.X,.8,goal.Z))
    end
    for i=2,#routePoints do
     local a,b=routePoints[i-1],routePoints[i];local length=(b-a).Magnitude
     if length>.1 then
      local segment=Instance.new("Part");segment.Name="PersonalGarageRoute";segment.Anchored=true;segment.CanCollide=false;segment.CanTouch=false;segment.CanQuery=false
      segment.Material=Enum.Material.Neon;segment.Color=Color3.fromRGB(105,255,181);segment.Transparency=.25
      segment.Size=Vector3.new(.7,.06,length);segment.CFrame=CFrame.lookAt((a+b)/2,b);segment.Parent=workspace;table.insert(routeParts,segment)
     end
    end
   end
   while routeIndex<#routePoints and (Vector3.new(predicted.pos.X,.8,predicted.pos.Z)-routePoints[routeIndex]).Magnitude<18 do routeIndex+=1 end
   local waypoint=routePoints[routeIndex] or goal
   if predicted.pos.X<65 then waypoint=Vector3.new(68,3.4,predicted.pos.Z) end
'''+client[end:]
out={'GaragePlots':plots,'Game':game,'Client':client,'Driving':driving,'Parking':parking,'PlazaLayout':(p/'PlazaLayout.luau').read_text()}
(p/'plaza_sources.json').write_text(json.dumps(out),encoding='utf8')
print('Prepared rotated plots, local-space parking and personal curved routes')
