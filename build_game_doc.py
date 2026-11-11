from pathlib import Path
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT = Path(__file__).parent
doc = Document()
sec = doc.sections[0]
sec.page_width = Inches(8.27)
sec.page_height = Inches(11.69)
sec.top_margin = sec.bottom_margin = Inches(.65)
sec.left_margin = sec.right_margin = Inches(.65)
for name in ['Normal', 'Title', 'Subtitle', 'Heading 1', 'Heading 2']:
    s = doc.styles[name]
    s.font.name = 'Calibri'
    s.font.color.rgb = RGBColor.from_string('000000')
doc.styles['Normal'].font.size = Pt(11)
doc.styles['Normal'].paragraph_format.space_after = Pt(7)
doc.styles['Normal'].paragraph_format.line_spacing = 1.06
doc.styles['Title'].font.size = Pt(30)
doc.styles['Title'].paragraph_format.space_after = Pt(6)
doc.styles['Heading 1'].font.size = Pt(20)
doc.styles['Heading 1'].paragraph_format.space_before = Pt(10)
doc.styles['Heading 1'].paragraph_format.space_after = Pt(10)
doc.styles['Heading 2'].font.size = Pt(13)
doc.styles['Heading 2'].paragraph_format.space_before = Pt(10)
doc.styles['Heading 2'].paragraph_format.space_after = Pt(5)

def p(text, boldlead=None):
    para = doc.add_paragraph()
    if boldlead and text.startswith(boldlead):
        para.add_run(boldlead).bold = True
        para.add_run(text[len(boldlead):])
    else:
        para.add_run(text)
    return para

def table(headers, rows, widths):
    t = doc.add_table(rows=1, cols=len(headers))
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    t.autofit = False
    for col, w in zip(t.columns, widths):
        col.width = Inches(w)
    props = t._tbl.tblPr
    borders = OxmlElement('w:tblBorders')
    for side in ['top','left','bottom','right','insideH','insideV']:
        e = OxmlElement('w:'+side)
        for k,v in [('val','single'),('sz','5'),('color','D9D9D9')]:
            e.set(qn('w:'+k),v)
        borders.append(e)
    props.append(borders)
    for index, data in enumerate([headers]+rows):
        row = t.rows[0] if index == 0 else t.add_row()
        trpr = row._tr.get_or_add_trPr()
        trpr.append(OxmlElement('w:cantSplit'))
        if index == 0:
            trpr.append(OxmlElement('w:tblHeader'))
        for j, (cell, text) in enumerate(zip(row.cells,data)):
            cell.width = Inches(widths[j])
            cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
            pr = cell._tc.get_or_add_tcPr()
            sh = OxmlElement('w:shd')
            sh.set(qn('w:fill'),'173F64' if index == 0 else ('EDF4FA' if index%2 else 'FFFFFF'))
            pr.append(sh)
            margins = OxmlElement('w:tcMar')
            for side, value in [('top','95'),('bottom','95'),('left','110'),('right','110')]:
                e=OxmlElement('w:'+side); e.set(qn('w:w'),value); e.set(qn('w:type'),'dxa'); margins.append(e)
            pr.append(margins)
            para=cell.paragraphs[0]
            para.paragraph_format.space_after=Pt(0)
            para.paragraph_format.line_spacing=1.03
            run=para.add_run(text)
            run.font.size=Pt(10.5)
            run.bold=index==0 or j==0
            run.font.color.rgb=RGBColor.from_string('FFFFFF' if index==0 else ('173F64' if j==0 else '202B36'))
    doc.add_paragraph().paragraph_format.space_after=Pt(0)
    return t

doc.add_paragraph('Steal a Ride', 'Title')
doc.add_paragraph('Game loop and first prototype', 'Subtitle')
p('Updated 4 November 2026  |  Starting theme: vans  |  Incremental collection game')
p('Steal vans from guarded NPC lots and bring them home. Keep a van for passive income or sell it to an NPC trader for immediate cash. Every newly secured type advances a permanent collection of eight discoveries.')
flow=p('STEAL  >  ESCAPE  >  EARN  >  UPGRADE  >  REPEAT')
flow.runs[0].font.color.rgb=RGBColor.from_string('167D8D'); flow.runs[0].bold=True
doc.add_heading('The game loop', 1)
table(['Step','Player action','Result','Example'],[
['1  Choose','Compare income, sale value and security.','Choose an earner, a sale or a discovery.','Target a missing collection type.'],
['2  Approach','Walk freely to the van and its Steal prompt.','The guard stays stationary until you steal.','No waiting for a patrol.'],
['3  Steal','Press Steal and enter in a brief animation.','Alarm sounds; guard reacts before chasing.','Gain control and a short head start.'],
['4  Escape','Follow a simple road back to the garage.','The guard stops chasing at the boundary.','First ride has one obvious route.'],
['5  Secure','Bring the stolen van across the safe zone.','Register its discovery permanently.','Collection advances from 0/8 to 1/8.'],
['6  Earn or sell','Park it for income or sell it to the trader.','Choose ongoing earnings or immediate cash.','Rusty van earns $1/s if kept.*'],
['7  Upgrade','Improve getaway acceleration or buy a slot.','Get moving faster or earn from more vans.','Expand from two slots to three.'],
['8  Repeat','Find missing types and attempt better thefts.','Complete eight discoveries to open a new lot.','Keep discoveries even after sales.']
],[.85,2.02,2.05,2.05])
p('* Income values are illustrative. Prices, timers and rewards must be balanced through testing.')
p('The main hook: you escape in the vehicle you just stole. Guards react to the theft; the challenge starts with the getaway. Test that activity before adding a large economy.', 'The main hook:')

