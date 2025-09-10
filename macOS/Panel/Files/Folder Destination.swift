import ScrechKit
import PteroNet

struct FolderDestination: View {
    @Environment(NavModel.self) private var nav
    @StateObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, at root: String = "") {
        self.id = id
        self.root = root
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    var body: some View {
        @Bindable var nav = nav
        
        List {
            Section {
                HStack(spacing: 0) {
                    Button("root") {
                        nav.folderPath.removeAll()
                    }
                    .buttonStyle(.plain)
                    
                    Text(root)
                }
                
                TextField("Search", text: $vm.searchField)
                    .textFieldStyle(.roundedBorder)
            }
            .listRowSeparator(.hidden)
            
            ForEach(vm.filteredFiles) {
                FileView(id, at: root, file: $0)
                    .id($0)
            }
            .animation(.default, value: vm.filteredFiles.indices)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Files")
        .scrollContentBackground(.hidden)
        .environmentObject(vm)
        .frame(minWidth: 200, maxWidth: 800)
#if os(macOS)
        .navigationSubtitle(root)
#endif
        //        .onChange(of: id) {
        //            vm.fetchFiles(path)
        //        }
        //        .onChange(of: nav.selectedServers) {
        //            nav.folderPath.removeAll()
        //        }
        //        .onChange(of: nav.folderPath) {
        //            try? nav.save()
        //        }
        .task {
            await vm.fetchFiles(root)
        }
    }
}

#Preview {
    NavigationStack {
        FolderDestination("")
    }
    .environment(NavModel())
}
