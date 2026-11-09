"""Bake mineral porcelain into the shipped mesh UVs; fragments share these UVs."""
import bpy, numpy as np, math, json
from pathlib import Path
ROOT=Path(__file__).resolve().parent
OUT=ROOT/'default-finish'; OUT.mkdir(exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'VesperExpansionV3.blend'))
N=512
def save(name, rgb):
    im=bpy.data.images.new(name,width=N,height=N,alpha=False)
    rgba=np.ones((N,N,4),dtype=np.float32); rgba[:,:,:3]=rgb
    im.pixels.foreach_set(rgba.ravel()); im.filepath_raw=str(OUT/(name+'.png')); im.file_format='PNG'; im.save(); bpy.data.images.remove(im)
for row in range(40):
    obj=bpy.data.objects[f'L1_R{row:02d}']; mesh=obj.data; mesh.calc_loop_triangles()
    uv=mesh.uv_layers.active.data
    color=np.full((N,N,3),[.66,.59,.45],dtype=np.float32)
    rough=np.full((N,N,3),.62,dtype=np.float32)
    normal=np.full((N,N,3),[.5,.5,1],dtype=np.float32)
    for tri in mesh.loop_triangles:
        coords=np.array([mesh.vertices[v].co[:] for v in tri.vertices])
        tex=np.array([uv[l].uv[:] for l in tri.loops])*(N-1)
        lo=np.maximum(np.floor(tex.min(axis=0)).astype(int)-1,0); hi=np.minimum(np.ceil(tex.max(axis=0)).astype(int)+1,N-1)
        xx,yy=np.meshgrid(np.arange(lo[0],hi[0]+1),np.arange(lo[1],hi[1]+1))
        a,b,c=tex; den=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
        if abs(den)<1e-8: continue
        w0=((b[1]-c[1])*(xx-c[0])+(c[0]-b[0])*(yy-c[1]))/den
        w1=((c[1]-a[1])*(xx-c[0])+(a[0]-c[0])*(yy-c[1]))/den; w2=1-w0-w1
        mask=(w0>=-.012)&(w1>=-.012)&(w2>=-.012)
        p=w0[...,None]*coords[0]+w1[...,None]*coords[1]+w2[...,None]*coords[2]
        x,y,z=p[...,0],p[...,1],p[...,2]
        cloud=np.sin(z*1.15+y*.8+np.sin(z*.31)*2)*np.sin(y*1.7+x*.27)
        vein=np.exp(-np.square(np.sin(y*2.2+z*.63+np.sin(z*1.4+y*.7)*.72)/.075))
        fine=np.sin(x*67+y*93+z*47)*np.sin(y*127-z*81)
        if tri.material_index==0:
            base=np.array([.88,.825,.69])+cloud[...,None]*np.array([.045,.046,.05])+fine[...,None]*.004
            gold=np.array([.61,.405,.15]); mix=vein[...,None]*.42
            rgb=base*(1-mix)+gold*mix
            r=.37+.07*cloud-.13*vein
        else:
            rgb=np.array([.68,.59,.42])+cloud[...,None]*.025+fine[...,None]*.012
            r=np.full_like(x,.67)
        iy,ix=yy[mask],xx[mask]; color[iy,ix]=np.clip(rgb[mask],0,1)
        rough[iy,ix]=np.repeat(np.clip(r[mask,None],.24,.75),3,axis=1)
        normal[iy,ix,0]=.5+.018*np.sin(x[mask]*43+y[mask]*61+z[mask]*37)
        normal[iy,ix,1]=.5+.018*np.cos(x[mask]*59-y[mask]*47+z[mask]*41)
    save(f'L1_R{row:02d}_color',color); save(f'L1_R{row:02d}_rough',rough); save(f'L1_R{row:02d}_normal',normal)
    print('BAKED',row,flush=True)
print('FINISH_READY',flush=True)
