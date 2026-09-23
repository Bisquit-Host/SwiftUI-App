import ScrechKit

struct DebugSettingsAttesterCheck: View {
    @State private var isChecking = false
    
    var body: some View {
        Section {
            AsyncButton(action: runCheck) {
                HStack {
                    Text("Run attester check")
                    
                    Spacer()
                    
                    if isChecking {
                        ProgressView()
                    }
                }
            }
            .disabled(isChecking)
        }
    }
    
    private func runCheck() async {
        guard !isChecking else { return }
        isChecking = true
        
        defer { isChecking = false }
        
        do {
            let result = try await AttestService.shared.attestDevice()
            let keyPrefix = String(result.keyID.prefix(8))
            
            SystemAlert.done("Attester check passed", subtitle: String(localized: "Key \(keyPrefix)"))
        } catch {
            SystemAlert.error("Attester check failed", subtitle: error.localizedDescription)
        }
    }
}

#Preview {
    DebugSettingsAttesterCheck()
        .darkSchemePreferred()
}
