//import SwiftUI
//
//struct AppContainer: UIViewControllerRepresentable {
//    @Binding var viewController: MessagesViewController? // Binding to hold the reference
//
//    func makeUIViewController(context: Context) -> MessagesViewController {
//        let viewController = MessagesViewController()
//        context.coordinator.viewController = viewController
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: MessagesViewController, context: Context) {
//        // Update the view controller if needed
//        self.viewController = uiViewController
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject {
//        var parent: AppContainer
//        weak var viewController: MessagesViewController?
//
//        init(_ parent: AppContainer) {
//            self.parent = parent
//        }
//    }
//}
