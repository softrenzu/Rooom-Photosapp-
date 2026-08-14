# App Review notes

Paste the following into App Review Information after the signed build has passed TestFlight.

---

RooomShot is a focused client for the user's Google Drive. It does not create a ROOOMTECH account and has no developer-operated backend.

Review steps:

1. Launch RooomShot.
2. Tap the standard Google Sign-In button and use any Google Account available to the reviewer.
3. Leave the destination name as “RooomShot” and tap “Create folder and start.”
4. Tap the large camera button. RooomShot presents its monthly subscription screen.
5. Purchase the App Review sandbox subscription `com.rooomtech.rooomshot.monthly` (¥500 per month). There is no free trial.
6. Tap the large camera button again, grant camera permission, and take a photo.
7. The History tab changes from Uploading to Done. The resulting JPEG is in the newly created RooomShot folder in that Google Drive.
8. To test offline behavior, disable connectivity, take a photo, restore connectivity, and observe automatic retry.
9. Purchase restoration and the App Store subscription-management link are available in Settings.

Google authorization requests only `https://www.googleapis.com/auth/drive.file`, which limits access to files and folders created by or explicitly opened with this app. The app cannot read the rest of the user's Drive.

Photos upload directly from the device to Google Drive and never pass through a ROOOMTECH server. The app contains no advertising, analytics, or tracking SDK. StoreKit 2 verifies the subscription entitlement on device. ROOOMTECH operates no purchase-validation backend and does not collect payment information or purchase history.

Sign in with Apple is not shown because Google authentication is used solely to authorize direct access to the user's content in the specific third-party Google Drive service. It is not used to create or authenticate a developer account. This follows the third-party service client exception in App Review Guideline 4.8.

The app download is free. Photo capture and automatic Google Drive upload require the auto-renewable monthly subscription above. Price, duration, renewal terms, purchase restoration, Terms of Use, and Privacy Policy are presented in the subscription screen. There are no external purchase links.

Support: support@rooomtech.com

---

The App Review contact phone number must be entered by the account holder and is not stored in this repository.
