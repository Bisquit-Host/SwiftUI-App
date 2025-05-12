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
            }
            
            Section {
                TextField("Search", text: $vm.searchField)
                    .textFieldStyle(.roundedBorder)
            }
            
            ForEach(vm.filteredFiles) { file in
                FileView(id, at: root, file: file)
                    .id(file)
            }
            .listRowSeparator(.hidden)
            .animation(.default, value: vm.filteredFiles.indices)
        }
        .transparentList()
        .scrollContentBackground(.hidden)
        .navigationTitle("Files")
        .environmentObject(vm)
        .frame(minWidth: 200, maxWidth: 800)
#if os(macOS)
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
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
            vm.fetchFiles(root)
        }
    }
}

#Preview {
    FolderDestination("")
        .environmentObject(ValueStore())
        .environmentObject(FileTabVM(""))
}
