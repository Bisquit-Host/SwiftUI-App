import SwiftUI
import QuickLooking

struct QuickLookFile: View {
    @State private var vm = QuickLookViewVM()
    
    @Binding var link: FileLink?
    
    init(_ link: Binding<FileLink?>) {
        _link = link
    }
    
    private var name: String {
        link?.name ?? ""
    }
    
    var body: some View {
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
            await vm.fetchDownloadUrl(link?.id, file: name, at: link?.root)
        }
        .toolbar {
            if let fileURL = vm.fileURL {
                ShareLink(item: fileURL)
            }
        }
    }
}
