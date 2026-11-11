-- One atomic record per player, with expiring ownership and serialized writes.
local ProfileStore={}
local Tiers=require(script.Parent.GarageTiers)
ProfileStore.Schema=2
ProfileStore.LeaseSeconds=180
ProfileStore.AutosaveSeconds=45
local function copy(v)
 if type(v)~="table" then return v end
 local r={};for k,x in pairs(v) do r[k]=copy(x) end;return r
end
local function number(v,min,max)
 return type(v)=="number" and v==v and v>=min and v<=max
end
function ProfileStore.Validate(data,allowed)
 if type(data)~="table" or (data.schema~=1 and data.schema~=2) then return nil,"Unsupported save format" end
 local legacy=data.schema==1
 if legacy then
  if data.capacity~=2 and data.capacity~=3 then return nil,"Invalid legacy capacity" end
  local paidThird=data.capacity==3
  data=copy(data);data.schema=2;data.tier=1;data.capacity=3
  if paidThird and number(data.cash,0,1e12-180) then data.cash+=180 end
 end
 local tier=Tiers.List[data.tier]
 if not tier then return nil,"Invalid garage tier" end
 if not number(data.cash,0,1e12) or data.cash%1~=0 or not number(data.bank,0,1e12) then return nil,"Invalid balances" end
 if not number(data.capacity,tier.included,tier.max) or data.capacity%1~=0 then return nil,"Invalid capacity" end
 if data.accel~=0 and data.accel~=1 then return nil,"Invalid upgrade" end
 if type(data.vans)~="table" or type(data.discovered)~="table" then return nil,"Invalid collection" end
 local used,ids={},{};local arrival,count=0,0
 for key,v in pairs(data.vans) do
  count+=1
  if type(key)~="number" or key%1~=0 or key<1 or key>data.capacity+1 or count>data.capacity+1 then return nil,"Invalid van list" end
  if type(v)~="table" or type(v.id)~="string" or #v.id>80 or #v.id==0 or ids[v.id] or not allowed[v.kind] then return nil,"Invalid van" end
  if not number(v.slot,0,data.capacity) or v.slot%1~=0 then return nil,"Invalid slot" end
  ids[v.id]=true
  if v.slot==0 then arrival+=1;if arrival>1 then return nil,"Multiple arrivals" end
  else if used[v.slot] then return nil,"Duplicate earning slot" end;used[v.slot]=true end
  if data.discovered[v.kind]~=true then return nil,"Owned van missing discovery" end
 end
 if count~=#data.vans then return nil,"Sparse van list" end
 for kind,value in pairs(data.discovered) do if not allowed[kind] or value~=true then return nil,"Invalid discovery" end end
 return copy(data)
end
function ProfileStore.Default()
 return {schema=2,tier=1,cash=0,bank=0,capacity=3,accel=0,vans={},discovered={}}
end
function ProfileStore.new(store,token,allowed,clock,waiter)
 local self={store=store,token=token,allowed=allowed,clock=clock or os.time,wait=waiter or task.wait,sessions={}}
 local function update(key,fn)
  local err
  for attempt=1,3 do
   local ok,result=pcall(function()return store:UpdateAsync(key,fn)end)
   if ok then return true,result end
   err=tostring(result);if attempt<3 then self.wait(attempt) end
  end
  return false,err
 end
 function self:Load(key)
  if self.sessions[key] then return nil,"Already loaded" end
  local denied
  local ok,record=update(key,function(old)
   denied=nil
   if old~=nil and (type(old)~="table" or old.format~=1 or type(old.data)~="table") then denied="Unknown record format";return nil end
   if old and old.lock and old.lock.owner~=self.token and old.lock.untilTime>self.clock() then denied="Progress is still open in another server";return nil end
   local data,error=ProfileStore.Validate(old and old.data or ProfileStore.Default(),allowed)
   if not data then denied=error;return nil end
   return {format=1,data=data,revision=old and old.revision or 0,lock={owner=self.token,untilTime=self.clock()+ProfileStore.LeaseSeconds}}
  end)
  if not ok then return nil,"Load request failed: "..tostring(record) end
  if denied or not record then return nil,denied or "Load canceled" end
  if not record.lock or record.lock.owner~=self.token then return nil,"Session ownership unavailable" end
  self.sessions[key]={busy=false,closed=false,expires=record.lock.untilTime}
  return copy(record.data)
 end
 function self:Save(key,data,release)
  local session=self.sessions[key]
  if not session or session.closed then return false,"No writable session" end
  local valid,error=ProfileStore.Validate(data,allowed)
  if not valid then return false,error end
  while session.busy do self.wait(.05) end
  if session.closed then return false,"Session closed" end
  session.busy=true
  local denied
  local ok,record=update(key,function(old)
   denied=nil
   if not old or not old.lock or old.lock.owner~=self.token then denied="Session ownership lost";return nil end
   local revision=(old.revision or 0)+1
   return {format=1,data=copy(valid),revision=revision,savedAt=self.clock(),lock=not release and {owner=self.token,untilTime=self.clock()+ProfileStore.LeaseSeconds} or nil}
  end)
  session.busy=false
  if denied then session.closed=true;return false,denied end
  if not ok or not record then return false,"Save request failed: "..tostring(record) end
  session.expires=release and 0 or record.lock.untilTime
  if release then session.closed=true end
  return true
 end
 function self:Owns(key)
  local s=self.sessions[key];return s and not s.closed and self.clock()<s.expires
 end
 return self
end
return ProfileStore
