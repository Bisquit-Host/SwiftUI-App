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
                            FileView(id, path: path, file: file)
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
        .onChange(of: id) {
            vm.fetchFiles(path)
        }
        .task {
            showToolbar = true
            vm.fetchFiles(path)
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
