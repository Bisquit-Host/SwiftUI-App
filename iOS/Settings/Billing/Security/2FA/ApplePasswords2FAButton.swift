import SwiftUI

struct ApplePasswords2FAButton: View {
    @Environment(\.openURL) private var openURL
    @State private var showingOpenError = false

    private let url: URL?

    init(serviceName: String, accountName: String, secret: String, issuer: String = "bisquit.host") {
        url = ApplePasswords2FAURL.make(
            serviceName: serviceName,
            accountName: accountName,
            secret: secret,
            issuer: issuer
        )
    }

    var body: some View {
        Button("Open in password manager", systemImage: "key") {
            guard let url else {
                showingOpenError = true
                return
            }

            openURL(url) { accepted in
                showingOpenError = !accepted
            }
        }
        .alert("Password manager unavailable", isPresented: $showingOpenError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Copy the 2FA secret and add it manually as a verification code in your password manager")
        }
    }
}
