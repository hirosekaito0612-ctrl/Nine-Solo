import 'package:flutter_test/flutter_test.dart';
import 'package:nine_solo/models/cat_pixels.dart';
import 'package:nine_solo/models/quit_data.dart';

QuitData _sample() => QuitData(
      onboarded: true,
      baseline: 10,
      pricePerPack: 500,
      cigsPerPack: 20,
      startDate: QuitData.today(),
      counts: <String, int>{},
    );

void main() {
  group('CatArt', () {
    test('全ての気分でドット絵は64x80である', () {
      for (final Mood m in Mood.values) {
        final List<String> g = CatArt.forMood(m);
        expect(g.length, 80, reason: '$m の行数');
        for (final String row in g) {
          expect(row.length, 64, reason: '$m の行 "$row"');
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
  });
}
