import Foundation
import OSLog
import WebKit

final class HCaptchaVM: NSObject, ObservableObject {
    @Published var token: String?
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private let siteKey = "35f8534a-b950-4dea-b304-9b00f1a0f300"
    
    func configure(_ webView: WKWebView) {
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(self, name: "captcha")
        webView.loadHTMLString(html, baseURL: URL(string: "https://my.bisquit.host"))
    }
    
    private var html: String {
        """
        <!doctype html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                html, body {
                    margin: 0;
                    width: 100%;
                    height: 100%;
                    background: #050505;
                    color: white;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                }
                #captcha {
                    min-width: 320px;
                    min-height: 100px;
                }
            </style>
            <script src="https://js.hcaptcha.com/1/api.js?render=explicit" async defer></script>
        </head>
        <body>
            <div id="captcha"></div>
            <script>
                function post(payload) {
                    window.webkit.messageHandlers.captcha.postMessage(payload)
                }
                
                function renderCaptcha() {
                    if (!window.hcaptcha) {
                        window.setTimeout(renderCaptcha, 100)
                        return
                    }
                    
                    hcaptcha.render("captcha", {
                        sitekey: "\(siteKey)",
                        theme: "dark",
                        callback: function(token) {
                            post({ token: token })
                        },
                        "error-callback": function(error) {
                            post({ error: String(error || "Captcha failed") })
                        },
                        "expired-callback": function() {
                            post({ error: "Captcha expired" })
                        }
                    })
                }
                
                renderCaptcha()
            </script>
        </body>
        </html>
        """
    }
}

extension HCaptchaVM: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
        Logger().error("hCaptcha navigation failed: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
        Logger().error("hCaptcha provisional navigation failed: \(error.localizedDescription)")
    }
}

extension HCaptchaVM: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        isLoading = false
        
        guard let payload = message.body as? [String: Any] else {
            errorMessage = "Invalid captcha response"
            return
        }
        
        if let token = payload["token"] as? String, !token.isEmpty {
            self.token = token
            return
        }
        
        errorMessage = payload["error"] as? String ?? "Captcha failed"
    }
}
