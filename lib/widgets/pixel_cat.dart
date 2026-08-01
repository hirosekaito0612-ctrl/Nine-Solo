import 'package:flutter/material.dart';

import '../models/cat_pixels.dart';

/// ドット絵の色定義。cat_pixels.dart の文字と対応する。
const Map<String, Color> kCatPalette = <String, Color>{
  'k': Color(0xFF2E2A2A), // 輪郭
  'w': Color(0xFFF7EFE1), // 体（クリーム）
  'p': Color(0xFFF3A6B0), // 耳・鼻のピンク
  'e': Color(0xFF35302E), // 目
  'h': Color(0xFFFFFFFF), // 目のハイライト
  'b': Color(0xFFF6B6C0), // ほっぺ
  'm': Color(0xFFB9B4AE), // けむり
  'g': Color(0xFF7BC96F), // きらきら
  'y': Color(0xFFD9B441), // タバコ
  't': Color(0xFF7FC1EC), // なみだ
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
