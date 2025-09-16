import SwiftUI

struct LogList: View {
    @State private var vm: LogVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = LogVM(id)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(vm.logs) {
                    LogCard($0)
                }
            }
            .padding()
        }
        .navigationTitle("Logs")
        .task {
            await vm.fetchLogs()
        }
        .onChange(of: id) {
            Task {
                await vm.fetchLogs()
            }
        }
    }
}

#Preview {
    NavigationStack {
        LogList("")
    }
}
