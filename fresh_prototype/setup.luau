assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")
assert(not game.ServerScriptService:FindFirstChild("RidePrototype"),"Prototype already exists; inspect before overwriting")
local folder=Instance.new("Folder");folder.Name="RidePrototype";folder.Parent=game.ServerScriptService
local net=Instance.new("Folder");net.Name="RideNetwork"
for _,name in ipairs({"Action","Update","Motion"}) do local r=Instance.new("RemoteEvent");r.Name=name;r.Parent=net end
net.Parent=game.ReplicatedStorage
return "Fresh prototype containers created"
