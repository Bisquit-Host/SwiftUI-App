import SwiftUI

struct StatRowSubdomains: View {
    @State private var vm: SubdomainVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = SubdomainVM(id)
    }
    
    @State private var sheetSubdomains = false
    
    var body: some View {
        Button {
            sheetSubdomains = true
        } label: {
            StatTile("Sudomains", value: vm.subdomains.count, icon: "globe")
        }
        .task {
            await vm.fetchSubdomains()
        }
        .sheet($sheetSubdomains) {
            SubdomainList()
                .environment(vm)
                .frame(minHeight: StatRows.minHeight)
        }
    }
}

#Preview {
    StatRowSubdomains("")
        .darkSchemePreferred()
}
