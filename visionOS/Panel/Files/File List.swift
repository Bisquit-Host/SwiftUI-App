import SwiftUI

struct FileList: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, root: String = "/") {
        self.id = id
        self.root = root
    }
    
    var body: some View {
        List {
            ForEach(vm.filteredFiles, id: \.name) { file in
                FileCard(id, file: file, root: root)
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
