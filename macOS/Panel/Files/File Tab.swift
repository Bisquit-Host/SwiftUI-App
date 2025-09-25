import ScrechKit
import PteroNet

struct FileTab: View {
    @Environment(NavModel.self) private var nav
    @StateObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, at root: String = "") {
        self.id = id
        self.root = root
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    @State private var showToolbar = false
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.folderPath) {
            List {                
                Section {
                    TextField("Search", text: $vm.searchField)
                        .textFieldStyle(.roundedBorder)
                }
                
                ForEach(vm.filteredFiles) {
                    FileView(id, at: root, file: $0)
                        .id($0)
                }
                .listRowSeparator(.hidden)
                .animation(.default, value: vm.filteredFiles.indices)
            }
            .scrollContentBackground(.hidden)
            .navigationDestination(for: String.self) { file in
                FolderDestination(id, at: file)
            }
        }
        .navigationTitle("Files")
        .environmentObject(vm)
        .frame(minWidth: 200, maxWidth: 800)
#if os(macOS)
        .navigationSubtitle(root)
#endif
        .onChange(of: id) {
            Task {
                await vm.fetchFiles(root)
            }
        }
        .onChange(of: nav.selectedServers) {
            nav.folderPath.removeAll()
        }
        .onChange(of: nav.folderPath) {
            try? nav.save()
        }
        .task {
            showToolbar = true
            await vm.fetchFiles(root)
        }
        .onDisappear {
            showToolbar = false
        }
        //        .toolbar {
        //            //            if showToolbar {
        //            Button {
        //                vm.fetchFiles(path)
        //            } label: {
        //                Image(systemName: "arrow.triangle.2.circlepath")
        //                    .rotate(vm.degrees)
        //                    .bold()
        //            }
        //            .keyboardShortcut("R")
        //            //            }
        //        }
    }
}

#Preview {
    FileTab("")
        .darkSchemePreferred()
        .environment(NavState())
        .environmentObject(FileTabVM(""))
}
