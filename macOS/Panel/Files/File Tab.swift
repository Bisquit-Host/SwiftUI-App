import ScrechKit
import PteroNet

struct FileTab: View {
    @StateObject private var vm: FileTabVM
    
    private let id, root: String
    
    init(_ id: String,
         root: String = ""
    ) {
        self.id = id
        self.root = root
        _vm = StateObject(wrappedValue: FileTabVM(id))
    }
    
    @State private var showToolbar = false
    
    var body: some View {
        VStack {
            TextField("Search", text: $vm.searchField)
                .textFieldStyle(.roundedBorder)
#if os(macOS)
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(vm.filteredFiles, id: \.name) { file in
                        NavigationLink {
                            Text("Destination")
                        } label: {
                            FileView(id, root: root, file: file)
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
                        FileView(id, root: root, file: file)
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
        .navigationSubtitle(root)
#endif
        .onChange(of: id) {
            vm.fetchFiles(root)
        }
        .task {
            showToolbar = true
            vm.fetchFiles(root)
        }
        .onDisappear {
            showToolbar = false
        }
        //        .toolbar {
        //            //            if showToolbar {
        //            Button {
        //                vm.fetchFiles(root)
        //            } label: {
        //                Image(systemName: "arrow.triangle.2.circlepath")
        //                    .rotate(vm.degrees)
        //                    .bold()
        //            }
        //            .keyboardShortcut("r", modifiers: .command)
        //            //            }
        //        }
    }
}

#Preview {
    FileTab("")
        .environmentObject(SettingsStorage())
        .environmentObject(FileTabVM(""))
}
