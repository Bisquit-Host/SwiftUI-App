import SwiftUI

struct ApplePasswords2FAButton: View {
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
        if let url {
            Link(destination: url) {
                Label("Open in Password Manager", systemImage: "key.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.primary)
        }
    }
}
