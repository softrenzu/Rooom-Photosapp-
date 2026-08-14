# Submission status

Updated: 2026-08-14

## Completed in the repository

- Native SwiftUI iPhone app
- Google Sign-In and least-privilege `drive.file` integration
- Resumable JPEG upload to an app-created destination folder
- Offline queue, reconnect retry, manual retry, and local history
- StoreKit 2 monthly subscription, entitlement checks, purchase restoration, and subscription management
- Japanese and English localization
- 1024 x 1024 opaque App Store icon
- Privacy manifest and camera permission strings
- Privacy Policy, Terms, and Support pages
- Japanese and English App Store metadata
- App Review notes, privacy answers, age-rating answers, and accessibility answers
- Xcode 26 CI, tests, actual simulator screenshot generation, and screenshot validation
- Signed archive, TestFlight upload, metadata upload, and optional App Review workflow

## Account-bound items still required

These values cannot be fabricated or committed. They must be created in the account owner's Apple and Google accounts:

- Apple Developer Team ID and active program membership
- App Store Connect app record and final available app name
- Active Paid Apps Agreement, banking information, and tax forms
- App Store Connect subscription group and monthly product priced at ¥500
- Apple Distribution certificate and matching private key
- App Store provisioning profile for `com.rooomtech.rooomshot`
- App Store Connect API key
- Google Cloud iOS OAuth client ID and reversed client ID
- Google OAuth production publishing status
- App Review contact phone number

Exact entry locations and secret names are listed in `REQUIRED_ACCOUNT_ACTIONS.md`.
