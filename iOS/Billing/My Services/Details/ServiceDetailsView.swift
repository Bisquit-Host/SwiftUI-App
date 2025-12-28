import SwiftUI

struct ServiceDetailsView<VM: ServiceDetailsVM & ServiceDetailsVMProtocol>: View {
    @State private var vm: VM
    
    private let serviceId: Int
    
    init(_ serviceId: Int) {
        self.serviceId = serviceId
        _vm = State(initialValue: VM())
    }
    
    @State private var pendingName = ""
    @State private var alertRename = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let service = vm.service {
                    ServiceHeader(service)
                    ServiceInfoSection(service)
                    ServiceBillingSection<VM, VM>(service)
                    
                } else if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                }
            }
            .padding()
        }
        .environment(vm)
        .navigationTitle(vm.service?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .refreshableTask {
            await vm.load(serviceId)
        }
        .onChange(of: vm.service?.id) { _, _ in
            if let service = vm.service {
                pendingName = service.name
            }
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
        .alert("Rename service", isPresented: $alertRename) {
            TextField("New name", text: $pendingName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            Button("Save", role: .confirm, action: rename)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func rename() {
        Task {
            guard let service = vm.service else { return }
            await vm.rename(pendingName.isEmpty ? service.name : pendingName, serviceId: service.id)
        }
    }
}

extension GameServiceDetailsVM: ServiceDetailsVMProtocol {}
extension BotServiceDetailsVM: ServiceDetailsVMProtocol {}
