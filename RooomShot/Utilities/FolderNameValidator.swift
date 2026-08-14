import Foundation

enum FolderNameValidator {
    static let maximumLength = 100

    static func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "_")
    }

    static func validate(_ value: String) throws -> String {
        let normalizedValue = normalized(value)
        guard !normalizedValue.isEmpty else {
            throw ValidationError.empty
        }
        guard normalizedValue.count <= maximumLength else {
            throw ValidationError.tooLong
        }
        return normalizedValue
    }

    enum ValidationError: LocalizedError {
        case empty
        case tooLong

        var errorDescription: String? {
            switch self {
            case .empty:
                return NSLocalizedString("error.folderName.empty", comment: "")
            case .tooLong:
                return NSLocalizedString("error.folderName.tooLong", comment: "")
            }
        }
    }
}

