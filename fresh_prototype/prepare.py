import json
from pathlib import Path
import xml.etree.ElementTree as ET
p=Path(__file__).parent
calls=[]
calls.append({'name':'multi_edit','arguments':{'file_path':'game.ReplicatedStorage.RideNetwork.Tutorial','className':'ModuleScript','datamodel_type':'Edit','edits':[{'old_string':'','new_string':(p/'Tutorial.luau').read_text(encoding='utf8')}]}})
calls.append({'name':'multi_edit','arguments':{'file_path':'game.ReplicatedStorage.RideNetwork.Parking','className':'ModuleScript','datamodel_type':'Edit','edits':[{'old_string':'','new_string':(p/'Parking.luau').read_text(encoding='utf8')}]}})
calls.append({'name':'multi_edit','arguments':{'file_path':'game.ReplicatedStorage.RideNetwork.Driving','className':'ModuleScript','datamodel_type':'Edit','edits':[{'old_string':'','new_string':(p/'Driving.luau').read_text(encoding='utf8')}]}})
for name in ['Config','World','Game','Scenery','ProfileStore','ReturnSprint','GarageTiers','GaragePlots']:
    calls.append({'name':'multi_edit','arguments':{'file_path':'game.ServerScriptService.RidePrototype.'+name,'className':'ModuleScript','datamodel_type':'Edit','edits':[{'old_string':'','new_string':(p/(name+'.luau')).read_text(encoding='utf8')}]}})
for path,file,cls in [('game.ServerScriptService.StartRide','Start.server.luau','Script'),('game.StarterPlayer.StarterPlayerScripts.RideClient','Client.client.luau','LocalScript')]:
    calls.append({'name':'multi_edit','arguments':{'file_path':path,'className':cls,'datamodel_type':'Edit','edits':[{'old_string':'','new_string':(p/file).read_text(encoding='utf8')}]}})
(p/'install_scripts.json').write_text(json.dumps(calls),encoding='utf8')
# Portable clean place; world is generated when Play starts.
roblox=ET.Element('roblox',{'version':'4'})
def item(parent,cls,name,source=None):
    node=ET.SubElement(parent,'Item',{'class':cls,'referent':'RBX'+str(len(list(roblox.iter())))})
    props=ET.SubElement(node,'Properties');ET.SubElement(props,'string',{'name':'Name'}).text=name
    if source is not None: ET.SubElement(props,'ProtectedString',{'name':'Source'}).text=source
    return node
workspace=item(roblox,'Workspace','Workspace')
preview_file=p/'world_preview.json'
if preview_file.exists():
    rows=json.loads(json.loads(preview_file.read_text())['content'][0]['text'])
    preview=item(workspace,'Folder','RidePreview')
    for row in rows:
        part=item(preview,'Part',row['name']);props=part.find('Properties')
        for name,value in [('Anchored','true'),('CanCollide','false')]:ET.SubElement(props,'bool',{'name':name}).text=value
        for name,values in [('Size',row['size'])]:
            v=ET.SubElement(props,'Vector3',{'name':name})
            for axis,value in zip(['X','Y','Z'],values):ET.SubElement(v,axis).text=str(value)
        cf=ET.SubElement(props,'CoordinateFrame',{'name':'CFrame'})
        for key,val in zip(['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'],row['cf']):ET.SubElement(cf,key).text=str(val)
        color=ET.SubElement(props,'Color3',{'name':'Color'})
        for axis,value in zip(['R','G','B'],row['color']):ET.SubElement(color,axis).text=str(value)
        ET.SubElement(props,'float',{'name':'Transparency'}).text=str(row['transparency'])
        ET.SubElement(props,'token',{'name':'Material'}).text=str(row['material'])
        ET.SubElement(props,'token',{'name':'shape'}).text=str(row['shape'])
server=item(roblox,'ServerScriptService','ServerScriptService');folder=item(server,'Folder','RidePrototype')
for name in ['Config','World','Game','Scenery','ProfileStore','ReturnSprint','GarageTiers','GaragePlots']:item(folder,'ModuleScript',name,(p/(name+'.luau')).read_text(encoding='utf8'))
item(server,'Script','StartRide','local preview=workspace:FindFirstChild("RidePreview")\nif preview then preview:Destroy() end\n'+(p/'Start.server.luau').read_text(encoding='utf8'))
rs=item(roblox,'ReplicatedStorage','ReplicatedStorage');network=item(rs,'Folder','RideNetwork')
for name in ['Action','Update']:item(network,'RemoteEvent',name)
item(network,'RemoteEvent','Motion')
item(network,'ModuleScript','Driving',(p/'Driving.luau').read_text(encoding='utf8'))
item(network,'ModuleScript','Parking',(p/'Parking.luau').read_text(encoding='utf8'))
item(network,'ModuleScript','Tutorial',(p/'Tutorial.luau').read_text(encoding='utf8'))
sp=item(roblox,'StarterPlayer','StarterPlayer');sps=item(sp,'StarterPlayerScripts','StarterPlayerScripts')
item(sps,'LocalScript','RideClient',(p/'Client.client.luau').read_text(encoding='utf8'))
ET.indent(roblox);ET.ElementTree(roblox).write(p/'Steal_a_Ride_Fresh_Prototype.rbxlx',encoding='utf-8',xml_declaration=True)
print('Prepared scripts and portable Roblox place')
