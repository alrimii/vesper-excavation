"""Author a static editable SVG proposal; no Roblox/runtime operations.

Every label is real SVG text. Each node, symbol and connector has a stable id.
The PNG is rendered separately from this SVG using an installed local browser.
"""
from pathlib import Path
import json
from html import escape

HERE = Path(__file__).parent
data = json.loads((HERE.parent / 'skill-tree-directions/design-content.json').read_text())
INK, MUTED, PAPER = '#233440', '#667782', '#f6f7f4'
COLORS = {'A': '#bb653b', 'B': '#258374', 'C': '#4f6cbb'}
positions = {
    'A1': (260,1045), 'A2': (145,875), 'A3': (380,875),
    'A4': (330,725), 'A5': (165,595), 'A6': (365,495), 'A7': (260,315),
    'B1': (735,1045), 'B2': (620,875), 'B3': (855,875),
    'B4': (805,725), 'B5': (640,595), 'B6': (840,495), 'B7': (735,315),
    'C1': (1200,1045), 'C2': (1060,875), 'C3': (1350,875),
    'C4': (1040,670), 'C5': (1360,670), 'C6': (1310,495), 'C7': (1200,315),
}
levels = {str(i): v for i,v in enumerate([0,1,5,15,30,50,75,100])}
ranks = data['illustrativeState']['ranks']
small = {'A1','A3','B1','B3','B6','C1'}
parts = []
def add(s): parts.append(s)
def text(x,y,value,size=20,fill=INK,weight=500,anchor='start',extra=''):
    add(f'<text x="{x}" y="{y}" font-size="{size}" font-weight="{weight}" fill="{fill}" text-anchor="{anchor}" {extra}>{escape(str(value))}</text>')
