"""Genera ilustraciones de DEMOSTRACIÓN (no son fotografías reales) para el
catálogo demo. Reemplázalas por fotos reales cuando existan. Uso:
    python3 tools/generar_imagenes_demo.py
Requiere Pillow. Escribe en assets/demo/."""
import math, random, os
from PIL import Image, ImageDraw, ImageFilter

W, H = 1200, 900
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'demo')
os.makedirs(OUT, exist_ok=True)

def grad(top, bottom):
    img = Image.new('RGB', (W, H)); d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        d.line([(0, y), (W, y)], fill=tuple(int(top[i]*(1-t)+bottom[i]*t) for i in range(3)))
    return img

def hills(name, sky_top, sky_bot, cols, sun=None, seed=0, mist=False):
    rnd = random.Random(seed)
    img = grad(sky_top, sky_bot); d = ImageDraw.Draw(img, 'RGBA')
    if sun:
        for r, a in [(190, 30), (130, 55), (80, 255)]:
            d.ellipse([sun[0]-r, sun[1]-r, sun[0]+r, sun[1]+r], fill=(255, 236, 190, a))
    for k, col in enumerate(cols):
        base = H*0.42 + k*H*0.15; amp = 55 + k*8; ph = rnd.uniform(0, 6); fr = 150 + k*40
        surf = lambda x, base=base, amp=amp, ph=ph, fr=fr: base + amp*math.sin(x/fr+ph) + amp*0.4*math.sin(x/(fr*0.43)+ph*2)
        d.polygon([(x, surf(x)) for x in range(0, W+1, 6)] + [(W, H), (0, H)], fill=col)
        if k >= 1:
            for row in range(7):
                for x in range(-10, W+20, 26 + row*3):
                    y = surf(x) + 16 + row*(20 + k*2)
                    if y > H - 4: continue
                    g = (int(col[0]*0.55), int(col[1]*0.75), int(col[2]*0.55), 255)
                    rr = 9 + row + k
                    d.ellipse([x-rr, y-rr*0.7, x+rr, y+rr*0.7], fill=g)
                    d.ellipse([x-rr*0.5, y-rr*0.6, x+rr*0.3, y-rr*0.1], fill=(min(255, g[0]+40), min(255, g[1]+45), min(255, g[2]+30), 200))
        if mist:
            d.rectangle([0, surf(W//2)-30, W, surf(W//2)+40], fill=(255, 255, 255, 38))
    img.filter(ImageFilter.SMOOTH).save(os.path.join(OUT, name), quality=86)

def beans(name, bg, cols, seed, count=340, size=(78, 50)):
    rnd = random.Random(seed); img = Image.new('RGB', (W, H), bg)
    for _ in range(count):
        w = int(size[0]*(0.85+0.3*rnd.random())); h = int(size[1]*(0.85+0.3*rnd.random()))
        layer = Image.new('RGBA', (150, 130), (0, 0, 0, 0)); d = ImageDraw.Draw(layer)
        c = rnd.choice(cols); cx, cy = 75, 65
        d.ellipse([cx-w//2+3, cy-h//2+5, cx+w//2+3, cy+h//2+5], fill=(0, 0, 0, 70))
        d.ellipse([cx-w//2, cy-h//2, cx+w//2, cy+h//2], fill=c)
        d.ellipse([cx-w//2+8, cy-h//2+5, cx+w//5, cy-h//7], fill=(min(255, c[0]+38), min(255, c[1]+30), min(255, c[2]+24), 190))
        dk = (int(c[0]*0.35), int(c[1]*0.35), int(c[2]*0.35), 255)
        d.line([(cx-w//2+7, cy+1), (cx-w//6, cy+5), (cx+w//6, cy-3), (cx+w//2-7, cy+1)], fill=dk, width=4)
        layer = layer.rotate(rnd.uniform(0, 360), expand=True, resample=Image.BICUBIC)
        img.paste(layer, (rnd.randint(-40, W-70), rnd.randint(-40, H-60)), layer)
    img.filter(ImageFilter.GaussianBlur(0.7)).save(os.path.join(OUT, name), quality=86)

def cherries(name, bg_top, bg_bot, seed):
    rnd = random.Random(seed); img = grad(bg_top, bg_bot); d = ImageDraw.Draw(img, 'RGBA')
    for b in range(4):
        y0 = 140 + b*200; pts = [(0, y0+rnd.randint(-30, 30))]
        for x in range(150, W+150, 150): pts.append((x, y0+rnd.randint(-45, 45)))
        d.line(pts, fill=(84, 58, 38, 255), width=10)
        for (x, y) in pts[1:]:
            for _ in range(3):
                lx, ly = x+rnd.randint(-70, 70), y+rnd.randint(-60, 60)
                d.ellipse([lx-52, ly-22, lx+52, ly+22], fill=(46, 112, 62, 240))
            for _ in range(5):
                cx, cy = x+rnd.randint(-50, 50), y+rnd.randint(12, 55)
                r = 19
                d.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(184, 28, 36, 255))
                d.ellipse([cx-r+4, cy-r+3, cx-2, cy-3], fill=(255, 120, 110, 190))
    img.filter(ImageFilter.SMOOTH).save(os.path.join(OUT, name), quality=86)

def cup(name, seed):
    rnd = random.Random(seed); img = grad((196, 160, 118), (128, 92, 62)); d = ImageDraw.Draw(img, 'RGBA')
    for y in range(0, H, 46): d.line([(0, y), (W, y+rnd.randint(-6, 6))], fill=(90, 62, 40, 40), width=3)
    cx, cy = W//2, H//2
    d.ellipse([cx-330, cy-300, cx+340, cy+330], fill=(0, 0, 0, 60))
    d.ellipse([cx-320, cy-310, cx+320, cy+310], fill=(245, 242, 236, 255))
    d.ellipse([cx-215, cy-215, cx+215, cy+215], fill=(255, 255, 255, 255), outline=(220, 214, 204, 255), width=6)
    d.ellipse([cx-170, cy-170, cx+170, cy+170], fill=(74, 44, 26, 255))
    d.ellipse([cx-150, cy-150, cx+150, cy+150], fill=(150, 98, 58, 255))
    for r in range(130, 10, -22):
        d.arc([cx-r, cy-r, cx+r, cy+r], start=rnd.randint(0, 90), end=rnd.randint(200, 320), fill=(226, 190, 146, 210), width=9)
    d.ellipse([cx+205, cy-38, cx+310, cy+38], outline=(255, 255, 255, 255), width=16)
    for _ in range(9):
        x, y = rnd.choice([rnd.randint(40, 300), rnd.randint(900, 1150)]), rnd.randint(60, H-60)
        d.ellipse([x-20, y-13, x+20, y+13], fill=(52, 30, 18, 255))
        d.line([(x-15, y), (x+15, y)], fill=(20, 10, 6, 255), width=3)
    img.filter(ImageFilter.GaussianBlur(0.6)).save(os.path.join(OUT, name), quality=86)

def sack(name, seed):
    img = grad((233, 224, 208), (200, 186, 162)); d = ImageDraw.Draw(img, 'RGBA')
    d.ellipse([260, 720, 940, 820], fill=(0, 0, 0, 55))
    d.rounded_rectangle([300, 170, 900, 760], radius=34, fill=(176, 132, 84, 255))
    d.rectangle([300, 170, 900, 230], fill=(150, 108, 66, 255))
    for x in range(316, 900, 22): d.line([(x, 176), (x+6, 226)], fill=(120, 84, 52, 255), width=2)
    d.rounded_rectangle([390, 330, 810, 620], radius=22, fill=(245, 238, 224, 255))
    d.ellipse([560, 350, 640, 430], fill=(74, 44, 26, 255)); d.line([(575, 390), (625, 390)], fill=(245, 238, 224, 255), width=5)
    for i, wdt in enumerate([300, 240, 280, 180]):
        d.rounded_rectangle([600-wdt//2, 460+i*34, 600+wdt//2, 474+i*34], radius=6, fill=(74, 44, 26, 220 if i == 0 else 130))
    d.rectangle([300, 690, 900, 760], fill=(160, 118, 72, 255))
    img.filter(ImageFilter.SMOOTH).save(os.path.join(OUT, name), quality=86)

def beds(name, seed):
    rnd = random.Random(seed); img = grad((173, 200, 214), (214, 226, 224)); d = ImageDraw.Draw(img, 'RGBA')
    d.rectangle([0, 300, W, H], fill=(196, 164, 118, 255))
    for i in range(4):
        y = 340 + i*138
        d.rounded_rectangle([90, y, W-90, y+104], radius=10, fill=(126, 88, 58, 255), outline=(94, 64, 40, 255), width=6)
        for _ in range(520):
            x, yy = rnd.randint(104, W-104), rnd.randint(y+8, y+96)
            c = rnd.choice([(196, 60, 52), (150, 92, 54), (108, 70, 44), (210, 150, 70)])
            d.ellipse([x-5, yy-4, x+5, yy+4], fill=c+(255,))
    d.rectangle([0, 0, W, 300], fill=(178, 206, 220, 255))
    for k, col in enumerate([(92, 140, 96, 255), (66, 112, 76, 255)]):
        d.polygon([(x, 280+k*22+22*math.sin(x/130+k)) for x in range(0, W+1, 8)] + [(W, 320), (0, 320)], fill=col)
    img.filter(ImageFilter.SMOOTH).save(os.path.join(OUT, name), quality=86)

hills('paisaje_cafetal_verde.jpg', (154, 200, 232), (222, 238, 236), [(120, 168, 96), (84, 140, 80), (58, 112, 66)], sun=(930, 170), seed=1)
hills('paisaje_cafetal_atardecer.jpg', (238, 156, 96), (252, 214, 150), [(146, 130, 78), (106, 118, 66), (70, 92, 56)], sun=(300, 250), seed=2)
hills('paisaje_cafetal_neblina.jpg', (170, 188, 202), (222, 228, 230), [(110, 150, 110), (78, 122, 92), (52, 96, 76)], seed=3, mist=True)
beans('granos_tostados.jpg', (58, 34, 20), [(92, 56, 34), (110, 66, 40), (78, 46, 28), (126, 78, 46)], 4)
beans('granos_claros.jpg', (190, 168, 132), [(168, 122, 74), (190, 140, 86), (150, 108, 64), (206, 158, 100)], 5)
cherries('cerezas_cafe.jpg', (206, 226, 200), (238, 240, 224), 6)
cup('taza_cafe.jpg', 7)
sack('empaque_cafe.jpg', 8)
beds('camas_secado.jpg', 9)
print('imagenes generadas en', os.path.abspath(OUT))
