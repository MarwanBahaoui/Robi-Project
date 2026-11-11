import json
from pathlib import Path
p=Path(__file__).parent
args={'file_path':'game.ServerScriptService.RidePrototype.Game','datamodel_type':'Edit','edits':[{'old_string':(p/'Game.before_slot_fix.luau').read_text(encoding='utf8'),'new_string':(p/'Game.luau').read_text(encoding='utf8')}]}
(p/'slot_fix.json').write_text(json.dumps(args),encoding='utf8')
