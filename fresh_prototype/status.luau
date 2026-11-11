local p=game.Players:GetPlayers()[1]
local gameModule=require(game.ServerScriptService.RidePrototype.Game)
local r=p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
return game:GetService("HttpService"):JSONEncode({player=p and p.Name,position=r and tostring(r.Position),state=p and gameModule.Inspect and gameModule.Inspect(p)})
