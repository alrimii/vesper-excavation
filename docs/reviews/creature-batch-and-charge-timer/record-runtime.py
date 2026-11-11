"""Short actual Studio runtime capture; private frames, no generated evidence."""
import ctypes,time,json
from ctypes import wintypes
from pathlib import Path
import mss
from PIL import Image
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'Backups/CreatureBatchTimer_20261111'
DEST=OUT/'timer-final-frames';DEST.mkdir(exist_ok=True)
ctypes.windll.user32.SetThreadDpiAwarenessContext(ctypes.c_void_p(-4))
ctypes.windll.user32.SetForegroundWindow(524524)
r=wintypes.RECT();ctypes.windll.user32.GetWindowRect(524524,ctypes.byref(r))
box=dict(left=r.left,top=max(0,r.top),width=r.right-r.left,height=r.bottom-max(0,r.top))
time.sleep(.3)
fps=12;stamps=[];start=time.perf_counter()
with mss.mss() as screen:
 for i in range(12*fps):
  due=start+i/fps
  if time.perf_counter()<due:time.sleep(due-time.perf_counter())
  shot=screen.grab(box);stamps.append(time.perf_counter()-start)
  Image.frombytes('RGB',shot.size,shot.bgra,'raw','BGRX').save(DEST/f'{i:04d}.png',compress_level=1)
(OUT/'timer-final-timing.json').write_text(json.dumps(dict(fps=fps,frames=len(stamps),timestampsSeconds=stamps,durationSeconds=time.perf_counter()-start,box=box,capture='Actual Studio memory-only runtime. Fixed normal third-person distance, FOV72. Video only.'),indent=2))
