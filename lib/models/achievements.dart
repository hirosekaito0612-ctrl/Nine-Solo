import 'package:flutter/material.dart';

import 'quit_data.dart';

/// アンロック式の実績（バッジ）。
///
/// 条件判定は [Achievements.evaluate] にまとまった純粋関数なのでテストしやすい。
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;
}

class Achievements {
  const Achievements._();

  /// 現在のデータから全実績とその達成状況を返す。
  static List<Achievement> evaluate(QuitData data) {
    final int streak = data.smokeFreeStreak;
    final int avoided = data.cigarettesAvoided;
    final double saved = data.moneySaved;
    final int resisted = data.totalResisted;

    return <Achievement>[
      Achievement(
        id: 'first_step',
        title: 'はじめの一歩',
        description: '記録をはじめた',
        icon: Icons.flag,
        color: const Color(0xFF3BB27A),
        unlocked: data.onboarded,
      ),
      Achievement(
        id: 'zero_1',
        title: 'ゼロの日',
        description: '1日ゼロ本を達成',
        icon: Icons.wb_sunny_outlined,
        color: const Color(0xFFE0A72E),
        unlocked: streak >= 1,
      ),
      Achievement(
        id: 'zero_3',
        title: '3日のカベ',
        description: '3日連続ゼロ本',
        icon: Icons.local_fire_department,
        color: const Color(0xFFE0763B),
        unlocked: streak >= 3,
      ),
      Achievement(
        id: 'zero_7',
        title: '1週間チャンピオン',
        description: '7日連続ゼロ本',
        icon: Icons.emoji_events,
        color: const Color(0xFFD9A521),
        unlocked: streak >= 7,
      ),
      Achievement(
        id: 'zero_30',
        title: 'ひと月マスター',
        description: '30日連続ゼロ本',
        icon: Icons.military_tech,
        color: const Color(0xFF8E6FD8),
        unlocked: streak >= 30,
      ),
      Achievement(
        id: 'resist_1',
        title: 'はじめてのがまん',
        description: '吸いたい気持ちに1回勝った',
        icon: Icons.self_improvement,
        color: const Color(0xFF4C8DD6),
        unlocked: resisted >= 1,
      ),
      Achievement(
        id: 'resist_10',
        title: 'がまんの達人',
        description: '吸いたい気持ちに10回勝った',
        icon: Icons.shield_outlined,
        color: const Color(0xFF4C8DD6),
        unlocked: resisted >= 10,
      ),
      Achievement(
        id: 'avoid_100',
        title: '100本のきせき',
        description: '我慢した本数が100本を超えた',
        icon: Icons.filter_vintage,
        color: const Color(0xFF3BB27A),
        unlocked: avoided >= 100,
      ),
      Achievement(
        id: 'save_1000',
        title: 'ちりつも貯金',
        description: '節約金額が¥1,000を超えた',
        icon: Icons.savings_outlined,
        color: const Color(0xFF6FBF73),
        unlocked: saved >= 1000,
      ),
      Achievement(
        id: 'save_10000',
        title: 'ごほうびチケット',
        description: '節約金額が¥10,000を超えた',
        icon: Icons.card_giftcard,
        color: const Color(0xFFD9695A),
        unlocked: saved >= 10000,
      ),
    ];
  }

  static int unlockedCount(QuitData data) =>
      evaluate(data).where((Achievement a) => a.unlocked).length;
}
