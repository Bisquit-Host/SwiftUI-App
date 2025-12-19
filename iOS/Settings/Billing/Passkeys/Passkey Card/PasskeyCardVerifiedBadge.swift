import SwiftUI

struct PasskeyCardVerifiedBadge: View {
    private let passkey: PasskeyListItem
    
    init(_ passkey: PasskeyListItem) {
        self.passkey = passkey
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: passkey.userVerified ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                .footnote()
            
            Text(passkey.userVerified ? "Verified" : "Not verified")
                .caption()
        }
        .foregroundStyle(passkey.userVerified ? .green : .yellow)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background((passkey.userVerified ? Color.green : .yellow).opacity(0.12), in: .capsule)
    }
}

//#Preview {
//    PasskeyCardVerifiedBadge()
//        .darkSchemePreferred()
//}
