import XCTest
@testable import RooomShot

final class FolderNameValidatorTests: XCTestCase {
    func testTrimsWhitespaceAndReplacesSlash() throws {
        XCTAssertEqual(try FolderNameValidator.validate("  Property / Photos  "), "Property _ Photos")
    }

    func testRejectsBlankName() {
        XCTAssertThrowsError(try FolderNameValidator.validate("   \n"))
    }

    func testRejectsMoreThanOneHundredCharacters() {
        XCTAssertThrowsError(try FolderNameValidator.validate(String(repeating: "a", count: 101)))
    }
}

