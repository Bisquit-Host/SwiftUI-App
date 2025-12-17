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
                    
                    Menu {
                        ForEach(VDSProtectionDefaultAction.menuCases) { action in
                            Button {
                                selectedAction = action
                            } label: {
                                if selectedAction == action {
                                    Label(action.title, systemImage: "checkmark")
                                } else {
                                    Text(action.title)
                                }
                            }
                            .disabled(!action.canBeSetFromApp)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(selectedAction.title)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .footnote(.semibold)
                                .secondary()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundStyle(.foreground)
                    .buttonStyle(.bordered)
                    .disabled(vm.isPerformingAction)
                }
                
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
