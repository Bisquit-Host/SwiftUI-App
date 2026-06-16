import ScrechKit
import AudioVisualizer

struct AudioPlayerView: View {
    @State private var vm = QuickLookVM()
    @EnvironmentObject private var fileVM: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    private let id, name, path: String
    
    init(_ id: String, name: String, at path: String) {
        self.id = id
        self.path = path
        self.name = name
    }
    
    var body: some View {
        VStack {
            if let url = vm.fileURL {
                AudioVisualizerView(url, fileName: name, image: Image(.artwork))
            } else {
                ProgressView()
            }
        }
        .navigationTitle(name)
        .ignoresSafeArea()
        .task {
            await vm.fetchDownloadURL(id, file: name, at: path)
        }
        .toolbarTitleMenu {
#if os(tvOS)
            ToolbarItem(placement: .topBarLeading) {
                SFButton("arrow.left") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
            }
#else
            if let url = vm.fileURL {
                ShareLink(item: url)
                    .transition(.identity)
            } else {
                ShareLink(item: name)
                    .disabled(vm.fileURL == nil)
            }
            
            Section {
                Button("Delete", systemImage: "trash", role: .destructive, action: deleteFile)
            }
#endif
        }
    }
    
    private func deleteFile() {
        Task {
            await fileVM.deleteFile(name, at: path) {
                dismiss()
            }
        }
    }
}

#Preview {
    AudioPlayerView("", name: "Preview", at: "")
        .darkSchemePreferred()
        .environmentObject(FileTabVM(""))
}
