import Combine
import Foundation
import UIKit

@MainActor
final class UploadQueue: ObservableObject {
    @Published private(set) var items: [UploadItem] = []
    @Published private(set) var isProcessing = false
    @Published private(set) var setupError: String?

    var pendingCount: Int {
        items.filter { $0.status == .queued || $0.status == .uploading }.count
    }

    var latestItem: UploadItem? { items.first }

    private let auth: GoogleAuthService
    private let settings: AppSettings
    private let network: NetworkMonitor
    private let drive: GoogleDriveAPI
    private let fileManager: FileManager
    private var cancellables = Set<AnyCancellable>()

    private lazy var storageDirectory: URL = {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let directory = base.appendingPathComponent("RooomShotUploads", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }()

    private var stateURL: URL {
        storageDirectory.appendingPathComponent("upload_history.json")
    }

    init(
        auth: GoogleAuthService,
        settings: AppSettings,
        network: NetworkMonitor,
        drive: GoogleDriveAPI,
        fileManager: FileManager = .default
    ) {
        self.auth = auth
        self.settings = settings
        self.network = network
        self.drive = drive
        self.fileManager = fileManager
        load()
        recoverInterruptedUploads()

        network.$isConnected
            .removeDuplicates()
            .filter { $0 }
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.retryRecoverableFailures()
                    await self?.processQueue()
                }
            }
            .store(in: &cancellables)

        auth.$state
            .sink { [weak self] state in
                guard case .signedIn(email: _) = state else { return }
                Task { @MainActor in await self?.processQueue() }
            }
            .store(in: &cancellables)
    }

    func enqueue(image: UIImage) throws {
        let identifier = UUID()
        let fileName = UploadFileNamer.make(identifier: identifier)
        let data = try PhotoEncoder.jpegData(from: image, quality: settings.uploadQuality)
        let fileURL = storageDirectory.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)

        let item = UploadItem(
            id: identifier,
            fileName: fileName,
            localFileName: fileName,
            pixelWidth: Int((image.size.width * image.scale).rounded()),
            pixelHeight: Int((image.size.height * image.scale).rounded())
        )
        items.insert(item, at: 0)
        trimHistory()
        persist()
        Task { await processQueue() }
    }

    func configureDestination(named rawName: String) async throws {
        let name = try FolderNameValidator.validate(rawName)
        setupError = nil
        do {
            let folder = try await drive.createFolder(named: name)
            settings.setDestination(id: folder.id, name: folder.name)
            await processQueue()
        } catch {
            setupError = error.localizedDescription
            throw error
        }
    }

    func retry(_ id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }),
              items[index].localFileName != nil else { return }
        items[index].status = .queued
        items[index].errorMessage = nil
        persist()
        Task { await processQueue() }
    }

    func retryAll() {
        for index in items.indices where items[index].status == .failed && items[index].localFileName != nil {
            items[index].status = .queued
            items[index].errorMessage = nil
        }
        persist()
        Task { await processQueue() }
    }

    func clearCompleted() {
        items.removeAll { $0.status == .uploaded }
        persist()
    }

    func processQueue() async {
        guard !isProcessing,
              network.isConnected,
              auth.isSignedIn,
              !LaunchEnvironment.isScreenshotMode else { return }

        isProcessing = true
        defer { isProcessing = false }

        do {
            let destinationID = try await ensureDestination()
            while let index = items.firstIndex(where: { $0.status == .queued }) {
                items[index].status = .uploading
                items[index].errorMessage = nil
                persist()

                guard let localFileName = items[index].localFileName else {
                    items[index].status = .failed
                    items[index].errorMessage = NSLocalizedString("error.localFileMissing", comment: "")
                    persist()
                    continue
                }

                let localURL = storageDirectory.appendingPathComponent(localFileName)
                do {
                    let data = try Data(contentsOf: localURL)

                    if items[index].remoteFileID == nil {
                        let remote = try await drive.uploadJPEG(
                            data,
                            fileName: items[index].fileName,
                            folderID: destinationID
                        )
                        items[index].remoteFileID = remote.id
                        items[index].remoteWebViewLink = remote.webViewLink
                        persist()
                    }

                    guard let remoteFileID = items[index].remoteFileID else {
                        throw GoogleDriveAPI.APIError.invalidResponse
                    }

                    if items[index].indexRecorded != true {
                        let recognizedLines = (try? await Task.detached(priority: .utility) {
                            try TextRecognitionService.recognizeText(in: data)
                        }.value) ?? []

                        let entry = PhotoSearchIndexEntry(
                            id: items[index].id,
                            capturedAt: items[index].createdAt,
                            fileName: items[index].fileName,
                            driveFileID: remoteFileID,
                            driveWebViewLink: items[index].remoteWebViewLink,
                            folderID: destinationID,
                            pixelWidth: items[index].pixelWidth,
                            pixelHeight: items[index].pixelHeight,
                            ocrText: recognizedLines.joined(separator: "\n")
                        )
                        try await drive.upsertSearchIndex(entry: entry, folderID: destinationID)
                        items[index].indexRecorded = true
                        persist()
                    }

                    try? fileManager.removeItem(at: localURL)
                    items[index].status = .uploaded
                    items[index].localFileName = nil
                    items[index].errorMessage = nil
                } catch {
                    items[index].status = .failed
                    items[index].attemptCount += 1
                    items[index].errorMessage = error.localizedDescription
                    persist()
                    break
                }
                persist()
            }
        } catch {
            setupError = error.localizedDescription
        }
    }

    private func ensureDestination() async throws -> String {
        if settings.hasDestination {
            do {
                let existing = try await drive.folder(id: settings.destinationFolderID)
                if existing.trashed != true {
                    if existing.name != settings.destinationFolderName {
                        settings.setDestination(id: existing.id, name: existing.name)
                    }
                    return existing.id
                }
            } catch let error as GoogleDriveAPI.APIError where error.isNotFound {
                settings.clearDestination()
            }
        }

        let name = try FolderNameValidator.validate(settings.destinationFolderName)
        let folder = try await drive.createFolder(named: name)
        settings.setDestination(id: folder.id, name: folder.name)
        return folder.id
    }

    private func retryRecoverableFailures() {
        for index in items.indices
        where items[index].status == .failed
            && items[index].attemptCount < 3
            && items[index].localFileName != nil {
            items[index].status = .queued
            items[index].errorMessage = nil
        }
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: stateURL),
              let decoded = try? JSONDecoder().decode([UploadItem].self, from: data) else {
            items = []
            return
        }
        items = decoded
    }

    private func recoverInterruptedUploads() {
        for index in items.indices where items[index].status == .uploading {
            items[index].status = .queued
        }
        persist()
    }

    private func persist() {
        trimHistory()
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: stateURL, options: .atomic)
    }

    private func trimHistory() {
        guard items.count > 200 else { return }
        let removed = items.suffix(from: 200)
        for item in removed {
            if let localFileName = item.localFileName {
                try? fileManager.removeItem(at: storageDirectory.appendingPathComponent(localFileName))
            }
        }
        items = Array(items.prefix(200))
    }
}
