import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let settings: AppSettings
    let auth: GoogleAuthService
    let network: NetworkMonitor
    let drive: GoogleDriveAPI
    let uploads: UploadQueue
    let subscriptions: SubscriptionManager

    init() {
        let settings = AppSettings()
        let auth = GoogleAuthService()
        let network = NetworkMonitor()
        let drive = GoogleDriveAPI(auth: auth)

        self.settings = settings
        self.auth = auth
        self.network = network
        self.drive = drive
        subscriptions = SubscriptionManager()
        uploads = UploadQueue(auth: auth, settings: settings, network: network, drive: drive)
    }
}
