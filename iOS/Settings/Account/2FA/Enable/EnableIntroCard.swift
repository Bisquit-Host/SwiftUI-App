import ScrechKit

struct EnableIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lock.shield")
                    .title(.semibold)
                    .frame(46)
                    .foregroundStyle(.white)
                    .background(.blue.gradient, in: .rect(cornerRadius: 14))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable 2FA")
                        .title2(.semibold)
                    
                    Text("Use your authenticator app to scan the code or open the setup link, then confirm the 6-digit code below")
                        .secondary()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            
            EnableInstructionsCard()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
    }
}
