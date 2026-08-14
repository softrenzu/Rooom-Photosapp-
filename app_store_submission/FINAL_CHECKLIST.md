# Final submission checklist

## Build

- [ ] GitHub Actions `iOS 26 Build, Tests, and Screenshots` is green.
- [ ] Signed Release archive uses Xcode 26 or later and iOS 26 SDK.
- [ ] Bundle ID is `com.rooomtech.rooomshot`.
- [ ] Version is 1.0.0 and build is unique.
- [ ] App icon is 1024 x 1024, opaque, and has no pre-rounded corners.
- [ ] Privacy manifest validation has no missing required-reason API.
- [ ] No placeholder Google client ID is present in the signed build.
- [ ] Product ID is exactly `com.rooomtech.rooomshot.monthly` in source and App Store Connect.

## Physical iPhone test

- [ ] Fresh install shows Google Sign-In.
- [ ] An account not on the Google test-user list can authorize the app.
- [ ] The RooomShot folder is created.
- [ ] A captured photo uploads and opens in Google Drive.
- [ ] Moving the folder within Drive does not break upload.
- [ ] Offline capture queues locally and uploads after reconnection.
- [ ] Failed upload can be retried.
- [ ] Sign-out and sign-in with another account create a valid destination.
- [ ] Camera denial produces understandable behavior.
- [ ] Japanese and English UI are complete.
- [ ] VoiceOver, larger text, and color-independent statuses were checked.
- [ ] Sandbox purchase unlocks the camera and upload.
- [ ] Restore Purchases restores an active subscription.
- [ ] Expired or revoked subscription locks new capture without deleting history or Drive content.

## App Store Connect

- [ ] Privacy and Support URLs load publicly without login.
- [ ] Five Japanese and five English 6.9-inch screenshots are uploaded; no alpha channels.
- [ ] App Privacy answers match `PRIVACY_ANSWERS.md`.
- [ ] Age rating answers match `AGE_RATING.md` and generate 4+.
- [ ] Export compliance is answered as exempt standard encryption.
- [ ] Review notes and contact phone are complete.
- [ ] Paid Apps Agreement, banking, and tax information are active.
- [ ] Subscription group and monthly product match `APP_STORE_VALUES.md`.
- [ ] The first subscription is added to the same review submission as version 1.0.0.
- [ ] Pricing, availability, copyright, categories, and manual release are confirmed.
- [ ] Build is tested in TestFlight before selecting Submit for Review.
