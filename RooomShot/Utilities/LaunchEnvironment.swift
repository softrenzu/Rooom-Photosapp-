import Foundation

enum LaunchEnvironment {
    static var isScreenshotMode: Bool {
        ProcessInfo.processInfo.arguments.contains("-ScreenshotMode")
    }

    static var screenshotScreen: String {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-ScreenshotScreen"),
              arguments.indices.contains(index + 1) else {
            return "home"
        }
        return arguments[index + 1]
    }
}

