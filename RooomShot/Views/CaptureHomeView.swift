import SwiftUI
import UIKit

struct CaptureHomeView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var network: NetworkMonitor
    @EnvironmentObject private var uploads: UploadQueue
    @EnvironmentObject private var subscriptions: SubscriptionManager

    @State private var showCamera = false
    @State private var showPaywall = false
    @State private var alertMessage: String?
    @State private var showSavedConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                BrandBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        connectionCard
                        captureButton
                        helperText
                        latestUploadCard
                    }
                    .padding(20)
                }

                if showSavedConfirmation {
                    savedConfirmation
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("home.title")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showCamera) {
                CameraPicker(
                    onImage: { image in
                        showCamera = false
                        do {
                            try uploads.enqueue(image: image)
                            withAnimation(.spring(response: 0.35)) { showSavedConfirmation = true }
                            Task {
                                try? await Task.sleep(nanoseconds: 1_600_000_000)
                                await MainActor.run {
                                    withAnimation { showSavedConfirmation = false }
                                }
                            }
                        } catch {
                            alertMessage = error.localizedDescription
                        }
                    },
                    onCancel: { showCamera = false }
                )
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showPaywall) {
                SubscriptionPaywallView()
                    .environmentObject(subscriptions)
            }
            .alert("alert.title", isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button("common.ok", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private var connectionCard: some View {
        GlassCard {
            HStack(spacing: 14) {
                Image(systemName: network.isConnected ? "checkmark.icloud.fill" : "icloud.slash.fill")
                    .font(.title2)
                    .foregroundStyle(network.isConnected ? .green : .orange)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.08), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(network.isConnected ? "home.ready" : "home.offline")
                        .font(.headline)
                    Text(settings.destinationFolderName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                if uploads.pendingCount > 0 {
                    Text("\(uploads.pendingCount)")
                        .font(.headline.monospacedDigit())
                        .frame(minWidth: 30, minHeight: 30)
                        .background(.orange.opacity(0.18), in: Circle())
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    private var captureButton: some View {
        Button {
            guard subscriptions.isSubscribed else {
                showPaywall = true
                return
            }
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                alertMessage = NSLocalizedString("error.cameraUnavailable", comment: "")
                return
            }
            showCamera = true
        } label: {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.12))
                    .frame(width: 204, height: 204)
                Circle()
                    .stroke(.white.opacity(0.24), lineWidth: 2)
                    .frame(width: 174, height: 174)
                Circle()
                    .fill(.white)
                    .frame(width: 142, height: 142)
                    .shadow(color: .cyan.opacity(0.45), radius: 30)
                Image(systemName: "camera.fill")
                    .font(.system(size: 45, weight: .semibold))
                    .foregroundStyle(Color(red: 0.03, green: 0.24, blue: 0.7))
                if !subscriptions.isSubscribed {
                    Image(systemName: "lock.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(Color.accentColor, in: Circle())
                        .offset(x: 62, y: 62)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(LocalizedStringKey(subscriptions.isSubscribed
                                                    ? "home.capture.accessibility"
                                                    : "subscription.showPlan")))
        .accessibilityHint(Text("home.capture.hint"))
    }

    private var helperText: some View {
        VStack(spacing: 6) {
            Text("home.capture")
                .font(.title2.bold())
            Text(LocalizedStringKey(subscriptions.isSubscribed
                                    ? (network.isConnected ? "home.capture.onlineHint" : "home.capture.offlineHint")
                                    : "subscription.captureLockedHint"))
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    @ViewBuilder
    private var latestUploadCard: some View {
        if let item = uploads.latestItem {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("home.latest")
                        .font(.headline)
                    HStack {
                        Image(systemName: "photo.fill")
                            .foregroundStyle(.cyan)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.fileName)
                                .font(.caption.monospaced())
                                .lineLimit(1)
                            Text(item.createdAt, format: .dateTime.hour().minute().second())
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        UploadStatusBadge(status: item.status)
                    }
                }
            }
        }
    }

    private var savedConfirmation: some View {
        Label("home.savedToQueue", systemImage: "checkmark.circle.fill")
            .font(.headline)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.ultraThickMaterial, in: Capsule())
            .shadow(radius: 20)
    }
}
