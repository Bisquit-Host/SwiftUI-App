import SwiftUI

struct RedeemButton: View {
    @Environment(SheetTopupVM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
    
    @State private var alertGiftCode = false
    @State private var giftCode = ""
    
    var body: some View {
        Button("Redeem gift code", systemImage: "gift.fill") {
            alertGiftCode = true
        }
        .labelStyle(.iconOnly)
        .tint(Color.yellow.gradient)
        .disabled(vm.isGiftCodeLoading)
        .alert("Redeem gift code", isPresented: $alertGiftCode) {
            TextField("Gift code", text: $giftCode)
                .limitInputLength($giftCode, length: 255)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            Button("Redeem", role: .confirm) {
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
