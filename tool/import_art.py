#!/usr/bin/env python3
"""ChatGPT kaynak görsellerini (design/art/) uygulamaya alır (assets/images/...).

python3 tool/import_art.py

- Kenara değen yabancı parçaları siler: en büyük şekil dışında görselin kenarına değen
  şekiller (ChatGPT görselleri tek tabakadan keserken komşu görselden kalanlar).
- İkonları şeklin sınırına kırpar, %5 payla kareye ortalar, 256 px'e küçültür.
- Sporcu portreleri kırpılmaz: altısı aynı ölçekte kalsın.

KAYNAK_ADI: ChatGPT ilk teslimde sporcu ve yükseltme dosyalarını istem sırasıyla üretip alfabetik
adlarla kaydetti; tablo dosyayı içindeki görsele eşler (ad = içerik).
"""
from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / 'design/art'
OUT = ROOT / 'assets/images'
SIZE = 256

# kaynak dosya → içerdiği görsel
KAYNAK_ADI = {
    'athletes/bear.png': 'cheetah',
    'athletes/cheetah.png': 'raccoon',
    'athletes/fox.png': 'bear',
    'athletes/rabbit.png': 'rabbit',
    'athletes/raccoon.png': 'turtle',
    'athletes/turtle.png': 'fox',
    'upgrades/archery-aim.png': 'jump-start',
    'upgrades/archery-bow.png': 'jump-steps',
    'upgrades/archery-last.png': 'jump-power',
    'upgrades/archery-wind.png': 'jump-land',
    'upgrades/jump-land.png': 'weight-strength',
    'upgrades/jump-power.png': 'weight-grip',
    'upgrades/jump-start.png': 'weight-balance',
    'upgrades/jump-steps.png': 'weight-finish',
    'upgrades/swim-breath.png': 'archery-aim',
    'upgrades/swim-dive.png': 'archery-bow',
    'upgrades/swim-paw.png': 'archery-wind',
    'upgrades/swim-wave.png': 'archery-last',
    'upgrades/weight-balance.png': 'swim-dive',
    'upgrades/weight-finish.png': 'swim-paw',
    'upgrades/weight-grip.png': 'swim-breath',
    'upgrades/weight-strength.png': 'swim-wave',
}

# grup → (hedef klasör, kırp)
GRUPLAR = {
    'athletes': ('art/athletes', False),
    'upgrades': ('art/upgrades', True),
    'branches': ('art/branches', True),
}

# tek dosyalar: kaynak → hedef
TEKLER = {
    'ui/calendar.png': 'rewards/calendar.png',
    'ui/boost.png': 'rewards/boost.png',
}


def clean(im: Image.Image) -> Image.Image:
    """En büyük şekil dışındaki, kenara değen şekilleri siler (128 px'lik haritada etiketlenir)."""
    small = im.getchannel('A').resize((128, 128), Image.BILINEAR)
    w, h = small.size
    solid = [[small.getpixel((x, y)) > 24 for x in range(w)] for y in range(h)]
    label = [[0] * w for _ in range(h)]
    shapes = []
    for y in range(h):
        for x in range(w):
            if not solid[y][x] or label[y][x]:
                continue
            n = len(shapes) + 1
            q, cells, edge = deque([(x, y)]), [], False
            label[y][x] = n
            while q:
                cx, cy = q.popleft()
                cells.append((cx, cy))
                edge |= cx in (0, w - 1) or cy in (0, h - 1)
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < w and 0 <= ny < h and solid[ny][nx] and not label[ny][nx]:
                        label[ny][nx] = n
                        q.append((nx, ny))
            shapes.append((cells, edge))
    if not shapes:
        return im
    main = max(range(len(shapes)), key=lambda i: len(shapes[i][0]))
    mask = Image.new('L', (w, h), 255)
    for i, (cells, edge) in enumerate(shapes):
        if i != main and edge:
            for cx, cy in cells:
                mask.putpixel((cx, cy), 0)
    # Silinen hücrelerin çevresini de al (küçük haritadan büyütürken kenar kalmasın).
    mask = mask.resize(im.size, Image.NEAREST)
    alpha = Image.composite(im.getchannel('A'), Image.new('L', im.size, 0), mask)
    out = im.copy()
    out.putalpha(alpha)
    return out


def fit(im: Image.Image) -> Image.Image:
    box = im.getchannel('A').point(lambda a: 255 if a > 8 else 0).getbbox()
    if box:
        im = im.crop(box)
    side = round(max(im.size) / .9)
    canvas = Image.new('RGBA', (side, side), (0, 0, 0, 0))
    canvas.paste(im, ((side - im.width) // 2, (side - im.height) // 2), im)
    return canvas


def save(im: Image.Image, dest: Path):
    dest.parent.mkdir(parents=True, exist_ok=True)
    im.resize((SIZE, SIZE), Image.LANCZOS).save(dest, optimize=True)
    print(dest.relative_to(ROOT))


def main():
    for group, (folder, trim) in GRUPLAR.items():
        for src in sorted((SRC / group).glob('*.png')):
            rel = f'{group}/{src.name}'
            name = KAYNAK_ADI.get(rel, src.stem)
            im = clean(Image.open(src).convert('RGBA'))
            save(fit(im) if trim else im, OUT / folder / f'{name}.png')
    for rel, dest in TEKLER.items():
        save(fit(clean(Image.open(SRC / rel).convert('RGBA'))), OUT / dest)


if __name__ == '__main__':
    main()
