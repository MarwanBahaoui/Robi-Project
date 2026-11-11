local T={}
function T.Resolve(context,data)
 local found=0
 for _,v in ipairs(data.discoveries or {}) do if v.found then found+=1 end end
 if context.enabled==nil then context.enabled=found==0 end
 if not context.enabled or context.done then return nil end
 if context.traderVisited then context.done=true;return nil end
 if data.driving then
  if context.escaped then
   return {step=2,title="PARK IN YOUR GARAGE",text="Follow the arrow. Stop inside the amber bay. When it turns green, press E or Exit Van.",target="parking"}
  end
  return {step=2,title="ESCAPE TO THE GREEN LINE",text="Accelerate toward the green line. The guard gives up when you cross it.",target="safe"}
 end
 if found==0 then
  return {step=1,title="STEAL YOUR FIRST VAN",text="Walk to the highlighted Rusty van and press E, or tap Steal. The guard reacts after you steal.",target="van"}
 end
 if context.collected or data.arrival or (data.rate or 0)==0 then
  return {step=4,title="MEET YOUR GARAGE TRADER",text="Visit the highlighted trader to see selling and upgrades. You do not need to buy anything.",target="trader"}
 end
 return {step=3,title="COLLECT YOUR EARNINGS",text="Your parked van earns $"..tostring(data.rate or 0).."/second. Use the green cash collector to collect it.",target="cash"}
end
return T

