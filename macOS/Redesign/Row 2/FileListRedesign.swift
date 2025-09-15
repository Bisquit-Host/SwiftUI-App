import SwiftUI
import PteroNet

struct FileListRedesign: View {
    @StateObject private var vm: FileTabVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    var body: some View {
        List {
            ForEach(vm.files) {
                FileCardRedesign($0)
                    .listRowSeparatorTint(.white.opacity(0.1))
            }
        }
        .listStyle(.plain)                 // removes grouped insets
        .scrollContentBackground(.hidden) // hides default system background
        .background(Color.clear)         // transparent background
        .task {
            await vm.fetchFiles()
        }
    }
}

#Preview {
    FileListRedesign("")
}
