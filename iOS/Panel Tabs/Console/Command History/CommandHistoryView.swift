import ScrechKit

struct CommandHistoryView: View {
    @Environment(ConsoleVM.self) private var vm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if vm.commandHistoryLoading {
                    ProgressView()
                } else if vm.commandHistory.isEmpty {
                    ContentUnavailableView("No command history", systemImage: "clock.arrow.circlepath")
                } else {
                    Section("Recent Commands") {
                        ForEach(vm.commandHistory) { snippet in
                            Button {
                                vm.useHistoryCommand(snippet.command)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(snippet.name)

                                    Text(snippet.command)
                                        .monospaced()
                                        .secondary()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Command History")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                }
            }
            .refreshableTask {
                await vm.fetchCommandHistory()
            }
        }
    }
}

#Preview {
    CommandHistoryView()
        .darkSchemePreferred()
        .environment(ConsoleVM(""))
}
