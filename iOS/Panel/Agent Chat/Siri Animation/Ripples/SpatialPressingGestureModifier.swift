import SwiftUI

// https://developer.apple.com/videos/play/wwdc2024/10151/?time=1416

extension View {
    func onPressingChanged(_ action: @escaping (CGPoint?) -> Void) -> some View {
        modifier(SpatialPressingGestureModifier(action))
    }
}

struct SpatialPressingGestureModifier: ViewModifier {
    var onPressingChanged: (CGPoint?) -> Void
    
    init(_ action: @escaping (CGPoint?) -> Void) {
        onPressingChanged = action
    }
    
    @State var currentLocation: CGPoint?
    
    func body(content: Content) -> some View {
#if os(visionOS)
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { currentLocation = $0.location }
                    .onEnded { _ in currentLocation = nil }
            )
            .onChange(of: currentLocation, initial: false) { _, location in
                onPressingChanged(location)
            }
#else
        let gesture = SpatialPressingGesture(location: $currentLocation)
        
        content
            .gesture(gesture)
            .onChange(of: currentLocation, initial: false) { _, location in
                onPressingChanged(location)
            }
#endif
    }
}

#if !os(visionOS)
struct SpatialPressingGesture: UIGestureRecognizerRepresentable {
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @objc func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
    
    @Binding var location: CGPoint?
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    
    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = 0
        recognizer.delegate = context.coordinator
        
        return recognizer
    }
    
    func handleUIGestureRecognizerAction(
        _ recognizer: UIGestureRecognizerType, context: Context) {
            switch recognizer.state {
            case .began:
                location = context.converter.localLocation
                
            case .ended, .cancelled, .failed:
                location = nil
                
            default:
                break
            }
        }
}
#endif
