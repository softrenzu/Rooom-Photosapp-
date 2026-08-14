import XCTest
@testable import RooomShot

final class SubscriptionPlanTests: XCTestCase {
    func testMonthlyProductIdentifierUsesBundlePrefix() {
        XCTAssertEqual(SubscriptionPlan.monthlyProductID, "com.rooomtech.rooomshot.monthly")
        XCTAssertTrue(SubscriptionPlan.monthlyProductID.hasPrefix("com.rooomtech.rooomshot."))
    }

    func testLegalAndManagementLinksUseHTTPS() {
        XCTAssertEqual(SubscriptionPlan.privacyURL.scheme, "https")
        XCTAssertEqual(SubscriptionPlan.termsURL.scheme, "https")
        XCTAssertEqual(SubscriptionPlan.manageSubscriptionsURL.scheme, "https")
    }
}
