local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local p=Players.LocalPlayer
local net=game.ReplicatedStorage:WaitForChild("PracticeNetwork")
local D=require(game.ReplicatedStorage.RideNetwork.PracticeDriving)
local gui=Instance.new("ScreenGui");gui.Name="PracticeHUD";gui.IgnoreGuiInset=false;gui.ResetOnSpawn=false;gui.Enabled=false;gui.Parent=p:WaitForChild("PlayerGui")
local card=Instance.new("TextLabel");card.Size=UDim2.new(.8,0,0,60);card.Position=UDim2.new(.1,0,0,10);card.BackgroundColor3=Color3.fromRGB(20,48,54);card.TextColor3=Color3.new(1,1,1);card.Font=Enum.Font.GothamBold;card.TextSize=18;card.TextWrapped=true;card.Text="FREE PRACTICE • W/S drive • A/D steer • Space brake\nR reset • E return to lobby";card.Parent=gui
local function button(text,x,callback)
 local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(165,44);b.Position=UDim2.new(x,-82,1,-70);b.BackgroundColor3=Color3.fromRGB(41,144,132);b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextSize=16;b.Text=text;b.Parent=gui;b.Activated:Connect(callback);return b
end
button("Reset van",.35,function()net.Action:FireServer("reset")end)
button("Return to lobby",.65,function()net.Action:FireServer("exit")end)
local active,visual,original,position,yaw,speed,fov,oldHUD
local down={};local tick=0
local touch=Instance.new("Frame");touch.Name="TouchControls";touch.BackgroundTransparency=1;touch.Size=UDim2.new(1,0,0,90);touch.Position=UDim2.new(0,0,1,-180);touch.Visible=UIS.TouchEnabled;touch.Parent=gui
for _,entry in ipairs({{"left","LEFT",.07},{"right","RIGHT",.24},{"brake","BRAKE",.43},{"back","BACK",.62},{"go","GO",.81}})do
 local b=Instance.new("TextButton");b.Size=UDim2.new(.15,0,0,62);b.Position=UDim2.new(entry[3],-20,0,0);b.Text=entry[2];b.TextSize=15;b.Font=Enum.Font.GothamBold;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(41,144,132);b.Parent=touch
 b.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then down[entry[1]]=true end end)
 b.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then down[entry[1]]=nil end end)
end
local function cleanup()
 if not active then return end
 active=false;gui.Enabled=false
 if visual then visual:Destroy();visual=nil end
 if original then for _,v in ipairs(original:GetDescendants())do if v:IsA("BasePart")then v.LocalTransparencyModifier=0 end end end
 original=nil;table.clear(down)
 local cam=workspace.CurrentCamera;cam.CameraType=Enum.CameraType.Custom;cam.FieldOfView=fov or 70
 local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then cam.CameraSubject=h end
 local hud=p.PlayerGui:FindFirstChild("RideHUD");if hud and oldHUD~=nil then hud.Enabled=oldHUD end
end
net.Motion.OnClientEvent:Connect(function(s)
 if s.ended then cleanup();return end
 if not active then
  original=workspace:WaitForChild("PracticeYard").Vehicles:FindFirstChild(s.model);if not original then return end
  active=true;fov=workspace.CurrentCamera.FieldOfView;gui.Enabled=true
  local hud=p.PlayerGui:FindFirstChild("RideHUD");if hud then oldHUD=hud.Enabled;hud.Enabled=false end
  visual=original:Clone();visual.Name="PracticeVisual"
  for _,v in ipairs(visual:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false;v.CanQuery=false;v.CanTouch=false end end
  visual.Parent=workspace.CurrentCamera
  for _,v in ipairs(original:GetDescendants())do if v:IsA("BasePart")then v.LocalTransparencyModifier=1 end end
  position=s.pos;yaw=s.yaw;speed=s.speed
 end
 position=s.pos;yaw=s.yaw;speed=s.speed
end)
local map={[Enum.KeyCode.W]="go",[Enum.KeyCode.S]="back",[Enum.KeyCode.A]="left",[Enum.KeyCode.D]="right",[Enum.KeyCode.Space]="brake"}
UIS.InputBegan:Connect(function(input,processed)
 if processed or not active then return end
 if map[input.KeyCode]then down[map[input.KeyCode]]=true end
 if input.KeyCode==Enum.KeyCode.E then net.Action:FireServer("exit")elseif input.KeyCode==Enum.KeyCode.R then net.Action:FireServer("reset")end
end)
UIS.InputEnded:Connect(function(input)if map[input.KeyCode]then down[map[input.KeyCode]]=nil end end)
UIS.WindowFocusReleased:Connect(function()table.clear(down);if active then net.Action:FireServer("drive",0,0,false)end end)
p.CharacterRemoving:Connect(cleanup)
Run.RenderStepped:Connect(function(dt)
 if not active or not visual then return end
 local target=CFrame.new(position)*CFrame.Angles(0,yaw,0)
 visual:PivotTo(visual:GetPivot():Lerp(target,1-math.exp(-20*dt)))
 local forward=Vector3.new(math.cos(yaw),0,-math.sin(yaw));local pos=visual:GetPivot().Position
 local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable
 camera.CFrame=camera.CFrame:Lerp(CFrame.lookAt(pos-forward*19+Vector3.new(0,10,0),pos+forward*8),1-math.exp(-9*dt))
 camera.FieldOfView=(fov or 70)+math.min(math.abs(speed)/40,1)*5
 tick+=dt;if tick>.05 then tick=0;net.Action:FireServer("drive",(down.go and 1 or 0)-(down.back and 1 or 0),(down.right and 1 or 0)-(down.left and 1 or 0),down.brake==true)end
end)
