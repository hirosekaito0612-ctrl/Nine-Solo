import 'package:flutter/material.dart';

import '../models/cat_pixels.dart';
import '../widgets/pixel_cat.dart';

/// 吸いたくなったときの深呼吸モード。
///
/// ヤメにゃんと一緒に「4秒すって4秒はく」を繰り返す。
/// 「がまんできた！」で閉じると true を返し、呼び出し側が記録する。
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  static const int _targetBreaths = 4;

  late final AnimationController _breath;
  int _completedBreaths = 0;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 吸う4秒 + 戻り(はく)4秒
    );
    _breath.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _breath.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _completedBreaths++;
        if (_completedBreaths < _targetBreaths) {
          _breath.forward();
        }
      }
      if (mounted) setState(() {}); // すって/はいての表示を更新
    });
    _breath.forward();
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  bool get _done => _completedBreaths >= _targetBreaths;

  String get _phaseText {
    if (_done) return 'よくがんばったにゃ！';
    return _breath.status == AnimationStatus.reverse
        ? 'はいて〜…'
        : 'すって〜…';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    const Color accent = Color(0xFF4C8DD6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('深呼吸タイム',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: <Widget>[
              Text(
                '吸いたい気持ちは3分でおさまるにゃ。\nいっしょにゆっくり呼吸しよ？',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const Spacer(),

              // 呼吸に合わせてふくらむヤメにゃん
              AnimatedBuilder(
                animation: _breath,
                builder: (BuildContext context, Widget? child) {
                  final double scale = 1.0 + 0.12 * _breath.value;
                  return Transform.scale(scale: scale, child: child);
                },
                child: const PixelCat(mood: Mood.calm, size: 200),
              ),
              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _phaseText,
                  key: ValueKey<String>(_phaseText),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _done ? const Color(0xFF3BB27A) : accent,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              // 呼吸の回数インジケータ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(_targetBreaths, (int i) {
                  final bool filled = i < _completedBreaths;
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? accent : accent.withOpacity(0.2),
                    ),
                  );
                }),
              ),
              const Spacer(),

              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.favorite),
                label: const Text('がまんできた！'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3BB27A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('もどる',
                    style: TextStyle(color: cs.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
