#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""高解像度(64x80)の猫耳女の子ドット絵を手続き的に生成し、Dartへ焼き込む。"""
import math

W, H = 64, 80
CX = 31.5

def blank():
    return [['.'] * W for _ in range(H)]

def put(g, x, y, ch):
    xi, yi = int(round(x)), int(round(y))
    if 0 <= xi < W and 0 <= yi < H:
        g[yi][xi] = ch

def in_ell(x, y, cx, cy, rx, ry):
    return ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0

def fill_ell(g, cx, cy, rx, ry, shader, over=None):
    for y in range(H):
        for x in range(W):
            if in_ell(x, y, cx, cy, rx, ry):
                if over is not None and g[y][x] not in over:
                    continue
                c = shader(x, y)
                if c:
                    g[y][x] = c

def tri(g, ax, ay, bx, by, cx, cy, shader):
    minx, maxx = int(min(ax, bx, cx)), int(max(ax, bx, cx))
    miny, maxy = int(min(ay, by, cy)), int(max(ay, by, cy))
    def sign(x1, y1, x2, y2, px, py):
        return (px - x2) * (y1 - y2) - (x1 - x2) * (py - y2)
    for y in range(miny, maxy + 1):
        for x in range(minx, maxx + 1):
            d1 = sign(ax, ay, bx, by, x, y)
            d2 = sign(bx, by, cx, cy, x, y)
            d3 = sign(cx, cy, ax, ay, x, y)
            neg = (d1 < 0) or (d2 < 0) or (d3 < 0)
            pos = (d1 > 0) or (d2 > 0) or (d3 > 0)
            if not (neg and pos):
                c = shader(x, y)
                if c:
                    put(g, x, y, c)

# ---- 各パーツの色シェーダ -------------------------------------------------

def hair_shader(x, y):
    # 上ほど明るい金髪。左からの光でわずかに左を明るく。
    if y < 16:
        base = 'y'
    elif y < 30:
        base = 'Y'
    elif y < 52:
        base = 'g'
    else:
        base = 'G'
    if x < CX - 8 and y < 40:
        base = {'y': 'y', 'Y': 'y', 'g': 'Y', 'G': 'g'}[base]
    if x > CX + 9:
        base = {'y': 'Y', 'Y': 'g', 'g': 'G', 'G': 'G'}[base]
    return base

def skin_shader(x, y):
    base = 'A'
    # 輪郭近く・下側は影
    if not in_ell(x, y, 32, 36, 11.2, 13.2):
        base = 's'
    # 額〜鼻筋の明るい部分
    if in_ell(x, y, 30, 31, 5, 7):
        base = 'a'
    return base

def hoodie_shader(x, y):
    base = 'd'
    if x < CX - 12 or x > CX + 12:
        base = 'D'
    if y > 74:
        base = 'D'
    if abs(x - CX) < 3:
        base = 'l'  # 中央のハイライト（襟元）
    return base

# ---- 目・口・アクセサリ ---------------------------------------------------

