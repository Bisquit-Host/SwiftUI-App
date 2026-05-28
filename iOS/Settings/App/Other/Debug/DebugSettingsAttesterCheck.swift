import SwiftUI

struct DebugSettingsAttesterCheck: View {
    @State private var isChecking = false
    
    var body: some View {
        Section {
            Button(action: runCheck) {
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
    
    private func runCheck() {
        guard !isChecking else { return }
        isChecking = true
        
        Task {
            defer { isChecking = false }
            
            do {
                let result = try await AttestService.shared.attestDevice()
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
