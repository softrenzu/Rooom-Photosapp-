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

