import SwiftUI

struct ServiceDetailsView<VM: ServiceDetailsVM & ServiceDetailsVMProtocol>: View {
    @State private var vm: VM
    
    private let service: any BillingServiceSummary
    
    init(_ service: any BillingServiceSummary) {
        self.service = service
        _vm = State(initialValue: VM())
    }
    
    @State private var pendingName = ""
    @State private var alertRename = false
    
    private var subtitle: String {
        let package = vm.service?.packageInfo.name ?? service.packageName
        let location = vm.service?.location.name ?? service.locationName
        
        return "\(package) • \(location)"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ServiceInfoSection(vm.service)
                
                ServiceBillingSection<VM, VM>(vm.service)
                    .id(service.id)
            }
            .padding()
        }
        .environment(vm)
        .navigationTitle(vm.service?.name ?? service.name)
        .navSubtitle(subtitle)
        .navigationBarTitleDisplayMode(.inline)
        .refreshableTask {
            await vm.load(service.id)
        }
        .onChange(of: vm.service?.id) {
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
