import ScrechKit
import QuickLooking

struct QuickLookFile: View {
    @State private var vm: QuickLookFileVM
    
    private let id, root, name: String
    
    init(_ id: String, root: String, name: String) {
        self.id = id
        self.root = root
        self.name = name
        self.vm = QuickLookFileVM(id)
    }
    
    @State private var sheetMetadata = false
    
    var body: some View {
        VStack {
            if let url = vm.fileURL {
                QuickLookView(url)
                    .transition(.opacity)
            } else {
                ProgressView()
            }
        }
        .animation(.default, value: vm.fileURL)
        .blur(radius: vm.isSensitive ? 10 : 0)
        .navigationTitle(name)
        .ignoresSafeArea(edges: .bottom)
        .sheet($sheetMetadata) {
            MetadataList(vm.metadata)
        }
        .task {
            vm.downloadFile(name, root: root)
        }
        .toolbar {
            if let url = vm.fileURL {
                if #available(iOS 18.1, *) {
                    ImagePlaygroundToolbarButton(url, root: root, name: name)
                }
                
                Menu {
                    Button {
                        sheetMetadata = true
                    } label: {
                        Label("Metadata", systemImage: "tag")
                    }
                    
                    ShareLink(item: url)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            
            if vm.isSensitive {
                SFButton("eye.slash") {
                    withAnimation {
                        vm.isSensitive = false
                    }
                }
            }
        }
    }
}
