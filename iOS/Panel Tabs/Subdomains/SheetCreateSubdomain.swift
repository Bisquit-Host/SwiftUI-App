import SwiftUI
import Calagopus

struct SheetCreateSubdomain: View {
    @Environment(SubdomainVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let allocations: [CalagopusServerAllocation]
    
    init(_ allocations: [CalagopusServerAllocation]) {
        self.allocations = allocations
    }
    
    private var placeholder: String {
        let subdomain = vm.subdomain.isEmpty ? "<your subdomain>" : vm.subdomain
        
        return subdomain + "." + (vm.domains?.first(where: {
            $0.id == vm.selectedDomain
        })?.domain ?? "<selected domain>")
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                Text(placeholder)
                
                TextField("Subdomain", text: $vm.subdomain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            
            Section {
                if let domains = vm.domains, !domains.isEmpty {
                    Picker("Domain", selection: $vm.selectedDomain) {
                        ForEach(domains) {
                            Text($0.domain)
                                .tag($0.id as String?)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    Text("No domains available")
                        .secondary()
                }
            }
            
            Picker("Port", selection: $vm.selectedAllocation) {
                ForEach(allocations) {
                    let ip = $0.ipAlias ?? $0.ip
                    let port = $0.port.description
                    
                    Text(ip + ":" + port)
                        .tag($0.uuid as String?)
                }
            }
            .pickerStyle(.inline)
            
            Section {
                let disabled = !vm.canCreateSubdomain
                
                Button("Create", systemImage: "plus", action: createSubdomain)
                    .foregroundStyle(disabled ? .secondary : .primary)
                    .disabled(disabled)
            }
        }
        .navigationTitle("Create Subdomain")
        .toolbarTitleDisplayMode(.inline)
        .task {
            if vm.domains == nil {
                await vm.fetchSubdomains()
            }
        }
        .ornamentDismissButton()
    }
    
    private func createSubdomain() {
        Task {
            await vm.createSubdomain {
                dismiss()
            }
        }
    }
}

#Preview {
    SheetCreateSubdomain([])
        .darkSchemePreferred()
        .environment(SubdomainVM(""))
}
