import Foundation

enum UploadFileNamer {
    static func make(date: Date = Date(), identifier: UUID = UUID()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "yyyyMMdd_HHmmss_SSS"
        let shortID = identifier.uuidString.prefix(8).uppercased()
        return "RooomShot_\(formatter.string(from: date))_\(shortID).jpg"
    }
}

