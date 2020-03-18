import JWTDecode
import RidiOAuth2
import RxSwift
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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
        isDevMode = false
    }
    
    private func makeAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func dispatch(event: SingleEvent<TokenResponse>) {
        switch event {
        case let .success(tokenResponse):
            refreshToken = tokenResponse.refreshToken
            let jwt = try! decode(jwt: tokenResponse.accessToken)
            let title = "Success"
            let subject = jwt.subject ?? "nil"
            let uIdx = jwt.claim(name: "u_idx").integer ?? 0
            let expDate = jwt.claim(name: "exp").date?.description ?? "nil"
            let message = "Subject = \(subject)\nu_idx = \(uIdx)\nexpDate = \(expDate)"
            makeAlert(title: title, message: message)
        case let .error(error):
            makeAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    @IBAction func switchMode(_ sender: UISegmentedControl) {
        isDevMode = sender.selectedSegmentIndex > 0
    }
    
    @IBAction func fetchAccessToken() {
        let username = idTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        authorization.requestPasswordGrantAuthorization(username: username, password: password)
            .subscribe(dispatch)
            .disposed(by: disposeBag)
    }
    
    @IBAction func refreshAccessToken() {
        if let token = refreshToken {
            authorization.refreshAccessToken(refreshToken: token)
                .subscribe(dispatch)
                .disposed(by: disposeBag)
        }
    }
}
