import ScrechKit
import Calagopus

struct FolderDestination: View {
    @StateObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String, at root: String = "") {
        self.id = id
        self.root = root
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 0) {
                    Button("root") {
                        
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
                    .id($0.id)
            }
            .animation(.default, value: vm.filteredFiles.indices)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Files")
        .navSubtitle(root)
        .environmentObject(vm)
        .scrollContentBackground(.hidden)
        .frame(minWidth: 200, maxWidth: 800)
        .task {
            await vm.fetchFiles(root)
        }
    }
}

#Preview {
    NavigationStack {
        FolderDestination("")
    }
    .darkSchemePreferred()
}
