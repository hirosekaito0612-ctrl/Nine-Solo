import 'package:flutter/material.dart';

/// 統計を表示する小さなカード。
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.wide = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Widget valueRow = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment:
          wide ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (unit.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(unit, style: TextStyle(color: cs.onSurfaceVariant)),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: wide
          ? Row(
              children: <Widget>[
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(label,
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 12)),
                      const SizedBox(height: 2),
                      valueRow,
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                Icon(icon, color: color),
                const SizedBox(height: 8),
                Text(label,
                    style:
                        TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 4),
                valueRow,
              ],
            ),
    );
  }
}
