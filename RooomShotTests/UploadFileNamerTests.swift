import XCTest
@testable import RooomShot

final class UploadFileNamerTests: XCTestCase {
    func testCreatesSafeUniqueJPEGName() {
        let identifier = UUID(uuidString: "A1B2C3D4-1111-2222-3333-444455556666")!
        let name = UploadFileNamer.make(date: Date(timeIntervalSince1970: 0), identifier: identifier)

        XCTAssertTrue(name.hasPrefix("RooomShot_"))
        XCTAssertTrue(name.hasSuffix("_A1B2C3D4.jpg"))
        XCTAssertNil(name.range(of: "[^A-Za-z0-9_.-]", options: .regularExpression))
    }
}

