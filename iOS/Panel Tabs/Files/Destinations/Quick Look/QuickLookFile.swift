import ScrechKit
import QuickLooking

struct QuickLookFile: View {
    @State private var vm: QuickLookFileVM
    @EnvironmentObject private var fileVM: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    private let id, name, path: String
    
    init(_ id: String, name: String, at path: String) {
        self.id = id
        self.path = path
        self.name = name
        vm = QuickLookFileVM(id)
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
            await vm.getFileURL(name, at: path)
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
        .toolbarTitleMenu {
            Button("Metadata", systemImage: "tag") {
                sheetMetadata = true
            }
            
            Section {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    Task {
                        await fileVM.deleteFile(name, at: path) {
                            dismiss()
                        }
                    }
                }
            }
        }
        .toolbar {
            if let url = vm.fileURL {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: url)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuickLookFile("", name: "", at: "")
    }
    .darkSchemePreferred()
    .environmentObject(FileTabVM(""))
}
