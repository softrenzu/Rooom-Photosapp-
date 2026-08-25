# RooomShot for iPhone

RooomShotは、iPhoneで写真を撮ると、指定した本人のGoogle Driveフォルダへ自動アップロードし、写真内の文字を端末上でOCRして検索用JSONへ整理するSwiftUIアプリです。

## 主な機能

- 撮影直後のGoogle Drive自動アップロード
- Apple Visionによる日本語・英語のオンデバイスOCR
- 保存先フォルダに `RooomShot_index.json` を自動作成
- JSONが既にある場合はDriveファイルID単位で写真情報を追加・更新
- JSONにはファイル名、撮影時刻、画像サイズ、DriveファイルID、OCRテキスト、検索用文字列を保存
- オフライン時の端末内キューと通信復帰後の再送
- 写真アップロード後にJSON更新だけ失敗した場合、写真を二重アップロードせずJSON更新のみ再試行
- 失敗時の手動再試行、送信履歴
- 3段階のJPEG画質設定
- StoreKit 2による月額500円の自動更新サブスクリプション
- 購入復元、解約状態の反映、App Storeの登録管理画面への導線
- 日本語・英語対応
- 広告、解析SDK、ROOOMTECHの中継サーバーなし
- Google Drive全体ではなく、アプリが作成したファイルだけに使える `drive.file` 権限

アプリのダウンロード、Google接続、保存先設定、履歴確認、設定画面は無料です。写真撮影、Google Driveへの自動アップロード、OCR、検索用JSONインデックス作成は月額500円のプラン登録後に利用できます。解約後もGoogle Driveへ保存済みの写真とJSONは残ります。

## 検索用JSON

保存先フォルダには `RooomShot_index.json` が1つ作成されます。写真を追加するたびに同じJSONを読み込み、DriveファイルIDをキーとして追加または更新します。

例:

```json
{
  "schemaVersion": 1,
  "updatedAt": "2026-08-20T00:00:00Z",
  "items": [
    {
      "id": "00000000-0000-0000-0000-000000000001",
      "capturedAt": "2026-08-20T00:00:00Z",
      "uploadedAt": "2026-08-20T00:00:03Z",
      "fileName": "RooomShot_20260820_090000_000000.jpg",
      "driveFileID": "...",
      "driveWebViewLink": "...",
      "mimeType": "image/jpeg",
      "folderID": "...",
      "pixelWidth": 3024,
      "pixelHeight": 4032,
      "ocrText": "物件名 Rooom House\n101号室",
      "searchText": "RooomShot_20260820_090000_000000.jpg\n物件名 Rooom House\n101号室"
    }
  ]
}
```

OCRはApple Visionを使ってiPhone上で実行し、認識のために写真をROOOMTECHのサーバーや外部AIサービスへ送りません。

## 対応環境

- iPhone / iOS 17以降
- Xcode 26以降
- Swift 5言語モード
- GoogleSignIn-iOS 9.2以降

Appleは2026年4月28日以降、App Store Connectへ送るアプリをXcode 26以降とiOS 26 SDKでビルドするよう求めています。CIも `macos-26` とXcode 26.6を固定しています。

## ローカル起動

1. XcodeGenをインストールします。
2. `Configuration/Secrets.example.xcconfig` を `Configuration/Secrets.xcconfig` へコピーします。
3. Google Cloudで発行したiOS OAuthクライアントID、逆順クライアントID、Apple Team IDを設定します。
4. `make project` を実行します。
5. `RooomShot.xcodeproj` をXcode 26で開き、実機のiPhoneを選んで実行します。

`Secrets.xcconfig` はGit管理されません。OAuthクライアントID自体は秘密鍵ではありませんが、環境ごとの設定を混在させないため分離しています。

## Google Cloud設定

1. Google Cloudプロジェクトを作成します。
2. Google Drive APIを有効にします。
3. OAuth同意画面を作成し、アプリ名、サポートメール、公開済みプライバシーポリシーを登録します。
4. スコープは `https://www.googleapis.com/auth/drive.file` だけを追加します。
5. iOS OAuthクライアントをBundle ID `com.rooomtech.rooomshot` で作成します。
6. 公開前にOAuthアプリをProductionへ切り替えます。

RooomShotはGoogle Drive直下に指定名の専用フォルダを作ります。利用者がそのフォルダをDrive内の別の場所へ移しても、フォルダIDが変わらないため保存先は維持されます。既存の任意フォルダを探索する権限は要求しません。

## ビルドと検査

```bash
make project
make test
make screenshots
make validate
```

GitHub Actionsは以下を自動実行します。

- Xcode 26での依存解決とビルド
- 単体テスト、UIテスト
- 日本語・英語の6.9インチApp Storeスクリーンショット生成
- アイコン、plist、ローカライズ、Google Drive権限の静的検査

## App Store申請

申請用の文言と回答は [app_store_submission](app_store_submission) にあります。公開用メタデータは [fastlane/metadata](fastlane/metadata) に機械投入できる形で格納しています。

署名証明書、Provisioning Profile、App Store Connect API KeyをGitHub Environment `app-store-production` のSecretsへ登録すると、`Signed TestFlight and App Store Release` ワークフローで署名、IPA生成、メタデータ送信、TestFlightアップロード、審査提出まで実行できます。

アカウント所有者にしか取得できない値は [REQUIRED_ACCOUNT_ACTIONS.md](app_store_submission/REQUIRED_ACCOUNT_ACTIONS.md) に分離しています。秘密鍵やパスワードをリポジトリへコミットしないでください。

課金商品はApp Store Connectで作成します。商品IDは `com.rooomtech.rooomshot.monthly`、期間は1か月、日本価格は月額500円です。商品IDは作成後に変更できないため、ソースコードと完全一致させてください。初回の自動更新サブスクリプションはアプリ1.0.0と同じ審査へ追加します。登録手順は [SUBSCRIPTION_SETUP.md](app_store_submission/SUBSCRIPTION_SETUP.md) にあります。

## プライバシー

詳細は [PRIVACY.md](PRIVACY.md) を参照してください。写真と検索用JSONはiPhoneから本人のGoogle Driveへ直接送られ、ROOOMTECHのサーバーを経由しません。

## ライセンス

ソースコードの非商用利用条件と商用ライセンスについては [LICENSE.md](LICENSE.md) を参照してください。商用・法人・本番利用は `support@rooomtech.com` までお問い合わせください。
