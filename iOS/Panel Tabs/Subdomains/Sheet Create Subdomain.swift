import SwiftUI
import PteroNet

struct SheetCreateSubdomain: View {
    @Environment(SubdomainVM.self) private var vm
    
    private var placeholder: String {
        vm.subdomain.isEmpty ? "<your subdomain>" : vm.subdomain + "." + (vm.domains?[vm.selectedDomain].domain ?? "<selected domain>")
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                Text("")
                
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
