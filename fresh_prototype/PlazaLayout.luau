local L={}
L.Angles={-48,-16,16,48}
L.Radius=275
L.Junction=Vector3.new(70,0,0)
function L.Entrance(index)
 local a=math.rad(L.Angles[index]);local direction=Vector3.new(math.cos(a),0,math.sin(a))
 return CFrame.new(L.Junction+direction*L.Radius)*CFrame.Angles(0,-a,0)
end
function L.LocalToWorld(index)
 local oldZ=(index-2.5)*152
 return L.Entrance(index)*CFrame.new(-77,0,-oldZ)
end
function L.ParkingFrame(pad)
 return pad.CFrame*CFrame.new(0,3.4-pad.Position.Y,0)
end
function L.Approach(entrance,pad)
 -- Front approach stays in the open plaza; final alignment is along the bay.
 return entrance*CFrame.new(-38,3.4,0),pad.CFrame*CFrame.new(-19,3.4-pad.Position.Y,0)
end
return L
