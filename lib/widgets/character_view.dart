import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/cat.dart';

/// ヤメにゃんのイラスト表示。
///
/// - きせかえ(outfit): シャツ色ちがいの画像 3種
/// - ふんいき(ambiance): カラーフィルタで 夜 / 夕暮れ / 深夜
/// - 気分(mood): きらきら・ほっぺ・あせ・なみだ等のエフェクトを重ねる
class CharacterView extends StatelessWidget {
  const CharacterView({
    super.key,
    required this.mood,
    this.height = 240,
    this.outfit = 0,
    this.ambiance = 0,
  });

  final Mood mood;
  final double height;
  final int outfit;
  final int ambiance;

  // 画像 (624x968) のアスペクト比
  static const double _aspect = 624 / 968;

  static const List<String> outfitAssets = <String>[
    'assets/images/yamenyan.png',
    'assets/images/yamenyan_wine.png',
    'assets/images/yamenyan_olive.png',
  ];
  static const List<String> outfitLabels = <String>['グレー', 'レッド', 'オリーブ'];
  static const List<String> ambianceLabels = <String>['よる', 'ゆうぐれ', 'しんや'];

  static const List<List<double>> _ambianceMatrix = <List<double>>[
    // よる(そのまま)
    <double>[
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, 1, 0,
    ],
    // ゆうぐれ(あたたかく)
    <double>[
      1.15, 0, 0, 0, 10, //
      0, 1.02, 0, 0, 0, //
      0, 0, 0.85, 0, -8, //
      0, 0, 0, 1, 0,
    ],
    // しんや(あおく・くらく)
    <double>[
      0.82, 0, 0, 0, -6, //
      0, 0.88, 0, 0, -2, //
      0, 0, 1.12, 0, 12, //
      0, 0, 0, 1, 0,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final double width = height * _aspect;
    final int o = outfit.clamp(0, outfitAssets.length - 1);
    final int a = ambiance.clamp(0, _ambianceMatrix.length - 1);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColorFiltered(
              colorFilter: ColorFilter.matrix(_ambianceMatrix[a]),
              child: Image.asset(outfitAssets[o], fit: BoxFit.cover),
            ),
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

  // 顔まわりの相対座標(画像 624x968 基準)
  static const Offset _cheekL = Offset(0.465, 0.435);
  static const Offset _cheekR = Offset(0.60, 0.425);
  static const Offset _eyeL = Offset(0.475, 0.395);
  static const Offset _temple = Offset(0.665, 0.28);

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(Offset f) => Offset(f.dx * size.width, f.dy * size.height);

    switch (mood) {
      case Mood.great:
        _blush(canvas, at(_cheekL), at(_cheekR), size, strong: true);
        _sparkle(canvas, Offset(size.width * 0.12, size.height * 0.06), 9);
        _sparkle(canvas, Offset(size.width * 0.06, size.height * 0.16), 6);
        _sparkle(canvas, Offset(size.width * 0.90, size.height * 0.62), 7);
        break;
      case Mood.good:
        _blush(canvas, at(_cheekL), at(_cheekR), size, strong: false);
        break;
      case Mood.worried:
        _sweatDrop(canvas, at(_temple), size);
        break;
      case Mood.bad:
        _tear(canvas, at(_eyeL), size);
        _vignette(canvas, size);
        break;
      case Mood.calm:
        _calmGlow(canvas, size);
        break;
    }
  }

  void _blush(Canvas canvas, Offset l, Offset r, Size size,
      {required bool strong}) {
    final Paint p = Paint()
      ..color = Color.fromRGBO(225, 105, 105, strong ? 0.45 : 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final double rr = size.height * 0.016;
    canvas.drawOval(
        Rect.fromCenter(center: l, width: rr * 2.6, height: rr * 1.5), p);
    canvas.drawOval(
        Rect.fromCenter(center: r, width: rr * 2.6, height: rr * 1.5), p);
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

  void _sweatDrop(Canvas canvas, Offset c, Size size) {
    final double k = size.height / 240;
    final Paint p = Paint()..color = const Color(0xCC7FC1EC);
    final Path path = Path()
      ..moveTo(c.dx, c.dy - 8 * k)
      ..quadraticBezierTo(c.dx + 6 * k, c.dy + 2 * k, c.dx, c.dy + 6 * k)
      ..quadraticBezierTo(c.dx - 6 * k, c.dy + 2 * k, c.dx, c.dy - 8 * k)
      ..close();
    canvas.drawPath(path, p);
  }

  void _tear(Canvas canvas, Offset eye, Size size) {
    // 目の下からつたうなみだ
    final Paint p = Paint()
      ..color = const Color(0xAA9FD4F2)
      ..strokeWidth = size.width * 0.012
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      eye,
      Offset(eye.dx - size.width * 0.008, eye.dy + size.height * 0.045),
      p,
    );
    canvas.drawCircle(
      Offset(eye.dx - size.width * 0.008, eye.dy + size.height * 0.05),
      size.width * 0.010,
      Paint()..color = const Color(0xCC9FD4F2),
    );
  }

  void _vignette(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint p = Paint()
      ..shader = ui.Gradient.radial(
        rect.center,
        size.height * 0.62,
        <Color>[const Color(0x00000000), const Color(0x59000000)],
        <double>[0.62, 1.0],
      );
    canvas.drawRect(rect, p);
  }

  void _calmGlow(Canvas canvas, Size size) {
    // 深呼吸中のおだやかな光
    final Rect rect = Offset.zero & size;
    final Paint p = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.42),
        size.height * 0.55,
        <Color>[const Color(0x2699C7EE), const Color(0x00000000)],
      );
    canvas.drawRect(rect, p);
  }

  @override
  bool shouldRepaint(covariant _MoodFxPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
