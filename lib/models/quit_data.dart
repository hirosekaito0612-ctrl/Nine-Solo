import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'cat_pixels.dart';

/// アプリの状態を保持し、端末に永続化するモデル。
///
/// SharedPreferences に保存するのは load()/save() のみで、
/// 集計や気分の判定ロジックはすべて純粋関数として書いてあるためテストしやすい。
class QuitData {
  bool onboarded;
  int baseline; // 禁煙前の1日平均本数（目安）
  double pricePerPack; // 1箱の値段（円）
  int cigsPerPack; // 1箱の本数
  String startDate; // 記録開始日 yyyy-MM-dd
  Map<String, int> counts; // 日付 -> 本数

  QuitData({
    required this.onboarded,
    required this.baseline,
    required this.pricePerPack,
    required this.cigsPerPack,
    required this.startDate,
    required this.counts,
  });

  // ---- 日付ヘルパー -------------------------------------------------------

  static String today() => fmt(DateTime.now());

  static String fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // ---- 集計・判定 ---------------------------------------------------------

  int get todayCount => counts[today()] ?? 0;

  double get pricePerCig => cigsPerPack > 0 ? pricePerPack / cigsPerPack : 0;

  /// 今日の本数と目安から、ヤメにゃんの気分を決める。
  Mood get mood {
    final int c = todayCount;
    final int b = baseline <= 0 ? 1 : baseline;
    if (c == 0) return Mood.great;
    final double ratio = c / b;
    if (ratio <= 0.34) return Mood.good;
    if (ratio <= 0.75) return Mood.worried;
    return Mood.bad;
  }

  /// 直近から連続してゼロ本だった日数。今日吸っていれば 0。
  int get smokeFreeStreak {
    int streak = 0;
    DateTime day = DateTime.now();
    for (int i = 0; i < 3650; i++) {
      final String key = fmt(day);
      if (key.compareTo(startDate) < 0) break; // 開始日より前は数えない
      final int c = counts[key] ?? 0;
      if (i == 0 && c > 0) return 0; // 今日吸っていたら連続は途切れる
      if (c == 0) {
        streak++;
      } else {
        break;
      }
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// 目安と比べて我慢できた本数の累計。
  int get cigarettesAvoided {
    int total = 0;
    counts.forEach((_, c) {
      final int a = baseline - c;
      if (a > 0) total += a;
    });
    return total;
  }

  double get moneySaved => cigarettesAvoided * pricePerCig;

  int get daysSinceStart {
    final DateTime? start = DateTime.tryParse(startDate);
    if (start == null) return 1;
    final DateTime s = DateTime(start.year, start.month, start.day);
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day).difference(s).inDays + 1;
  }

  // ---- 更新 ---------------------------------------------------------------

  Future<void> addCigarette() async {
    final String k = today();
    counts[k] = (counts[k] ?? 0) + 1;
    await save();
  }

  Future<void> removeCigarette() async {
    final String k = today();
    final int v = (counts[k] ?? 0) - 1;
    counts[k] = v < 0 ? 0 : v;
    await save();
  }

  Future<void> completeOnboarding({
    required int baseline,
    required double pricePerPack,
  }) async {
    this.baseline = baseline;
    this.pricePerPack = pricePerPack;
    onboarded = true;
    startDate = today();
    await save();
  }

  // ---- 永続化 -------------------------------------------------------------

  static Future<QuitData> load() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    return QuitData(
      onboarded: p.getBool('onboarded') ?? false,
      baseline: p.getInt('baseline') ?? 10,
      pricePerPack: p.getDouble('price_per_pack') ?? 500,
      cigsPerPack: p.getInt('cigs_per_pack') ?? 20,
      startDate: p.getString('start_date') ?? today(),
      counts: _decode(p.getString('counts')),
    );
  }

  Future<void> save() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setBool('onboarded', onboarded);
    await p.setInt('baseline', baseline);
    await p.setDouble('price_per_pack', pricePerPack);
    await p.setInt('cigs_per_pack', cigsPerPack);
    await p.setString('start_date', startDate);
    await p.setString('counts', jsonEncode(counts));
  }

  Future<void> resetAll() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.clear();
    onboarded = false;
    baseline = 10;
    pricePerPack = 500;
    cigsPerPack = 20;
    startDate = today();
    counts = <String, int>{};
  }

  static Map<String, int> _decode(String? s) {
    if (s == null || s.isEmpty) return <String, int>{};
    final Map<String, dynamic> m = jsonDecode(s) as Map<String, dynamic>;
    return m.map((String k, dynamic v) => MapEntry(k, (v as num).toInt()));
  }
}
