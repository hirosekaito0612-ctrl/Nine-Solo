import 'package:flutter/material.dart';

import '../models/quit_data.dart';

/// 直近14日間の記録をグラフとリストで表示する画面。
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.data});

  static const int _days = 14;

  final QuitData data;

  Color _barColor(int count) {
    if (count == 0) return const Color(0xFF3BB27A);
    final int b = data.baseline <= 0 ? 1 : data.baseline;
    final double ratio = count / b;
    if (ratio <= 0.34) return const Color(0xFF6FBF73);
    if (ratio <= 0.75) return const Color(0xFFE0A72E);
    return const Color(0xFFD9695A);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final List<DayRecord> records = data.recentDays(_days);
    final int totalCount =
        records.fold(0, (int sum, DayRecord r) => sum + r.count);
    final int totalResisted =
        records.fold(0, (int sum, DayRecord r) => sum + r.resisted);
    final int maxCount = records.fold(
        1, (int m, DayRecord r) => r.count > m ? r.count : m);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('きろく', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: <Widget>[
            // 14日間のまとめ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _SummaryItem(
                      label: '14日間で吸った',
                      value: '$totalCount本',
                      color: const Color(0xFFD9695A),
                    ),
                  ),
                  Container(width: 1, height: 36, color: cs.outlineVariant),
                  Expanded(
                    child: _SummaryItem(
                      label: 'がまんできた',
                      value: '$totalResisted回',
                      color: const Color(0xFF4C8DD6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 棒グラフ
            Text('毎日の本数',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: records.map((DayRecord r) {
                  final double h =
                      r.count == 0 ? 4 : 8 + 112 * (r.count / maxCount);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          if (r.count > 0)
                            Text('${r.count}',
                                style: TextStyle(
                                    fontSize: 9, color: cs.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Container(
                            height: h,
                            decoration: BoxDecoration(
                              color: r.beforeStart
                                  ? cs.outlineVariant
                                  : _barColor(r.count),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('${r.date.day}',
                              style: TextStyle(
                                  fontSize: 9, color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '緑=ゼロ本の日・黄=ちょっと注意・赤=多めの日',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 20),

            // 日別リスト（新しい順）
            Text('日別のきろく',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...records.reversed.map((DayRecord r) {
              final bool zero = r.count == 0 && !r.beforeStart;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  r.beforeStart
                      ? Icons.remove
                      : zero
                          ? Icons.emoji_emotions_outlined
                          : Icons.smoking_rooms,
                  color: r.beforeStart ? cs.outlineVariant : _barColor(r.count),
                ),
                title: Text('${r.date.month}/${r.date.day}'),
                subtitle: r.resisted > 0 ? Text('がまん ${r.resisted}回') : null,
                trailing: Text(
                  r.beforeStart ? '記録前' : (zero ? 'ゼロ本！' : '${r.count}本'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        r.beforeStart ? cs.onSurfaceVariant : _barColor(r.count),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        Text(label,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
