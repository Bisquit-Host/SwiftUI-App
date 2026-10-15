import ScrechKit

struct DatabaseInstanceLogsView: View {
    @Environment(DatabaseInstanceDetailsVM.self) private var vm
    
    var body: some View {
        ScrollView {
            Text(vm.logs)
                .monospaced()
                .caption()
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .defaultScrollAnchor(.bottom)
        .navigationTitle("Logs")
        .toolbarTitleDisplayMode(.inline)
        .overlay {
            if vm.isLoadingLogs && vm.logs.isEmpty {
                ProgressView()
            } else if !vm.isLoadingLogs && vm.logs.isEmpty {
                ContentUnavailableView("No logs", systemImage: "text.alignleft")
            }
        }
        .refreshableTask {
            await vm.fetchLogs()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Copy", systemImage: "doc.on.doc") {
                    Pasteboard.copy(vm.logs)
                    SystemAlert.copied()
                }
                .disabled(vm.logs.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DatabaseInstanceLogsView()
    }
    .darkSchemePreferred()
    .environment(DatabaseInstanceDetailsVM("", instance: PreviewProp.databaseInstance))
}
