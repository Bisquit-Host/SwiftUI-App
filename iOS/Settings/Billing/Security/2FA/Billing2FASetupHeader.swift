import ScrechKit

struct Billing2FASetupHeader: View {
    var body: some View {
        VStack {
            Image(systemName: "shield.fill")
                .largeTitle()
                .foregroundStyle(.tint)
                .padding()
                .background(.tint.opacity(0.1), in: .circle)
                .accessibilityHidden(true)

            Text("Setup 2FA")
                .title2(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    Billing2FASetupHeader()
}