def rect(x,y,w,h,fill,rx=0,stroke='none',sw=1):
    add(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"/>')
def path(d,stroke=INK,sw=3,fill='none',extra=''):
    add(f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round" {extra}/>')
def circle(x,y,r,fill,stroke='none',sw=1):
    add(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"/>')

# Compact original vector vocabulary: structure symbols, not a finished illustrated icon set.
symbols = {
 'pick': '<path d="M-4 18 7-11 M-20-5 Q-5-22 19-9 L23-2 Q6-9-10 3Z"/>',
 'shell': '<path d="M-19 15 Q-22-7 0-20 Q22-7 19 15Z M2-16-5-4 5 2-4 14"/>',
 'bucket': '<path d="M-19-7-13 19H13L19-7Z M-11-8V-14Q0-27 11-14V-8 M-21-7H21"/>',
 'crystal': '<path d="M0-22 16-8 12 14 0 22-13 11-16-7Z M0-22V22 M-16-7H16"/>',
 'drill': '<path d="M-22-12H-3L7-5V7L-3 12H-22Z M-11 12-16 22H-25L-20 10 M7-6 24 0 7 7 M-17-5H-6"/>',
 'lightning': '<path d="M-22-11-8-3-13 5 4 12 M-1-16 8-3 3 4 22 12"/><path d="M-27-17-17-20-16-9-26-7Z M-6 8 6 5 9 16-1 21Z M18 5 28 4 31 15 21 19Z"/>',
 'lens': '<circle cx="-4" cy="-5" r="14"/><path d="M6 7 20 21 M-5-15-10-4-1-2-5 5"/>',
 'aim': '<path d="M-22-8V-20H-10 M10-20H22V-8 M22 8V20H10 M-10 20H-22V8 M-4 0H4 M0-4V4"/>',
 'latch': '<path d="M-18 0H18L13 20H-13Z M-8 0V-14H9V-7 M-2 9H3"/>',
 'pack': '<path d="M-20-14H20V18H-20Z M-20-4H20 M0-14V18 M-20 7H20"/>',
 'sort': '<path d="M-21-16H-9V-4H-21Z M8-16H20V-4H8Z M-15 2V14H-3 M14 2V14H3 M-2 8 4 14-2 20"/>',
 'clean': '<path d="M0-21 13-6 0 8-13-6Z M-23 8-14 20H14L23 8 M-19-16-22-12 M20-20 24-16"/>',
 'link': '<path d="M-7-13-14-20Q-25-24-25-11L-13 1Q-3 5 0-6 M7 13 14 20Q25 24 25 11L13-1Q3-5 0 6 M-9-9 9 9"/>',
 'harness': '<path d="M-18-12H18V22H-18Z M-9-12V-22H9V-12 M-18-2H18 M-9-2V10H9V-2 M-18-8-26 0V15 M18-8 26 0V15"/>',
 'relay': '<path d="M-24-15-8-10-12 6-25 1Z M8-1 23 4 18 21 3 16Z M-7-3H11 M6-8 12-3 6 2"/>',
 'charge': '<path d="M-23 0Q0 29 23 0 M-23 0Q0 12 23 0 M0-4V-20 M-7-15 0-23 7-15"/>',
 'routing': '<path d="M0 20V1L-18-15 M0 1 18-15"/><path d="M-24-22H-12V-10H-24Z M12-22H24V-10H12Z M-6 15H6V27H-6Z"/>',
 'circuit': '<path d="M0-24 23 16H-23Z M0-24-5-12 4-9-1 1 M23 16 9 15 12 6 3 6 M-23 16-16 3-9 8-5-1"/>',
 'collapse': '<path d="M-24 17-18-5-9-18H8L19-5 25 17 M-8-18-3-5-9 2 1 9 M9-18 4-9 12 1 6 8 M-25 23H-13 M13 23H25"/>',
 'mark': '<path d="M0-21 9 5 0 20-9 5Z M-23-12-12-1 M12-1 23-12 M-23 7-14 11 M14 11 23 7"/>',
 'book': '<path d="M0-13Q-10-21-24-17V16Q-9 12 0 20Q10 12 24 16V-17Q10-21 0-13V20 M-17-7-7-5 M7-5 17-7"/>',
}
add('''<svg xmlns="http://www.w3.org/2000/svg" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" width="2000" height="1360" viewBox="0 0 2000 1360" role="img" aria-labelledby="title description">
<title id="title">Skill tree — unified disciplines, editable structural proposal</title>
<desc id="description">One continuous map with Impact, Collection and Technique regions, exact 21-node prerequisites, and Chain Lightning selected. Static design only.</desc>
<defs>''')
for name,body in symbols.items():
    add(f'<g id="symbol-{name}" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round">{body}</g>')
add('</defs><g font-family="Segoe UI, Arial, sans-serif">')
rect(0,0,2000,1360,PAPER)
rect(0,0,2000,103,'#ffffff')
text(42,35,'STRUCTURE PROPOSAL / NOT IMPLEMENTED',15,MUTED,700,extra='letter-spacing="2"')
text(42,80,'Skills',38,INK,750)
text(185,77,'Shape your excavation style',20,MUTED)
text(1250,55,'LEVEL',14,MUTED,700)
text(1250,85,'15',30,INK,750)
rect(1355,28,179,55,'#e9eefc',12)
text(1375,64,'2 points available',20,'#3e5c9e',700)
text(1560,61,'7 spent / 9 earned',18,MUTED)
rect(1765,25,155,58,'#ffffff',10,'#cbd3d5',1.5)
text(1842,50,'Free respec',19,INK,650,'middle')
text(1842,71,'In your room',13,MUTED,500,'middle')
rect(1940,28,42,49,'#edf0ef',10)
path('M1953 43 1970 61 M1970 43 1953 61',INK,2.5)

add('<g id="branch-focus-controls">')
text(42,149,'FOCUS',13,MUTED,700,extra='letter-spacing="2"')
for x,w,label,c,active in [(115,125,'All paths',INK,True),(253,150,'Impact',COLORS['A'],False),(416,165,'Collection',COLORS['B'],False),(594,165,'Technique',COLORS['C'],False)]:
    rect(x,118,w,48,c if active else '#ffffff',9,'#d2d9d8',0 if active else 1)
    if not active: circle(x+20,142,4,c)
    text(x+w/2+(5 if not active else 0),149,label,18,'#ffffff' if active else c,650,'middle')
text(800,148,'One map · choose a discipline to focus',17,MUTED)
rect(1285,118,165,48,'#ffffff',9,'#cbd3d5')
text(1367,149,'Recenter map',17,INK,650,'middle')
add('</g>')

# Quiet continuous region shading, no terrain or opaque dashboard containers.
for x,w,c,label,sub,center in [(34,450,'#f3eeea','IMPACT','Read faults. Deliver deliberate strikes.',260),(509,450,'#eaf1ed','COLLECTION','Handle resources with fewer interruptions.',735),(984,470,'#edf0f7','TECHNIQUE','Link attacks. Master your tools.',1219)]:
    rect(x,185,w,960,c,22)
    text(x+22,222,label,21,COLORS[{'IMPACT':'A','COLLECTION':'B','TECHNIQUE':'C'}[label]],750,extra='letter-spacing="2"')
    text(x+22,249,sub,15,MUTED)

byref = {n['ref']: n for n in data['nodes']}
edges=[]
def edge(a,b,d):
    dest=byref[b]
    state='owned' if ranks.get(b,0)>0 else ('available' if dest['implemented'] and all(ranks.get(p,0)>0 for p in dest['prerequisites']) else 'locked')
    color=COLORS[b[0]] if state!='locked' else '#98a6ac'
    edges.append({'from':a,'to':b,'path':d,'state':state})
    add(f'<g id="edge-{a}-{b}" data-prerequisite="{a}" data-skill="{b}">')
    path(d,color,4 if state=='owned' else 2.5,extra='stroke-dasharray="6 7"' if state=='locked' else '')
    add('</g>')
add('<g id="prerequisite-connectors">')
for prefix,off in [('A',0),('B',475)]:
    edge(prefix+'1',prefix+'2',f'M {245+off} 1015 L {250+off} 985 V 875 H {185+off}')
    edge(prefix+'1',prefix+'3',f'M {280+off} 1015 L {300+off} 980 V 875 H {350+off}')
    edge(prefix+'2',prefix+'4',f'M {145+off} 833 V 725 H {288+off}')
    edge(prefix+'3',prefix+'4',f'M {380+off} 845 L {455+off} 820 V 725 H {372+off}')
    edge(prefix+'4',prefix+'5',f'M {330+off} 683 V 595 H {207+off}')
    sixth_size = 42 if prefix == 'A' else 30
    edge(prefix+'5',prefix+'6',f'M {165+off} 553 V 495 H {365+off-sixth_size}')
    edge(prefix+'6',prefix+'7',f'M {365+off} {495-sixth_size} V 315 H {316+off}')
edge('C1','C2','M1180 1015V875H1102')
edge('C1','C3','M1220 1015 1230 980V875H1308')
edge('C2','C4','M1060 833V800H1160V670H1082')
edge('C3','C5','M1350 833V800H1250V670H1318')
edge('C2','C6','M1102 875H1190V495H1268')
edge('C6','C7','M1310 453V315H1256')
add('</g>')

motifs={'A1':'lens','A2':'pick','A3':'aim','A4':'pick','A5':'shell','A6':'mark','A7':'collapse','B1':'bucket','B2':'latch','B3':'pack','B4':'sort','B5':'clean','B6':'link','B7':'harness','C1':'relay','C2':'lightning','C3':'drill','C4':'charge','C5':'drill','C6':'routing','C7':'circuit'}
for n in data['nodes']:
    ref=n['ref']; x,y=positions[ref]; rank=ranks.get(ref,0); c=COLORS[ref[0]]
    selected=ref=='C2'; available=ref in ['A3','C2','C3']; owned=rank>0; cap=ref.endswith('7')
    size=56 if cap else (30 if ref in small else 42)
    fill=c if owned else ('#fffdf5' if selected else ('#ffffff' if available else '#e2e7e7'))
    stroke='#c18a19' if selected else (c if owned or available else '#9ca9af')
    glyph='#ffffff' if owned else (c if available else '#61717a')
    state='selected' if selected else ('purchased' if owned else ('available' if available else 'locked'))
    add(f'<g id="node-{n["id"]}" data-state="{state}" data-implemented="{str(n["implemented"]).lower()}"><title>{escape(n["name"])}</title>')
    if selected:
        path(f'M{x-56} {y-30}V{y-53}H{x-30} M{x+30} {y-53}H{x+56}V{y-30} M{x-56} {y+30}V{y+53}H{x-30} M{x+30} {y+53}H{x+56}V{y+30}',stroke,3)
    if cap:
        path(f'M{x} {y-size} {x+size} {y} {x} {y+size} {x-size} {y}Z',stroke,2,fill)
    elif ref in small:
        rect(x-size,y-size,size*2,size*2,fill,10,stroke,2.5)
    else:
        path(f'M{x-22} {y-size}H{x+22}L{x+size} {y-19}V{y+19}L{x+22} {y+size}H{x-22}L{x-size} {y+19}V{y-19}Z',stroke,3 if selected or available else 2,fill)
    add(f'<g id="glyph-{ref}" transform="translate({x} {y})" color="{glyph}"><use href="#symbol-{motifs[ref]}"/></g>')
    if ref=='A4': path(f'M{x-24} {y+23}H{x+22} M{x+15} {y+17} {x+23} {y+23} {x+15} {y+29}',glyph,2)
    if ref=='C5': path(f'M{x+20} {y-19}Q{x+36} {y} {x+20} {y+19}',glyph,2)
    if not owned and not available:
        add(f'<g id="lock-{ref}" transform="translate({x+size-3} {y-size+3})">')
        circle(0,0,12,PAPER)
        path('M-5-1V-6Q0-13 5-6V-1 M-7-1H7V10H-7Z',MUTED,1.8)
        add('</g>')
    elif owned:
        circle(x+size-2,y-size+2,12,'#ffffff',c,1.5)
        path(f'M{x+size-8} {y-size+2} {x+size-3} {y-size+7} {x+size+5} {y-size-3}',c,2.5)
    elif available and not selected:
        circle(x+size-1,y-size+1,7,c,PAPER,3)
    name_y=y+size+28
    text(x,name_y,n['name'],21,INK,700,'middle')
    text(x,name_y+24,f'{rank}/{n["maxRank"]} · {n["rankCost"]} pt / rank' + (f' · Lv {levels[ref[1]]}' if not n['implemented'] else ''),16,MUTED,500,'middle')
    if not n['implemented']:
        rect(x-size-8,y-size-8,18,18,PAPER,3,'#9ca9af',1)
        text(x-size+1,y-size+5,'P',11,MUTED,750,'middle')
    elif available:
        text(x,name_y+46,'SELECTED · AVAILABLE' if selected else 'AVAILABLE',12,stroke if selected else c,750,'middle',extra='letter-spacing="1"')
    if ref.endswith('4') and ref[0]!='C':
        text(x,y-59,'AND',11,MUTED,650,'middle',extra='letter-spacing="1"')
    add('</g>')

add('<g id="field-journal-root">')
# These neutral lines designate entry access, not a paid prerequisite.
path('M675 1210H65V1045H230','#b5bfc2',2)
path('M795 1210H960V1045H765','#b5bfc2',2)
path('M795 1210H1450V1045H1230','#b5bfc2',2)
rect(642,1160,185,87,PAPER,12,'#bec8ca',1.5)
add('<g transform="translate(667 1187) scale(.55)" color="#667782"><use href="#symbol-book"/></g>')
text(743,1194,'Field Journal',19,INK,700,'middle')
text(735,1222,'START · NO POINT COST',11,MUTED,700,'middle',extra='letter-spacing="1"')
add('</g>')

# Selected-skill area. All information remains editable live text, not artwork.
add('<g id="selected-skill-panel">')
rect(1480,185,482,1063,'#ffffff',18,'#d7dedd',1)
text(1512,225,'TECHNIQUE / SELECTED SKILL',14,COLORS['C'],700,extra='letter-spacing="1.4"')
add('<g id="selected-lightning-symbol" transform="translate(1720 340) scale(3.4)" color="#4f6cbb"><use href="#symbol-lightning"/></g>')
text(1512,466,'Chain Lightning',34,INK,750)
text(1512,501,'PASSIVE · PICKAXE / DRILL',14,MUTED,700,extra='letter-spacing="1"')
text(1512,547,'Your strikes can arc into nearby',23,INK,500)
text(1512,580,'exposed shell sections.',23,INK,500)
path('M1512 613H1930','#e0e5e5',1)
text(1512,650,'CURRENT',12,MUTED,700,extra='letter-spacing="1.5"')
text(1512,680,'No lightning',23,INK,600)
text(1770,650,'NEXT · RANK 1/1',12,COLORS['C'],700,extra='letter-spacing="1"')
text(1770,680,'2 extra targets',23,COLORS['C'],700)
text(1512,731,'Arc damage',17,MUTED)
text(1930,731,'80% → 50% base power',19,INK,650,'end')
text(1512,776,'25% chance, checked every 4 seconds.',18,INK)
text(1512,805,'8-second cooldown after a trigger.',18,INK)
path('M1512 838H1930','#e0e5e5',1)
text(1512,871,'REQUIREMENTS',12,MUTED,750,extra='letter-spacing="1.5"')
for yy,label in [(912,'Level 5'),(951,'Precision Relay · rank 1')]:
    circle(1524,yy-7,11,'#e7f3ec')
    path(f'M1518 {yy-7} 1523 {yy-2} 1530 {yy-12}','#258374',2)
    text(1548,yy,label,20,INK,600)
text(1512,1005,'Cost',19,MUTED)
text(1930,1005,'2 skill points',24,INK,750,'end')
rect(1512,1038,418,65,'#4f6cbb',12)
text(1721,1079,'Unlock Chain Lightning',22,'#ffffff',700,'middle')
text(1721,1138,'2 available → 0 remaining',17,MUTED,500,'middle')
text(1512,1209,'Select a node to compare its next rank.',16,MUTED)
add('</g>')

# Footer separates state and shape semantics; no hover-only explanation.
rect(0,1280,2000,80,'#ffffff')
text(35,1310,'STATES',11,MUTED,750,extra='letter-spacing="1.5"')
for xx,label,c in [(35,'Purchased','#258374'),(202,'Available','#4f6cbb'),(360,'Locked','#98a6ac'),(495,'Selected','#c18a19')]:
    rect(xx,1325,13,13,c,3)
    text(xx+23,1337,label,16,INK)
text(670,1310,'NODE HIERARCHY',11,MUTED,750,extra='letter-spacing="1.5"')
text(670,1337,'Rounded: upgrade · Hex: ability · Diamond: capstone',16,INK)
text(1210,1310,'NAVIGATION',11,MUTED,750,extra='letter-spacing="1.5"')
text(1210,1337,'P = planned · Drag / scroll to explore',16,INK)
rect(1690,1300,45,42,'#edf0ef',8); text(1712,1330,'−',24,INK,600,'middle')
text(1785,1328,'100%',19,INK,650,'middle')
rect(1835,1300,45,42,'#edf0ef',8); text(1857,1330,'+',24,INK,600,'middle')
text(1930,1328,'MAP',12,MUTED,700,'middle')
add('</g></svg>')
(HERE/'skill-tree-structure.svg').write_text('\n'.join(parts),encoding='utf-8')
layout={'status':'Static proposal; no runtime behavior','canvas':[2000,1360],
 'sourceSpec':'docs/PHASE_5A_PROGRESSION_SPEC.md','sourceCatalog':'src/SkillCatalog.luau',
 'illustrativeState':data['illustrativeState'],'selected':'C2','positions':positions,'edges':edges,
 'nodes':data['nodes']}
(HERE/'layout.json').write_text(json.dumps(layout,indent=2),encoding='utf-8')
print('Wrote editable SVG and layout.json')
