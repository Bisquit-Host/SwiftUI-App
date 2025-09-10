import SwiftUI

struct FileList: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, at root: String = "/") {
        self.id = id
        self.root = root
    }
    
    var body: some View {
        List {
            ForEach(vm.filteredFiles) {
                FileCard(id, file: $0, at: root)
                    .fileContextMenu(id, file: $0, at: root)
            }
        }
        .navigationTitle(root)
        .refreshableTask {
            await vm.fetchFiles(root)
        }
    }
}

#Preview {
    FileList("")
        .environmentObject(FileTabVM(""))
}
