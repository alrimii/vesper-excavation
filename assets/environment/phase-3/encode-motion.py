"""Encode actual captured PNG frames with the already-installed Blender FFmpeg encoder."""
import bpy
from pathlib import Path
ROOT=Path(r'C:/Users/BOSS/Desktop/egg');frames=ROOT/'Backups/InteriorPhase3_20261111/motion-frames'
scene=bpy.context.scene;scene.render.resolution_x=1224;scene.render.resolution_y=670;scene.render.resolution_percentage=100;scene.render.fps=12
editor=scene.sequence_editor_create();strip=editor.strips.new_image('Actual fixed-camera Studio capture',str(frames/'0000.png'),channel=1,frame_start=1)
files=sorted(frames.glob('*.png'))
for p in files[1:]:strip.elements.append(p.name)
scene.frame_start=1;scene.frame_end=len(files)
scene.view_settings.view_transform='Standard';scene.view_settings.look='None';scene.view_settings.exposure=0;scene.view_settings.gamma=1;scene.sequencer_colorspace_settings.name='sRGB'
scene.render.image_settings.media_type='VIDEO';scene.render.image_settings.file_format='FFMPEG';scene.render.ffmpeg.format='MPEG4';scene.render.ffmpeg.codec='H264';scene.render.ffmpeg.constant_rate_factor='MEDIUM';scene.render.ffmpeg.audio_codec='NONE'
scene.render.filepath=str(ROOT/'docs/reviews/interior-phase-3/mist-motion.mp4')
bpy.ops.render.render(animation=True)
