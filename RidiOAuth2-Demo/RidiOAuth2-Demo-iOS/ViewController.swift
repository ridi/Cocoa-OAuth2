import JWTDecode
import RidiOAuth2
import RxSwift
import UIKit

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private var authorization: Authorization!
    
    private var refreshToken: String?
    
    private var isDevMode = false {
        didSet {
            Global.removeAllCookies()
            refreshToken = nil
            let clientId = isDevMode ? Global.devClientId : Global.realClientId
            authorization = Authorization(clientId: clientId, devMode: isDevMode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isDevMode = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login" {
            (segue.destination as! WebViewController).isDevMode = isDevMode
        }
    }
    
    private func alertWith(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func dispatch(event: SingleEvent<TokenPair>) {
        switch event {
        case .success(let tokenPair):
            self.refreshToken = tokenPair.refreshToken
            let jwt = try! decode(jwt: tokenPair.accessToken)
            let title = "Success"
            let subject = jwt.subject ?? "nil"
            let uIdx = jwt.claim(name: "u_idx").integer ?? 0
            let expDate = jwt.claim(name: "exp").date?.description ?? "nil"
            let message = "Subject = \(subject)\nu_idx = \(uIdx)\nexpDate = \(expDate)"
            self.alertWith(title: title, message: message)
        case .error(let error):
            self.alertWith(title: "Error", message: error.localizedDescription)
        }
    }
    
    @IBAction func switchMode(_ sender: UISegmentedControl) {
        isDevMode = sender.selectedSegmentIndex > 0
    }
    
    @IBAction func fetchAccessToken() {
        authorization.requestRidiAuthorization().subscribe(self.dispatch).addDisposableTo(disposeBag)
    }
    
    @IBAction func refreshAccessToken() {
        if let token = refreshToken {
            authorization.refreshAccessToken(refreshToken: token).subscribe(self.dispatch).addDisposableTo(disposeBag)
        }
    }
}
