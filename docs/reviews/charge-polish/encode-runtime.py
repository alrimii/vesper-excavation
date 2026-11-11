"""Encode actual PNG frames through the project's existing Blender FFmpeg workflow."""
import bpy,json,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];frames=ROOT/'Backups/ChargePolish_20261111/runtime-frames'
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene;scene.render.resolution_x=1362;scene.render.resolution_y=752;scene.render.resolution_percentage=100;scene.render.fps=60
# PNG capture throughput varied. Preserve real timing instead of speeding the
# countdown up: hold each actual capture until the next recorded timestamp.
timing=json.loads((frames.parent/'runtime-timing.json').read_text())
stamps=timing['timestampsSeconds'];base=stamps[0];duration=7.5
selected=[(i,t-base) for i,t in enumerate(stamps) if t-base<duration]
editor=scene.sequence_editor_create()
for j,(i,t) in enumerate(selected):
 start=1+round(t*60)
 end=1+round((selected[j+1][1] if j+1<len(selected) else duration)*60)
 strip=editor.strips.new_image('Actual capture '+str(i),str(frames/f'{i:04d}.png'),channel=1,frame_start=start)
 strip.frame_final_duration=max(1,end-start)
scene.frame_start=1;scene.frame_end=round(duration*60)
scene.view_settings.view_transform='Standard';scene.view_settings.look='None';scene.view_settings.exposure=0;scene.view_settings.gamma=1;scene.sequencer_colorspace_settings.name='sRGB'
scene.render.image_settings.media_type='VIDEO';scene.render.image_settings.file_format='FFMPEG';scene.render.ffmpeg.format='MPEG4';scene.render.ffmpeg.codec='H264';scene.render.ffmpeg.constant_rate_factor='MEDIUM';scene.render.ffmpeg.audio_codec='NONE'
scene.render.filepath=str(ROOT/'docs/reviews/charge-polish/runtime-countdown.mp4')
bpy.ops.render.render(animation=True)
(ROOT/'docs/reviews/charge-polish/clip-timing.json').write_text(json.dumps(dict(durationSeconds=duration,encodedFps=60,capturedFramesUsed=len(selected),sourceCaptureSeconds=timing['durationSeconds'],method='Actual frames held until the next recorded timestamp, quantized to 1/60 second. No interpolation or time compression. Video only.',sourceTimestampsSeconds=[t for _,t in selected]),indent=2))
