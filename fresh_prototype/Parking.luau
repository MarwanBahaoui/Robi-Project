local P={}
P.MaxSpeed=1.2
P.HoldTime=.3
P.AngleTolerance=math.rad(30)
function P.Check(position,yaw,speed,padPosition,padSize)
 local x=math.abs(position.X-padPosition.X);local z=math.abs(position.Z-padPosition.Z)
 -- Forgiving center zone: a straight van still fits completely inside the larger bay.
 local allowanceX=math.max(.5,padSize.X/2-5.15)
 local allowanceZ=math.max(.5,padSize.Z/2-2.9)
 if x>allowanceX or z>allowanceZ then return false,"Move into the middle of your highlighted bay" end
 local angle=math.acos(math.clamp(math.abs(math.cos(yaw)),-1,1))
 if angle>P.AngleTolerance then return false,"Turn roughly along the parking lines" end
 if math.abs(speed)>P.MaxSpeed then return false,"Brake and stop - Space makes parking easier" end
 return true,"Good position - hold still"
end
return P
