import SwiftUI

struct RedeemButton: View {
    @Environment(SheetTopupVM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
    
    @State private var showGiftCodeAlert = false
    @State private var giftCode = ""
    
    var body: some View {
        Menu {
            Button("Paste from clipboard", systemImage: "document.on.clipboard") {
                if let paste = UIPasteboard.general.string {
                    redeem(paste)
                }
            }
            
            Button("Enter manually", systemImage: "keyboard") {
                showGiftCodeAlert = true
            }
        } label: {
            Label("Redeem gift code", systemImage: "gift.fill")
                .labelIconToTitleSpacing(8)
                .rounded()
                .semibold()
                .frame(maxWidth: .infinity)
        }
#if !os(visionOS)
        .buttonStyle(.glass)
#endif
        .tint(Color.yellow.gradient)
        .disabled(vm.isGiftCodeLoading)
        .alert("Redeem gift code", isPresented: $showGiftCodeAlert) {
            TextField("Gift code", text: $giftCode)
                .limitInputLength($giftCode, length: 255)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            Button("Redeem", role: .confirmy) {
                redeem(giftCode)
            }
            .disabled(giftCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isGiftCodeLoading)
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a gift code to add bonus balance")
        }
    }
    
    private func redeem(_ code: String) {
        Task {
            if let _ = await vm.redeemGiftCode(code) {
                await dashboardVM.fetchUserInfo()
                await vm.fetchOperations()
                giftCode = ""
            }
        }
    }
}

#Preview {
    RedeemButton()
        .darkSchemePreferred()
}
