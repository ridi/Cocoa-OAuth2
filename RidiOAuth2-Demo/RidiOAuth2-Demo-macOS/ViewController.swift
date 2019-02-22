import Cocoa
import JWTDecode
import RidiOAuth2
import RxSwift

class ViewController: NSViewController {
    private let disposeBag = DisposeBag()
    
    private var authorization: Authorization!
    
    private var refreshToken: String?
    
    private var isDevMode = false {
        didSet {
            Global.removeAllCookies()
            refreshToken = nil
            let clientId = isDevMode ? Global.ClientID.dev : Global.ClientID.real
            authorization = Authorization(clientId: clientId, devMode: isDevMode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSApplication.shared.activate(ignoringOtherApps: true)
        isDevMode = false
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "login" {
            (segue.destinationController as! WebViewController).isDevMode = isDevMode
        }
    }
    
    private func alertWith(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "확인")
        alert.beginSheetModal(for: view.window!, completionHandler: nil)
    }
    
    private func dispatch(event: SingleEvent<TokenPair>) {
        switch event {
        case .success(let tokenPair):
            self.refreshToken = tokenPair.refreshToken
            let jwt = try! decode(jwt: tokenPair.accessToken)
            let subject = jwt.subject ?? "nil"
            let uIdx = jwt.claim(name: "u_idx").integer ?? 0
            let expDate = jwt.claim(name: "exp").date?.description ?? "nil"
            let message = "Subject = \(subject)\nu_idx = \(uIdx)\nexpDate = \(expDate)"
            self.alertWith(message: "Success:\n\(message)")
        case .error(let error):
            self.alertWith(message: "Error:\n\(error.localizedDescription)")
        }
    }
    
    @IBAction func switchMode(_ sender: NSSegmentedControl) {
        isDevMode = sender.selectedSegment != 0
    }
    
    @IBAction func fetchAccessToken(_ sender: Any) {
        authorization.requestRidiAuthorization().subscribe(self.dispatch).addDisposableTo(disposeBag)
    }
    
    @IBAction func refreshAccessToken(_ sender: Any) {
        if let token = refreshToken {
            authorization.refreshAccessToken(refreshToken: token).subscribe(self.dispatch).addDisposableTo(disposeBag)
        }
    }
}
