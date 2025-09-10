import SwiftUI

struct FileListHeader: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let root: String
    
    init(_ root: String) {
        self.root = root
    }
    
    var body: some View {
        if vm.fileCount != 0 {
            HStack {
                FolderPath(root)
                
                Spacer()
                
                Text(.files(vm.fileCount))
                    .monospacedDigit()
            }
            .numericTransition()
        }
    }
}

#Preview {
    FileListHeader("/preview")
        .environmentObject(FileTabVM(""))
}
