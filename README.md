# ヤメにゃん 🐾🚭

ネコ耳としっぽの相棒「**ヤメにゃん**」と一緒にがんばる、**禁煙サポートアプリ**です。
Flutter 製なので iPhone / Android の両方で動きます。

## できること

- 🐱 **オンボーディング**: 最初に「1日の平均タバコ本数」と「1箱の値段」を登録
- 📊 **今日の本数を記録**: ボタンで簡単にカウント（取り消しもOK）
- 😺 **キャラの反応が変わる**: 今日の本数に応じてヤメにゃんのセリフと画面エフェクトが変化
  | 状態 | 条件（目安比） | エフェクト |
  | --- | --- | --- |
  | ぜっこうちょう | 0本 | きらきら✨ |
  | いいペース | 〜34% | （なし） |
  | ちょっと注意 | 〜75% | あせ💦 |
  | ひとやすみ | 76%〜 | けむり |
- 🔥 **連続ゼロ本日数** / 🫧 **我慢した本数** / 💰 **節約できた金額** を自動集計
- 🌬️ **深呼吸モード**: 吸いたくなったら「深呼吸する」ボタン。ヤメにゃんと一緒に4秒吸って4秒吐く×4回。がまんできたら回数を記録
- 📈 **きろく画面**: 直近14日間の本数を色分け棒グラフ＋日別リストで振り返り
- 🏅 **じっせき画面**: 連続ゼロ本・がまん回数・節約金額などで10種のバッジをアンロック
- 💾 データは端末内（SharedPreferences）に保存

## キャラクターについて

ヤメにゃんの画像は `assets/images/yamenyan.png` です。
ユーザー提供のイラストをベースに、ネコ耳としっぽをスクリプトで描き足したものを使っています。
気分（Mood）はセリフ・状態バッジ・画面上のエフェクト（きらきら / あせ / けむり）で表現し、
`lib/widgets/character_view.dart` が画像表示とエフェクト描画を担当します。

## 動かし方

このリポジトリには Flutter の **ソースコード（`lib/`・`test/`・`pubspec.yaml`）** が入っています。
ネイティブのプラットフォームフォルダ（`android/` `ios/` など）は含めていないので、
初回だけ以下を実行して生成してください。

```bash
# 1. Flutter SDK を用意（https://docs.flutter.dev/get-started/install）
flutter --version

# 2. リポジトリのルートでプラットフォームフォルダを生成
flutter create --project-name nine_solo --org com.example .

# 3. 依存関係を取得
flutter pub get

# 4. 実機 / シミュレータで実行
flutter run
```

> `flutter create .` は `lib/main.dart` を上書きすることがあります。
> その場合は `git checkout lib/main.dart` で元に戻してください（本リポジトリの実装が正です）。

### テスト

```bash
flutter test
```

気分判定・集計・実績アンロックのロジックが正しいかを検証します。

## 構成

```
assets/
  images/yamenyan.png          ヤメにゃんのイラスト
lib/
  main.dart                     エントリ / テーマ / 画面分岐
  models/
    cat.dart                   Mood定義とセリフ・ラベル
    quit_data.dart             データ保存・集計・気分判定ロジック
    achievements.dart          実績（バッジ）の定義と判定
  screens/
    onboarding_screen.dart     初回設定
    home_screen.dart           メイン画面
    breathing_screen.dart      深呼吸モード（吸いたくなったとき用）
    history_screen.dart        直近14日間のグラフと日別リスト
    achievements_screen.dart   実績バッジ一覧
  widgets/
    character_view.dart        イラスト表示＋気分エフェクト
    speech_bubble.dart         ふきだし
    stat_tile.dart             統計カード
test/
  quit_data_test.dart          ロジックの単体テスト
```