doc.add_page_break()
doc.add_heading('Progression and player rules', 1)
p('Guards wait at their posts until a theft triggers an alarm. Give the player vehicle control and a brief, readable head start before pursuit. NPC targets keep the loop playable alone.')
table(['Situation','Rule'],[
['Caught by a guard','The guard ejects the player with a short, comic ragdoll push onto safe ground. Recover automatically; return the stolen van to its lot. No money, upgrade or secured-van loss.'],
['After the knockback','End the pursuit. Give a brief on-foot sprint boost and capture protection so the player can return home or approach another theft. Neither stacks; both end on starting a theft or entering a vehicle.'],
['Entering the garage','The guard stops immediately at the marked boundary and returns to its stationary post. Record a discovery only when the stolen van itself crosses into the garage.'],
['Full garage','Place the incoming van in one non-earning arrival bay. Sell a parked van to free a slot, or sell the incoming van. Resolve this choice before starting another theft; no automatic discard.'],
['Selling a van','Show the trader price, lost income per second and a confirmation. Remove that van and pay once. Its discovery stays recorded. No separate automatic theft cash bonus.'],
['Duplicate vehicle','A duplicate gives no new discovery and cannot create a second earning copy of the same type. Sell it to the trader for cash.'],
['Collecting income','Parked vans add to a single garage balance. Collect with one interaction. Income continues during thefts in the same session.'],
['Safe progress','Only one stolen van can be in transit. Other players cannot steal secured vans in the initial version. Save an unresolved arrival-bay van so reconnecting does not lose it.']
],[1.40,5.57])
doc.add_heading('Make capture funny and fair', 2)
p('Show a warning before capture. Keep the ragdoll brief and land the player clear of hazards and walls. Restore control as soon as they stand up. The guard returns to its stationary post instead of repeatedly knocking them down. The first theft has generous reaction time and no escape countdown.')

doc.add_page_break()
doc.add_heading('Collections and meaningful choices', 1)
doc.add_heading('Eight discoveries in each collection', 2)
p('Each themed collection contains eight distinct van types. A type counts the first time it reaches the garage safely, not when it is merely entered or spotted. Show eight silhouettes and a clear progress counter. Selling a van never removes its discovery; owning eight parking slots is not required.')
p('Finishing 8/8 unlocks the next collection lot. Make all eight types obtainable with current-area equipment and show where missing types can be found. Avoid rare random spawns that leave a player stuck at 7/8. The prototype uses a small test collection; the eight-type structure is validated in a later content test.')
doc.add_heading('Keep for income or sell for cash', 2)
p('Keep valuable earners to improve long-term income. Sell lower earners or duplicates when immediate cash is more useful. The trader replaces discarding and the former automatic theft reward; the player earns sale cash only when a secured van is actually sold. There is no permanent vehicle storage beyond parked vans and one arrival bay.')
p('Show sale prices before a theft and warn when selling the last earning van. Keep an easy starter target available so an empty garage is recoverable. Balance sale cash against passive income and theft duration so neither keeping everything nor repeatedly selling the easiest van always wins.')
doc.add_heading('Two upgrades to start with', 2)
p('Getaway acceleration: a persistent player upgrade that helps each stolen van reach its normal top speed faster. Preserve differences between vehicle types and keep the first theft achievable without upgrades. Garage capacity: start with two earning slots and offer one extra slot in the prototype. Exact upgrade strength and cost need playtesting.')
doc.add_heading('Give each target a different tradeoff', 2)
table(['Vehicle','Appeal','Challenge'],[
['Rusty van','Easy starter discovery.','Slow guard reaction and a simple road home.'],
['Armored van','Higher earning potential.','Slower acceleration requires a clean start.'],
['Sport van','Fast getaway.','A quicker guard reaction after the theft.']
],[1.25,2.25,3.47])
p('Keep roads readable throughout. The first route is short, wide and obvious, without tight turns or branching decisions. Introduce optional shortcuts only after the player understands driving. Vary guard reaction times, vehicle handling and target placement. Never let a guard capture the player before driving controls are available.')

