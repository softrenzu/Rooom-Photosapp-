import XCTest
@testable import RooomShot

final class PhotoSearchIndexTests: XCTestCase {
    func testUpsertAddsAndReplacesByDriveFileID() {
        let capturedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let first = PhotoSearchIndexEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            capturedAt: capturedAt,
            uploadedAt: capturedAt,
            fileName: "first.jpg",
            driveFileID: "drive-1",
            driveWebViewLink: "https://drive.google.com/file/d/drive-1/view",
            folderID: "folder-1",
            pixelWidth: 1200,
            pixelHeight: 1600,
            ocrText: "Room 101"
        )
        let replacement = PhotoSearchIndexEntry(
            id: first.id,
            capturedAt: capturedAt,
            uploadedAt: capturedAt,
            fileName: "first.jpg",
            driveFileID: "drive-1",
            driveWebViewLink: first.driveWebViewLink,
            folderID: "folder-1",
            pixelWidth: 1200,
            pixelHeight: 1600,
            ocrText: "Room 101 updated"
        )

        var index = PhotoSearchIndex(updatedAt: capturedAt)
        index.upsert(first, now: capturedAt)
        index.upsert(replacement, now: capturedAt)

        XCTAssertEqual(index.items.count, 1)
        XCTAssertEqual(index.items.first?.ocrText, "Room 101 updated")
        XCTAssertTrue(index.items.first?.searchText.contains("Room 101 updated") == true)
    }

    func testEncodingRoundTripsAsJSON() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let entry = PhotoSearchIndexEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            capturedAt: date,
            uploadedAt: date,
            fileName: "photo.jpg",
            driveFileID: "drive-2",
            driveWebViewLink: nil,
            folderID: "folder-1",
            pixelWidth: 1000,
            pixelHeight: 1000,
            ocrText: "予約番号 ABC123"
        )
        let original = PhotoSearchIndex(updatedAt: date, items: [entry])

        let data = try original.encoded()
        let decoded = try PhotoSearchIndex.decode(from: data)

        XCTAssertEqual(decoded, original)
        XCTAssertTrue(String(decoding: data, as: UTF8.self).contains("予約番号 ABC123"))
    }
}
