import XCTest

final class RooomShotScreenshotTests: XCTestCase {
    func testScreenshotSurfacesLaunch() {
        for screen in ["home", "uploading", "history", "settings"] {
            let app = XCUIApplication()
            app.launchArguments = ["-ScreenshotMode", "-ScreenshotScreen", screen]
            app.launch()
            XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5), "Missing tab bar for \(screen)")

            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = "RooomShot_\(screen)"
            attachment.lifetime = .keepAlways
            add(attachment)
            app.terminate()
        }
    }
}
