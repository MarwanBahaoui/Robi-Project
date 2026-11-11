import json
from pathlib import Path
import xml.etree.ElementTree as E
p=Path(__file__).parent
source=(p/'Driving.luau').read_text(encoding='utf8')
start=source.index(' local garageArea=')
end=source.index(' if z~=nextPos.Z',start)
source=source[:start]+' local z=math.clamp(nextPos.Z,-278,-112)\n local x=math.clamp(nextPos.X,-128,58)\n'+source[end:]
(p/'PracticeDriving.luau').write_text(source,encoding='utf8')
specs=[('game.ServerScriptService.RidePrototype.PracticePark','ModuleScript','PracticePark.luau'),
('game.ReplicatedStorage.RideNetwork.PracticeDriving','ModuleScript','PracticeDriving.luau'),
('game.ServerScriptService.PracticeServer','Script','Practice.server.luau'),
('game.StarterPlayer.StarterPlayerScripts.PracticeClient','LocalScript','Practice.client.luau')]
calls=[{'name':'multi_edit','arguments':{'file_path':path,'className':cls,'datamodel_type':'Edit','edits':[{'old_string':'','new_string':(p/file).read_text(encoding='utf8')}]}} for path,cls,file in specs]
(p/'practice_install_draft.json').write_text(json.dumps(calls),encoding='utf8')
# A standalone MODEL of the scripts, for review; it is not an auto-running place.
root=E.Element('roblox',{'version':'4'});model=E.SubElement(root,'Item',{'class':'Folder','referent':'RBX0'})
props=E.SubElement(model,'Properties');E.SubElement(props,'string',{'name':'Name'}).text='PracticeYard_DraftSources'
for index,(path,cls,file) in enumerate(specs,1):
 item=E.SubElement(model,'Item',{'class':cls,'referent':'RBX'+str(index)})
 props=E.SubElement(item,'Properties');E.SubElement(props,'string',{'name':'Name'}).text=path.split('.')[-1]
 E.SubElement(props,'ProtectedString',{'name':'Source'}).text=(p/file).read_text(encoding='utf8')
 if cls in ('Script','LocalScript'):E.SubElement(props,'bool',{'name':'Disabled'}).text='true'
E.indent(root);E.ElementTree(root).write(p/'PracticeYard_DraftSources.rbxmx',encoding='utf-8',xml_declaration=True)
assert 'GetDataStore' not in (p/'Practice.server.luau').read_text()
assert 'ProfileStore' not in (p/'Practice.server.luau').read_text()
assert len(E.parse(p/'PracticeYard_DraftSources.rbxmx').findall('.//ProtectedString'))==4
print('Created isolated draft source model and installation payload; runtime validation pending Studio.')
