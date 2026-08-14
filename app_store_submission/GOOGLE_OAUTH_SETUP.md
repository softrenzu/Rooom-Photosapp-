# Google OAuth production setup

1. Open Google Cloud Console with the ROOOMTECH-owned Google account.
2. Create or select the production project for RooomShot.
3. Enable **Google Drive API**.
4. Configure the OAuth consent screen:
   - App name: RooomShot
   - User support email: `support@rooomtech.com`
   - Home page: `https://softrenzu.github.io/Rooom-Photosapp-/`
   - Privacy Policy: `https://softrenzu.github.io/Rooom-Photosapp-/privacy.html`
   - Terms: `https://github.com/softrenzu/Rooom-Photosapp-/blob/main/TERMS.md`
   - Authorized domain: `softrenzu.github.io`
   - Developer contact: `support@rooomtech.com`
5. Add only `https://www.googleapis.com/auth/drive.file`.
6. Create an OAuth Client ID of type **iOS**:
   - Bundle ID: `com.rooomtech.rooomshot`
   - App Store ID: add after App Store Connect assigns it
   - Apple Team ID: use the exact active ROOOMTECH team value
7. Put the iOS client ID and reversed client ID in `Configuration/Secrets.xcconfig` for local builds and in GitHub Environment secrets for releases.
8. Add test users while developing.
9. Before App Review, change publishing status to **Production** and complete any branding or verification steps shown by Google.
10. Test with a Google Account that was not listed as a test user. The consent screen must not show an unverified-development block.

Do not request the broad `drive` scope. Do not upload an OAuth client secret; native iOS clients use a client ID and URL scheme, not a confidential client secret.

