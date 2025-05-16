import SwiftUI
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
            
            Section {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.red)
                
                Button("Confirm") {
                    vm.pullRemoteFile(remoteFile, dir: path) {
                        dismiss()
                    }
                }
            }
        }
        .autocorrectionDisabled()
    }
}

#Preview {
    SheetRemoteFile("")
        .environmentObject(FileTabVM(""))
}
