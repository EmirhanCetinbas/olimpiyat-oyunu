"""Ayarlar ekran görüntüsünü tasarım referansıyla yan yana koyar.

python3 tool/settings_vs_reference.py <flutter-png> <çıktı-png>
"""
import sys

from PIL import Image

shot = Image.open(sys.argv[1]).convert('RGB')
ref = Image.open('pati-sampiyonlari/dist/assets/settings-panel.png').convert('RGB')
h = shot.height
ref = ref.resize((int(ref.width * h / ref.height), h))
sheet = Image.new('RGB', (ref.width + shot.width + 24, h), 'white')
sheet.paste(ref, (0, 0))
sheet.paste(shot, (ref.width + 24, 0))
scale = min(1.0, 1800 / sheet.width)
sheet.resize((int(sheet.width * scale), int(sheet.height * scale))).save(sys.argv[2])
