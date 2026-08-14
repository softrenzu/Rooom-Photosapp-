# RooomShot プライバシーポリシー

施行日: 2026年8月14日  
提供者: ROOOMTECH株式会社

## 1. 対象

本ポリシーは、iPhoneアプリ「RooomShot」における情報の取扱いを説明します。

## 2. 取り扱う情報

RooomShotは、機能提供のため次の情報を取り扱います。

- 利用者がGoogleログインで選択したアカウントのメールアドレス
- 利用者がRooomShotのカメラで撮影した写真
- 写真のファイル名、撮影時刻、アップロード状態、Google Drive上のファイルID
- 保存先としてRooomShotが作成したGoogle Driveフォルダの名前とID

## 3. 利用目的

上記情報は、Googleアカウントへの接続、保存先の管理、写真のアップロード、オフライン送信待ち、再試行、端末内の送信履歴表示にのみ利用します。

## 4. 保存と送信

- 写真は利用者のiPhoneから、利用者が選んだGoogleアカウントのGoogle Driveへ直接送信されます。
- 写真やGoogleアクセストークンはROOOMTECHのサーバーを経由せず、ROOOMTECHのサーバーには保存されません。
- オフライン時または送信失敗時の写真は、再送のためiPhoneのアプリ専用領域に一時保存されます。
- アップロード成功後、端末内の一時写真は削除されます。ファイル名、時刻、状態などの履歴は端末内に最大200件保存されます。
- Googleの認証情報はGoogle Sign-In SDKとiOSの安全な認証ストレージによって管理されます。

## 5. Google Driveへのアクセス範囲

RooomShotが要求するGoogle Drive権限は `drive.file` です。この権限は、RooomShotが作成した、または利用者がRooomShotに明示的に許可したファイルとフォルダに限定されます。Google Drive内の他の文書や写真を一覧取得、閲覧、変更する目的では使用しません。

RooomShotによるGoogle APIから取得した情報の使用および他のアプリへの転送は、Limited Use要件を含むGoogle API Services User Data Policyに準拠します。取得情報を広告、信用評価、データ販売、第三者への再提供、AIモデルの学習に使用しません。また、法令上必要な場合または利用者から明確な依頼がある場合を除き、人が内容を閲覧しません。

## 6. 第三者提供と外部サービス

写真は利用者の操作に基づきGoogle Driveへ送信されます。RooomShotはGoogle Sign-InおよびGoogle Drive APIを利用します。Googleにおける情報の取扱いには、Googleのプライバシーポリシーが適用されます。

ROOOMTECHは、利用者情報を販売せず、広告事業者へ提供しません。本アプリには広告SDK、行動解析SDK、トラッキングSDKを組み込んでいません。

## 7. カメラ権限

カメラ権限は、利用者が写真を撮影するときだけ使用します。位置情報、マイク、連絡先、写真ライブラリ全体へのアクセスは要求しません。

## 8. 削除方法

- Google Driveへアップロード済みの写真とフォルダは、利用者がGoogle Drive上で削除できます。
- 端末内の送信履歴はアプリ内の「完了履歴を消去」から削除できます。
- 送信待ち写真を含む端末内データは、アプリをiPhoneから削除することで消去できます。
- Googleアカウントとの接続は、アプリの設定画面からログアウトして解除できます。Googleアカウントのセキュリティ設定からRooomShotのアクセス権を取り消すこともできます。

## 9. 子どもの利用

本アプリは一般利用者向けの実用ツールであり、13歳未満の子どもを対象として情報を収集する設計ではありません。

## 10. 安全管理

通信はHTTPSで暗号化し、Googleの短時間アクセストークンを使用します。アップロード先を必要最小限の権限に限定し、秘密情報をアプリのソースコードへ埋め込みません。

## 11. 変更

本ポリシーを変更する場合、施行日と変更内容を本ページで告知します。重要な変更はアプリ内またはApp Storeの更新情報でも案内します。

## 12. お問い合わせ

ROOOMTECH株式会社  
メール: support@rooomtech.com  
サポート: https://softrenzu.github.io/Rooom-Photosapp-/support.html

---

# RooomShot Privacy Policy

Effective date: August 14, 2026

RooomShot handles the Google Account email address selected by the user, photos captured in the app, destination folder identifiers, file identifiers, timestamps, and upload status solely to provide sign-in, direct Google Drive uploads, offline queuing, retries, and on-device history.

Photos travel directly from the user's iPhone to the user's Google Drive and never pass through or remain on a ROOOMTECH server. A queued photo remains in the app's private on-device storage until upload succeeds, after which the temporary local copy is deleted. Up to 200 metadata-only history records may remain on device.

RooomShot requests only the Google Drive `drive.file` scope. It does not read or list the user's other Drive content. Its use and transfer of information received from Google APIs complies with the Google API Services User Data Policy, including the Limited Use requirements. Google user data is not used for advertising, credit decisions, sale, transfer to data brokers, or training generalized AI models.

The app contains no advertising, behavioral analytics, or tracking SDK. It does not request location, microphone, contacts, or full photo-library access. Users can delete uploaded content in Google Drive, clear completed history in the app, revoke Google access from their Google Account, and remove all queued local data by deleting the app.

Contact: support@rooomtech.com

