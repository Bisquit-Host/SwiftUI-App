import SwiftUI

struct FolderPath: View {
    @EnvironmentObject private var store: ValueStore
    private var vm = FolderPathVM()
    
    private let path: String
    
    init(_ path: String) {
        self.path = path
    }
    
    private var listPath: String {
        store.showFullFilePath ? "/home/container/" + path : path
    }
    
    var body: some View {
        if !path.isEmpty {
            Button {
                vm.copyFilePath(path, withHomeContainer: store.showFullFilePath)
            } label: {
                Text(listPath)
                    .footnote()
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
    }
}
