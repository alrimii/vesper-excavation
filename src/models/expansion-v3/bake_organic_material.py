"""Project the Studio material study into a reusable, compact PBR surface."""
import bpy,numpy as np,json
from pathlib import Path
R=Path(__file__).resolve().parent/'organic-finish';N=1024
tris=np.array(json.loads((R/'mesh.json').read_text()))
images={}
for k in ['color','rough','metal']:
    raw=np.fromfile(R/(k+'.rgba'),dtype=np.uint8);size=int(np.sqrt(len(raw)/4))
    images[k]=raw.reshape(size,size,4).astype(float)/255
def save(name,rgb):
    h,w=rgb.shape[:2];im=bpy.data.images.new(name,width=w,height=h,alpha=False)
    rgba=np.ones((h,w,4),dtype=np.float32);rgba[:,:,:3]=rgb
    im.pixels.foreach_set(rgba[::-1].ravel());im.filepath_raw=str(R/(name+'.png'));im.file_format='PNG';im.save();bpy.data.images.remove(im)
save('generated-atlas',images['color'][:,:,:3])
# Crop an interior square of the actual textured face; exclude atlas padding and side islands.
depth=np.full((N,N),-1e9);fields={k:np.zeros((N,N,3)) for k in images}
for tri in tris:
    points=tri[:,[2,1]];tex=(points+.40)/.80*(N-1)
    lo=np.maximum(np.floor(tex.min(axis=0)).astype(int),0);hi=np.minimum(np.ceil(tex.max(axis=0)).astype(int),N-1)
    if np.any(lo>hi):continue
    xx,yy=np.meshgrid(np.arange(lo[0],hi[0]+1),np.arange(lo[1],hi[1]+1));a,b,c=tex
    den=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
    if abs(den)<1e-9:continue
    w0=((b[1]-c[1])*(xx-c[0])+(c[0]-b[0])*(yy-c[1]))/den
    w1=((c[1]-a[1])*(xx-c[0])+(a[0]-c[0])*(yy-c[1]))/den;w2=1-w0-w1
    z=w0*tri[0,0]+w1*tri[1,0]+w2*tri[2,0]
    mask=(w0>=-1e-5)&(w1>=-1e-5)&(w2>=-1e-5)&(z>depth[yy,xx])
    uv=w0[...,None]*tri[0,3:]+w1[...,None]*tri[1,3:]+w2[...,None]*tri[2,3:]
    iy,ix=yy[mask],xx[mask];depth[iy,ix]=z[mask]
    for k,img in images.items():
        size=img.shape[0];sx=np.clip(uv[:,:,0][mask]*(size-1),0,size-1);sy=np.clip(uv[:,:,1][mask]*(size-1),0,size-1)
        x0=sx.astype(int);y0=sy.astype(int);x1=np.minimum(x0+1,size-1);y1=np.minimum(y0+1,size-1)
        fx=(sx-x0)[:,None];fy=(sy-y0)[:,None]
        fields[k][iy,ix]=(img[y0,x0,:3]*(1-fx)+img[y0,x1,:3]*fx)*(1-fy)+(img[y1,x0,:3]*(1-fx)+img[y1,x1,:3]*fx)*fy
# Keep the generated growth relief, replace exaggerated iridescent coloration with warm bone.
color=fields['color'];lum=color@np.array([.2126,.7152,.0722])
low,high=np.quantile(lum,[.02,.98]);height=np.clip((lum-low)/max(high-low,.01),0,1)
ivory=.47+.43*height**.55
result=ivory[:,:,None]*np.array([1.0,.958,.864])
result += (color-lum[:,:,None])*.055
save('ancient-ivory-color',np.clip(result,0,1))
# Polished nacre highs and matte recesses; real variation rather than flat reflectance.
rough=np.clip(.60-height*.36 + (fields['rough'].mean(axis=2)-.5)*.06,.22,.64)
save('ancient-ivory-rough',np.repeat(rough[:,:,None],3,axis=2)[::2,::2])
# Use the material relief as a low-amplitude tangent-space normal; soften pixel noise.
freq=np.fft.fftfreq(N);blur=np.exp(-(freq[:,None]**2+freq[None,:]**2)*120)
smooth=np.fft.ifft2(np.fft.fft2(height)*blur).real
dy,dx=np.gradient(smooth);normal=np.stack((-dx*4.5,dy*4.5,np.ones_like(dx)),axis=2);normal/=np.linalg.norm(normal,axis=2)[:,:,None]
save('ancient-ivory-normal',(normal*.5+.5)[::2,::2])
metal=np.clip(fields['metal'].mean(axis=2)*.14,0,.12)
save('ancient-ivory-metal',np.repeat(metal[:,:,None],3,axis=2)[::4,::4])
print('ORGANIC_MAPS_READY',float(height.std()),float(depth.min()),flush=True)
