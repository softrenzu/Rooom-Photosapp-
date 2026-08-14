import XCTest
@testable import RooomShot

@MainActor
final class AppSettingsTests: XCTestCase {
    func testDestinationPersists() {
        let suite = "AppSettingsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let settings = AppSettings(defaults: defaults)
        settings.setDestination(id: "folder-123", name: "Rental Photos")

        let restored = AppSettings(defaults: defaults)
        XCTAssertEqual(restored.destinationFolderID, "folder-123")
        XCTAssertEqual(restored.destinationFolderName, "Rental Photos")
        XCTAssertTrue(restored.hasDestination)
    }
}

