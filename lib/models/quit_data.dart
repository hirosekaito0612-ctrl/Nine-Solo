import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'cat.dart';

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
  Map<String, int> resisted; // 日付 -> 我慢できた回数
  int outfit; // きせかえ 0=グレー 1=レッド 2=オリーブ
  int ambiance; // ふんいき 0=よる 1=ゆうぐれ 2=しんや

  QuitData({
    required this.onboarded,
    required this.baseline,
    required this.pricePerPack,
    required this.cigsPerPack,
    required this.startDate,
    required this.counts,
    required this.resisted,
    this.outfit = 0,
    this.ambiance = 0,
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

  int get todayResisted => resisted[today()] ?? 0;

  /// 「吸いたいのを我慢できた」回数の累計。
  int get totalResisted =>
      resisted.values.fold(0, (int sum, int v) => sum + v);

  /// 直近 [days] 日分の記録を古い順に返す（今日を含む）。
  List<DayRecord> recentDays(int days) {
    final List<DayRecord> result = <DayRecord>[];
    final DateTime now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final DateTime d = DateTime(now.year, now.month, now.day - i);
      final String key = fmt(d);
      result.add(DayRecord(
        date: d,
        count: counts[key] ?? 0,
        resisted: resisted[key] ?? 0,
        beforeStart: key.compareTo(startDate) < 0,
      ));
    }
    return result;
  }

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

  Future<void> addResisted() async {
    final String k = today();
    resisted[k] = (resisted[k] ?? 0) + 1;
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
      resisted: _decode(p.getString('resisted')),
      outfit: p.getInt('outfit') ?? 0,
      ambiance: p.getInt('ambiance') ?? 0,
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
    await p.setString('resisted', jsonEncode(resisted));
    await p.setInt('outfit', outfit);
    await p.setInt('ambiance', ambiance);
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
    resisted = <String, int>{};
    outfit = 0;
    ambiance = 0;
  }

  static Map<String, int> _decode(String? s) {
    if (s == null || s.isEmpty) return <String, int>{};
    final Map<String, dynamic> m = jsonDecode(s) as Map<String, dynamic>;
    return m.map((String k, dynamic v) => MapEntry(k, (v as num).toInt()));
  }
}

/// 履歴表示用の1日分の記録。
class DayRecord {
  const DayRecord({
    required this.date,
    required this.count,
    required this.resisted,
    required this.beforeStart,
  });

  final DateTime date;
  final int count; // 吸った本数
  final int resisted; // 我慢できた回数
  final bool beforeStart; // 記録開始日より前かどうか
}
