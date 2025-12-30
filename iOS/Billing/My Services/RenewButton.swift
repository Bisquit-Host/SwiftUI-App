import SwiftUI

struct RenewButton: View {
    @Binding var isPerformingAction: Bool
    @Binding var renewMonths: Int
    let name: String?
    let confirmPayment: () -> Void
    
    @State private var alertRenew = false
    
    var body: some View {
        HStack(spacing: 5) {
            Button {
                alertRenew = true
            } label: {
                if isPerformingAction {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Renew for")
                        .semibold()
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.glassProminent)
            .disabled(isPerformingAction)
            
            MonthAmountPicker($renewMonths)
        }
        .padding(8)
        .background(.ultraThinMaterial, in: .capsule)
        .alert("Renew service", isPresented: $alertRenew) {
            Button("Confirm payment", role: .confirm, action: confirmPayment)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Renew \(name ?? "this service") for \(renewMonths) \(renewMonths == 1 ? "month" : "months")?")
        }
    }
}

//#Preview {
//    RenewButton()
//}
