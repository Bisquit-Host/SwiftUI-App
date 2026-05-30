import ScrechKit

struct Disable2FASheet: View {
    var body: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lock.slash")
                    .title3(.semibold)
                    .frame(30)
                    .foregroundStyle(.red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Password sign-ins will be less protected")
                        .subheadline(.semibold)
                    
                    Text("Your account will stop asking for one-time codes when you sign in")
                        .secondary()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        } footer: {
            Text("You can turn 2FA back on from Account settings")
        }
    }
}
