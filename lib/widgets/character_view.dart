import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/cat.dart';

/// ヤメにゃんのイラスト表示。
///
/// `assets/images/yamenyan.png` を角丸カードで表示し、
/// 気分に応じたエフェクト（きらきら・あせ・けむり）を上に重ねる。
class CharacterView extends StatelessWidget {
  const CharacterView({super.key, required this.mood, this.height = 220});

  final Mood mood;
  final double height;

  // 画像 (414x404) のアスペクト比
  static const double _aspect = 414 / 404;

  @override
  Widget build(BuildContext context) {
    final double width = height * _aspect;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset('assets/images/yamenyan.png', fit: BoxFit.cover),
            CustomPaint(painter: _MoodFxPainter(mood)),
          ],
        ),
      ),
    );
  }
}

class _MoodFxPainter extends CustomPainter {
  _MoodFxPainter(this.mood);

  final Mood mood;

  @override
  void paint(Canvas canvas, Size size) {
    switch (mood) {
      case Mood.great:
        _sparkle(canvas, Offset(size.width * 0.10, size.height * 0.14), 9);
        _sparkle(canvas, Offset(size.width * 0.88, size.height * 0.10), 7);
        _sparkle(canvas, Offset(size.width * 0.94, size.height * 0.30), 5);
        break;
      case Mood.worried:
        _sweatDrop(canvas, Offset(size.width * 0.80, size.height * 0.16));
        break;
      case Mood.bad:
        // 口元のタバコの先からけむり
        _smoke(canvas, Offset(size.width * 0.42, size.height * 0.66), size);
        break;
      case Mood.good:
      case Mood.calm:
        break;
    }
  }

  void _sparkle(Canvas canvas, Offset c, double r) {
    final Paint p = Paint()..color = const Color(0xDDFFD960);
    final Path path = Path();
    for (int i = 0; i < 4; i++) {
      final double a = i * math.pi / 2;
      path.moveTo(c.dx, c.dy);
      path.lineTo(
        c.dx + math.cos(a - 0.25) * r * 0.3,
        c.dy + math.sin(a - 0.25) * r * 0.3,
      );
      path.lineTo(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      path.lineTo(
        c.dx + math.cos(a + 0.25) * r * 0.3,
        c.dy + math.sin(a + 0.25) * r * 0.3,
      );
      path.close();
    }
    canvas.drawPath(path, p);
  }

  void _sweatDrop(Canvas canvas, Offset c) {
    final Paint p = Paint()..color = const Color(0xCC7FC1EC);
    final Path path = Path()
      ..moveTo(c.dx, c.dy - 8)
      ..quadraticBezierTo(c.dx + 6, c.dy + 2, c.dx, c.dy + 6)
      ..quadraticBezierTo(c.dx - 6, c.dy + 2, c.dx, c.dy - 8)
      ..close();
    canvas.drawPath(path, p);
  }

  void _smoke(Canvas canvas, Offset from, Size size) {
    final Paint p = Paint()..color = const Color(0x66C9C4BE);
    double x = from.dx;
    double y = from.dy;
    double r = 3;
    for (int i = 0; i < 6; i++) {
      canvas.drawCircle(Offset(x, y), r, p);
      y -= size.height * 0.07;
      x += (i.isEven ? -1 : 1) * size.width * 0.02;
      r += 1.6;
    }
  }

  @override
  bool shouldRepaint(covariant _MoodFxPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
