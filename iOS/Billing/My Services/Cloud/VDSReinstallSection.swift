import SwiftUI

struct VDSReinstallSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    let serviceId: Int
    @Binding var selectedOS: Int?
    
    var body: some View {
        VDSSectionCard("Reinstall OS") {
            VStack(alignment: .leading, spacing: 8) {
                Picker("OS", selection: $selectedOS) {
                    ForEach(flatOSOptions(), id: \.0) {
                        Text($0.1)
                            .tag($0.0)
                    }
                }
                .pickerStyle(.navigationLink)
                
                Button(role: .destructive) {
                    if let osId = selectedOS {
                        Task {
                            await vm.reinstall(osId: osId, serviceId: serviceId)
                        }
                    }
                } label: {
                    Text("Reinstall")
                        .frame(maxWidth: .infinity)
                }
                .disabled(selectedOS == nil || vm.isPerformingAction)
            }
        }
        .onChange(of: vm.osOptions.count) { _, _ in
            if selectedOS == nil {
                selectedOS = flatOSOptions().first?.0
            }
        }
    }
    
    private func flatOSOptions() -> [(Int, String)] {
        vm.osOptions.flatMap { category in
            category.os.map {
                ($0.id, "\(category.name) \($0.version ?? "")")
            }
        }
    }
}
