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
        
        return subdomain + "." + (vm.domains?.first(where: { $0.id == vm.selectedDomain })?.domain ?? "<selected domain>")
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
                    ForEach(domains) { domain in
                        Text(domain.domain)
                    }
                }
            }
            
            Picker("Allocation", selection: $vm.selectedAllocation) {
                ForEach(allocations) { allocation in
                    let ip = allocation.ipAlias ?? allocation.ip
                    let port = allocation.port.description
                    
                    Text(ip + ":" + port)
                        .tag(allocation.id)
                }
            }
            
            Section {
                let disabled = vm.selectedAllocation == nil
                || vm.subdomain.isEmpty
                || vm.limit <= vm.subdomains.count
                
                Button {
                    Task {
                        await vm.createSubdomain {
                            dismiss()
                        }
                    }
                } label: {
                    Label("Create", systemImage: "plus")
                }
                .foregroundStyle(disabled ? .secondary : .primary)
                .disabled(disabled)
            }
        }
        .pickerStyle(.inline)
        .transparentList()
        .ornamentDismissButton()
    }
}

#Preview {
    SheetCreateSubdomain([])
        .environment(SubdomainVM(""))
        .darkSchemePreferred()
}
