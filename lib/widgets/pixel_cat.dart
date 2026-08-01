import 'package:flutter/material.dart';

import '../models/cat_pixels.dart';

/// ドット絵の色定義。cat_pixels.dart の文字と対応する。
const Map<String, Color> kCatPalette = <String, Color>{
  'k': Color(0xFF2A211C), // 輪郭（やわらかい濃茶）
  // 金髪（明→暗）
  'y': Color(0xFFF3DE9A), // ハイライト
  'Y': Color(0xFFE4C46F), // 明
  'g': Color(0xFFC8A24E), // 中
  'G': Color(0xFF9C7A38), // 影
  // 肌
  'a': Color(0xFFF7DCC4), // ハイライト
  'A': Color(0xFFEEC5A6), // 中
  's': Color(0xFFD89E80), // 影
  'b': Color(0xFFE79A8E), // ほっぺ
  // 目
  'w': Color(0xFFF4F1EA), // 白目
  'i': Color(0xFFC79A5A), // 虹彩（明）
  'I': Color(0xFF8A5A2A), // 虹彩（暗）
  'e': Color(0xFF241C16), // 瞳孔
  'h': Color(0xFFFFFFFF), // ハイライト
  'm': Color(0xFFA65E58), // 口
  // 服（オーバーサイズ）
  'd': Color(0xFF3B3A44),
  'D': Color(0xFF2C2B34),
  'l': Color(0xFF4A4954),
  'p': Color(0xFFE7A6A6), // 猫耳の内側
  // アクセサリ
  'c': Color(0xFFEDE7DA), // タバコ
  'r': Color(0xFFE8623A), // 火種
  'o': Color(0xFFCFC9C1), // けむり
  't': Color(0xFF86C4EC), // なみだ
  'q': Color(0xFF8BD08C), // きらきら
};

/// 気分に応じたドット絵ネコを描画するウィジェット。
class PixelCat extends StatelessWidget {
  const PixelCat({super.key, required this.mood, this.size = 220});

  final Mood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CatPainter(CatArt.forMood(mood)),
        isComplex: true,
      ),
    );
  }
}

class _CatPainter extends CustomPainter {
  _CatPainter(this.grid);

  final List<String> grid;

  @override
  void paint(Canvas canvas, Size size) {
    final int rows = grid.length;
    if (rows == 0) return;
    final int cols = grid.first.length;
    final double cw = size.width / cols;
    final double ch = size.height / rows;
    final Paint paint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      final String line = grid[r];
      for (int c = 0; c < line.length; c++) {
        final Color? color = kCatPalette[line[c]];
        if (color == null) continue; // '.' などは透明
        paint.color = color;
        // わずかに重ねて描くことでドット間の隙間をなくす
        canvas.drawRect(
          Rect.fromLTWH(c * cw, r * ch, cw + 0.6, ch + 0.6),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CatPainter oldDelegate) =>
      oldDelegate.grid != grid;
}
