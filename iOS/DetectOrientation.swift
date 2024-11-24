import SwiftUI

struct DetectOrientation: ViewModifier {
    @Binding private var orientation: UIDeviceOrientation
    
    init(_ orientation: Binding<UIDeviceOrientation>) {
        _orientation = orientation
    }
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                orientation = UIDevice.current.orientation
            }
    }
}

extension View {
    func detectOrientation(_ orientation: Binding<UIDeviceOrientation>) -> some View {
        modifier(DetectOrientation(orientation))
    }
}
