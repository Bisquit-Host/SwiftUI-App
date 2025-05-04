import SwiftUI

struct LogList: View {
    @State private var vm: LogVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = LogVM(id)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(vm.logs) { log in
                    LogCard(log)
                }
            }
            .padding()
        }
        .navigationTitle("Logs")
        .task {
            vm.fetchLogs()
        }
        .onChange(of: id) {
            vm.fetchLogs()
        }
    }
}

#Preview {
    LogList("")
        .environment(LogVM(""))
}
