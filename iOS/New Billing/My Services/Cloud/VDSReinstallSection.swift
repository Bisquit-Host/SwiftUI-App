import SwiftUI

struct VDSReinstallSection: View {
    let serviceId: Int
    let osOptions: [(Int, String)]
    @Binding var selectedOsId: Int?
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    var body: some View {
        BillingSectionCard("Reinstall OS") {
            VStack(alignment: .leading, spacing: 8) {
                Picker("OS", selection: $selectedOsId) {
                    ForEach(osOptions, id: \.0) { os in
                        Text(os.1)
                            .tag(Optional(os.0))
                    }
                }
                .pickerStyle(.navigationLink)
                
                Button(role: .destructive) {
                    if let osId = selectedOsId {
                        Task { await vm.reinstall(osId: osId, serviceId: serviceId) }
                    }
                } label: {
                    Text("Reinstall")
                        .frame(maxWidth: .infinity)
                }
                .disabled(selectedOsId == nil || vm.isPerformingAction)
            }
        }
    }
}
