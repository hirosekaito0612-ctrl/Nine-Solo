# ヤメにゃん 🐾🚭

ドット絵ネコの相棒「**ヤメにゃん**」と一緒にがんばる、**禁煙サポートアプリ**です。
Flutter 製なので iPhone / Android の両方で動きます。

## できること

- 🐱 **オンボーディング**: 最初に「1日の平均タバコ本数」と「1箱の値段」を登録
- 📊 **今日の本数を記録**: ボタンで簡単にカウント（取り消しもOK）
- 😺 **キャラの反応が変わる**: 今日の本数に応じてヤメにゃんの表情とセリフが変化
  | 状態 | 条件（目安比） | ヤメにゃん |
  | --- | --- | --- |
  | ぜっこうちょう | 0本 | 満面の笑み＋きらきら🌱 |
  | いいペース | 〜34% | にっこり |
  | ちょっと注意 | 〜75% | あせあせ💦 |
  | ひとやすみ | 76%〜 | なみだ＋けむり |
- 🔥 **連続ゼロ本日数** / 🫧 **我慢した本数** / 💰 **節約できた金額** を自動集計
- 💾 データは端末内（SharedPreferences）に保存

## キャラクターについて

ヤメにゃんは、このアプリのために描き下ろした**完全オリジナルのドット絵キャラクター**です。
画像ファイルは使わず、`lib/models/cat_pixels.dart` の 16×16 の文字グリッドを
`CustomPainter`（`lib/widgets/pixel_cat.dart`）でリアルタイムに描画しています。
そのため外部アセットが不要で、どの解像度でもドットがくっきり表示されます。
既存キャラクターの画像・データは一切使用していません。

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

ドット絵が全気分で 16×16 になっているか、気分判定・集計ロジックが正しいかを検証します。

## 構成

```
lib/
  main.dart                     エントリ / テーマ / 画面分岐
  models/
    cat_pixels.dart             ヤメにゃんのドット絵＆セリフ
    quit_data.dart             データ保存・集計・気分判定ロジック
  screens/
    onboarding_screen.dart     初回設定
    home_screen.dart           メイン画面
  widgets/
    pixel_cat.dart             ドット絵描画
    speech_bubble.dart         ふきだし
    stat_tile.dart             統計カード
test/
  quit_data_test.dart          ロジック＆ドット絵の単体テスト
```
