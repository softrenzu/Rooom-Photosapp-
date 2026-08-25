# RooomShot プライバシーポリシー

施行日: 2026年8月20日  
提供者: ROOOMTECH株式会社

## 1. 対象

本ポリシーは、iPhoneアプリ「RooomShot」における情報の取扱いを説明します。

## 2. 取り扱う情報

RooomShotは、機能提供のため次の情報を取り扱います。

- 利用者がGoogleログインで選択したアカウントのメールアドレス
- 利用者がRooomShotのカメラで撮影した写真
- 写真のファイル名、撮影時刻、画像サイズ、アップロード状態、Google Drive上のファイルID
- 端末上の文字認識機能で写真から読み取ったテキスト
- 保存先としてRooomShotが作成したGoogle Driveフォルダの名前とID
- 検索用JSONインデックス `RooomShot_index.json` に記録する上記の写真情報と認識テキスト

## 3. 利用目的

上記情報は、Googleアカウントへの接続、保存先の管理、写真のアップロード、オフライン送信待ち、再試行、端末内の送信履歴表示、および利用者自身のGoogle Drive内で写真を検索しやすくするためのJSONインデックス作成に利用します。

文字認識はAppleのVisionフレームワークを使用してiPhone上で実行します。認識のために写真をROOOMTECHのサーバーや外部AIサービスへ送信しません。

## 4. 保存と送信

- 写真は利用者のiPhoneから、利用者が選んだGoogleアカウントのGoogle Driveへ直接送信されます。
- 写真やGoogleアクセストークンはROOOMTECHのサーバーを経由せず、ROOOMTECHのサーバーには保存されません。
- 写真アップロード後、同じ保存先フォルダに `RooomShot_index.json` を作成し、ファイル名、撮影時刻、画像サイズ、Google DriveファイルID、文字認識結果などをJSON形式で記録します。
- `RooomShot_index.json` が既に存在する場合は、同じ写真を重複させないようGoogle DriveファイルID単位で追加または更新します。
- オフライン時または送信失敗時の写真は、再送のためiPhoneのアプリ専用領域に一時保存されます。
- 写真とJSONインデックスの更新が成功した後、端末内の一時写真は削除されます。ファイル名、時刻、状態などの履歴は端末内に最大200件保存されます。
- Googleの認証情報はGoogle Sign-In SDKとiOSの安全な認証ストレージによって管理されます。

## 5. Google Driveへのアクセス範囲

RooomShotが要求するGoogle Drive権限は `drive.file` です。この権限は、RooomShotが作成した、または利用者がRooomShotに明示的に許可したファイルとフォルダに限定されます。Google Drive内の他の文書や写真を一覧取得、閲覧、変更する目的では使用しません。

RooomShotによるGoogle APIから取得した情報の使用および他のアプリへの転送は、Limited Use要件を含むGoogle API Services User Data Policyに準拠します。取得情報を広告、信用評価、データ販売、第三者への再提供、AIモデルの学習に使用しません。また、法令上必要な場合または利用者から明確な依頼がある場合を除き、人が内容を閲覧しません。

## 6. 第三者提供と外部サービス

写真と検索用JSONインデックスは利用者の操作に基づき利用者本人のGoogle Driveへ送信されます。RooomShotはGoogle Sign-In、Google Drive API、Apple Visionを利用します。Googleにおける情報の取扱いには、Googleのプライバシーポリシーが適用されます。

ROOOMTECHは、利用者情報を販売せず、広告事業者へ提供しません。本アプリには広告SDK、行動解析SDK、トラッキングSDKを組み込んでいません。

## 7. カメラ権限

カメラ権限は、利用者が写真を撮影するときだけ使用します。位置情報、マイク、連絡先、写真ライブラリ全体へのアクセスは要求しません。

## 8. App Store課金

月額プランの購入、請求、解約はAppleのApp Storeが処理します。RooomShotは有効な利用権の有無を端末上で確認しますが、ROOOMTECHのサーバーへ購入履歴や支払情報を送信・保存しません。

## 9. 削除方法

- Google Driveへアップロード済みの写真、`RooomShot_index.json`、フォルダは、利用者がGoogle Drive上で削除できます。
- 端末内の送信履歴はアプリ内の「完了履歴を消去」から削除できます。
- 送信待ち写真を含む端末内データは、アプリをiPhoneから削除することで消去できます。
- Googleアカウントとの接続は、アプリの設定画面からログアウトして解除できます。Googleアカウントのセキュリティ設定からRooomShotのアクセス権を取り消すこともできます。

## 10. 子どもの利用

本アプリは一般利用者向けの実用ツールであり、13歳未満の子どもを対象として情報を収集する設計ではありません。

## 11. 安全管理

通信はHTTPSで暗号化し、Googleの短時間アクセストークンを使用します。アップロード先を必要最小限の権限に限定し、秘密情報をアプリのソースコードへ埋め込みません。文字認識は端末上で実行します。

## 12. 変更

本ポリシーを変更する場合、施行日と変更内容を本ページで告知します。重要な変更はアプリ内またはApp Storeの更新情報でも案内します。

## 13. お問い合わせ

ROOOMTECH株式会社  
メール: support@rooomtech.com  
サポート: https://softrenzu.github.io/Rooom-Photosapp-/support.html

---

# RooomShot Privacy Policy

Effective date: August 20, 2026

RooomShot handles the Google Account email address selected by the user, photos captured in the app, destination folder identifiers, file identifiers, timestamps, image dimensions, upload status, and text recognized from captured photos solely to provide sign-in, direct Google Drive uploads, offline queuing, retries, on-device history, and a searchable JSON index in the user's own Google Drive.

Text recognition is performed on the iPhone with Apple's Vision framework. Photos are not sent to a ROOOMTECH server or an external AI service for recognition.

Photos travel directly from the user's iPhone to the user's Google Drive and never pass through or remain on a ROOOMTECH server. After each successful photo upload, RooomShot creates or updates `RooomShot_index.json` in the same Drive folder. The index contains the file name, capture time, image dimensions, Google Drive file ID, and recognized text. Existing records are updated by Drive file ID to avoid duplicate index entries.

A queued photo remains in the app's private on-device storage until both the photo upload and index update succeed, after which the temporary local copy is deleted. Up to 200 metadata-only history records may remain on device.

RooomShot requests only the Google Drive `drive.file` scope. It does not read or list the user's other Drive content. Its use and transfer of information received from Google APIs complies with the Google API Services User Data Policy, including the Limited Use requirements. Google user data is not used for advertising, credit decisions, sale, transfer to data brokers, or training generalized AI models.

The app contains no advertising, behavioral analytics, or tracking SDK. It does not request location, microphone, contacts, or full photo-library access. Users can delete uploaded photos and the JSON index in Google Drive, clear completed history in the app, revoke Google access from their Google Account, and remove all queued local data by deleting the app.

Apple processes subscription purchases, billing, and cancellation. RooomShot checks entitlement status on device but does not send or store purchase history or payment information on a ROOOMTECH server.

Contact: support@rooomtech.com
