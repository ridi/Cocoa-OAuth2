import Alamofire
import RxSwift

public let AuthorizationErrorDomain = "Authorization.Error.Domain"
public let AuthorizationErrorKey = "AuthorizationErrorKey"

public final class Authorization {
    private let devHost = "account.dev.ridi.io"
    private let realHost = "account.ridibooks.com"
    
    private let redirectUri = "app://authorized"
    
    private let atCookieName = "ridi-at"
    private let rtCookieName = "ridi-rt"
    
    private let clientId: String
    private let api: Api
    
    public init(clientId: String, devMode: Bool = false) {
        self.clientId = clientId
        self.api = Api(baseUrl: "https://\(devMode ? devHost : realHost)/")
    }
    
    private func makeError(_ statusCode: Int = 0, _ error: Error? = nil) -> Error {
        let userInfo: [String: Any] = [AuthorizationErrorKey: error ?? "nil"]
        return NSError(domain: AuthorizationErrorDomain, code: statusCode, userInfo: userInfo)
    }
    
    private func dispatch(
        response: DefaultDataResponse,
        to emitter: ((SingleEvent<TokenPair>) -> Void),
        with filter: () -> Bool
    ) {
        let error = makeError(response.response?.statusCode ?? 0, response.error)
        if filter() {
            let cookieStorage = HTTPCookieStorage.shared
            guard let at = cookieStorage.cookies?.first(where: { $0.name == atCookieName })?.value,
                let rt = cookieStorage.cookies?.first(where: { $0.name == rtCookieName })?.value else {
                    emitter(.error(error))
                    return
            }
            let tokenPair = TokenPair(accessToken: at, refreshToken: rt)
            emitter(.success(tokenPair))
        } else {
            emitter(.error(error))
        }
    }
    
    @available(*, deprecated, message: "use requestPasswordGrantAuthorization: instead")
    public func requestRidiAuthorization() -> Single<TokenPair> {
        return Single<TokenPair>.create { emitter -> Disposable in
            self.api.requestAuthorization(
                clientId: self.clientId,
                responseType: .code,
                redirectUri: self.redirectUri
            ) { response in
                self.dispatch(response: response, to: emitter, with: { () -> Bool in
                    if let nsError = response.error as NSError?,
                        nsError.code == NSURLErrorUnsupportedURL,
                        let failingUrl = nsError.userInfo[NSURLErrorFailingURLStringErrorKey] as? String,
                        failingUrl == self.redirectUri {
                            return true
                    }
                    return false
                })
            }
            return Disposables.create()
        }
    }
    
    public func requestPasswordGrantAuthorization() -> Single<TokenPair> {
        fatalError("TODO")
    }
    
    public func refreshAccessToken(refreshToken: String) -> Single<TokenPair> {
        return Single<TokenPair>.create { emitter -> Disposable in
            self.api.refreshAccessToken { response in
                self.dispatch(response: response, to: emitter, with: { () -> Bool in
                    let statusCode = response.response?.statusCode ?? 0
                    return statusCode == 200
                })
            }
            return Disposables.create()
        }
    }
}
