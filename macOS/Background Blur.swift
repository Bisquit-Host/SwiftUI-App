import SwiftUI

struct BackgroundBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct BackgroundBlurModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                BackgroundBlur()
                    .ignoresSafeArea()
            }
    }
}

extension View {
    public func backgroundBlur() -> some View {
        modifier(BackgroundBlurModifier())
    }
}
