import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    var isDevMode = false
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !webView.isLoading {
            let url = URL(string: "https://\(isDevMode ? Global.Host.dev : Global.Host.real)/account/login")!
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
    
    private func willLoad() {
        indicatorView.startAnimating()
        UIView.animate(withDuration: 0.1) {
            self.indicatorView.alpha = 1.0
        }
    }
    
    private func didLoad() {
        indicatorView.stopAnimating()
        UIView.animate(withDuration: 0.1) {
            self.indicatorView.alpha = 0.0
        }
    }
    
    func webView(
        _ webView: UIWebView,
        shouldStartLoadWith request: URLRequest,
        navigationType: UIWebViewNavigationType
    ) -> Bool {
        if request.url?.absoluteString == "https://\(isDevMode ? Global.devHost : Global.realHost)/" {
            dismiss(animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        willLoad()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        didLoad()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        didLoad()
    }
}