def draw_eye(g, ex, ey, style):
    # 白目
    fill_ell(g, ex, ey, 4.2, 5.2, lambda x, y: 'w')
    if style in ('open', 'sparkle'):
        # 虹彩
        fill_ell(g, ex, ey + 0.5, 3.0, 4.0, lambda x, y: 'I')
        fill_ell(g, ex, ey + 1.0, 2.1, 3.0, lambda x, y: 'i')
        # 瞳孔
        fill_ell(g, ex, ey + 1.0, 1.1, 1.7, lambda x, y: 'e')
        # ハイライト
        put(g, ex - 1, ey - 1, 'h'); put(g, ex - 1.5, ey - 1.5, 'h')
        if style == 'sparkle':
            put(g, ex + 1.5, ey + 2, 'h')
        # 上まつげ
        for dx in range(-4, 5):
            put(g, ex + dx, ey - 4 + (abs(dx) // 3), 'k')
        put(g, ex - 5, ey - 3, 'k'); put(g, ex + 5, ey - 2, 'k')
    elif style == 'happy':  # ^ ^ 閉じた笑い目
        for dx in range(-4, 1):
            put(g, ex + dx, ey + 1 + dx // 2, 'k')
        for dx in range(0, 5):
            put(g, ex + dx, ey + 1 - dx // 2, 'k')
        for dx in range(-4, 5):
            put(g, ex + dx, ey + 2 + (abs(dx) // 3), 'k')
        # 白目消して肌に戻す
        fill_ell(g, ex, ey, 4.0, 4.5, lambda x, y: None if (y > ey + 2 or y < ey - 3) else 'A', over={'w'})
    elif style == 'tired':  # 半目（気だるげ）
        fill_ell(g, ex, ey + 1, 3.0, 3.4, lambda x, y: 'I')
        fill_ell(g, ex, ey + 1.5, 2.1, 2.4, lambda x, y: 'i')
        fill_ell(g, ex, ey + 1.5, 1.0, 1.3, lambda x, y: 'e')
        put(g, ex - 1, ey, 'h')
        # 上まぶたを下げる
        for dy in range(-5, 0):
            for dx in range(-5, 6):
                if in_ell(x=ex + dx, y=ey + dy, cx=ex, cy=ey, rx=4.4, ry=5.4):
                    put(g, ex + dx, ey + dy, 'A' if dy < -1 else 'k')
        for dx in range(-4, 5):
            put(g, ex + dx, ey - 1, 'k')
        # 目の下のクマ
        for dx in range(-3, 4):
            put(g, ex + dx, ey + 5, 's')

def draw_brow(g, ex, ey, style):
    yoff = -7
    if style == 'worried':
        for dx in range(-3, 4):
            put(g, ex + dx, ey + yoff + (dx + 3) // 3, 'G')
    else:
        for dx in range(-3, 4):
            put(g, ex + dx, ey + yoff, 'G')

def draw_mouth(g, style):
    mx, my = 32, 52
    if style == 'big':  # にっこり開いた笑顔（‿）：中央が下・口角が上
        for dx in range(-4, 5):
            yo = my - abs(dx) // 2
            put(g, mx + dx, yo, 'm')
            put(g, mx + dx, yo + 1, 'm')  # 厚み
    elif style == 'smile':  # やさしい笑み
        for dx in range(-3, 4):
            put(g, mx + dx, my - abs(dx) // 2, 'm')
    elif style == 'flat':
        for dx in range(-2, 3):
            put(g, mx + dx, my, 'm')
    elif style == 'sad':  # への字（∩）：中央が上・口角が下
        for dx in range(-3, 4):
            put(g, mx + dx, my + abs(dx) // 2, 'm')

def draw_cigarette(g):
    # 口の右にくわえタバコ＋煙
    for dx in range(0, 9):
        put(g, 34 + dx, 51, 'c')
        put(g, 34 + dx, 52, 'c')
    put(g, 42, 51, 'r'); put(g, 42, 52, 'r')  # 火種
    # 煙
    path = [(42, 48), (43, 44), (41, 40), (43, 36), (41, 32), (43, 28)]
    for (sx, sy) in path:
        put(g, sx, sy, 'o'); put(g, sx + 1, sy, 'o')

def draw_tear(g, ex, ey):
    for dy in range(0, 6):
        put(g, ex, ey + 4 + dy, 't')

def draw_sparkle(g):
    for (sx, sy, ch) in [(12, 18, 'q'), (52, 20, 'q'), (10, 40, 'q'), (55, 44, 'q')]:
        put(g, sx, sy, ch)
        put(g, sx - 1, sy, ch); put(g, sx + 1, sy, ch)
        put(g, sx, sy - 1, ch); put(g, sx, sy + 1, ch)

# ---- 全体の組み立て -------------------------------------------------------

def outline(g):
    src = [row[:] for row in g]
    for y in range(H):
        for x in range(W):
            if src[y][x] != '.':
                continue
            near = False
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < W and 0 <= yy < H and src[yy][xx] not in ('.', 'k', 'o', 'q'):
                        near = True
            if near:
                g[y][x] = 'k'

def build(mood):
    g = blank()

    # しっぽ（右下、金髪と同色）
    tail = [(50, 74, 5), (54, 70, 5), (57, 65, 4), (58, 59, 4), (56, 54, 3), (52, 51, 3)]
    for (tx, ty, tr) in tail:
        fill_ell(g, tx, ty, tr, tr, hair_shader)

    # 後ろ髪（頭より大きく、下に伸ばす）
    fill_ell(g, 32, 33, 20, 23, hair_shader)
    for y in range(30, 68):
        w = 20 - (y - 30) * 0.15
        for x in range(W):
            if abs(x - CX) < w and (x < CX - 10 or x > CX + 10):
                g[y][x] = hair_shader(x, y)

    # パーカー（オーバーサイズ・肩）
    fill_ell(g, 32, 78, 24, 12, hoodie_shader)
    for y in range(62, H):
        for x in range(W):
            if in_ell(x, y, 32, 74, 22, 16) and y >= 62:
                g[y][x] = hoodie_shader(x, y)
    # 首
    for y in range(56, 64):
        for x in range(28, 36):
            g[y][x] = 's' if x < 30 else 'A'

    # 顔
    fill_ell(g, 32, 36, 12, 14, skin_shader)

    # 猫耳
    tri(g, 21, 3, 14, 22, 30, 20, hair_shader)
    tri(g, 42, 3, 34, 20, 50, 22, hair_shader)
    tri(g, 21, 8, 17, 20, 27, 19, lambda x, y: 'p')
    tri(g, 42, 8, 37, 19, 47, 20, lambda x, y: 'p')

    # 前髪（額を覆う。目の少し上まで）
    for y in range(14, 34):
        for x in range(W):
            if in_ell(x, y, 32, 30, 15, 18) and y < 33:
                # 中央分け目のすき間を少し残す
                if not (abs(x - CX) < 1.5 and 20 < y < 30):
                    g[y][x] = hair_shader(x, y)
    # サイドの毛束（頬の横）
    for y in range(20, 50):
        for x in range(W):
            if (18 < x < 24 or 40 < x < 46) and in_ell(x, y, 32, 34, 17, 20):
                g[y][x] = hair_shader(x, y)

    # 目・眉・口
    LE, RE = 25, 39
    EY = 38
    styles = {
        'great': ('sparkle', 'normal', 'big'),
        'good': ('open', 'normal', 'smile'),
        'worried': ('open', 'worried', 'flat'),
        'bad': ('tired', 'worried', 'sad'),
    }
    eye_style, brow_style, mouth_style = styles[mood]
    draw_brow(g, LE, EY, brow_style)
    draw_brow(g, RE, EY, brow_style)
    draw_eye(g, LE, EY, eye_style)
    draw_eye(g, RE, EY, eye_style)

    # ほっぺ
    for (bx) in (22, 42):
        fill_ell(g, bx, 45, 3, 2, lambda x, y: 'b', over={'A', 'a', 's'})

    # 鼻
    put(g, 32, 47, 's')

    draw_mouth(g, mouth_style)

    if mood == 'great':
        draw_sparkle(g)
    if mood == 'worried':
        for dx in range(0, 3):
            put(g, 46 + dx, 30 + dx, 't')  # 汗
    if mood == 'bad':
        draw_cigarette(g)
        draw_tear(g, LE, EY)
        draw_tear(g, RE, EY)

    outline(g)
    return [''.join(row) for row in g]

# ---- Dart 出力 -----------------------------------------------------------

def emit():
    moods = ['great', 'good', 'worried', 'bad']
    grids = {m: build(m) for m in moods}
    for m in moods:
        assert len(grids[m]) == H, (m, len(grids[m]))
        for r in grids[m]:
            assert len(r) == W, (m, len(r))

    lines = []
    lines.append('/// 猫耳の女の子「ヤメにゃん」の高解像度ドット絵データ。')
    lines.append('///')
    lines.append('/// 画像ファイルは使わず、%dx%d の文字グリッドをコードで描画する。' % (W, H))
    lines.append('/// grids は tool（Python）で手続き生成して焼き込んだもの。')
    lines.append('library;')
    lines.append('')
    lines.append('enum Mood { great, good, worried, bad }')
    lines.append('')
    lines.append('class CatArt {')
    lines.append('  const CatArt._();')
    lines.append('')
    lines.append('  static const Map<Mood, List<String>> _grids = <Mood, List<String>>{')
    for m in moods:
        lines.append('    Mood.%s: <String>[' % m)
        for r in grids[m]:
            lines.append("      '%s'," % r)
        lines.append('    ],')
    lines.append('  };')
    lines.append('')
    lines.append('  static List<String> forMood(Mood mood) => _grids[mood]!;')
    lines.append('')
    lines.append('  static String message(Mood mood) {')
    lines.append('    switch (mood) {')
    lines.append("      case Mood.great:")
    lines.append("        return '今日はまだゼロ本！さいこうにゃ〜！';")
    lines.append("      case Mood.good:")
    lines.append("        return 'へらせてるね、えらいにゃ〜！';")
    lines.append("      case Mood.worried:")
    lines.append("        return 'んー、ちょっと多いかも。深呼吸しよ？';")
    lines.append("      case Mood.bad:")
    lines.append("        return 'ゴホッ…むりしないで休もうにゃ。また一緒にがんばろ？';")
    lines.append('    }')
    lines.append('  }')
    lines.append('')
    lines.append('  static String statusLabel(Mood mood) {')
    lines.append('    switch (mood) {')
    lines.append("      case Mood.great:")
    lines.append("        return 'ぜっこうちょう！';")
    lines.append("      case Mood.good:")
    lines.append("        return 'いいペース';")
    lines.append("      case Mood.worried:")
    lines.append("        return 'ちょっと注意';")
    lines.append("      case Mood.bad:")
    lines.append("        return 'ひとやすみ';")
    lines.append('    }')
    lines.append('  }')
    lines.append('}')
    lines.append('')
    out = '\n'.join(lines)
    with open('/home/user/Nine-Solo/lib/models/cat_pixels.dart', 'w') as f:
        f.write(out)
    print('wrote cat_pixels.dart  (%d moods, %dx%d)' % (len(moods), W, H))

if __name__ == '__main__':
    emit()
