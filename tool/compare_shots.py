"""Web | Flutter yan yana karşılaştırma ve genel bakış sayfaları üretir.

python3 tool/compare_shots.py [docs/verification] [tarih]
"""
import glob
import os
import sys
from datetime import date

from PIL import Image, ImageDraw

root = sys.argv[1] if len(sys.argv) > 1 else 'docs/verification'
day = sys.argv[2] if len(sys.argv) > 2 else date.today().isoformat()
pairs = []
for folder in sorted(glob.glob(f'{root}/*-{day}')):
    name = os.path.basename(folder)[: -len(day) - 1]
    web, app = f'{folder}/{name}-web.png', f'{folder}/{name}.png'
    if not (os.path.exists(web) and os.path.exists(app)):
        continue
    a, b = Image.open(web).convert('RGB'), Image.open(app).convert('RGB')
    h = max(a.height, b.height)
    sheet = Image.new('RGB', (a.width + b.width + 12, h + 22), 'white')
    draw = ImageDraw.Draw(sheet)
    draw.text((4, 4), f'WEB  {name}', fill='black')
    draw.text((a.width + 16, 4), 'FLUTTER', fill='black')
    sheet.paste(a, (0, 22))
    sheet.paste(b, (a.width + 12, 22))
    out = f'{folder}/{name}-compare.png'
    sheet.save(out)
    pairs.append(out)

out_dir = f'{root}/compare-{day}'
os.makedirs(out_dir, exist_ok=True)
per_page = 3
for page in range(0, len(pairs), per_page):
    imgs = [Image.open(p) for p in pairs[page : page + per_page]]
    w = sum(i.width for i in imgs) + 16 * (len(imgs) - 1)
    h = max(i.height for i in imgs)
    sheet = Image.new('RGB', (w, h), (230, 230, 230))
    x = 0
    for i in imgs:
        sheet.paste(i, (x, 0))
        x += i.width + 16
    sheet.save(f'{out_dir}/overview-{page // per_page + 1:02d}.png')
print(f'{len(pairs)} karşılaştırma, {out_dir}')
