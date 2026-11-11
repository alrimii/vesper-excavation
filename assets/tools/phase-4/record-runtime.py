"""One actual 12 fps recording with a bounded, ordinary-key tool sequence. No synthetic frames."""
import ctypes,time,json,sys
from pathlib import Path
import mss
from PIL import Image
name=sys.argv[1]; assert name in ('pick-drill','charge','followup')
root=Path(r'C:/Users/BOSS/Desktop/egg/Backups/InteriorPhase4_20261111')
dest=root/(name+'-frames');dest.mkdir(exist_ok=True)
u=ctypes.windll.user32;u.SetThreadDpiAwarenessContext(ctypes.c_void_p(-4))
class RECT(ctypes.Structure):_fields_=[('left',ctypes.c_long),('top',ctypes.c_long),('right',ctypes.c_long),('bottom',ctypes.c_long)]
r=RECT();assert u.GetWindowRect(460584,ctypes.byref(r))
u.SetForegroundWindow(460584);u.SetCursorPos(r.left+(int(sys.argv[2]) if len(sys.argv)>2 else 990),r.top+(int(sys.argv[3]) if len(sys.argv)>3 else 500))
box={'left':r.left+366,'top':r.top+270,'width':1224,'height':670}
# Keyboard E invokes the game's existing use route. 1/2/3 invoke its existing equip route.
events=([(1,0x31,False),(1.1,0x31,True),(3,0x45,False),(3.1,0x45,True),
         (6,0x32,False),(6.1,0x32,True),(9,0x45,False),(9.7,0x31,False),
         (9.8,0x31,True),(10,0x45,True)] if name=='pick-drill' else
        [(1,0x33,False),(1.1,0x33,True),(3,0x45,False),(3.1,0x45,True)])
if name=='followup':
 events=[(1,0x31,False),(1.1,0x31,True),(3,0x45,False),(3.1,0x45,True),(6,0x33,False),(6.1,0x33,True),(9,0x45,False),(9.1,0x45,True)]
fps=12;duration=13 if name!='charge' else 7;stamps=[];sent=[];start=time.perf_counter()
try:
 with mss.mss() as screen:
  for i in range(fps*duration):
   due=start+i/fps
   if time.perf_counter()<due:time.sleep(due-time.perf_counter())
   elapsed=time.perf_counter()-start
   while events and events[0][0]<=elapsed:
    at,key,up=events.pop(0);u.keybd_event(key,0,2 if up else 0,0);sent.append([elapsed,key,up])
   shot=screen.grab(box);stamps.append(time.perf_counter()-start)
   Image.frombytes('RGB',shot.size,shot.bgra,'raw','BGRX').save(dest/f'{i:04d}.png',compress_level=1)
finally:
 for key in (0x31,0x32,0x33,0x45):u.keybd_event(key,0,2,0)
record={'fps':fps,'frames':len(stamps),'timestampsSeconds':stamps,'keyEvents':sent,'box':box,'capture':'actual loaded Studio viewport, normal speed, no synthetic/interpolated frames'}
(root/(name+'-timing.json')).write_text(json.dumps(record,indent=2));print(name,len(stamps))
