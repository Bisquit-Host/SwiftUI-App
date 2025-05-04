import SwiftUI

@available(macOS 10.10, *)
struct BackgroundBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

@available(macOS 10.15, *)
struct BackgroundBlurModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                BackgroundBlur()
                    .ignoresSafeArea()
            }
    }
}

@available(macOS 10.15, *)
extension View {
    public func backgroundBlur() -> some View {
        modifier(BackgroundBlurModifier())
    }
}
