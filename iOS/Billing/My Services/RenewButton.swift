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
#if !os(visionOS)
            .buttonStyle(.glassProminent)
#endif
            .disabled(isPerformingAction)
            
            MonthAmountPicker($renewMonths)
        }
        .padding(8)
        .background(.ultraThinMaterial, in: .capsule)
        .alert("Renew service", isPresented: $alertRenew) {
            Button("Confirm payment", role: .confirm, action: confirmPayment)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(renewalMessage)
        }
    }

    private var renewalMessage: String {
        let serviceName = name ?? String(localized: "this service")
        let duration = String.localizedStringWithFormat(String(localized: "%lld months"), Int64(renewMonths))

        return String(localized: "Renew \(serviceName) for \(duration)?")
    }
}

//#Preview {
//    RenewButton()
//}
