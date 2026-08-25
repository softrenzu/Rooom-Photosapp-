import Foundation

struct PhotoSearchIndex: Codable, Equatable {
    static let fileName = "RooomShot_index.json"

    var schemaVersion: Int
    var updatedAt: Date
    var items: [PhotoSearchIndexEntry]

    init(
        schemaVersion: Int = 1,
        updatedAt: Date = Date(),
        items: [PhotoSearchIndexEntry] = []
    ) {
        self.schemaVersion = schemaVersion
        self.updatedAt = updatedAt
        self.items = items
    }

    mutating func upsert(_ entry: PhotoSearchIndexEntry, now: Date = Date()) {
        if let index = items.firstIndex(where: { $0.driveFileID == entry.driveFileID }) {
            items[index] = entry
        } else {
            items.insert(entry, at: 0)
        }
        updatedAt = now
    }

    static func decode(from data: Data) throws -> PhotoSearchIndex {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PhotoSearchIndex.self, from: data)
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }
}

struct PhotoSearchIndexEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let capturedAt: Date
    let uploadedAt: Date
    let fileName: String
    let driveFileID: String
    let driveWebViewLink: String?
    let mimeType: String
    let folderID: String
    let pixelWidth: Int?
    let pixelHeight: Int?
    let ocrText: String
    let searchText: String

    init(
        id: UUID,
        capturedAt: Date,
        uploadedAt: Date = Date(),
        fileName: String,
        driveFileID: String,
        driveWebViewLink: String?,
        mimeType: String = "image/jpeg",
        folderID: String,
        pixelWidth: Int?,
        pixelHeight: Int?,
        ocrText: String
    ) {
        self.id = id
        self.capturedAt = capturedAt
        self.uploadedAt = uploadedAt
        self.fileName = fileName
        self.driveFileID = driveFileID
        self.driveWebViewLink = driveWebViewLink
        self.mimeType = mimeType
        self.folderID = folderID
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.ocrText = ocrText
        self.searchText = [fileName, ocrText]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }
}
