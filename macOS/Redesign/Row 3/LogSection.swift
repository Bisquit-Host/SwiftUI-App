import SwiftUI
import PteroNet

struct LogSection: View {
    @State private var vm: LogVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = LogVM(id)
    }
    
    var body: some View {
        Card("Logs") {
            VStack(alignment: .leading) {
                HStack {
                    HeaderCell("Actor")
                        .frame(width: 32, alignment: .leading)
                    
                    HeaderCell("Description")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HeaderCell("Date")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 6)
                
                LogSectionList(vm.logs)
            }
            .padding(.vertical, 6)
        }
        .task {
            await vm.fetchLogs()
        }
    }
}

#Preview {
    LogSection("")
}
