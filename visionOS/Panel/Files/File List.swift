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
            ForEach(vm.filteredFiles) { file in
                FileCard(id, file: file, at: root)
                    .fileContextMenu(id, file: file, at: root)
            }
        }
        .navigationTitle(root)
        .refreshableTask {
            vm.fetchFiles(root)
        }
    }
}

#Preview {
    FileList("")
}
