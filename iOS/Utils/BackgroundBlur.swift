import SwiftUI

fileprivate struct BackgroundBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

extension View {
    public func backgroundBlur() -> some View {
        self.background {
            BackgroundBlur()
                .ignoresSafeArea()
        }
    }
}
