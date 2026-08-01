/// ヤメにゃんのドット絵データ。
///
/// 画像ファイルは一切使わず、16x16 のドット（文字グリッド）をコードで描画する。
/// これにより外部アセット不要でどの端末でもクリアに表示でき、
/// 既存キャラクターの著作物にも一切依存しないオリジナルの相棒ネコになる。
///
/// 各文字は [palette] の色に対応する（'.' は透明）:
///   k=輪郭  w=体(クリーム)  p=耳/鼻ピンク  e=目  h=ハイライト
///   b=ほっぺ  m=けむり  g=きらきら  y=タバコ(黄)  t=なみだ
library;

enum Mood { great, good, worried, bad }

class CatArt {
  const CatArt._();

  /// ベースとなる素体（ふつうの顔）。全16行×16文字。
  static const List<String> _base = <String>[
    '...k........k...', // 0  耳の先
    '..kwk......kwk..', // 1
    '.kwpwk....kwpwk.', // 2  耳（内側ピンク）
    '.kwwwwwwwwwwwwk.', // 3  頭
    'kwwwwwwwwwwwwwwk', // 4
    'kwwwwwwwwwwwwwwk', // 5
    'kwweewwwwwweewwk', // 6  目
    'kwwehwwwwwwehwwk', // 7  目のハイライト
    'kwwwwwwppwwwwwwk', // 8  鼻
    'kwbwwwwkkwwwwbwk', // 9  口・ほっぺ
    'kwbwwwwwwwwwwbwk', // 10
    'kwwwwwwwwwwwwwwk', // 11
    '.kwwwwwwwwwwwwk.', // 12
    '.kwwwwwwwwwwwwk.', // 13
    '..kwwwwwwwwwwk..', // 14
    '...kkkkkkkkkk...', // 15  あご
  ];

  /// 気分ごとに、目・口などの行だけを差し替えて表情を作る。
  static List<String> forMood(Mood mood) {
    final List<String> g = List<String>.from(_base);
    switch (mood) {
      case Mood.great: // ゼロ本！ 満面の笑み＋きらきら
        g[1] = '..kwkg....gkwk..';
        g[6] = 'kwwwkwwwwwwkwwwk';
        g[7] = 'kwwkwkwwwwkwkwwk';
        g[9] = 'kwwwwwkwwkwwwwwk';
        g[10] = 'kwwwwwkkkkwwwwwk';
        break;
      case Mood.good: // 減らせてる にっこり
        g[9] = 'kwbwwwkwwkwwwbwk';
        g[10] = 'kwbwwwwkkwwwwbwk';
        break;
      case Mood.worried: // ちょっと多い 汗＋への字口
        g[4] = 'kwwwwwwwwwwwtwwk';
        g[6] = 'kwweewwwwwweewwk';
        g[7] = 'kwweewwwwwweewwk';
        g[9] = 'kwwwwwwkkwwwwwwk';
        break;
      case Mood.bad: // 吸いすぎ なみだ＋タバコ＋けむり
        g[3] = '.kwwwwwmwwwwwwk.';
        g[5] = 'kwwwwwwwmwwwwwwk';
        g[6] = 'kwweewwwwwweewwk';
        g[7] = 'kwwttwwwwwwttwwk';
        g[9] = 'kwwwwwkyykwwwwwk';
        g[10] = 'kwbwwkwwwwkwwbwk';
        break;
    }
    return g;
  }

  /// 気分に応じたヤメにゃんのセリフ。
  static String message(Mood mood) {
    switch (mood) {
      case Mood.great:
        return '今日はまだゼロ本！さいこうにゃ🌱';
      case Mood.good:
        return 'へらせてるね、えらいにゃ〜！';
      case Mood.worried:
        return 'んー、ちょっと多いかも。深呼吸しよ？';
      case Mood.bad:
        return 'ゴホッ…むりしないで休もうにゃ。また一緒にがんばろ？';
    }
  }

  /// 状態ラベル（バッジ表示用）。
  static String statusLabel(Mood mood) {
    switch (mood) {
      case Mood.great:
        return 'ぜっこうちょう！';
      case Mood.good:
        return 'いいペース';
      case Mood.worried:
        return 'ちょっと注意';
      case Mood.bad:
        return 'ひとやすみ';
    }
  }
}
