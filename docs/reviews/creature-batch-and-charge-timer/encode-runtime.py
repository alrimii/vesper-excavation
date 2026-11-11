"""Encode actual desktop frames with recorded timing; crop only Studio chrome."""
import bpy,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
frames=ROOT/'Backups/CreatureBatchTimer_20261111/timer-final-cropped'
timing=json.loads((frames.parent/'timer-final-timing.json').read_text())
bpy.ops.wm.read_factory_settings(use_empty=True)
s=bpy.context.scene;s.render.resolution_x=1224;s.render.resolution_y=670;s.render.resolution_percentage=100;s.render.fps=60
base=timing['timestampsSeconds'][0];duration=min(6.5,timing['durationSeconds']-base)
selected=[(i,t-base) for i,t in enumerate(timing['timestampsSeconds']) if t-base<duration]
editor=s.sequence_editor_create()
for j,(i,t) in enumerate(selected):
 start=1+round(t*60);end=1+round((selected[j+1][1] if j+1<len(selected) else duration)*60)
 strip=editor.strips.new_image('Actual capture '+str(i),str(frames/f'{i:04d}.png'),channel=1,frame_start=start)
 strip.frame_final_duration=max(1,end-start)
s.frame_start=1;s.frame_end=round(duration*60)
s.view_settings.view_transform='Standard';s.view_settings.look='None';s.view_settings.exposure=0;s.view_settings.gamma=1;s.sequencer_colorspace_settings.name='sRGB'
s.render.image_settings.media_type='VIDEO';s.render.image_settings.file_format='FFMPEG';s.render.ffmpeg.format='MPEG4';s.render.ffmpeg.codec='H264';s.render.ffmpeg.constant_rate_factor='MEDIUM';s.render.ffmpeg.audio_codec='NONE'
s.render.filepath=str(ROOT/'docs/reviews/creature-batch-and-charge-timer/runtime-countdown.mp4')
bpy.ops.render.render(animation=True)
(ROOT/'docs/reviews/creature-batch-and-charge-timer/clip-timing.json').write_text(json.dumps(dict(durationSeconds=duration,sourceFramesUsed=len(selected),encodedFps=60,method='Actual frames held until next timestamp; no interpolation or time compression. Studio chrome cropped. Silent.'),indent=2))
