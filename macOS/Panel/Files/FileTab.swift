import ScrechKit
import Calagopus

struct FileTab: View {
    @StateObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, at root: String = "") {
        self.id = id
        self.root = root
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    @State private var showToolbar = false
    
    var body: some View {
        List {
            Section {
                TextField("Search", text: $vm.searchField)
                    .textFieldStyle(.roundedBorder)
            }
            
            ForEach(vm.filteredFiles) {
                FileView(id, at: root, file: $0)
                    .id($0.id)
            }
            .listRowSeparator(.hidden)
            .animation(.default, value: vm.filteredFiles.indices)
        }
        .scrollContentBackground(.hidden)
        .navigationDestination(for: String.self) {
            FolderDestination(id, at: $0)
        }
        .navigationTitle("Files")
        .navSubtitle(root)
        .environmentObject(vm)
        .frame(minWidth: 200, maxWidth: 800)
        .onChange(of: id) {
            Task {
                await vm.fetchFiles(root)
            }
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
