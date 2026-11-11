local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Park=require(script.Parent.RidePrototype.PracticePark)
local World=require(script.Parent.RidePrototype.World)
local D=require(game.ReplicatedStorage.RideNetwork.PracticeDriving)
local yard=Park.Build()
local net=game.ReplicatedStorage:WaitForChild("PracticeNetwork")
local sessions={};local elapsed=0
local def={id="Practice",color=Color3.fromRGB(63,191,176),speed=40,accel=28}
local function finish(p)
 local s=sessions[p];if not s then return end;sessions[p]=nil
 p:SetAttribute("PracticeDriving",nil)
 net.Motion:FireClient(p,{ended=true})
 if s.model then s.model:Destroy()end
 if s.root.Parent then s.root.Anchored=s.anchor;s.root.AssemblyLinearVelocity=Vector3.zero;s.root.CFrame=CFrame.new(Park.Lobby+Vector3.new(5,0,0)) end
 if s.hum.Parent then s.hum.PlatformStand=s.platform;s.hum.AutoRotate=s.rotate end
 for part,values in pairs(s.parts)do if part.Parent then part.Transparency=values[1];part.CanCollide=values[2] end end
end
local function snapshot(s)
 return {pos=s.pos,yaw=s.yaw,speed=s.speed,model=s.model.Name}
end
yard.LobbyKiosk.EnterPractice.Triggered:Connect(function(p)
 if sessions[p] or p:GetAttribute("DrivingVan")then return end
 local char=p.Character;local root=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not root or not hum or hum.Health<=0 or (root.Position-yard.LobbyKiosk.Position).Magnitude>18 then return end
 local spawn=Park.Spawn+Vector3.new(0,0,(p.UserId%4)*5)
 local model=World.Van(yard.Vehicles,def,CFrame.new(spawn-Vector3.new(0,2.8,0)),"Practice_"..p.UserId)
 for _,part in ipairs(model:GetDescendants())do if part:IsA("BasePart")then part.CanCollide=false;part.CanTouch=false end end
 local s={model=model,root=root,hum=hum,char=char,anchor=root.Anchored,platform=hum.PlatformStand,rotate=hum.AutoRotate,parts={},
 pos=spawn,yaw=0,speed=0,steer=0,throttle=0,lastInput=os.clock()}
 for _,part in ipairs(char:GetDescendants())do if part:IsA("BasePart")then s.parts[part]={part.Transparency,part.CanCollide};part.Transparency=1;part.CanCollide=false end end
 root.Anchored=true;hum.PlatformStand=true;hum.AutoRotate=false;sessions[p]=s
 p:SetAttribute("PracticeDriving",true);net.Motion:FireClient(p,snapshot(s))
end)
net.Action.OnServerEvent:Connect(function(p,verb,t,steer,brake)
 local s=sessions[p];if not s then return end
 if verb=="exit"then finish(p);return end
 if verb=="reset"then
  if s.lastReset and os.clock()-s.lastReset<1 then return end
  s.lastReset=os.clock();s.pos=Park.Spawn;s.yaw=0;s.speed=0;s.throttle=0;s.steer=0
  net.Motion:FireClient(p,snapshot(s));return
 end
 if verb~="drive"or typeof(t)~="number"or typeof(steer)~="number"or t~=t or steer~=steer or math.abs(t)==math.huge or math.abs(steer)==math.huge then return end
 s.throttle=math.clamp(t,-1,1);s.steer=math.clamp(steer,-1,1);s.handbrake=brake==true;s.lastInput=os.clock()
end)
Run.Heartbeat:Connect(function(dt)
 elapsed+=dt
 for p,s in pairs(sessions)do
  if p.Character~=s.char or not s.root.Parent or s.hum.Health<=0 then finish(p)
  else
   if os.clock()-s.lastInput>.5 then s.throttle=0;s.steer=0;s.handbrake=false end
   D.Step(s,def,math.min(dt,.05),0);s.model:PivotTo(D.Frame(s));s.root.CFrame=CFrame.new(s.pos+Vector3.new(0,2,0))
   if elapsed>.08 then net.Motion:FireClient(p,snapshot(s)) end
  end
 end
 if elapsed>.08 then elapsed=0 end
end)
Players.PlayerRemoving:Connect(finish)
local function watch(p)p.CharacterRemoving:Connect(function()finish(p)end)end
Players.PlayerAdded:Connect(watch);for _,p in ipairs(Players:GetPlayers())do watch(p)end
