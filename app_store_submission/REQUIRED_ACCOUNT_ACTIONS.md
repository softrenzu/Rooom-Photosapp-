# Required account-owner actions

These are the only values and approvals that cannot be generated safely from source code.

## Apple Developer and App Store Connect

Completed for the current ROOOMTECH account:

- Apple Developer Program membership is active.
- Bundle ID `com.rooomtech.rooomshot` is registered.
- The iOS app record `RooomShot` exists in App Store Connect.
- Team ID is `FP4P58VA5F`.

Still required before sale:

- Enter the App Review contact phone number.
- Confirm worldwide availability or select the intended storefronts.
- Keep the app download free and use manual release after approval unless the release policy is intentionally changed.
- In **Business**, accept the current **Paid Apps Agreement** and complete required banking and tax information.
- Create subscription group `RooomShot Premium` and monthly product `com.rooomtech.rooomshot.monthly` using `SUBSCRIPTION_SETUP.md` and `APP_STORE_VALUES.md`.
- Set the Japan storefront price to ¥500 per month and make the subscription available in the intended countries and regions.
- Add Japanese and English subscription localizations and the review screenshot.
- Add the first subscription and its subscription group to the same App Review submission as app version 1.0.0.
- Complete App Privacy using `PRIVACY_ANSWERS.md` and set the public privacy-policy URL.
- Request App Store Connect API access under **Users and Access > Integrations** if it is not already enabled.
- Create a **team App Store Connect API key** with sufficient app-management/distribution permissions and download its `.p8` private key once.
- Keep cloud-managed app distribution permission enabled for the Account Holder. The release workflow uses Apple cloud signing, so a manually exported `.p12` certificate and provisioning profile are no longer required.

## Google Cloud

- Complete every step in `GOOGLE_OAUTH_SETUP.md`.
- Confirm Google Drive API is enabled.
- Confirm the iOS OAuth client uses Bundle ID `com.rooomtech.rooomshot`.
- Confirm the OAuth consent configuration is owned by ROOOMTECH and is in Production before public release.

## GitHub Environment secrets

Create protected environment `app-store-production` and add only these secrets:

| Secret | Contents |
|---|---|
| `APPLE_TEAM_ID` | `FP4P58VA5F` |
| `GOOGLE_CLIENT_ID` | Google iOS OAuth client ID |
| `GOOGLE_REVERSED_CLIENT_ID` | Reversed Google iOS OAuth client ID |
| `APP_STORE_CONNECT_KEY_ID` | Team App Store Connect API key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect issuer ID |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64 of the downloaded `AuthKey_*.p8` file |

Require manual approval for this environment. Never paste the API private key or Google credentials into issues, source files, chat messages, build logs, or App Review notes.

## Release order

1. Merge the validated production changes to `main`.
2. Populate the GitHub environment secrets above.
3. Run **Signed TestFlight and App Store Release** with `submit_for_review=false` and `subscription_review_ready=false` to build, cloud-sign, upload the IPA, metadata, and screenshots without submitting the app.
4. Verify the processed build in App Store Connect/TestFlight and test the production candidate.
5. Finish the ¥500 subscription and add the subscription + group to the same App Review submission as RooomShot 1.0.0.
6. Complete privacy, age rating, availability, review contact, content rights, and other required App Store fields.
7. Run the release workflow with `submit_for_review=true` and `subscription_review_ready=true`, or use App Store Connect to add the uploaded build and subscription to the draft submission and click **Submit for Review**.
8. After Apple approval, release manually from App Store Connect.
