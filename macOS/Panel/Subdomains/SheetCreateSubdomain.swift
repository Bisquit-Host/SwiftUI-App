import SwiftUI
import Calagopus

struct SheetCreateSubdomain: View {
    @Environment(SubdomainVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private var domain: String {
        vm.domains?.first(where: { $0.id == vm.selectedDomain })?.domain ?? "<selected domain>"
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                HStack(spacing: 0) {
                    if vm.subdomain.isEmpty {
                        Text("<your subdomain>")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(vm.subdomain)
                    }

                    Text(".")
                    Text(domain)
                }
                
                TextField("Subdomain", text: $vm.subdomain)
                    .autocorrectionDisabled()
            }
            
            if let domains = vm.domains {
                Picker("Domain", selection: $vm.selectedDomain) {
                    ForEach(domains) {
                        Text($0.domain)
                            .tag($0.id as String?)
                    }
                }
                .pickerStyle(.inline)
            }
            
            Section {
                Button("Create", systemImage: "plus") {
                    createSubdomain()
                }
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
    SheetCreateSubdomain()
        .darkSchemePreferred()
        .environment(SubdomainVM(""))
}
