import SwiftUI

struct FileErrorView: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    private let name, path: String
    
    init(_ name: String, at path: String) {
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
                Task {
                    await vm.deleteFile(name, at: path) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FileErrorView("name", at: "path")
        .darkSchemePreferred()
        .environmentObject(FileTabVM(""))
}
