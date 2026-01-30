import ScrechKit
import PteroNet

struct SheetRemoteFile: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    private let path: String
    
    init(_ path: String) {
        self.path = path
    }
    
    @State private var remoteFile = FilePullRequestBody()
    
    var body: some View {
        List {
            TextField("Url", text: $remoteFile.url)
            
            TextField("Name (optional)", text: $remoteFile.filename)
            
            Toggle("Process in foreground", isOn: $remoteFile.foreground)
            
            Toggle("Use header", isOn: $remoteFile.use_header)
        }
        .navigationTitle("Pull remote file")
        .navSubtitle(path)
        .autocorrectionDisabled()
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                SFButton("xmark") {
                    dismiss()
                }
                .tint(.red)
            }
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
            
            ToolbarItem(placement: .bottomBar) {
                SFButton("checkmark", action: pull)
                    .tint(.green)
                    .disabled(remoteFile.url.isEmpty)
            }
        }
    }
    
    private func pull() {
        Task {
            await vm.pullRemoteFile(remoteFile, at: path) {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SheetRemoteFile("preview/preview")
    }
    .darkSchemePreferred()
    .environmentObject(FileTabVM(""))
}
