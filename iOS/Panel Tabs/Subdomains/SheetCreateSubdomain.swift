import SwiftUI
import PteroNet

struct SheetCreateSubdomain: View {
    @Environment(SubdomainVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let allocations: [AllocationAttributes]
    
    init(_ allocations: [AllocationAttributes]) {
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
            
            if let domains = vm.domains {
                Picker("Domain", selection: $vm.selectedDomain) {
                    ForEach(domains) {
                        Text($0.domain)
                    }
                }
            }
            
            Picker("Port", selection: $vm.selectedAllocation) {
                ForEach(allocations) {
                    let ip = $0.ipAlias ?? $0.ip
                    let port = $0.port.description
                    
                    Text(ip + ":" + port)
                        .tag($0.id)
                }
            }
            
            Section {
                let disabled = vm.selectedAllocation == nil
                || vm.subdomain.isEmpty
                || vm.limit <= vm.subdomains.count
                
                Button("Create", systemImage: "plus") {
                    createSubdomain()
                }
                .foregroundStyle(disabled ? .secondary : .primary)
                .disabled(disabled)
            }
        }
        .pickerStyle(.inline)
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
