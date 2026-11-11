"""Capture 12 seconds of actual Studio viewport at 15 fps; no synthetic frames."""
import ctypes,time,json
from pathlib import Path
import mss
from PIL import Image
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'Backups/ChargePolish_20261111'
DEST=OUT/'runtime-frames';DEST.mkdir(exist_ok=True)
ctypes.windll.user32.SetThreadDpiAwarenessContext(ctypes.c_void_p(-4))
ctypes.windll.user32.SetForegroundWindow(460584)
time.sleep(.25)
box={'left':285,'top':207,'width':1362,'height':752}
fps=15;stamps=[];start=time.perf_counter()
with mss.mss()as screen:
 for i in range(fps*12):
  due=start+i/fps
  if time.perf_counter()<due:time.sleep(due-time.perf_counter())
  shot=screen.grab(box);stamps.append(time.perf_counter()-start)
  Image.frombytes('RGB',shot.size,shot.bgra,'raw','BGRX').save(DEST/f'{i:04d}.png',compress_level=1)
record=dict(fps=fps,frames=len(stamps),timestampsSeconds=stamps,durationSeconds=time.perf_counter()-start,
 capture='Actual memory-only Studio runtime, aiming/placement/full countdown/detonation; normal speed; no generated or interpolated frames; video only',box=box)
(OUT/'runtime-timing.json').write_text(json.dumps(record,indent=2))
