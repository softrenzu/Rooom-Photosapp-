# App Store Connect subscription setup

RooomShot uses one auto-renewable subscription. Do not create a consumable, non-consumable, or non-renewing subscription.

## 1. Activate paid-app contracts

1. Open App Store Connect and select **Business**.
2. Under **Agreements**, accept the current **Paid Apps Agreement** as the Account Holder.
3. Complete all required banking and tax information.
4. Wait until the agreement, banking, and tax statuses allow paid content.

Official references:

- https://developer.apple.com/help/app-store-connect/manage-agreements/sign-and-update-agreements/
- https://developer.apple.com/help/app-store-connect/manage-banking-information/enter-banking-information/
- https://developer.apple.com/help/app-store-connect/manage-tax-information/provide-tax-information/

## 2. Create the subscription group

1. Open **Apps** and select **RooomShot**.
2. In the sidebar under **Monetization**, select **Subscriptions**.
3. Create a group with reference name `RooomShot Premium`.
4. Add group localization:
   - Japanese display name: `RooomShot プレミアム`
   - English display name: `RooomShot Premium`

## 3. Create the monthly product

Enter these values exactly:

| Field | Value |
|---|---|
| Reference name | RooomShot Monthly |
| Product ID | `com.rooomtech.rooomshot.monthly` |
| Duration | 1 month |
| Japan price | ¥500 per month |
| Introductory offer | None |
| Family Sharing | Off |
| Availability | All App Store countries and regions |

The product ID cannot be changed or reused after creation. It must exactly match `SubscriptionPlan.monthlyProductID` in the app.

Apple automatically proposes comparable prices for other storefronts. Confirm Japan as the base storefront at ¥500 and review the automatically generated regional prices before saving.

Official references:

- https://developer.apple.com/help/app-store-connect/manage-subscriptions/offer-auto-renewable-subscriptions/
- https://developer.apple.com/help/app-store-connect/manage-subscriptions/manage-pricing-for-auto-renewable-subscriptions/

## 4. Add localized product metadata

Japanese:

- Display name: `月額プラン`
- Description: `写真撮影、Google Drive自動保存、OCR、検索用JSON整理を無制限で利用できます。`

English:

- Display name: `Monthly Plan`
- Description: `Unlimited capture, Google Drive upload, on-device OCR, and searchable JSON indexing.`

Upload `fastlane/screenshots/ja/5_subscription.jpg` as the review screenshot after the screenshot workflow succeeds. Review notes are in `REVIEW_NOTES.md`.

## 5. Test and submit

1. Test purchase, renewal, cancellation, expiration, and restoration in Apple's sandbox or TestFlight.
2. Confirm an active purchase unlocks the camera, Drive upload, OCR, and JSON indexing.
3. Confirm a captured photo creates or updates `RooomShot_index.json` in the same Drive folder.
4. Confirm expiration or revocation locks new capture without deleting history or Google Drive content.
5. On the subscription detail page, select **Add for Review**.
6. Add the subscription to the same App Review submission as RooomShot 1.0.0.

The first auto-renewable subscription must be submitted with a new app version. Do not run the release workflow with `submit_for_review=true` until the subscription is complete and attached to the version.
