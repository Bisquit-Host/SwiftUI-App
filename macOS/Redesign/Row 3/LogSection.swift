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
                
                List {
                    ForEach(vm.logs) { log in
                        VStack(spacing: 6) {
                            HStack {
                                LogActorAvatar(log.relationships.actor.attributes)
                                    .frame(width: 32, alignment: .leading)
                                    .clipped()
                                
                                LogCardEvent(log)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(log.timestamp)
                                    .secondary()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .listRowSeparatorTint(.white.opacity(0.1))
                    }
                }
                .frame(height: 300)
                .listStyle(.plain)                 // removes grouped insets
                .scrollContentBackground(.hidden) // hides default system background
                .background(Color.clear)         // transparent background
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
