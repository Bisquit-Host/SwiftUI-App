import SwiftUI

struct VerificationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LoginVM.self) private var vm
    
    let userID: String?
    let onHCaptcha: () -> Void
    let onAppAttestSuccess: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Choose verification method")
                    .headline()
                    .padding(.top)
                
                VStack(spacing: 12) {
                    Button {
                        performAppAttest()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.shield")
                            
                            if vm.isAttesting {
                                ProgressView()
                            } else {
                                Text("App Attest")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
#if !os(visionOS)
                    .glassEffect()
#endif
                    .disabled(!vm.isAppAttestSupported || vm.isAttesting)
                    
                    Button {
                        dismiss()
                        onHCaptcha()
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.shield.checkmark")
                            Text("hCaptcha")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
#if !os(visionOS)
                    .glassEffect()
#endif
                }
                .padding(.horizontal)
                
                if let result = vm.attestationResult {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Attestation Success")
                            .headline()
                            .foregroundStyle(.green)
                        
                        if let userID = result.userID {
                            Text("User: \(userID)")
                                .caption()
                                .secondary()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Verify")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func performAppAttest() {
        Task {
            if let _ = await vm.performAppAttest(userID: userID) {
                dismiss()
                onAppAttestSuccess()
            }
        }
    }
}
