import SwiftUI
import WebKit

struct HCaptchaWebView: UIViewRepresentable {
    @ObservedObject var vm: HCaptchaVM
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        vm.configure(webView)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
}
