import SwiftUI

struct StartupList: View {
    @Environment(StartupVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.startupVariables, id: \.name) { variable in
                Section {
                    Text(variable.name)
                    Text(variable.description)
                }
            }
        }
        .navigationTitle("Startup")
    }
}

#Preview {
    StartupList()
}
