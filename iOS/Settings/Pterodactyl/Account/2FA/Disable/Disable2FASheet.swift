import ScrechKit

struct Disable2FASheet: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lock.slash")
                    .title(.semibold)
                    .frame(46)
                    .foregroundStyle(.white)
                    .background(.red.gradient, in: .rect(cornerRadius: 14))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Disable 2FA")
                        .title2(.semibold)
                    
                    Text("Removing two-factor reduces account protection. Confirm with your password to proceed")
                        .secondary()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Disable2FAInstructionRow("You’ll stop using one-time codes for login", systemImage: "exclamationmark.triangle")
                Disable2FAInstructionRow("You can re-enable 2FA later in Account settings", systemImage: "clock.arrow.circlepath")
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(.thinMaterial, in: .rect(cornerRadius: 18))
            .padding([.bottom, .horizontal])
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
    }
}
