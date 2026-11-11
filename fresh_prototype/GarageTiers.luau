local T={}
T.List={
 {name="Starter",included=3,max=6,price=0,slots={400,900,1800},color=Color3.fromRGB(75,159,144),description="Neighborhood garage with timber trim",rows=6,depth=62},
 {name="Workshop",included=8,max=12,price=12000,slots={2400,3200,4000,5000},color=Color3.fromRGB(79,148,198),description="Workshop with metal shutters and overhead lighting",rows=8,depth=110},
 {name="Warehouse",included=14,max=18,price=36000,slots={6500,8000,9500,11000},color=Color3.fromRGB(221,159,61),description="Industrial warehouse with steel beams",rows=8,depth=158},
 {name="Showroom",included=20,max=24,price=75000,slots={14000,16000,18000,20000},color=Color3.fromRGB(159,116,210),description="Glass displays and polished showroom floor",rows=8,depth=174},
 {name="Elite Garage",included=28,max=32,price=130000,slots={24000,28000,32000,36000},color=Color3.fromRGB(230,200,112),description="Luxury collection hall with illuminated displays",rows=8,depth=206},
}
function T.SlotCost(tier,capacity)
 local d=T.List[tier];if not d or capacity>=d.max then return nil end
 return d.slots[capacity-d.included+1]
end
function T.Offer(a)
 local tier=a.tier or 1;local current=T.List[tier];local nextTier=T.List[tier+1]
 return {tier=tier,name=current.name,max=current.max,slotCost=T.SlotCost(tier,a.capacity),
 nextTier=nextTier and {tier=tier+1,name=nextTier.name,price=nextTier.price,included=nextTier.included,max=nextTier.max,description=nextTier.description},
 canTier=nextTier~=nil and a.capacity==current.max}
end
function T.Buy(a,kind)
 if a.run then return false,"Park and exit your van before upgrading." end
 if kind=="slot" then
  local cost=T.SlotCost(a.tier,a.capacity)
  if not cost then return false,"All slots in this tier are unlocked." end
  if a.cash<cost then return false,"Not enough cash. Collect your garage earnings first." end
  a.cash-=cost;a.capacity+=1;return true,"Slot "..a.capacity.." unlocked!"
 elseif kind=="tier" then
  local current=T.List[a.tier];local nextTier=T.List[a.tier+1]
  if not nextTier then return false,"Maximum garage tier reached." end
  if a.capacity~=current.max then return false,"Unlock all "..current.max.." slots first. They do not need to be occupied." end
  if a.cash<nextTier.price then return false,"Not enough cash for the next garage." end
  a.cash-=nextTier.price;a.tier+=1;a.capacity=nextTier.included
  return true,nextTier.name.." unlocked with "..a.capacity.." usable slots!"
 end
 return false,"Unknown garage upgrade."
end
return T
