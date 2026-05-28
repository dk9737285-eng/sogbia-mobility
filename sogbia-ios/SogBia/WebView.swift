import SwiftUI
import WebKit
import CoreLocation

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        // Configure WebView settings
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        // Enable local storage, cookies and DOM databases
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Enable swipe back/forward gestures natively
        webView.allowsBackForwardNavigationGestures = true
        
        // Modern iOS visuals: transparency & disable web scroll bounces
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.bounces = true
        
        // Load web URL request
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, CLLocationManagerDelegate {
        var parent: WebView
        let locationManager = CLLocationManager()
        
        init(_ parent: WebView) {
            self.parent = parent
            super.init()
            // Request native system location permissions if needed
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
        
        // MARK: - WKNavigationDelegate Methods
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Dynamic CSS injection: Hides the top navigation bar (.main-nav) within the iOS native app
            // to provide a full-screen native user interface, identical to the Android app behavior.
            let cssString = ".main-nav { display: none !important; }"
            let cssInjection = """
            var style = document.createElement('style');
            style.innerHTML = '\(cssString)';
            document.head.appendChild(style);
            """
            
            webView.evaluateJavaScript(cssInjection) { _, error in
                if let error = error {
                    print("[SogBia Debug] WKWebView dynamic CSS injection failed: \(error.localizedDescription)")
                }
            }
            
            // Failsafe slight delay before fading out loading overlay to ensure smooth UI transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        // MARK: - WKUIDelegate Methods (Handles HTML5 Geolocation API Requests)
        
        @available(iOS 15.0, *)
        func webView(
            _ webView: WKWebView,
            decidePolicyFor securityOrigin: WKSecurityOrigin,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            // Seamlessly forward Geolocation requests to native iOS CoreLocation prompt
            decisionHandler(.grant)
        }
        
        // Custom elegant representation of JavaScript Alerts natively in iOS
        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            let alert = UIAlertController(title: "SogBia", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            } else {
                completionHandler()
            }
        }
    }
}
