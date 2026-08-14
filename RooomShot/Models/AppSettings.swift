import Foundation
import UIKit

enum UploadQuality: String, CaseIterable, Identifiable, Codable {
    case original
    case high
    case efficient

    var id: String { rawValue }

    var titleKey: LocalizedStringKeyName {
        switch self {
        case .original: return "quality.original"
        case .high: return "quality.high"
        case .efficient: return "quality.efficient"
        }
    }

    var compressionQuality: CGFloat {
        switch self {
        case .original: return 0.96
        case .high: return 0.88
        case .efficient: return 0.76
        }
    }

    var maximumDimension: CGFloat? {
        switch self {
        case .original: return nil
        case .high: return 4_096
        case .efficient: return 2_560
        }
    }
}

typealias LocalizedStringKeyName = String

@MainActor
final class AppSettings: ObservableObject {
    private enum Key {
        static let destinationFolderID = "destinationFolderID"
        static let destinationFolderName = "destinationFolderName"
        static let uploadQuality = "uploadQuality"
        static let hasCompletedWelcome = "hasCompletedWelcome"
    }

    private let defaults: UserDefaults

    @Published var destinationFolderID: String {
        didSet { defaults.set(destinationFolderID, forKey: Key.destinationFolderID) }
    }

    @Published var destinationFolderName: String {
        didSet { defaults.set(destinationFolderName, forKey: Key.destinationFolderName) }
    }

    @Published var uploadQuality: UploadQuality {
        didSet { defaults.set(uploadQuality.rawValue, forKey: Key.uploadQuality) }
    }

    @Published var hasCompletedWelcome: Bool {
        didSet { defaults.set(hasCompletedWelcome, forKey: Key.hasCompletedWelcome) }
    }

    var hasDestination: Bool {
        !destinationFolderID.isEmpty
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        destinationFolderID = defaults.string(forKey: Key.destinationFolderID) ?? ""
        destinationFolderName = defaults.string(forKey: Key.destinationFolderName) ?? "RooomShot"
        uploadQuality = UploadQuality(rawValue: defaults.string(forKey: Key.uploadQuality) ?? "") ?? .high
        hasCompletedWelcome = defaults.bool(forKey: Key.hasCompletedWelcome)
    }

    func setDestination(id: String, name: String) {
        destinationFolderID = id
        destinationFolderName = name
        hasCompletedWelcome = true
    }

    func clearDestination() {
        destinationFolderID = ""
        hasCompletedWelcome = false
    }
}

