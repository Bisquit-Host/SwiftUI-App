import SwiftUI
import PteroNet

struct SheetCreateSubdomain: View {
    @Environment(SubdomainVM.self) private var vm
    
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
                .pickerStyle(.inline)
            }
        }
    }
}

#Preview {
    SheetCreateSubdomain()
        .environment(SubdomainVM(""))
        .darkSchemePreferred()
}
