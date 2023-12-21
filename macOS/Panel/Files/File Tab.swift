import ScrechKit

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    @EnvironmentObject private var settings: SettingsStorage
    
    private let id, path: String
    
    init(_ id: String,
         path: String = ""
    ) {
        self.id = id
        self.path = path
        //        _vm = StateObject(wrappedValue: FileManagerVM(id))
    }
    
    var body: some View {
        List {
            ForEach(vm.filteredFiles, id: \.name) { file in
                //                NavigationLink {
                //                    Text(":1")
                //                } label: {
                FileView(id,
                         path: path,
                         file: file
                )
                //                }
            }
        }
        .task {
            vm.fetchFiles(path)
        }
        .toolbar {
            if settings.lastTabPanel == .fileManager {
                Button {
                    vm.fetchFiles(path)
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .rotate(vm.degrees)
                        .bold()
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }
    }
}

#Preview {
    FileTab("")
        .environmentObject(SettingsStorage())
        .environmentObject(FileTabVM(""))
}
