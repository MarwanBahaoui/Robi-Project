local D={}
D.Settings={brake=65,coast=8,reverseRatio=.32,steerResponse=9,wheelbase=7,lowAngle=30,highAngle=15,handbrake=38}
local function approach(a,b,amount) return a+math.clamp(b-a,-amount,amount) end
function D.Step(r,d,dt,upgrade)
 local h=D.Settings
 local old=r.speed
 local t=r.throttle or 0
 local braking=t*r.speed < -.5 or r.handbrake
 if r.handbrake then r.speed=approach(r.speed,0,h.handbrake*dt)
 elseif math.abs(t)<.05 then r.speed=approach(r.speed,0,h.coast*dt)
 elseif t*r.speed<-.5 then
  r.speed=approach(r.speed,0,h.brake*dt)
 else
  local goal=t*(t<0 and d.speed*h.reverseRatio or d.speed)
  local engine=d.accel*(upgrade==1 and 1.3 or 1)*(1-.28*math.min(1,math.abs(r.speed)/d.speed))
  r.speed=approach(r.speed,goal,engine*dt)
 end
 r.steering=(r.steering or 0)+((r.steer or 0)-(r.steering or 0))*(1-math.exp(-h.steerResponse*dt))
 local ratio=math.clamp(math.abs(r.speed)/d.speed,0,1)
 local angle=math.rad(h.lowAngle+(h.highAngle-h.lowAngle)*ratio)*r.steering
 if r.handbrake then angle*=1.3 end
 local yawRate=-r.speed/h.wheelbase*math.tan(angle)
 r.yaw=math.atan2(math.sin(r.yaw+yawRate*dt),math.cos(r.yaw+yawRate*dt))
 local nextPos=r.pos+Vector3.new(math.cos(r.yaw),0,-math.sin(r.yaw))*r.speed*dt
 -- Open the garage approach after the safe line; keep vans inside the perimeter.
 local garageArea=r.escaped or nextPos.X>=65
 local z=math.clamp(nextPos.Z,garageArea and -294 or -48,garageArea and 294 or 48)
 local x=math.clamp(nextPos.X,garageArea and 65 or -130,garageArea and 299 or 70)
 if z~=nextPos.Z or x~=nextPos.X then r.speed*=.35;r.impact=1 end
 r.pos=Vector3.new(x,3.4,z)
 r.impact=math.max(0,(r.impact or 0)-dt*4)
 r.wheel=(r.wheel or 0)+r.speed*dt/1.25
 r.acceleration=(r.speed-old)/math.max(dt,.001)
 r.braking=braking
 r.turnAngle=angle
 r.yawRate=yawRate
 return r
end
function D.Frame(r)
 local speed=math.abs(r.speed)
 local lean=math.clamp(-(r.yawRate or 0)*speed*.0014,-.055,.055)
 local pitch=math.clamp((r.acceleration or 0)*.0008,-.035,.035)
 local bob=math.sin((r.wheel or 0)*.65)*.025*math.min(speed/20,1)
 return CFrame.new(r.pos+Vector3.new(0,bob,0))*CFrame.Angles(0,r.yaw,0)*CFrame.Angles(lean,0,pitch)
end
return D
