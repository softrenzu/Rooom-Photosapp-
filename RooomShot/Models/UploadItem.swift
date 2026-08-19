import Foundation

struct UploadItem: Codable, Identifiable, Equatable {
    enum Status: String, Codable {
        case queued
        case uploading
        case uploaded
        case failed
    }

    let id: UUID
    let createdAt: Date
    let fileName: String
    var localFileName: String?
    var status: Status
    var attemptCount: Int
    var remoteFileID: String?
    var remoteWebViewLink: String?
    var pixelWidth: Int?
    var pixelHeight: Int?
    var indexRecorded: Bool?
    var errorMessage: String?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        fileName: String,
        localFileName: String,
        status: Status = .queued,
        attemptCount: Int = 0,
        remoteFileID: String? = nil,
        remoteWebViewLink: String? = nil,
        pixelWidth: Int? = nil,
        pixelHeight: Int? = nil,
        indexRecorded: Bool? = nil,
        errorMessage: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.fileName = fileName
        self.localFileName = localFileName
        self.status = status
        self.attemptCount = attemptCount
        self.remoteFileID = remoteFileID
        self.remoteWebViewLink = remoteWebViewLink
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.indexRecorded = indexRecorded
        self.errorMessage = errorMessage
    }
}
