import Cocoa
import JWTDecode
import RidiOAuth2
import RxSwift

class ViewController: NSViewController {
    @IBOutlet weak var idTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    
    private let disposeBag = DisposeBag()
    
    private var authorization: Authorization!
    
    private var refreshToken: String?
    
    private var isDevMode = false {
        didSet {
            refreshToken = nil
            let clientId = isDevMode ? Global.ClientID.dev : Global.ClientID.real
            let clientSecret = isDevMode ? Global.ClientSecret.dev : Global.ClientSecret.real
            authorization = Authorization(clientId: clientId, clientSecret: clientSecret, devMode: isDevMode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSApplication.shared.activate(ignoringOtherApps: true)
        isDevMode = false
    }
    
    private func makeAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "확인")
        alert.beginSheetModal(for: view.window!, completionHandler: nil)
    }
    
    private func dispatch(event: SingleEvent<TokenResponse>) {
        switch event {
        case let .success(tokenResponse):
            refreshToken = tokenResponse.refreshToken
            let jwt = try! decode(jwt: tokenResponse.accessToken)
            let subject = jwt.subject ?? "nil"
            let uIdx = jwt.claim(name: "u_idx").integer ?? 0
            let expDate = jwt.claim(name: "exp").date?.description ?? "nil"
            let message = "Subject = \(subject)\nu_idx = \(uIdx)\nexpDate = \(expDate)"
            makeAlert(message: "Success:\n\(message)")
        case let .error(error):
            makeAlert(message: "Error:\n\(error.localizedDescription)")
        }
    }
    
    @IBAction func switchMode(_ sender: NSSegmentedControl) {
        isDevMode = sender.selectedSegment != 0
    }
    
    @IBAction func fetchAccessToken(_ sender: Any) {
        let username = idTextField.stringValue
        let password = passwordTextField.stringValue
        authorization.requestPasswordGrantAuthorization(username: username, password: password)
            .subscribe(dispatch)
            .disposed(by: disposeBag)
    }
    
    @IBAction func refreshAccessToken(_ sender: Any) {
        if let token = refreshToken {
            authorization.refreshAccessToken(refreshToken: token)
                .subscribe(dispatch)
                .disposed(by: disposeBag)
        }
    }
}
