import SwiftUI

struct PanelCustomGesture: UIGestureRecognizerRepresentable {
    var handle: (UIPanGestureRecognizer) -> Void
    var shouldBegin: ((UIPanGestureRecognizer) -> Bool)?
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> GestureCoordinator {
        GestureCoordinator(shouldBegin: shouldBegin)
    }
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        gesture.delegate = context.coordinator
        return gesture
    }
    
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {
        context.coordinator.shouldBegin = shouldBegin
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }
    
    final class GestureCoordinator: NSObject, UIGestureRecognizerDelegate {
        var shouldBegin: ((UIPanGestureRecognizer) -> Bool)?
        
        init(shouldBegin: ((UIPanGestureRecognizer) -> Bool)?) {
            self.shouldBegin = shouldBegin
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
                return true
            }
            
            return shouldBegin?(panGesture) ?? true
        }
    }
}
