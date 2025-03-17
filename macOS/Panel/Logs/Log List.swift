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
                ForEach(vm.logs, id: \.id) { log in
                    LogCard(log)
                }
            }
        }
        .navigationTitle("Logs")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
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
