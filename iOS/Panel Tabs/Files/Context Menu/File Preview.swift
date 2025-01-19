import ScrechKit
import QuickLooking
import UniformTypeIdentifiers

struct FilePreview: View {
    @State private var vm: FilePreviewVM
    
    private let id, path, name: String
    
    init(_ id: String, path: String, name: String) {
        self.id = id
        self.path = path
        self.name = name
        self.vm = FilePreviewVM(id)
    }
    
    var body: some View {
        VStack {
            if let url = vm.fileUrl {
                QuickLookView(url)
                    .transition(.opacity)
            } else {
                ProgressView()
                    .frame(width: 100, height: 100)
            }
        }
        .animation(.default, value: vm.fileUrl)
        .blur(radius: vm.isSensitive ? 10 : 0)
        .task {
            vm.getFileUrl(name, at: path)
        }
        .onDisappear {
            vm.fileUrl = nil
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
    }
    
    private func isImage(_ url: URL) -> Bool {
        guard let fileType = UTType(filenameExtension: url.pathExtension) else {
            return false
        }
        
        return fileType.conforms(to: .image)
    }
}
