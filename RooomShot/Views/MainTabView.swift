import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            CaptureHomeView()
                .tabItem { Label("tab.capture", systemImage: "camera.fill") }

            UploadHistoryView()
                .tabItem { Label("tab.history", systemImage: "clock.arrow.circlepath") }

            SettingsView()
                .tabItem { Label("tab.settings", systemImage: "gearshape.fill") }
        }
        .tint(.cyan)
    }
}

