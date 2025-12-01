import SwiftUI

struct BillingSettingsPasskeys: View {
    var body: some View {
        NavigationLink {
            BillingPasskeysView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "key.fill")
                    .frame(32)
                    .glassEffect(.regular.tint(.blue.opacity(0.15)), in: .rect(cornerRadius: 10))
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Passkeys")
                        .subheadline(.semibold)
                    
                    Text("Sign in without a password!")
                        .footnote()
                        .secondary()
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .footnote()
                    .secondary()
            }
            .contentShape(.rect)
        }
        .foregroundStyle(.foreground)
    }
}

#Preview {
    BillingSettingsPasskeys()
        .darkSchemePreferred()
}
