import SwiftUI

struct GameServiceDetails: View {
    @State private var vm = GameServiceDetailsVM()
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    let serviceId: Int
    
    @State private var pendingName = ""
    @State private var alertRename = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let service = vm.service {
                    GameServiceHeader(service)
                    GameServiceInfoSection(service)
                    GameServiceBillingSection(service)
                    GameServiceUpgradeSection()
                    
                } else if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                }
                
                if let message = vm.actionMessage {
                    Text(message)
                        .footnote()
                        .foregroundStyle(.green)
                }
            }
            .padding()
            .environment(vm)
        }
        .navigationTitle(vm.service?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .refreshableTask {
            await vm.load(serviceId)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if vm.isPerformingAction {
                    ProgressView()
                } else {
                    Menu {
                        Button("Rename", systemImage: "pencil") {
                            alertRename = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
        .onChange(of: vm.service?.id) { _, _ in
            if let service = vm.service {
                pendingName = service.name
            }
        }
        .alert("Rename service", isPresented: $alertRename, presenting: vm.service) { service in
            TextField("New name", text: $pendingName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            Button("Save") {
                Task {
                    await vm.rename(pendingName.isEmpty ? service.name : pendingName, serviceId: service.id)
                }
            }
            
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    NavigationStack {
        GameServiceDetails(serviceId: 1)
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
