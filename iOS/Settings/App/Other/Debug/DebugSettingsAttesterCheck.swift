import SwiftUI

struct DebugSettingsAttesterCheck: View {
    @State private var isChecking = false
    
    var body: some View {
        Section {
            Button(String("Run attester check"), systemImage: "checkmark.shield", action: runCheck)
                .disabled(isChecking)
        } footer: {
            if isChecking {
                Text("Checking App Attest")
            }
        }
    }
    
    private func runCheck() {
        guard !isChecking else { return }
        isChecking = true
        
        Task {
            defer { isChecking = false }
            
            do {
                let result = try await AppAttestService.shared.attestDevice()
                let keyPrefix = String(result.keyID.prefix(8))
                
                SystemAlert.done("Attester check passed", subtitle: "Key \(keyPrefix)")
            } catch {
                SystemAlert.error("Attester check failed", subtitle: error.localizedDescription)
            }
        }
    }
}

#Preview {
    DebugSettingsAttesterCheck()
        .darkSchemePreferred()
}
