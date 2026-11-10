"""Real fixed-camera desktop recording; 12 fps, 18 seconds, no synthetic/interpolated frames."""
import ctypes,time,json
from pathlib import Path
import mss
from PIL import Image
ROOT=Path(r'C:/Users/BOSS/Desktop/egg/Backups/InteriorPhase3_20261111')
DEST=ROOT/'motion-frames';DEST.mkdir(exist_ok=True)
ctypes.windll.user32.SetThreadDpiAwarenessContext(ctypes.c_void_p(-4))
class RECT(ctypes.Structure):_fields_=[('left',ctypes.c_long),('top',ctypes.c_long),('right',ctypes.c_long),('bottom',ctypes.c_long)]
r=RECT();assert ctypes.windll.user32.GetWindowRect(460584,ctypes.byref(r))
box={'left':r.left+366,'top':r.top+270,'width':1224,'height':670}
fps=12;frames=[];start=time.perf_counter()
with mss.mss()as screen:
 for i in range(fps*18):
  due=start+i/fps
  if time.perf_counter()<due:time.sleep(due-time.perf_counter())
  shot=screen.grab(box);stamp=time.perf_counter()-start
  frames.append(stamp)
  Image.frombytes('RGB',shot.size,shot.bgra,'raw','BGRX').save(DEST/f'{i:04d}.png',compress_level=1)
record={'fps':fps,'frames':len(frames),'timestampsSeconds':frames,'durationSeconds':time.perf_counter()-start,'capture':'actual Studio viewport; fixed camera; no speed changes or frame synthesis','box':box}
(ROOT/'motion-timing.json').write_text(json.dumps(record,indent=2));print(json.dumps({k:v for k,v in record.items()if k!='timestampsSeconds'}))
