# Required account-owner actions

These are the only values and approvals that cannot be generated safely from source code.

## Apple Developer and App Store Connect

- Confirm the ROOOMTECH Apple Developer Program membership is active.
- Register Bundle ID `com.rooomtech.rooomshot`.
- Create the iOS app record using the values in `APP_STORE_VALUES.md`.
- Confirm whether “RooomShot” is available as the product-page name. If not, choose the final name before creating screenshots and metadata.
- Enter the App Review contact phone number.
- Confirm worldwide availability or select the intended storefronts.
- Confirm the app is free and uses manual release after approval.
- Create/download an Apple Distribution certificate with its private key and an App Store provisioning profile.
- Create an App Store Connect API key with App Manager access.

## Google Cloud

- Complete every step in `GOOGLE_OAUTH_SETUP.md`.
- Confirm the OAuth client is owned by ROOOMTECH and is in Production.

## GitHub Environment secrets

Create protected environment `app-store-production` and add:

| Secret | Contents |
|---|---|
| `APPLE_TEAM_ID` | 10-character Apple Team ID |
| `GOOGLE_CLIENT_ID` | Google iOS OAuth client ID |
| `GOOGLE_REVERSED_CLIENT_ID` | Reversed Google iOS OAuth client ID |
| `BUILD_CERTIFICATE_BASE64` | Base64 of Apple Distribution `.p12` |
| `P12_PASSWORD` | Password used when exporting the `.p12` |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64 of the App Store `.mobileprovision` |
| `KEYCHAIN_PASSWORD` | A new random CI-only keychain password |
| `APP_STORE_CONNECT_KEY_ID` | App Store Connect API key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect issuer ID |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64 of the downloaded `AuthKey_*.p8` file |

Require manual approval for this environment. Never paste these secrets into issues, source files, chat messages, build logs, or App Review notes.

After all values are present, run **Signed TestFlight and App Store Release** once with `submit_for_review=false`. Test the build on a physical iPhone. Then run it with `submit_for_review=true` only after the final checklist passes.

