import SwiftUI
import QuickLooking

struct QuickLookFile: View {
    @State private var vm = QuickLookVM()
    
    @Binding var link: FileLink?
    
    init(_ link: Binding<FileLink?>) {
        _link = link
    }
    
    var body: some View {
        let name = link?.name ?? ""
        
        VStack {
            if let fileURL = vm.fileURL {
                QuickLookView(fileURL)
                    .transition(.opacity)
                    .padding()
            } else {
                ProgressView()
            }
        }
        .navigationTitle(name)
        .animation(.default, value: vm.fileURL)
        .ignoresSafeArea(edges: .bottom)
        .task {
            if let id = link?.id, let root = link?.root {
                await vm.fetchDownloadURL(id, file: name, at: root)
            }
        }
        .toolbar {
            if let fileURL = vm.fileURL {
                ShareLink(item: fileURL)
            }
        }
    }
}
