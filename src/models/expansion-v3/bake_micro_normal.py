import bpy,numpy as np
from pathlib import Path
N=512;rng=np.random.default_rng(2819)
noise=rng.normal(size=(N,N));freq=np.fft.fftfreq(N)
blur=np.exp(-((freq[:,None]**2+freq[None,:]**2)*160))
field=np.fft.ifft2(np.fft.fft2(noise)*blur).real
dy,dx=np.gradient(field);dx/=max(abs(dx.min()),dx.max());dy/=max(abs(dy.min()),dy.max())
rgba=np.ones((N,N,4),dtype=np.float32);rgba[:,:,0]=.5+dx*.004;rgba[:,:,1]=.5+dy*.004
im=bpy.data.images.new('Fine mineral pores',width=N,height=N,alpha=False);im.pixels.foreach_set(rgba.ravel());im.filepath_raw=str(Path(__file__).resolve().parent/'default-finish'/'mineral-micro-normal.png');im.file_format='PNG';im.save()
