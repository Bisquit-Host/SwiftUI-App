import ScrechKit
import QuickLooking
import UniformTypeIdentifiers

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
        .navigationTitle(name)
        .animation(.default, value: vm.fileURL)
        .blur(radius: vm.isSensitive ? 10 : 0)
        .ignoresSafeArea(edges: .bottom)
        .sheet($sheetMetadata) {
            MetadataList(vm.metadata)
        }
        .task {
            vm.downloadFile(name, root: root)
        }
        .overlay {
            if vm.isSensitive {
                SFButton("eye.slash") {
                    withAnimation {
                        vm.isSensitive = false
                    }
                }
                .title(.semibold)
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            }
        }
        .toolbar {
            if let url = vm.fileURL {
                if #available(iOS 18.1, *) {
                    if isImage(url) {
                        ImagePlaygroundToolbarButton(url, root, name)
                    }
                }
            }
            
            Menu {
                Button {
                    sheetMetadata = true
                } label: {
                    Label("Metadata", systemImage: "tag")
                }
                
                if let url = vm.fileURL {
                    ShareLink(item: url)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    private func isImage(_ url: URL) -> Bool {
        guard let fileType = UTType(filenameExtension: url.pathExtension) else {
            return false
        }
        
        return fileType.conforms(to: .image)
    }
}
