# App Review notes

Paste the following into App Review Information after the signed build has passed TestFlight.

---

RooomShot is a focused client for the user's Google Drive. It does not create a ROOOMTECH account and has no developer-operated backend.

Review steps:

1. Launch RooomShot.
2. Tap the standard Google Sign-In button and use any Google Account available to the reviewer.
3. Leave the destination name as “RooomShot” and tap “Create folder and start.”
4. Tap the large camera button, grant camera permission, and take a photo.
5. The History tab changes from Uploading to Done. The resulting JPEG is in the newly created RooomShot folder in that Google Drive.
6. To test offline behavior, disable connectivity, take a photo, restore connectivity, and observe automatic retry.

Google authorization requests only `https://www.googleapis.com/auth/drive.file`, which limits access to files and folders created by or explicitly opened with this app. The app cannot read the rest of the user's Drive.

Photos upload directly from the device to Google Drive and never pass through a ROOOMTECH server. The app contains no advertising, analytics, or tracking SDK.

Sign in with Apple is not shown because Google authentication is used solely to authorize direct access to the user's content in the specific third-party Google Drive service. It is not used to create or authenticate a developer account. This follows the third-party service client exception in App Review Guideline 4.8.

No paid content, in-app purchases, subscriptions, or external purchase links are present.

Support: support@rooomtech.com

---

The App Review contact phone number must be entered by the account holder and is not stored in this repository.

