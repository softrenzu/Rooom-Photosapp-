import SwiftUI

struct RootView: View {
    @EnvironmentObject private var auth: GoogleAuthService
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var subscriptions: SubscriptionManager

    var body: some View {
        Group {
            if LaunchEnvironment.isScreenshotMode {
                DemoShowcaseView(screen: LaunchEnvironment.screenshotScreen)
            } else {
                switch auth.state {
                case .restoring:
                    SplashView()
                case .signedOut, .error:
                    OnboardingView()
                case .signedIn(email: _):
                    if settings.hasDestination {
                        MainTabView()
                    } else {
                        OnboardingView()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .task { await subscriptions.prepare() }
    }
}

private struct SplashView: View {
    var body: some View {
        ZStack {
            BrandBackground()
            VStack(spacing: 18) {
                Image("AppMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 112, height: 112)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
                Text("RooomShot")
                    .font(.largeTitle.bold())
                ProgressView()
                    .tint(.white)
            }
            .foregroundStyle(.white)
        }
    }
}
