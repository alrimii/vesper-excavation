import bpy,numpy as np
from pathlib import Path
out=Path(__file__).resolve().parent/'default-finish'
n=256;y,x=np.mgrid[0:n,0:n]/n
cloud=np.sin(x*9+np.sin(y*7))*.5+np.sin(y*11-x*4)*.5
for name,base,amount in [('clean-porcelain-color',[.92,.885,.80],.008),('clean-porcelain-rough',[.24,.24,.24],.015)]:
    rgba=np.ones((n,n,4),dtype=np.float32);rgba[:,:,:3]=np.array(base)+cloud[:,:,None]*amount
    im=bpy.data.images.new(name,width=n,height=n,alpha=False);im.pixels.foreach_set(rgba.ravel());im.filepath_raw=str(out/(name+'.png'));im.file_format='PNG';im.save()
