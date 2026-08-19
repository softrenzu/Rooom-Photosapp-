import Foundation

struct DriveFolder: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let mimeType: String?
    let trashed: Bool?
}

struct DriveFile: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let mimeType: String?
    let webViewLink: String?
}

actor GoogleDriveAPI {
    enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case http(status: Int, message: String)
        case missingUploadLocation

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return NSLocalizedString("error.invalidURL", comment: "")
            case .invalidResponse:
                return NSLocalizedString("error.invalidServerResponse", comment: "")
            case let .http(status, message):
                return "Google Drive (\(status)): \(message)"
            case .missingUploadLocation:
                return NSLocalizedString("error.missingUploadLocation", comment: "")
            }
        }

        var isNotFound: Bool {
            if case .http(status: 404, message: _) = self { return true }
            return false
        }
    }

    private struct FolderMetadata: Encodable {
        let name: String
        let mimeType = "application/vnd.google-apps.folder"
    }

    private struct UploadMetadata: Encodable {
        let name: String
        let parents: [String]
        let mimeType = "image/jpeg"
    }

    private struct TextFileMetadata: Encodable {
        let name: String
        let parents: [String]
        let mimeType: String
    }

    private struct FileListResponse: Decodable {
        let files: [DriveFile]
    }

    private struct GoogleErrorEnvelope: Decodable {
        struct GoogleError: Decodable {
            let message: String
        }
        let error: GoogleError
    }

    private let auth: GoogleAuthService
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(auth: GoogleAuthService, session: URLSession = .shared) {
        self.auth = auth
        self.session = session
    }

    func createFolder(named name: String) async throws -> DriveFolder {
        let token = try await auth.validAccessToken()
        guard let url = URL(string: "https://www.googleapis.com/drive/v3/files?fields=id,name,mimeType,trashed") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(FolderMetadata(name: name))

        let data = try await perform(request)
        return try decoder.decode(DriveFolder.self, from: data)
    }

    func folder(id: String) async throws -> DriveFolder {
        let token = try await auth.validAccessToken()
        guard var components = URLComponents(string: "https://www.googleapis.com/drive/v3/files/\(id)") else {
            throw APIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "fields", value: "id,name,mimeType,trashed"),
            URLQueryItem(name: "supportsAllDrives", value: "true")
        ]
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let data = try await perform(request)
        return try decoder.decode(DriveFolder.self, from: data)
    }

    func uploadJPEG(_ jpegData: Data, fileName: String, folderID: String) async throws -> DriveFile {
        let token = try await auth.validAccessToken()
        guard var components = URLComponents(string: "https://www.googleapis.com/upload/drive/v3/files") else {
            throw APIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "uploadType", value: "resumable"),
            URLQueryItem(name: "supportsAllDrives", value: "true"),
            URLQueryItem(name: "fields", value: "id,name,mimeType,webViewLink")
        ]
        guard let url = components.url else { throw APIError.invalidURL }

        var startRequest = URLRequest(url: url)
        startRequest.httpMethod = "POST"
        startRequest.timeoutInterval = 60
        startRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        startRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        startRequest.setValue("image/jpeg", forHTTPHeaderField: "X-Upload-Content-Type")
        startRequest.setValue(String(jpegData.count), forHTTPHeaderField: "X-Upload-Content-Length")
        startRequest.httpBody = try encoder.encode(UploadMetadata(name: fileName, parents: [folderID]))

        let (_, startResponse) = try await session.data(for: startRequest)
        let startHTTP = try validate(startResponse, data: Data())
        guard let location = startHTTP.value(forHTTPHeaderField: "Location"),
              let uploadURL = URL(string: location) else {
            throw APIError.missingUploadLocation
        }

        var uploadRequest = URLRequest(url: uploadURL)
        uploadRequest.httpMethod = "PUT"
        uploadRequest.timeoutInterval = 180
        uploadRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        uploadRequest.setValue(String(jpegData.count), forHTTPHeaderField: "Content-Length")

        let (responseData, response) = try await session.upload(for: uploadRequest, from: jpegData)
        _ = try validate(response, data: responseData)
        return try decoder.decode(DriveFile.self, from: responseData)
    }

    func upsertSearchIndex(entry: PhotoSearchIndexEntry, folderID: String) async throws {
        if let existing = try await file(named: PhotoSearchIndex.fileName, in: folderID) {
            let existingData = try await downloadFile(id: existing.id)
            var index = try PhotoSearchIndex.decode(from: existingData)
            index.upsert(entry)
            _ = try await updateTextFile(
                try index.encoded(),
                fileID: existing.id,
                mimeType: "application/json"
            )
        } else {
            var index = PhotoSearchIndex()
            index.upsert(entry)
            _ = try await createTextFile(
                try index.encoded(),
                fileName: PhotoSearchIndex.fileName,
                folderID: folderID,
                mimeType: "application/json"
            )
        }
    }

    private func file(named name: String, in folderID: String) async throws -> DriveFile? {
        let token = try await auth.validAccessToken()
        guard var components = URLComponents(string: "https://www.googleapis.com/drive/v3/files") else {
            throw APIError.invalidURL
        }

        let escapedName = escapeDriveQueryValue(name)
        let escapedFolderID = escapeDriveQueryValue(folderID)
        components.queryItems = [
            URLQueryItem(name: "q", value: "'\(escapedFolderID)' in parents and name = '\(escapedName)' and trashed = false"),
            URLQueryItem(name: "spaces", value: "drive"),
            URLQueryItem(name: "pageSize", value: "1"),
            URLQueryItem(name: "supportsAllDrives", value: "true"),
            URLQueryItem(name: "includeItemsFromAllDrives", value: "true"),
            URLQueryItem(name: "fields", value: "files(id,name,mimeType,webViewLink)")
        ]
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let data = try await perform(request)
        return try decoder.decode(FileListResponse.self, from: data).files.first
    }

    private func downloadFile(id: String) async throws -> Data {
        let token = try await auth.validAccessToken()
        guard var components = URLComponents(string: "https://www.googleapis.com/drive/v3/files/\(id)") else {
            throw APIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "alt", value: "media"),
            URLQueryItem(name: "supportsAllDrives", value: "true")
        ]
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return try await perform(request)
    }

    private func createTextFile(
        _ data: Data,
        fileName: String,
        folderID: String,
        mimeType: String
    ) async throws -> DriveFile {
        let token = try await auth.validAccessToken()
        guard var components = URLComponents(string: "https://www.googleapis.com/upload/drive/v3/files") else {
            throw APIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "uploadType", value: "multipart"),
            URLQueryItem(name: "supportsAllDrives", value: "true"),
            URLQueryItem(name: "fields", value: "id,name,mimeType,webViewLink")
        ]
        guard let url = components.url else { throw APIError.invalidURL }

        let boundary = "RooomShot-\(UUID().uuidString)"
        let metadata = try encoder.encode(
            TextFileMetadata(name: fileName, parents: [folderID], mimeType: mimeType)
        )
        var body = Data()
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Type: application/json; charset=utf-8\r\n\r\n".utf8))
        body.append(metadata)
        body.append(Data("\r\n--\(boundary)\r\n".utf8))
        body.append(Data("Content-Type: \(mimeType)\r\n\r\n".utf8))
        body.append(data)
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/related; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let responseData = try await perform(request)
        return try decoder.decode(DriveFile.self, from: responseData)
    }

    private func updateTextFile(
        _ data: Data,
        fileID: String,
        mimeType: String
    ) async throws -> DriveFile {
        let token = try await auth.validAccessToken()
        guard var components = URLComponents(string: "https://www.googleapis.com/upload/drive/v3/files/\(fileID)") else {
            throw APIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "uploadType", value: "media"),
            URLQueryItem(name: "supportsAllDrives", value: "true"),
            URLQueryItem(name: "fields", value: "id,name,mimeType,webViewLink")
        ]
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(mimeType, forHTTPHeaderField: "Content-Type")

        let (responseData, response) = try await session.upload(for: request, from: data)
        _ = try validate(response, data: responseData)
        return try decoder.decode(DriveFile.self, from: responseData)
    }

    private func escapeDriveQueryValue(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        _ = try validate(response, data: data)
        return data
    }

    @discardableResult
    private func validate(_ response: URLResponse, data: Data) throws -> HTTPURLResponse {
        guard let response = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(response.statusCode) else {
            let message = (try? decoder.decode(GoogleErrorEnvelope.self, from: data).error.message)
                ?? String(data: data, encoding: .utf8)
                ?? NSLocalizedString("error.unknown", comment: "")
            throw APIError.http(status: response.statusCode, message: message)
        }
        return response
    }
}
