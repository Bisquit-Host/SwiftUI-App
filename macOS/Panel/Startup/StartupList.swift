import SwiftUI
import PteroNet

struct StartupList: View {
    @State private var vm: StartupVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = StartupVM(id)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.startupVariables) {
//                    VariableCard(plugin)
                    Text($0.name)
                }
            }
        }
        .animation(.default, value: vm.startupVariables.indices)
        .navigationTitle("Startup")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            await vm.fetchStartupVariables()
        }
        .onChange(of: id) {
            Task {
                await vm.fetchStartupVariables()
            }
        }
    }
}

#Preview {
    NavigationStack {
        StartupList("")
    }
    .darkSchemePreferred()
}
