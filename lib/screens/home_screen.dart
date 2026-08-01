import 'package:flutter/material.dart';

import '../models/cat_pixels.dart';
import '../models/quit_data.dart';
import '../widgets/pixel_cat.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/stat_tile.dart';

/// メイン画面。ヤメにゃんと今日の本数、統計を表示する。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.data, required this.onReset});

  final QuitData data;
  final VoidCallback onReset;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  QuitData get data => widget.data;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  Color _moodColor(Mood mood, ColorScheme cs) {
    switch (mood) {
      case Mood.great:
        return const Color(0xFF3BB27A);
      case Mood.good:
        return const Color(0xFF6FBF73);
      case Mood.worried:
        return const Color(0xFFE0A72E);
      case Mood.bad:
        return const Color(0xFFD9695A);
    }
  }

  Future<void> _smoke() async {
    await data.addCigarette();
    if (mounted) setState(() {});
  }

  Future<void> _undo() async {
    await data.removeCigarette();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Mood mood = data.mood;
    final Color accent = _moodColor(mood, cs);
    final int today = data.todayCount;
    final double progress =
        data.baseline <= 0 ? 0 : (today / data.baseline).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ヤメにゃん',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '設定',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 状態バッジ
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    CatArt.statusLabel(mood),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ふわふわ動くヤメにゃん
              AnimatedBuilder(
                animation: _bob,
                builder: (BuildContext context, Widget? child) {
                  final double dy = (mood == Mood.great ? -10 : -5) * _bob.value;
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: child,
                  );
                },
                child: Center(child: PixelCat(mood: mood, size: 200)),
              ),
              const SizedBox(height: 8),

              // セリフ
              SpeechBubble(
                text: CatArt.message(mood),
                color: accent.withOpacity(0.12),
                borderColor: accent.withOpacity(0.4),
              ),
              const SizedBox(height: 24),

              // 今日の本数カード
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: <Widget>[
                    Text('今日 吸った本数',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <InlineSpan>[
                          TextSpan(
                            text: '$today',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                          TextSpan(
                            text: '  / 目安 ${data.baseline} 本',
                            style: TextStyle(
                              fontSize: 16,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: cs.surfaceContainerHighest,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: today > 0 ? _undo : null,
                            icon: const Icon(Icons.remove),
                            label: const Text('取り消し'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: _smoke,
                            icon: const Icon(Icons.smoking_rooms),
                            label: const Text('1本 吸った'),
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 統計
              Row(
                children: <Widget>[
                  Expanded(
                    child: StatTile(
                      icon: Icons.local_fire_department,
                      label: '連続ゼロ本',
                      value: '${data.smokeFreeStreak}',
                      unit: '日',
                      color: const Color(0xFFE0763B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      icon: Icons.self_improvement,
                      label: '我慢した本数',
                      value: '${data.cigarettesAvoided}',
                      unit: '本',
                      color: const Color(0xFF3BB27A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StatTile(
                icon: Icons.savings_outlined,
                label: '節約できた金額',
                value: '¥${data.moneySaved.round()}',
                unit: '',
                color: const Color(0xFF4C8DD6),
                wide: true,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '記録${data.daysSinceStart}日目',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    final TextEditingController baselineCtrl =
        TextEditingController(text: '${data.baseline}');
    final TextEditingController priceCtrl =
        TextEditingController(text: '${data.pricePerPack.round()}');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('設定',
                  style: Theme.of(ctx)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: baselineCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '1日の平均本数（目安）',
                  border: OutlineInputBorder(),
                  suffixText: '本',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '1箱の値段',
                  border: OutlineInputBorder(),
                  prefixText: '¥ ',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  data.baseline =
                      int.tryParse(baselineCtrl.text.trim()) ?? data.baseline;
                  data.pricePerPack = double.tryParse(priceCtrl.text.trim()) ??
                      data.pricePerPack;
                  await data.save();
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) setState(() {});
                },
                child: const Text('保存する'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _confirmReset(ctx),
                child: const Text('データをリセット',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmReset(BuildContext sheetContext) async {
    final bool? ok = await showDialog<bool>(
      context: sheetContext,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('リセットしますか？'),
        content: const Text('記録した本数や設定がすべて消えるにゃ。この操作は取り消せないにゃ。'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('やめる')),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('リセット'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await data.resetAll();
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      widget.onReset();
    }
  }
}
