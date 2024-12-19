import ScrechKit
import QuickLooking
import UniformTypeIdentifiers

struct QuickLookFile: View {
    @State private var vm: QuickLookFileVM
    @EnvironmentObject private var fileVm: FileTabVM
    
    @Environment(\.dismiss) private var dismiss
    
    private let id, path, name: String
    
    init(_ id: String, path: String, name: String) {
        self.id = id
        self.path = path
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
            vm.downloadFile(name, root: path)
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
                        ImagePlaygroundToolbarButton(url, path, name)
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
                
                Section {
                    Button("Delete", role: .destructive) {
                        fileVm.deleteFile(name, at: path) {
                            dismiss()
                        }
                    }
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
