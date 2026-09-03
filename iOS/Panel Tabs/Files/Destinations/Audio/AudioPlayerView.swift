import ScrechKit
import AudioVisualizer

struct AudioPlayerView: View {
    @State private var vm = QuickLookVM()
    @EnvironmentObject private var fileVM: FileTabVM
    @Environment(\.dismiss) private var dismiss
    @Environment(\.panelToolbarButtonsVisible) private var toolbarButtonsVisible
    
    @State private var alertDelete = false
    
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
            if toolbarButtonsVisible {
                Section {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        alertDelete = true
                    }
                }
            }
        }
        .alert("Delete \(name)?", isPresented: $alertDelete) {
            Button("Delete", role: .destructive, action: deleteFile)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This file will be deleted permanently")
        }
        .toolbar {
            if let url = vm.fileURL {
                PanelToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: url)
                        .transition(.identity)
                }
            }
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
