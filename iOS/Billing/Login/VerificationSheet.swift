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
                Text("Verifying...")
                    .headline()
                    .padding(.top)
                
                ProgressView()
                    .padding()
                
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
        .task {
            await performAppAttest()
        }
    }
    
    private func performAppAttest() async {
        if vm.isAppAttestSupported, await vm.performAppAttest(userID: userID) {
            dismiss()
            onAppAttestSuccess()
        } else {
            dismiss()
            onHCaptcha()
        }
    }
}
