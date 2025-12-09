import SwiftUI

struct VDSReinstallSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    let serviceId: Int
    let osOptions: [(Int, String)]
    @Binding var selectedOS: Int?
    var body: some View {
        BillingSectionCard("Reinstall OS") {
            VStack(alignment: .leading, spacing: 8) {
                Picker("OS", selection: $selectedOS) {
                    ForEach(osOptions, id: \.0) { os in
                        Text(os.1)
                            .tag(Optional(os.0))
                    }
                }
                .pickerStyle(.navigationLink)
                
                Button(role: .destructive) {
                    if let osId = selectedOS {
                        Task { await vm.reinstall(osId: osId, serviceId: serviceId) }
                    }
                } label: {
                    Text("Reinstall")
                        .frame(maxWidth: .infinity)
                }
                .disabled(selectedOS == nil || vm.isPerformingAction)
            }
        }
    }
}
