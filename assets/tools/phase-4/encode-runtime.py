"""Encode actual runtime frames with the existing Blender encoder."""
import bpy,sys
from pathlib import Path
name=sys.argv[sys.argv.index('--')+1]
root=Path(r'C:/Users/BOSS/Desktop/egg');frames=root/('Backups/InteriorPhase4_20261111/'+name+'-frames')
s=bpy.context.scene;s.render.resolution_x=1224;s.render.resolution_y=670;s.render.resolution_percentage=100;s.render.fps=12
editor=s.sequence_editor_create();strip=editor.strips.new_image('Actual Studio runtime',str(frames/'0000.png'),channel=1,frame_start=1)
files=sorted(frames.glob('*.png'))
if name=='followup':files=files[:60] # Only the corrected pickaxe segment, before the diagnosed charge attempt.
for p in files[1:]:strip.elements.append(p.name)
s.frame_start=1;s.frame_end=len(files);s.view_settings.view_transform='Standard';s.view_settings.look='None';s.view_settings.exposure=0;s.view_settings.gamma=1;s.sequencer_colorspace_settings.name='sRGB'
s.render.image_settings.media_type='VIDEO';s.render.image_settings.file_format='FFMPEG';s.render.ffmpeg.format='MPEG4';s.render.ffmpeg.codec='H264';s.render.ffmpeg.constant_rate_factor='MEDIUM';s.render.ffmpeg.audio_codec='NONE'
s.render.filepath=str(root/('docs/reviews/interior-phase-4/'+name+'.mp4'));bpy.ops.render.render(animation=True)
