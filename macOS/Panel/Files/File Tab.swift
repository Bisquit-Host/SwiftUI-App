import ScrechKit
import PteroNet

struct FileTab: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, path: String
    
    init(_ id: String,
         path: String = ""
    ) {
        self.id = id
        self.path = path
    }
    
    @State private var selectedItem: Tabs = .info
    @State private var showToolbar = false
    
    var body: some View {
        List(selection: $selectedItem) {
            ForEach(vm.filteredFiles, id: \.name) { file in
                NavigationLink {
                    Text("Destination")
                } label: {
                    FileView(id, path: path, file: file)
                        .fileContextMenu(file.name,
                                         path: path,
                                         mimeType: file.mimetype)
                }
            }
        }
        .navigationTitle("Files")
        .navigationSubtitle(path)
        .task {
            vm.fetchFiles(path)
            showToolbar = true
        }
        .onDisappear {
            showToolbar = false
        }
        .toolbar {
            if showToolbar {
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
