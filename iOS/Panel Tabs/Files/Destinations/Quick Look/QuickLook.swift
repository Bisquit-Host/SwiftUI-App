import SwiftUI
import QuickLook

struct QuickLookView: UIViewControllerRepresentable {
    private let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        var parent: QuickLookView
        
        init(_ parent: QuickLookView) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            parent.url as QLPreviewItem
        }
    }
}
