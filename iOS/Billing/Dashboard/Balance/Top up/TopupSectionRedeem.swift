import SwiftUI

struct TopupSectionRedeem: View {
    @Environment(SheetTopupVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    @State private var showGiftCodeAlert = false
    @State private var giftCode = ""
    
    var body: some View {
        Button {
            showGiftCodeAlert = true
        } label: {
            Label("Redeem gift code", systemImage: "gift.fill")
                .labelIconToTitleSpacing(8)
                .rounded()
                .semibold()
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glass)
        .tint(Color.yellow.gradient)
        .disabled(vm.isGiftCodeLoading)
        .alert("Redeem gift code", isPresented: $showGiftCodeAlert) {
            TextField("Gift code", text: $giftCode)
                .limitInputLength($giftCode, length: 255)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            Button("Redeem", role: .confirm) {
                Task {
                    if let _ = await vm.redeemGiftCode(giftCode) {
                        await dashboardVM.fetchUserInfo()
                        await vm.fetchOperations()
                        giftCode = ""
                    }
                }
            }
            .disabled(giftCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isGiftCodeLoading)
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a gift code to add bonus balance")
        }
    }
}

#Preview {
    TopupSectionRedeem()
        .darkSchemePreferred()
}
