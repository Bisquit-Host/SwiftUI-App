import SwiftUI

/// Wrapper-view to provide UIView instance
struct UIViewWrapperView: UIViewRepresentable {
    @ObservedObject var host: HCaptchaHost
    
    func makeUIView(context: Context) -> UIView {
        host.view.backgroundColor = .systemBackground
        return host.view
    }
    
    func updateUIView(_ view: UIView, context: Context) {}
}
