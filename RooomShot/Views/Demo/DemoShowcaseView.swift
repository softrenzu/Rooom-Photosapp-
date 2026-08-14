import SwiftUI

struct DemoShowcaseView: View {
    let screen: String

    private var selection: String {
        switch screen {
        case "history": return "history"
        case "settings": return "settings"
        default: return "home"
        }
    }

    var body: some View {
        TabView(selection: .constant(selection)) {
            DemoHomeScreen(isUploading: screen == "uploading")
                .tag("home")
                .tabItem { Label("tab.capture", systemImage: "camera.fill") }

            DemoHistoryScreen()
                .tag("history")
                .tabItem { Label("tab.history", systemImage: "clock.arrow.circlepath") }

            DemoSettingsScreen()
                .tag("settings")
                .tabItem { Label("tab.settings", systemImage: "gearshape.fill") }
        }
        .tint(.cyan)
    }
}

private struct DemoHomeScreen: View {
    let isUploading: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                BrandBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        GlassCard {
                            HStack(spacing: 14) {
                                Image(systemName: "checkmark.icloud.fill")
                                    .font(.title2)
                                    .foregroundStyle(.green)
                                    .frame(width: 44, height: 44)
                                    .background(.white.opacity(0.08), in: Circle())
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("home.ready").font(.headline)
                                    Text("RooomShot").font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if isUploading {
                                    Text("1")
                                        .font(.headline.monospacedDigit())
                                        .frame(width: 32, height: 32)
                                        .background(.orange.opacity(0.18), in: Circle())
                                        .foregroundStyle(.orange)
                                }
                            }
                        }

                        ZStack {
                            Circle().fill(.white.opacity(0.12)).frame(width: 204, height: 204)
                            Circle().stroke(.white.opacity(0.24), lineWidth: 2).frame(width: 174, height: 174)
                            Circle().fill(.white).frame(width: 142, height: 142)
                                .shadow(color: .cyan.opacity(0.45), radius: 30)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 45, weight: .semibold))
                                .foregroundStyle(Color(red: 0.03, green: 0.24, blue: 0.7))
                        }

                        VStack(spacing: 6) {
                            Text("home.capture").font(.title2.bold())
                            Text("home.capture.onlineHint")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("home.latest").font(.headline)
                                HStack {
                                    Image(systemName: "photo.fill").foregroundStyle(.cyan)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("RooomShot_20260814_194218_A1B2C3D4.jpg")
                                            .font(.caption.monospaced()).lineLimit(1)
                                        Text("19:42:18").font(.caption2).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    UploadStatusBadge(status: isUploading ? .uploading : .uploaded)
                                }
                                if isUploading {
                                    ProgressView(value: 0.72).tint(.cyan)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("home.title")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

private struct DemoHistoryScreen: View {
    private let rows: [(String, UploadItem.Status, String)] = [
        ("RooomShot_20260814_194218_A1B2C3D4.jpg", .uploaded, "2026/08/14 19:42"),
        ("RooomShot_20260814_182703_E5F6A7B8.jpg", .uploaded, "2026/08/14 18:27"),
        ("RooomShot_20260814_164511_C9D0E1F2.jpg", .uploaded, "2026/08/14 16:45"),
        ("RooomShot_20260813_221904_3344AABB.jpg", .uploaded, "2026/08/13 22:19")
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 12) {
                            Image(systemName: "photo.fill")
                                .foregroundStyle(.cyan)
                                .frame(width: 34, height: 34)
                                .background(.cyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(row.0).font(.caption.monospaced()).lineLimit(1)
                                Text(row.2).font(.caption2).foregroundStyle(.secondary)
                            }
                            Spacer()
                            UploadStatusBadge(status: row.1)
                        }
                        .padding(.vertical, 7)
                        .listRowBackground(Color.white.opacity(0.055))
                    }
                } header: {
                    Text("history.recent")
                }
            }
            .scrollContentBackground(.hidden)
            .background(BrandBackground())
            .navigationTitle("history.title")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

private struct DemoSettingsScreen: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("settings.account") {
                    Label("photo@rooomtech.com", systemImage: "person.crop.circle.fill")
                }
                Section("settings.destination") {
                    LabeledContent("settings.folder", value: "RooomShot")
                    Label("settings.newFolder", systemImage: "folder.badge.plus")
                    Text("settings.folderHint").font(.caption).foregroundStyle(.secondary)
                }
                Section("settings.quality") {
                    LabeledContent("settings.quality", value: NSLocalizedString("quality.high", comment: ""))
                    Text("settings.qualityHint").font(.caption).foregroundStyle(.secondary)
                }
                Section("settings.privacySupport") {
                    Label("link.privacy", systemImage: "hand.raised.fill")
                    Label("link.support", systemImage: "questionmark.circle.fill")
                }
                Section("settings.about") {
                    LabeledContent("settings.version", value: "1.0.0 (1)")
                    LabeledContent("settings.developer", value: "ROOOMTECH株式会社")
                }
            }
            .navigationTitle("settings.title")
        }
    }
}

