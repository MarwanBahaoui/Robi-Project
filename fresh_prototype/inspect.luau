local items={}
for _,v in ipairs(workspace:GetChildren()) do table.insert(items,v.Name..":"..v.ClassName) end
local scripts={}
for _,v in ipairs(game:GetDescendants()) do if v:IsA("LuaSourceContainer") then table.insert(scripts,v:GetFullName()) end end
return game:GetService("HttpService"):JSONEncode({items=items,scripts=scripts,running=game:GetService("RunService"):IsRunning()})
