import ScrechKit

struct CommandHistory: View {
    @Environment(ConsoleVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            if vm.commandHistoryLoading {
                ProgressView()
                
            } else if vm.commandHistory.isEmpty {
                ContentUnavailableView("No command history", systemImage: "clock.arrow.circlepath")
                
            } else {
                ForEach(vm.commandHistory) {
                    CommandHistoryCard($0)
                }
            }
        }
        .navigationTitle("Command History")
        .toolbarTitleDisplayMode(.inline)
        .refreshableTask {
            await vm.fetchCommandHistory()
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
#if !os(visionOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
        }
    }
}

#Preview {
    CommandHistory()
        .darkSchemePreferred()
        .environment(ConsoleVM(""))
}
