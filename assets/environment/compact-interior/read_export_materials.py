"""Retain actual GLB primitive bounds and authored material colors for Studio import normalization."""
import json, struct, math
from pathlib import Path
root=Path(__file__).parent
def srgb(v):return 12.92*v if v<=0.0031308 else 1.055*v**(1/2.4)-0.055
out={}
for name in ['ChargeBundle','Microscope','FossilStudy','EnclosurePanes']:
    raw=(root/'exports'/f'{name}.glb').read_bytes()
    length,kind=struct.unpack_from('<II',raw,12)
    doc=json.loads(raw[20:20+length])
    records=[]
    for node in doc['nodes']:
        if 'mesh' not in node:continue
        assert not any(k in node for k in ['matrix','translation','rotation','scale']), (name,node)
        mesh=doc['meshes'][node['mesh']]
        for index,p in enumerate(mesh['primitives']):
            a=doc['accessors'][p['attributes']['POSITION']]
            low,high=a['min'],a['max']
            mat=doc.get('materials',[{}])[p.get('material',0)] if doc.get('materials') else {}
            color=mat.get('pbrMetallicRoughness',{}).get('baseColorFactor',[1,1,1,1])
            records.append({'node':node.get('name',mesh.get('name','mesh')),'primitive':index,'material':mat.get('name','none'),'size':[high[i]-low[i] for i in range(3)],'center':[(high[i]+low[i])/2 for i in range(3)],'colorSrgb':[round(max(0,min(1,srgb(v)))*255) for v in color[:3]],'baseColorLinear':color})
    low=[min(r['center'][i]-r['size'][i]/2 for r in records) for i in range(3)]
    high=[max(r['center'][i]+r['size'][i]/2 for r in records) for i in range(3)]
    out[name]={'size':[high[i]-low[i] for i in range(3)],'center':[(high[i]+low[i])/2 for i in range(3)],'primitives':records}
    print(name,len(records),'primitives',out[name]['size'])
(root/'export-materials.json').write_text(json.dumps(out,indent=2),encoding='utf-8')
