# App Privacy answers

Choose **Yes, data is collected** and declare only the following data types. This conservative declaration includes data sent directly to the user's Google Drive even though ROOOMTECH has no backend access.

## Contact Info

### Email Address

- Collected: Yes
- Linked to the user's identity: Yes
- Used for tracking: No
- Purpose: App Functionality
- Detail: Display the selected Google Account and maintain the authorized Google session.

## User Content

### Photos or Videos

- Collected: Yes
- Linked to the user's identity: Yes
- Used for tracking: No
- Purpose: App Functionality
- Detail: Upload photos captured by the user directly to that user's Google Drive.

### Other User Content

- Collected: Yes
- Linked to the user's identity: Yes
- Used for tracking: No
- Purpose: App Functionality
- Detail: Text recognized on-device from the user's photos is written to `RooomShot_index.json` in the user's own Google Drive together with photo metadata so the user's records are easier to search and process.

## All other types

- Declare as not collected.
- Purchases: not collected by ROOOMTECH. Apple processes the transaction and StoreKit verifies entitlement on device; purchase history is not sent to a ROOOMTECH server.
- Tracking: No.
- Data broker sharing: No.
- Third-party advertising: No.
- Developer advertising or marketing: No.
- Analytics: No.
- Product personalization: No.

## Privacy architecture evidence

- No ROOOMTECH backend endpoint exists in the code.
- App-functionality network destinations are Google Sign-In, `googleapis.com`, and Apple's StoreKit services.
- OCR uses Apple's Vision framework on the iPhone; photos are not uploaded to an OCR/AI service.
- No advertising or analytics SDK is included.
- Photos queued offline remain in Application Support and are deleted locally only after both the photo upload and JSON index update succeed.
- The Drive scope remains `drive.file`; the app reads and updates only the folder/files it created or the user explicitly authorized.
- `RooomShot_index.json` is stored in the user's Google Drive, not on a ROOOMTECH server.
