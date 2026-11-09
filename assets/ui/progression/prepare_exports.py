"""Reproducible runtime exports; original flattened illustration masters stay untouched."""
from pathlib import Path
from PIL import Image, ImageDraw
import hashlib, json

root = Path(__file__).resolve().parent
manifest = json.loads((root / 'manifest.json').read_text(encoding='utf-8-sig'))
for asset in manifest['assets']:
    name = asset['name']
    source = Image.open(root / asset['master']).convert('RGBA')
    if name == 'panel':
        # Fill only the enclosed panel interior, never its transparent outside corners.
        under = Image.new('RGBA', source.size)
        ImageDraw.Draw(under).rounded_rectangle((66, 66, 1188, 1188), 110, fill=(12, 22, 43, 255))
        source = Image.alpha_composite(under, source)
    size = 1024 if name == 'background' else 512 if name == 'panel' else 256
    runtime = source.resize((size, size), Image.Resampling.LANCZOS)
    destination = root / asset['export']
    runtime.save(destination, optimize=True)
    asset['dimensions'] = [size, size]
    asset['size'] = destination.stat().st_size
    asset['sha256'] = hashlib.sha256(destination.read_bytes()).hexdigest()
    asset['masterDimensions'] = [1254, 1254]
manifest['exportPreparation'] = 'prepare_exports.py; original masters preserved; enclosed panel alpha filled'
(root / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
print('Runtime export bytes:', sum(a['size'] for a in manifest['assets']))
