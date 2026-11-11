local p=game.Players.LocalPlayer
local prompt=workspace.RidePrototype.Targets.Sport.Body.Steal
p.Character:PivotTo(CFrame.new(-106,5,32));p.Character.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero
task.wait(.5)
return game:GetService("HttpService"):JSONEncode({distance=(p.Character.HumanoidRootPart.Position-prompt.Parent.Position).Magnitude,enabled=prompt.Enabled,position=tostring(p.Character.HumanoidRootPart.Position),target=tostring(prompt.Parent.Position)})
