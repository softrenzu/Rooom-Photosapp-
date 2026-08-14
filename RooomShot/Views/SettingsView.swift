import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var auth: GoogleAuthService
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var uploads: UploadQueue
    @EnvironmentObject private var subscriptions: SubscriptionManager

    @State private var showFolderSheet = false
    @State private var folderName = "RooomShot"
    @State private var isCreatingFolder = false
    @State private var folderError: String?
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Form {
                Section("settings.subscription") {
                    LabeledContent("settings.subscriptionStatus") {
                        Text(LocalizedStringKey(subscriptions.isSubscribed
                                                ? "subscription.active"
                                                : "subscription.inactive"))
                            .foregroundStyle(subscriptions.isSubscribed ? .green : .secondary)
                    }

                    if subscriptions.isSubscribed {
                        Link(destination: SubscriptionPlan.manageSubscriptionsURL) {
                            Label("subscription.manage", systemImage: "creditcard.fill")
                        }
                    } else {
                        Button("subscription.showPlan", systemImage: "sparkles") {
                            showPaywall = true
                        }
                    }

                    Button("subscription.restore", systemImage: "arrow.clockwise") {
                        Task { await subscriptions.restorePurchases() }
                    }
                    .disabled(subscriptions.isLoading)

                    if let errorMessage = subscriptions.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                Section("settings.account") {
                    Label(auth.emailAddress ?? "—", systemImage: "person.crop.circle.fill")
                    Button("settings.signOut", role: .destructive) {
                        settings.clearDestination()
                        auth.signOut()
                    }
                }

                Section("settings.destination") {
                    LabeledContent("settings.folder", value: settings.destinationFolderName)
                    Button("settings.newFolder", systemImage: "folder.badge.plus") {
                        folderName = settings.destinationFolderName
                        showFolderSheet = true
                    }
                    Text("settings.folderHint")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("settings.quality") {
                    Picker("settings.quality", selection: $settings.uploadQuality) {
                        ForEach(UploadQuality.allCases) { quality in
                            Text(LocalizedStringKey(quality.titleKey)).tag(quality)
                        }
                    }
                    Text("settings.qualityHint")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("settings.privacySupport") {
                    Link(destination: URL(string: "https://github.com/softrenzu/Rooom-Photosapp-/blob/main/PRIVACY.md")!) {
                        Label("link.privacy", systemImage: "hand.raised.fill")
                    }
                    Link(destination: URL(string: "https://github.com/softrenzu/Rooom-Photosapp-/issues")!) {
                        Label("link.support", systemImage: "questionmark.circle.fill")
                    }
                    Link(destination: URL(string: "mailto:support@rooomtech.com")!) {
                        Label("settings.emailSupport", systemImage: "envelope.fill")
                    }
                }

                Section("settings.about") {
                    LabeledContent("settings.version", value: versionText)
                    LabeledContent("settings.developer", value: "ROOOMTECH株式会社")
                }
            }
            .navigationTitle("settings.title")
            .sheet(isPresented: $showPaywall) {
                SubscriptionPaywallView()
                    .environmentObject(subscriptions)
            }
            .sheet(isPresented: $showFolderSheet) {
                NavigationStack {
                    Form {
                        Section("settings.newFolder") {
                            TextField("onboarding.folder.placeholder", text: $folderName)
                                .autocorrectionDisabled()
                            Text("settings.newFolderWarning")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if let folderError {
                            Section {
                                Label(folderError, systemImage: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .navigationTitle("settings.newFolder")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("common.cancel") { showFolderSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("common.create") {
                                Task {
                                    isCreatingFolder = true
                                    defer { isCreatingFolder = false }
                                    do {
                                        try await uploads.configureDestination(named: folderName)
                                        folderError = nil
                                        showFolderSheet = false
                                    } catch {
                                        folderError = error.localizedDescription
                                    }
                                }
                            }
                            .disabled(isCreatingFolder || FolderNameValidator.normalized(folderName).isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}
