import Foundation

enum SubscriptionPlan {
    static let monthlyProductID = "com.rooomtech.rooomshot.monthly"
    static let productIDs = [monthlyProductID]
    static let fallbackMonthlyPrice = "¥500"

    static let privacyURL = URL(string: "https://github.com/softrenzu/Rooom-Photosapp-/blob/main/PRIVACY.md")!
    static let termsURL = URL(string: "https://github.com/softrenzu/Rooom-Photosapp-/blob/main/TERMS.md")!
    static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")!
}
