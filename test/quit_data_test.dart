import 'package:flutter_test/flutter_test.dart';
import 'package:nine_solo/models/achievements.dart';
import 'package:nine_solo/models/cat_pixels.dart';
import 'package:nine_solo/models/quit_data.dart';

QuitData _sample() => QuitData(
      onboarded: true,
      baseline: 10,
      pricePerPack: 500,
      cigsPerPack: 20,
      startDate: QuitData.today(),
      counts: <String, int>{},
      resisted: <String, int>{},
    );

void main() {
  group('CatArt', () {
    test('全ての気分でドット絵は16x16である', () {
      for (final Mood m in Mood.values) {
        final List<String> g = CatArt.forMood(m);
        expect(g.length, 16, reason: '$m の行数');
        for (final String row in g) {
          expect(row.length, 16, reason: '$m の行 "$row"');
        }
      }
    });

    test('全ての気分でセリフとラベルが空でない', () {
      for (final Mood m in Mood.values) {
        expect(CatArt.message(m).isNotEmpty, isTrue);
        expect(CatArt.statusLabel(m).isNotEmpty, isTrue);
      }
    });
  });

  group('QuitData.mood', () {
    test('今日の本数で気分が変わる', () {
      final QuitData d = _sample();
      final String today = QuitData.today();

      expect(d.mood, Mood.great); // 0本

      d.counts[today] = 2; // 20%
      expect(d.mood, Mood.good);

      d.counts[today] = 5; // 50%
      expect(d.mood, Mood.worried);

      d.counts[today] = 9; // 90%
      expect(d.mood, Mood.bad);
    });
  });

  group('QuitData 集計', () {
    test('連続ゼロ本日数は今日吸うと0になる', () {
      final QuitData d = _sample();
      expect(d.smokeFreeStreak, 1); // 今日まだ0本
      d.counts[QuitData.today()] = 1;
      expect(d.smokeFreeStreak, 0);
    });

    test('我慢した本数と節約金額', () {
      final QuitData d = _sample();
      d.counts[QuitData.today()] = 4; // 目安10に対し6本我慢
      expect(d.cigarettesAvoided, 6);
      // 1本 = 500 / 20 = 25円 => 6本で150円
      expect(d.moneySaved, closeTo(150, 0.001));
    });

    test('がまんできた回数の累計', () {
      final QuitData d = _sample();
      expect(d.totalResisted, 0);
      expect(d.todayResisted, 0);

      d.resisted[QuitData.today()] = 3;
      d.resisted['2000-01-01'] = 2;
      expect(d.todayResisted, 3);
      expect(d.totalResisted, 5);
    });

    test('recentDays は指定日数分を古い順に返す', () {
      final QuitData d = _sample();
      final String today = QuitData.today();
      d.counts[today] = 2;
      d.resisted[today] = 1;

      final List<DayRecord> records = d.recentDays(14);
      expect(records.length, 14);
      expect(QuitData.fmt(records.last.date), today); // 末尾が今日
      expect(records.last.count, 2);
      expect(records.last.resisted, 1);
      expect(records.last.beforeStart, isFalse);
      // 開始日（今日）より前の日は beforeStart になる
      expect(records.first.beforeStart, isTrue);
      // 日付は1日ずつ増えている
      for (int i = 1; i < records.length; i++) {
        expect(
          records[i].date.difference(records[i - 1].date).inDays,
          1,
          reason: '${records[i - 1].date} -> ${records[i].date}',
        );
      }
    });
  });

  group('Achievements', () {
    test('初期状態では「はじめの一歩」と「ゼロの日」だけアンロック', () {
      final QuitData d = _sample();
      final Map<String, bool> byId = <String, bool>{
        for (final Achievement a in Achievements.evaluate(d)) a.id: a.unlocked,
      };
      expect(byId['first_step'], isTrue);
      expect(byId['zero_1'], isTrue); // 今日まだ0本なので連続1日
      expect(byId['zero_3'], isFalse);
      expect(byId['resist_1'], isFalse);
      expect(byId['save_1000'], isFalse);
    });

    test('がまん・節約系の実績が条件でアンロックされる', () {
      final QuitData d = _sample();
      d.resisted[QuitData.today()] = 10;
      // 我慢100本 => 節約 100 * 25円 = 2500円
      d.startDate = '2000-01-01';
      for (int i = 1; i <= 10; i++) {
        d.counts['2000-01-${i.toString().padLeft(2, '0')}'] = 0; // 10日 x 10本我慢
      }

      final Map<String, bool> byId = <String, bool>{
        for (final Achievement a in Achievements.evaluate(d)) a.id: a.unlocked,
      };
      expect(byId['resist_1'], isTrue);
      expect(byId['resist_10'], isTrue);
      expect(byId['avoid_100'], isTrue);
      expect(byId['save_1000'], isTrue);
      expect(byId['save_10000'], isFalse);
      expect(Achievements.unlockedCount(d), greaterThanOrEqualTo(6));
    });

    test('実績のIDは重複しない', () {
      final List<Achievement> items = Achievements.evaluate(_sample());
      final Set<String> ids =
          items.map((Achievement a) => a.id).toSet();
      expect(ids.length, items.length);
    });
  });
}
