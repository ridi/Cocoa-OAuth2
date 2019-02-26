import Cocoa
import WebKit

class WebViewController: NSViewController, WebFrameLoadDelegate {
    var isDevMode = false
    
    @IBOutlet weak var webView: WebView!
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if !webView.isLoading {
            let url = URL(string: "https://\(isDevMode ? Global.Host.dev : Global.Host.real)/account/login")!
            let request = URLRequest(url: url)
            webView.mainFrame.load(request)
        }
    }
    
    private func willLoad() {
        indicator.isHidden = false
        indicator.startAnimation(self)
    }
    
    private func didLoad() {
        indicator.stopAnimation(self)
        indicator.isHidden = true
    }
    
    func webView(_ sender: WebView!, didStartProvisionalLoadFor frame: WebFrame!) {
        willLoad()
    }
    
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        didLoad()
        if frame.dataSource?.request.url?.absoluteString == "about:blank" {
            dismiss(self)
        }
    }
    
    func webView(_ sender: WebView!, didFailLoadWithError error: Error!, for frame: WebFrame!) {
        didLoad()
    }
}
