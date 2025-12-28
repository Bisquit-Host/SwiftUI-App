import SwiftUI

struct VDSProtectionIPSection: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    @State private var selectedAction: VDSProtectionDefaultAction = .filter
    
    var body: some View {
        ServiceSectionCard("Protection IP") {
            if let ip = vm.ipInfo {
                LabeledContent("IPv4", value: ip.ipv4)
                
                VDSProtectionDefaultActionPicker($selectedAction)
                
                if selectedAction != vm.ipInfo?.defaultAction {
                    Button("Save default action") {
                        Task {
                            await vm.updateDefaultAction(selectedAction)
                        }
                    }
                    .foregroundStyle(.foreground)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                }
            } else if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            } else {
                Text("No protection IP available")
                    .footnote()
                    .secondary()
            }
        }
        .onAppear {
            selectedAction = vm.ipInfo?.defaultAction ?? .filter
        }
        .onChange(of: vm.ipInfo?.defaultAction) { _, newValue in
            selectedAction = newValue ?? .filter
        }
    }
}

#Preview {
    VDSProtectionIPSection()
        .environment(VDSProtectionVM())
        .padding()
        .darkSchemePreferred()
}
