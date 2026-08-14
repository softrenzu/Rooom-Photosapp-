import GoogleSignInSwift
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var auth: GoogleAuthService
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var uploads: UploadQueue

    @State private var folderName = "RooomShot"
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            BrandBackground()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 42)

                    Image("AppMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .black.opacity(0.3), radius: 22, y: 12)

                    VStack(spacing: 8) {
                        Text("RooomShot")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                        Text("onboarding.tagline")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.78))
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            if auth.isSignedIn {
                                destinationStep
                            } else {
                                signInStep
                            }
                        }
                    }

                    privacySummary
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 22)
            }
        }
        .foregroundStyle(.white)
        .onAppear { folderName = settings.destinationFolderName }
    }

    private var signInStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(number: "1", title: "onboarding.connect.title", icon: "person.crop.circle.badge.checkmark")
            Text("onboarding.connect.body")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            GoogleSignInButton {
                Task {
                    isWorking = true
                    defer { isWorking = false }
                    do {
                        try await auth.signIn()
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .frame(height: 50)
            .disabled(isWorking)

            if isWorking { ProgressView().frame(maxWidth: .infinity) }
            errorView
        }
    }

    private var destinationStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(number: "2", title: "onboarding.folder.title", icon: "folder.badge.plus")
            Text("onboarding.folder.body")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("onboarding.folder.placeholder", text: $folderName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(14)
                .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 14))
                .accessibilityLabel(Text("onboarding.folder.accessibility"))

            Button {
                Task {
                    isWorking = true
                    defer { isWorking = false }
                    do {
                        try await uploads.configureDestination(named: folderName)
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            } label: {
                HStack {
                    if isWorking { ProgressView().tint(.white) }
                    Text("onboarding.start")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .disabled(isWorking || FolderNameValidator.normalized(folderName).isEmpty)

            errorView
        }
    }

    private func stepHeader(number: String, title: LocalizedStringKey, icon: String) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.headline)
                .frame(width: 32, height: 32)
                .background(Color.accentColor, in: Circle())
            Label(title, systemImage: icon)
                .font(.headline)
        }
    }

    @ViewBuilder
    private var errorView: some View {
        if let message = errorMessage ?? uploads.setupError {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }

    private var privacySummary: some View {
        VStack(spacing: 8) {
            Label("onboarding.privacy", systemImage: "lock.shield.fill")
                .font(.footnote.weight(.semibold))
            HStack(spacing: 16) {
                Link("link.privacy", destination: URL(string: "https://github.com/softrenzu/Rooom-Photosapp-/blob/main/PRIVACY.md")!)
                Link("link.support", destination: URL(string: "https://github.com/softrenzu/Rooom-Photosapp-/issues")!)
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.72))
        }
    }
}

