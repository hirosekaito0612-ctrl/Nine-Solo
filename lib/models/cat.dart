/// ヤメにゃんのキャラクター定義。
///
/// 見た目は `assets/images/yamenyan.png`（猫耳としっぽを描き足したイラスト）を
/// 使い、気分はセリフ・ラベル・画面上のエフェクトで表現する。
library;

enum Mood { great, good, worried, bad, calm }

class CatArt {
  const CatArt._();

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
      case Mood.calm:
        return 'すーっ…はーっ…いっしょに深呼吸するにゃ…';
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
      case Mood.calm:
        return 'しんこきゅう';
    }
  }
}
