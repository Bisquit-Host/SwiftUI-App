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
        VStack {
#if os(macOS)
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(vm.filteredFiles, id: \.name) { file in
                        NavigationLink {
                            Text("Destination")
                        } label: {
                            HStack {
                                FileView(id, path: path, file: file)
                                    .fileContextMenu(file.name, path: path, mimeType: file.mimetype)
                                
                                Spacer()
                            }
                            .padding(5)
                        }
                    }
                }
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
        .navigationTitle("Files")
#if os(macOS)
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .navigationSubtitle(path)
#endif
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
