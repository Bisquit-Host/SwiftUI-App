#if DEBUG
import ScrechKit
import QuickLooking

struct FilePreview: View {
    @State private var vm: FilePreviewVM
    
    private let id, name, path: String
    
    init(_ id: String, name: String, at path: String) {
        self.id = id
        self.name = name
        self.path = path
        self.vm = FilePreviewVM(id)
    }
    
    var body: some View {
        VStack {
            if let url = vm.fileUrl, vm.isLoaded {
                QuickLookView(url)
            } else {
                ProgressView()
                    .frame(50)
            }
        }
        .animation(.default, value: vm.isLoaded)
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
}
#endif
