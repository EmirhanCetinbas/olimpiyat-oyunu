"""Ayarlar ikonlarını tasarım referansından (settings-panel.png) ayrı, şeffaf PNG'ler olarak çıkarır.

python3 tool/extract_settings_icons.py
Kenarlardan başlayan taşma doldurma ile krem satır zemini şeffaflaşır; ikonların koyu konturu sınır olur.
"""
from collections import deque

from PIL import Image

SRC = 'pati-sampiyonlari/dist/assets/settings-panel.png'
OUT = 'assets/images/settings'
# Referanstaki ikon kutuları (piksel; 1024×1536).
BOXES = {
    'music': (78, 300, 186, 410),
    'sound': (76, 452, 200, 556),
    'vibration': (76, 600, 206, 708),
    'shoe': (78, 810, 208, 922),
    'pause': (78, 960, 198, 1076),
    'save': (74, 1166, 216, 1276),
    'support': (100, 1316, 232, 1418),
    'reset': (562, 1310, 690, 1426),
}


def is_background(px, ref):
    r, g, b, _ = px
    return abs(r - ref[0]) + abs(g - ref[1]) + abs(b - ref[2]) < 60 and r > 200 and g > 190


def cut(img):
    img = img.convert('RGBA')
    w, h = img.size
    data = img.load()
    ref = data[1, 1]
    seen = set()
    queue = deque((x, y) for x in range(w) for y in (0, h - 1)) + deque((x, y) for y in range(h) for x in (0, w - 1))
    while queue:
        x, y = queue.popleft()
        if (x, y) in seen or not (0 <= x < w and 0 <= y < h):
            continue
        seen.add((x, y))
        if not is_background(data[x, y], ref):
            continue
        data[x, y] = (0, 0, 0, 0)
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    return img.crop(img.getbbox())


if __name__ == '__main__':
    import os

    os.makedirs(OUT, exist_ok=True)
    src = Image.open(SRC)
    for name, box in BOXES.items():
        icon = cut(src.crop(box))
        icon.save(f'{OUT}/{name}.png')
        print(name, icon.size)
