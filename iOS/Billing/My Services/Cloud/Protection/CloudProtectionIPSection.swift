import SwiftUI

struct CloudProtectionIPSection: View {
    @Environment(CloudProtectionVM.self) private var vm
    @State private var selectedAction: CloudProtectionDefaultAction = .filter
    
    var body: some View {
        BillingSectionCard("Protection IP") {
            if let ip = vm.ipInfo {
                VStack(alignment: .leading, spacing: 10) {
                    LabeledContent("IPv4", value: ip.ipv4)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Default action")
                            .subheadline(.semibold)
                        
                        Picker("Default action", selection: $selectedAction) {
                            ForEach(CloudProtectionDefaultAction.allCases) { action in
                                Text(action.title).tag(action)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Button("Save default action") {
                        Task { await vm.updateDefaultAction(selectedAction) }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                    .disabled(
                        vm.isPerformingAction ||
                        !selectedAction.isUpdatable ||
                        selectedAction == (ip.defaultAction ?? .filter)
                    )
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
    CloudProtectionIPSection()
        .environment(CloudProtectionVM())
        .padding()
        .darkSchemePreferred()
}

