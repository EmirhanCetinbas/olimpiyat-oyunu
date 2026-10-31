"""Panel ekran görüntülerinden kırpılmış düşük çözünürlüklü ödül ikonlarını, oyunun
256 px'lik ikon setlerindeki (ui-icons, nav-icons) karşılıklarıyla değiştirir.

python3 tool/hires_reward_icons.py
Karşılığı olmayanlar (lock, clock, calendar, ach-*) extract_panel_icons.py'den gelir.
"""
from PIL import Image

OUT = 'assets/images/rewards'
UI = 'assets/images/ui-icons.png'
NAV = 'assets/images/nav-icons.png'
ICONS = {
    # ad: (kaynak, sütun, satır) — 256×256 kareler
    'gem': (UI, 3, 0),
    'money': (UI, 5, 0),
    'ticket': (UI, 5, 1),
    'medal': (UI, 3, 2),
    'gift': (NAV, 2, 0),
}

if __name__ == '__main__':
    for name, (src, col, row) in ICONS.items():
        tile = Image.open(src).convert('RGBA').crop((col * 256, row * 256, col * 256 + 256, row * 256 + 256))
        # Saydam kenarları kırp (1 px pay); RewardIcon BoxFit.contain ile ölçekler.
        x0, y0, x1, y1 = tile.getchannel('A').point(lambda a: 255 if a > 8 else 0).getbbox()
        img = tile.crop((max(0, x0 - 1), max(0, y0 - 1), min(256, x1 + 1), min(256, y1 + 1)))
        img.save(f'{OUT}/{name}.png', optimize=True)
        print(name, img.size)
