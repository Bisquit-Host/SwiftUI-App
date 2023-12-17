import SwiftUI

struct Folder_Path: View {
    @EnvironmentObject private var settings: SettingsStorage
    private var vm = FolderPathVM()
    
    private let path: String
    
    init(_ path: String) {
        self.path = path
    }
    
    private var listPath: String {
        settings.showFullFilePath ? "/home/container/" + path : path
    }
    
    var body: some View {
        if !path.isEmpty {
            Button {
                vm.copyFilePath(path, withHomeContainer: settings.showFullFilePath)
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc")
                        .semibold()
                    
                    Text(listPath)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .footnote()
            }
        }
    }
}
