import SwiftUI

struct FileErrorView: View {
    @EnvironmentObject private var vm: FileTabVM
    
    @Environment(\.dismiss) private var dismiss
    
    private let path, name: String
    
    init(path: String, name: String) {
        self.path = path
        self.name = name
    }
    
    var body: some View {
        ContentUnavailableView {
            Label("Unable to view the contents of \(name)", systemImage: "exclamationmark.triangle")
        } actions: {
            Button("Dismiss") {
                dismiss()
            }
            
            Button("Delete", role: .destructive) {
                vm.deleteFile(name, at: path) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    FileErrorView(path: "path", name: "name")
        .environmentObject(FileTabVM(""))
}
