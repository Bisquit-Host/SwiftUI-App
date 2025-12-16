import SwiftUI

struct VDSProtectionIPSection: View {
    @Environment(VDSProtectionVM.self) private var vm
    @State private var selectedAction: VDSProtectionDefaultAction = .filter
    
    var body: some View {
        VDSSectionCard("Protection IP") {
            if let ip = vm.ipInfo {
                LabeledContent("IPv4", value: ip.ipv4)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Default action")
                        .subheadline(.semibold)
                    
                    Picker("Default action", selection: $selectedAction) {
                        ForEach(VDSProtectionDefaultAction.allCases) {
                            Text($0.title)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Button("Save default action") {
                    Task {
                        await vm.updateDefaultAction(selectedAction)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
                .disabled(
                    vm.isPerformingAction ||
                    !selectedAction.isUpdatable ||
                    selectedAction == (ip.defaultAction ?? .filter)
                )
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

