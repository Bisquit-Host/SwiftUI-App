import SwiftUI

struct StartupList: View {
    @Environment(StartupVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.startupVariables) { variable in
                StartupCard(variable)
            }
        }
        .navigationTitle("Startup (view only)")
        .task {
            await vm.fetchStartupVariables()
        }
    }
}

#Preview {
    NavigationView {
        StartupList()
            .environment(StartupVM(""))
    }
}
