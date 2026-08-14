import SwiftUI

@main
struct RooomShotApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container.settings)
                .environmentObject(container.auth)
                .environmentObject(container.network)
                .environmentObject(container.uploads)
        }
    }
}
