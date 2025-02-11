import SwiftUI

struct StartupList: View {
    @Environment(StartupVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.startupVariables, id: \.name) { variable in
                StartupCard(variable)
            }
        }
        .navigationTitle("Startup (view only)")
        .task {
            vm.fetchStartupVariables()
        }
    }
}

#Preview {
    NavigationView {
        StartupList()
            .environment(StartupVM(""))
    }
}
