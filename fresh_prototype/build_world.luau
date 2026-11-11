local world=require(game.ServerScriptService.RidePrototype.World).Build()
local original=workspace:FindFirstChild("SpawnLocation")
if original then original.Enabled=false end
game.Lighting.ClockTime=15
game.Lighting.Brightness=2
return "Built fresh world with "..#world.Targets:GetChildren().." vans, "..#world.Guards:GetChildren().." guards and "..#world.Garages:GetChildren().." garages"
