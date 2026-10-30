"""Başarımlar ve Günlük Ödül ikonlarını eski panel görsellerinden ayrı PNG'ler olarak çıkarır.

python3 tool/extract_panel_icons.py
`cut=True` olanlarda kenardan taşma doldurma ile açık zemin şeffaflaşır; resimli kareler olduğu gibi kırpılır.
"""
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
from extract_settings_icons import cut  # noqa: E402

A = 'pati-sampiyonlari/dist/assets/achievements-panel-exact.png'
D = 'pati-sampiyonlari/dist/assets/daily-panel-exact.png'
OUT = 'assets/images/rewards'
ICONS = {
    # ad: (kaynak, kutu, şeffaf zemin?)
    'ach-first': (A, (40, 215, 147, 317), False),
    'ach-fast': (A, (40, 353, 147, 456), False),
    'ach-stand': (A, (40, 491, 147, 595), False),
    'ach-ticket': (A, (40, 629, 147, 734), False),
    'medal': (A, (82, 16, 170, 128), True),
    'lock': (A, (636, 376, 694, 438), True),
    'clock': (A, (186, 774, 236, 824), True),
    'money': (D, (688, 286, 792, 368), True),
    'ticket': (D, (283, 298, 387, 368), True),
    'gem': (D, (492, 296, 588, 368), True),
    'gift': (D, (560, 556, 760, 690), True),
    'calendar': (D, (72, 36, 222, 192), True),
}

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for name, (src, box, transparent) in ICONS.items():
        img = Image.open(src).crop(box)
        img = cut(img) if transparent else img.convert('RGBA')
        img.save(f'{OUT}/{name}.png')
        print(name, img.size)
