# AppStore 申請チェックリスト

## 1. Xcode 設定

- [ ] Bundle ID: `com.alrebo92.WisdomSnap`
- [ ] Version: `1.0.0` / Build: `1`
- [ ] Deployment Target: iOS 17.0
- [ ] Signing & Capabilities: Apple Developer アカウント設定済み
- [ ] App Groups: `group.com.alrebo92.WisdomSnap` （メインアプリ + ウィジェット両方）
- [ ] Push Notifications capability 追加
- [ ] WidgetKit capability 追加

## 2. アイコン

- [ ] `AppStore/icon/AppIcon.svg` を元に 1024×1024 PNG を書き出し
- [ ] Xcode の `Assets.xcassets > AppIcon` に各サイズを設定
  - 1024×1024（AppStore用）
  - Xcode が自動生成するその他サイズ
- [ ] 透過なし、角丸なし（Xcodeが自動でマスク）

> 💡 SVGから一括生成ツール: https://appicon.co にSVGを貼り付けるとZIPで全サイズ出力

## 3. スクリーンショット

Xcode Previews で `ScreenshotPreviews.swift` を開き、以下のサイズで撮影:

| デバイス | サイズ | 必須 |
|---------|-------|------|
| iPhone 6.9" (iPhone 16 Pro Max) | 1320×2868 | ✅ |
| iPhone 6.5" (iPhone 14 Plus) | 1284×2778 | ✅ |
| iPad Pro 12.9" (6th gen) | 2048×2732 | 任意 |

撮影する5枚:
- [ ] 1枚目: キャッチコピー画面
- [ ] 2枚目: スキャン機能
- [ ] 3枚目: 提案カード
- [ ] 4枚目: 興味マップ
- [ ] 5枚目: ウィジェット

## 4. App Store Connect 入力内容

ファイル場所: `AppStore/metadata/ja/`

| 項目 | ファイル | 文字数制限 |
|------|---------|-----------|
| アプリ名 | name.txt | 30字以内 ✅ |
| サブタイトル | subtitle.txt | 30字以内 ✅ |
| 説明文 | description.txt | 4000字以内 ✅ |
| キーワード | keywords.txt | 100字以内 ✅ |
| プロモーションテキスト | promotional_text.txt | 170字以内 ✅ |
| リリースノート | release_notes.txt | 4000字以内 ✅ |

## 5. プライバシー情報（App Store Connect）

| データ種別 | 用途 | トラッキング |
|-----------|------|------------|
| 写真 | スキャン・テキスト抽出 | なし |
| 利用状況データ | 興味プロファイル生成 | なし |

プライバシーポリシーURL: 要作成（GitHub Pages 等で公開）

## 6. 審査情報

- カテゴリ: 「仕事効率化」または「ライフスタイル」
- 年齢制限: 4+
- 審査メモ:
  ```
  このアプリは写真ライブラリへのアクセスを使用して、
  ユーザーが保存したスクリーンショットからテキストを抽出します。
  Claude API（Anthropic）を使用してテキストを分析し、
  パーソナライズされた格言・習慣を提案します。
  APIキーはアプリ内に含まれており、外部送信データは
  OCRテキストのみです。
  ```

## 7. 最終ビルド確認

- [ ] Release ビルドでクラッシュしないか確認
- [ ] 実機（iPhone）で全画面動作確認
- [ ] ウィジェットが表示されるか確認
- [ ] 通知が届くか確認
- [ ] `Secrets.swift` がリリースビルドに含まれているか確認（含める必要あり）
