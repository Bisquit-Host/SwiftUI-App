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
            if let url = vm.fileUrl {
                QuickLookView(url)
                    .transition(.opacity)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(name)
        .animation(.default, value: vm.fileUrl)
        .blur(radius: vm.isSensitive ? 10 : 0)
        .ignoresSafeArea(edges: .bottom)
        .sheet($sheetMetadata) {
            MetadataList(vm.metadata)
        }
        .task {
            vm.getFileUrl(name, at: path)
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
            if #available(iOS 18.1, *), let url = vm.fileUrl, isImage(url) {
                ImagePlaygroundToolbarButton(url, path, name)
            }
            
            Menu {
                Button {
                    sheetMetadata = true
                } label: {
                    Label("Metadata", systemImage: "tag")
                }
                
                if let url = vm.fileUrl {
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

#Preview {
    QuickLookFile("", path: "", name: "")
        .environmentObject(FileTabVM(""))
}
