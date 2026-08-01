import 'package:flutter/material.dart';

import '../models/achievements.dart';
import '../models/quit_data.dart';

/// 実績（バッジ）の一覧画面。
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key, required this.data});

  final QuitData data;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final List<Achievement> items = Achievements.evaluate(data);
    final int unlocked = items.where((Achievement a) => a.unlocked).length;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('じっせき', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: <Widget>[
            Center(
              child: Text(
                '$unlocked / ${items.length} こ かくとく！',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: items.isEmpty ? 0 : unlocked / items.length,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                color: const Color(0xFF3BB27A),
              ),
            ),
            const SizedBox(height: 20),
            ...items.map((Achievement a) {
              final Color color = a.unlocked ? a.color : cs.outlineVariant;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: a.unlocked
                      ? a.color.withOpacity(0.10)
                      : cs.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.15),
                      ),
                      child: Icon(
                        a.unlocked ? a.icon : Icons.lock_outline,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            a.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: a.unlocked ? null : cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            a.description,
                            style: TextStyle(
                                fontSize: 12, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (a.unlocked)
                      const Icon(Icons.check_circle,
                          color: Color(0xFF3BB27A), size: 20),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
