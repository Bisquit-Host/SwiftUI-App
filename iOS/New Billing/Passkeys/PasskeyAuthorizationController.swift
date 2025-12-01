import AuthenticationServices
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

@MainActor
final class PasskeyAuthorizationController: NSObject {
    private var continuation: CheckedContinuation<ASAuthorizationCredential, Error>?

    func perform(_ request: ASAuthorizationRequest) async throws -> ASAuthorizationCredential {
        try await withCheckedThrowingContinuation { continuation in
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self

            self.continuation = continuation
            controller.performRequests()
        }
    }
}

extension PasskeyAuthorizationController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation?.resume(returning: authorization.credential)
        continuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

extension PasskeyAuthorizationController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
#if canImport(UIKit)
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let activeScene = scenes.first { $0.activationState == .foregroundActive }
        let window = activeScene?.keyWindow
            ?? scenes.flatMap(\.windows).first(where: \.isKeyWindow)

        if let window {
            return window
        }

        guard let scene = activeScene ?? scenes.first else {
            fatalError("ASAuthorizationController requires an active UIWindowScene")
        }

        return UIWindow(windowScene: scene)
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
        return NSApplication.shared.windows.first ?? ASPresentationAnchor()
#else
        return ASPresentationAnchor()
#endif
    }
}
