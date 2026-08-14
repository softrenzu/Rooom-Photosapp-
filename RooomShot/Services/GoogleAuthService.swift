import Foundation
import GoogleSignIn
import UIKit

@MainActor
final class GoogleAuthService: ObservableObject {
    static let driveFileScope = "https://www.googleapis.com/auth/drive.file"

    enum SessionState: Equatable {
        case restoring
        case signedOut
        case signedIn(email: String)
        case error(message: String)
    }

    enum AuthenticationError: LocalizedError {
        case missingConfiguration
        case missingPresenter
        case noUser
        case noToken

        var errorDescription: String? {
            switch self {
            case .missingConfiguration:
                return NSLocalizedString("error.googleConfiguration", comment: "")
            case .missingPresenter:
                return NSLocalizedString("error.missingPresenter", comment: "")
            case .noUser:
                return NSLocalizedString("error.noGoogleUser", comment: "")
            case .noToken:
                return NSLocalizedString("error.noAccessToken", comment: "")
            }
        }
    }

    @Published private(set) var state: SessionState = .restoring

    var isSignedIn: Bool {
        GIDSignIn.sharedInstance.currentUser != nil || LaunchEnvironment.isScreenshotMode
    }

    var emailAddress: String? {
        if LaunchEnvironment.isScreenshotMode { return "photo@rooomtech.com" }
        return GIDSignIn.sharedInstance.currentUser?.profile?.email
    }

    init() {
        if LaunchEnvironment.isScreenshotMode {
            state = .signedIn(email: "photo@rooomtech.com")
        } else {
            restoreSession()
        }
    }

    func restoreSession() {
        state = .restoring
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            Task { @MainActor in
                guard let self else { return }
                if let user {
                    self.updateState(for: user)
                } else if let error {
                    self.state = .error(message: error.localizedDescription)
                } else {
                    self.state = .signedOut
                }
            }
        }
    }

    func signIn() async throws {
        try verifyConfiguration()
        let presenter = try Self.presentingViewController()

        let result: GIDSignInResult = try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                withPresenting: presenter,
                hint: nil,
                additionalScopes: [Self.driveFileScope]
            ) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: AuthenticationError.noUser)
                }
            }
        }

        updateState(for: result.user)
    }

    func validAccessToken() async throws -> String {
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            throw AuthenticationError.noUser
        }

        let refreshedUser: GIDGoogleUser = try await withCheckedThrowingContinuation { continuation in
            currentUser.refreshTokensIfNeeded { user, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let user {
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: AuthenticationError.noUser)
                }
            }
        }

        let token = refreshedUser.accessToken.tokenString
        guard !token.isEmpty else { throw AuthenticationError.noToken }
        return token
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        state = .signedOut
    }

    private func updateState(for user: GIDGoogleUser) {
        let email = user.profile?.email ?? NSLocalizedString("google.account.connected", comment: "")
        state = .signedIn(email: email)
    }

    private func verifyConfiguration() throws {
        let value = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String
        guard let value,
              !value.isEmpty,
              !value.contains("placeholder") else {
            throw AuthenticationError.missingConfiguration
        }
    }

    private static func presentingViewController() throws -> UIViewController {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            throw AuthenticationError.missingPresenter
        }

        return topViewController(from: root)
    }

    private static func topViewController(from root: UIViewController) -> UIViewController {
        if let presented = root.presentedViewController {
            return topViewController(from: presented)
        }
        if let navigation = root as? UINavigationController,
           let visible = navigation.visibleViewController {
            return topViewController(from: visible)
        }
        if let tabs = root as? UITabBarController,
           let selected = tabs.selectedViewController {
            return topViewController(from: selected)
        }
        return root
    }
}

