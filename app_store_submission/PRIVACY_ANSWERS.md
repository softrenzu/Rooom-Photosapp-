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
- Detail: Upload the photo selected by the user directly to that user's Google Drive.

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
- No advertising or analytics SDK is included.
- Photos queued offline remain in Application Support and are deleted locally after upload succeeds.
- `PrivacyInfo.xcprivacy` declares email address and photos/videos for app functionality and no tracking.
