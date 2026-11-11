"""Roblox expects a grayscale emissive mask modulating the existing albedo."""
from PIL import Image,ImageChops
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
im=Image.open(ROOT/'rodin-drill-source/texture_emissive.png').convert('RGB')
r,g,b=im.split()
# Maximum source RGB intensity preserves the supplied accent mask, no packed PBR guess.
mask=ImageChops.lighter(ImageChops.lighter(r,g),b)
mask.save(ROOT/'assets/environment/compact-interior/exports/DrillEmissiveMask.png')
