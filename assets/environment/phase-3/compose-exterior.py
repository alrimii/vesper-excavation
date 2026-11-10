"""One final placement table derived from the existing v212 mesh inventory."""
import json,math,random
from pathlib import Path
ROOT=Path(r'C:/Users/BOSS/Desktop/egg');PRIVATE=ROOT/'Backups/InteriorPhase3_20261111'
rows=[]
for name in ['ContinuousLowGround','IrregularForestIslands','SparseMeadowPockets']:
 d=json.loads((PRIVATE/('exterior-'+name+'.json')).read_text());assert not d['missing'];rows+=d['rows']
rng=random.Random(31011)
def pose(d,x,z,yaw,scale=1):
 c,s=math.cos(yaw),math.sin(yaw);d['cf']=[x,0,z,c,0,s,0,1,0,-s,0,c]
 d['size']=[v*scale for v in d['size']];d['seat']=True
trees=[d for d in rows if d['group']=='IrregularForestIslands'];rng.shuffle(trees)
clusters=[(10,350,18),(80,355,18),(113,470,14),(145,335,18),(176,480,12),(210,350,20),(245,420,16),(278,345,20),(314,470,12),(345,365,20)]
i=0
for ci,(a,r,n) in enumerate(clusters):
 a=math.radians(a);cx,cz=math.cos(a)*r,math.sin(a)*r
 for j in range(n):
  d=trees[i];i+=1;angle=rng.random()*math.tau;rad=math.sqrt(rng.random())
  x=cx+math.cos(angle)*rad*62;z=cz+math.sin(angle)*rad*49
  k=max(1,300/math.hypot(x,z));x*=k;z*=k
  scale=rng.uniform(.91,1.14);pose(d,x,z,rng.random()*math.tau,scale)
  # Select a few taller existing conifers; no uniform world compression.
  if d['name']=='MountainPine' and r<400:d['size']=[v*1.14 for v in d['size']]
  d['cluster']=ci+1;d['group']='LayeredWoodland'
peaks={1:(760,95,.98,17),2:(-250,720,.93,147),3:(-570,-560,.94,232),4:(510,-670,1.0,310),5:(365,510,1.06,62)}
for d in rows:
 if d['group']=='SeparatedRockMassifs':
  idx=int(d['name'][-1]);x,z,k,yaw=peaks[idx];pose(d,x,z,math.radians(yaw),k);d['bury']=12 if idx==5 else 36;d['group']='SeparatedRockMassifs'
cliffs=[d for d in rows if d['group']=='RockyFoothills']
for d,(x,z,s,yaw)in zip(cliffs,[(415,130,.60,10),(275,420,.57,135),(-145,495,.72,208),(-420,275,.61,85),(-420,-235,.66,200),(-100,-470,.61,290),(400,-380,.62,32)]):
 pose(d,x,z,math.radians(yaw),s);d['bury']=12;d['group']='SeatedFoothills'
meadow=[d for d in rows if d['group']=='SparseMeadowPockets']
for i,d in enumerate(meadow):
 ci=i%len(clusters);a,r,n=clusters[ci];a=math.radians(a+rng.uniform(-15,15));r=rng.uniform(285,420)if i%3 else rng.uniform(430,570)
 pose(d,math.cos(a)*r,math.sin(a)*r,rng.random()*math.tau,rng.uniform(.85,1.15));d['group']='MeadowTransitions';d['bury']=.2
# Retain terrain-fitted grass transforms: their mesh vertices were baked to this ground.
# Relocating their bounding boxes would lift some individual tufts off the surface.
rows.sort(key=lambda d:(d['group'],d['name'],d['cf'][0],d['cf'][2]))
payload=json.dumps(rows,separators=(',',':'))
(ROOT/'src/ExteriorIntegrationLayout.luau').write_text('-- Final Phase 3 placements. Ground and all mesh sources are retained; no competing old layout.\nreturn game:GetService("HttpService"):JSONDecode([==['+payload+']==])\n')
(ROOT/'assets/environment/phase-3/exterior-placement-summary.json').write_text(json.dumps({'seed':31011,'placements':len(rows),'clusterCenters':clusters,'mountainPoses':peaks,'minimumTreeRadius':min(math.hypot(d['cf'][0],d['cf'][2])for d in trees),'maximumTreeRadius':max(math.hypot(d['cf'][0],d['cf'][2])for d in trees)},indent=2))
print('Final placements',len(rows))
