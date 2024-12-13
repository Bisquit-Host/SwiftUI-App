import SwiftUI
import PteroNet

struct StartupList: View {
    @State private var vm: StartupVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = StartupVM(id)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.startupVariables, id: \.name) { variable in
                    //                    VariableCard(plugin)
                    Text(variable.name)
                }
            }
        }
        .animation(.default, value: vm.startupVariables.indices)
        .navigationTitle("Startup")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            vm.fetchStartupVariables()
        }
        .onChange(of: id) {
            vm.fetchStartupVariables()
        }
    }
}

#Preview {
    StartupList(sampleJSON(.serverListAttributes))
}
