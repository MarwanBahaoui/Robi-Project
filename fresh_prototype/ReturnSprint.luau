local Sprint={}
function Sprint.Clear(player,state,consume)
 local boost=state.returnBoost
 state.returnBoost=nil
 if boost and boost.humanoid.Parent then
  -- Do not overwrite a speed that another movement system changed.
  if boost.humanoid.WalkSpeed==boost.applied then boost.humanoid.WalkSpeed=boost.previous end
 end
 player:SetAttribute("ReturnSprintActive",nil)
 if consume then state.returnSprintArmed=nil;state.returnPreviousX=nil end
end
function Sprint.Arm(player,state,position)
 Sprint.Clear(player,state,true)
 state.returnSprintArmed=true
 state.returnPreviousX=position.X
end
function Sprint.Step(player,state,root,humanoid,lineX,lineHalfWidth,sprintSpeed)
 if not root or not humanoid or humanoid.Health<=0 then Sprint.Clear(player,state,true);return end
 if state.run or state.closing then Sprint.Clear(player,state,true);return end
 local x=root.Position.X
 if state.recovery then
  Sprint.Clear(player,state,false)
  state.returnPreviousX=x
  return
 end
 if state.returnBoost and state.returnBoost.humanoid~=humanoid then
  Sprint.Clear(player,state,true);return
 end
 if x>=lineX+.5 or math.abs(root.Position.Z)>lineHalfWidth then
  Sprint.Clear(player,state,false)
 end
 local crossed=state.returnPreviousX and state.returnPreviousX>=lineX and x<lineX
 if state.returnSprintArmed and not state.returnBoost and crossed and math.abs(root.Position.Z)<=lineHalfWidth then
  local applied=math.max(humanoid.WalkSpeed,sprintSpeed)
  state.returnBoost={humanoid=humanoid,previous=humanoid.WalkSpeed,applied=applied}
  humanoid.WalkSpeed=applied
  player:SetAttribute("ReturnSprintActive",true)
 end
 state.returnPreviousX=x
end
return Sprint