doc.add_page_break()
doc.add_heading('Build and test the first version', 1)
doc.add_heading('The first session', 2)
p('Show a starter van with its income, trader value and a clear road home. The player approaches freely and presses Steal. A brief entry animation leads into vehicle control; the alarm and guard reaction signal the chase. At the garage, the guard leaves and the discovery registers. Park the first van to establish income; introduce selling on a later return.')
p('Aim for a first successful theft in roughly one to two minutes, followed shortly by an affordable upgrade. These are design targets to test, not proven benchmarks.')
doc.add_heading('Prototype scope', 2)
table(['Build first','Include'],[
['World and challenge','One compact map, one garage, one lot, one stationary NPC guard that reacts to theft, and one short, wide road home.'],
['Vehicles and upgrades','Three van types; two earning slots plus one purchasable slot; one getaway-acceleration upgrade.'],
['Economy and collection','NPC trader, session income, one arrival bay, permanent discoveries and sale confirmations.'],
['Readable failure','Guard warnings, a short ragdoll ejection, a temporary sprint boost and capture protection, and a garage boundary that ends pursuit.']
],[1.40,5.57])
p('Test in two stages: first use three types and a clearly labeled 3/3 test collection to validate stealing, selling and upgrading. Then expand to eight types and test the real 8/8 unlock. Do not show unreachable 8/8 progress in the three-van build.', 'Test in two stages:')
p('Before a public playtest, save money, collection and upgrades reliably, and validate rewards and purchases on the server. Local prototypes can use temporary progress.')
doc.add_heading('What to watch in playtests', 2)
p('Observe 5–10 new players. Do they understand that stealing triggers the guard and get time to drive? Can they explain keep versus sell, clear a full garage and retain discoveries after sales? Do they enjoy capture and choose to retry? Check that sprint protection ends on the next theft and that acceleration upgrades feel useful.')
p('Track waiting for cash, repeated farming of one easy target and players stuck on a final missing discovery. Fix confusing objectives and unfair capture before adding content. Small tests find design problems; they do not prove demand.')
doc.add_heading('Keep the scope small', 2)
p('Defer player raids, player-to-player trading, combat, rebirths, offline income, large cities, advanced police chases and monetization. The NPC trader is part of the first version. Expand beyond vans only after the core loop earns repeat play.')
p('Thumbnail direction: silver van $1/s to gold van $9,999/s. These are concept numbers; the final thumbnail must match the actual game. The design has not yet been built or playtested.', 'Thumbnail direction:')

doc.core_properties.title='Steal a Ride Game Loop'
doc.core_properties.subject='Core loop, progression rules and prototype plan'
doc.core_properties.author=''
out=ROOT/'Steal_a_Ride_Game_Loop.docx'
doc.save(out)
print(out)
check=Document(out)
assert len(check.tables)==4
assert len(check.tables[0].rows)==9
assert len(check.tables[1].rows)==9
print('Verified DOCX structure: 4 tables, 8 loop steps and 8 situation rules.')

# Keep the original plain-text companion synchronized with the Word version.
from docx.text.paragraph import Paragraph
from docx.table import Table
text_blocks = []
for block in check.element.body:
    if block.tag == qn('w:p'):
        text = Paragraph(block, check).text.strip()
        if text:
            text_blocks.append(text)
    elif block.tag == qn('w:tbl'):
        t = Table(block, check)
        headers = [c.text for c in t.rows[0].cells]
        for row in t.rows[1:]:
            text_blocks.append('\n'.join(f'{label}: {cell.text}' for label, cell in zip(headers, row.cells)))
(ROOT/'Steal_a_Ride_Game_Loop.txt').write_text('\n\n'.join(text_blocks)+'\n', encoding='utf-8')
all_text = '\n'.join(text_blocks)
for term in ['eight distinct van types', 'ragdoll', 'arrival bay', 'NPC trader', 'no escape countdown', 'stationary', 'Getaway acceleration', '4 November 2026']:
    assert term in all_text, term
for stale in ['non-earning storage', 'immediate theft rewards', 'two escape routes', 'Caught or out of time', 'Wait for a guard to turn', 'Avoid the patrol', 'unlocking-tool', 'Unlocking tool', 'returns to patrol']:
    assert stale not in all_text, stale
print('Verified requested mechanics and removed superseded rules; TXT companion synchronized.')
