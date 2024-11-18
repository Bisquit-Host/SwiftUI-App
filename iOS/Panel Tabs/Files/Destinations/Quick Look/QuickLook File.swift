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
    
    @State private var sheetPlayground = false
    @State private var sheetMetadata = false
    
    var body: some View {
        VStack {
            if let url = vm.fileURL {
                QuickLookView(url)
                    .transition(.opacity)
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
                    @Environment(\.supportsImagePlayground) var supportsImagePlayground
                    
                    SFButton("tag") {
                        sheetMetadata = true
                    }
                    
                    Button {
                        sheetPlayground = true
                    } label: {
                        Image(.appleIntelligence)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .opacity(supportsImagePlayground ? 1 : 0.3)
                    }
                    .disabled(!supportsImagePlayground)
                    .sheet($sheetPlayground) {
                        NavigationView {
                            ImagePlayground(url, root: root)
                        }
                    }
                }
                
                ShareLink(item: url)
            }
            
            if vm.isSensitive {
                Button {
                    withAnimation {
                        vm.isSensitive = false
                    }
                } label: {
                    Image(systemName: "eye.slash")
                }
            }
        }
    }
}
