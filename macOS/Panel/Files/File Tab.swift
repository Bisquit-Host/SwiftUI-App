import ScrechKit
import PteroNet

struct FileTab: View {
    @StateObject private var vm: FileTabVM
    
    private let id, path: String
    
    init(_ id: String,
         path: String = ""
    ) {
        self.id = id
        self.path = path
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    @State private var selectedItem: Tabs = .info
    @State private var showToolbar = false
    
    func clear() {
        print("clicked")
        vm.searchRule = ""
    }
    
    var body: some View {
        VStack {
            TextField("Search", text: $vm.searchRule)
            
#if os(macOS)
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(vm.filteredFiles, id: \.name) { file in
                        NavigationLink {
                            Text("Destination")
                        } label: {
                            HStack {
                                FileView(id, path: path, file: file)
                                
                                Spacer()
                            }
                            .padding(5)
                        }
                    }
                }
                .animation(.default, value: vm.filteredFiles.indices)
                .padding(.trailing, 20)
            }
            .background(.clear)
#else
            List {
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
#endif
        }
        .environmentObject(vm)
        .navigationTitle("Files")
#if os(macOS)
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .navigationSubtitle(path)
#endif
        .onChange(of: id) { _, _ in
            vm.fetchFiles(path, id: id)
        }
        .task {
            showToolbar = true
            vm.fetchFiles(path)
        }
        .onDisappear {
            showToolbar = false
        }
        .toolbar {
            //            ToolbarItemGroup(placement: .leading) {
            Text("BH")
            //            }
            
            
            //            //            if showToolbar {
            //            Button {
            //                vm.fetchFiles(path)
            //            } label: {
            //                Image(systemName: "arrow.triangle.2.circlepath")
            //                    .rotate(vm.degrees)
            //                    .bold()
            //            }
            //            .keyboardShortcut("r", modifiers: .command)
            //            //            }
        }
    }
}

#Preview {
    FileTab("")
        .environmentObject(SettingsStorage())
        .environmentObject(FileTabVM(""))
}
