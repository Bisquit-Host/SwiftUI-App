import SwiftUI

struct PluginList: View {
    @State private var vm: PluginVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = PluginVM(id)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.plugins, id: \.name) { plugin in
                    PluginCard(plugin)
                }
            }
        }
        .navigationTitle("Plugins")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            vm.fetchPlugins()
        }
        .onChange(of: id) {
            vm.fetchPlugins()
        }
    }
}

#Preview {
    PluginList("")
        .environment(PluginVM(""))
}
