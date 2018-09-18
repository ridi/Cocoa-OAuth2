import Alamofire
import RxSwift

public let AuthorizationErrorDomain = "Authorization.Error.Domain"
public let AuthorizationErrorKey = "AuthorizationErrorKey"

public final class Authorization {
    private let devHost = "account.dev.ridi.io"
    private let realHost = "account.ridibooks.com"
    private let redirectUri = "app://authorized"
    
    private let clientId: String
    private let api: Api
    
    public init(clientId: String, devMode: Bool = false) {
        self.clientId = clientId
        self.api = Api(baseUrl: "https://\(devMode ? devHost : realHost)/")
    }
    
    private func makeError(_ statusCode: Int = 0, _ nsError: NSError? = nil) -> Error {
        let userInfo: [String: Any] = [AuthorizationErrorKey: nsError ?? "nil"]
        return NSError(domain: AuthorizationErrorDomain, code: statusCode, userInfo: userInfo)
    }
    
    private func dispatch(response: DefaultDataResponse, to single: (SingleEvent<TokenPair>) -> Void) {
        guard let nsError = response.error as NSError? else {
            single(.error(makeError()))
            return
        }
        
        let error = makeError(response.response?.statusCode ?? 0, nsError)
        let cookieStorage = HTTPCookieStorage.shared
        if nsError.code != NSURLErrorUnsupportedURL {
            single(.error(error))
            return
        }
        
        if let failingUrl = nsError.userInfo[NSURLErrorFailingURLErrorKey] as? String,
            failingUrl == redirectUri {
                single(.error(error))
                return
        }
        
        guard let at = cookieStorage.cookies?.first(where: { $0.name == "ridi-at" })?.value,
            let rt = cookieStorage.cookies?.first(where: { $0.name == "ridi-rt" })?.value else {
                single(.error(error))
                return
        }
        
        let tokenPair = TokenPair(accessToken: at, refreshToken: rt)
        single(.success(tokenPair))
    }
    
    @available(*, deprecated, message: "use requestPasswordGrantAuthorization: instead")
    public func requestRidiAuthorization() -> Single<TokenPair> {
        return Single<TokenPair>.create { single -> Disposable in
            self.api.requestAuthorization(
                clientId: self.clientId,
                responseType: .code,
                redirectUri: self.redirectUri
            ) { response in
                self.dispatch(response: response, to: single)
            }
            return Disposables.create()
        }
    }
    
    public func requestPasswordGrantAuthorization() -> Single<TokenPair> {
        fatalError("TODO")
    }
    
    public func refreshAccessToken(refreshToken: String) -> Single<TokenPair> {
        return Single<TokenPair>.create { single -> Disposable in
            self.api.refreshAccessToken { response in
                self.dispatch(response: response, to: single)
            }
            return Disposables.create()
        }
    }
}
