import Alamofire
import RxSwift

public let AuthorizationErrorDomain = "Authorization.Error.Domain"
public let AuthorizationErrorKey = "AuthorizationErrorKey"

private extension Array where Element: HTTPCookie {
    func first(where predicate: (domain: String, name: String)) -> Element? {
        return first { $0.domain.hasSuffix(predicate.domain) && $0.name == predicate.name }
    }
}

public final class Authorization {
    private struct Host {
        static let dev = "dev.ridi.io"
        static let real = "ridibooks.com"
    }
    
    private struct CookieName {
        static let accessToken = "ridi-at"
        static let refreshToken = "ridi-rt"
    }
    
    private let clientId: String
    private let host: String
    private let api: Api
    
    private let redirectUri = "app://authorized"
    
    private let cookieStorage = HTTPCookieStorage.shared
    
    public init(clientId: String, devMode: Bool = false) {
        self.clientId = clientId
        self.host = devMode ? Host.dev : Host.real
        self.api = Api(baseUrl: "https://account.\(host)/")
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
            let cookies = cookieStorage.cookies ?? []
            guard let at = cookies.first(where: (host, CookieName.accessToken))?.value,
                let rt = cookies.first(where: (host, CookieName.refreshToken))?.value else {
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
