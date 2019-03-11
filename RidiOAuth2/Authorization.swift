import Alamofire
import RxSwift

public let AuthorizationErrorDomain = "Authorization.Error.Domain"
public let AuthorizationErrorKey = "AuthorizationErrorKey"

private extension Array where Element: HTTPCookie {
    func first(where matches: (domain: String, name: String)) -> Element? {
        return first { $0.domain.hasSuffix(matches.domain) && $0.name == matches.name }
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
    private let apiService: ApiService
    
    private let redirectUri = "app://authorized"
    
    private let cookieStorage = HTTPCookieStorage.shared
    
    public init(clientId: String, devMode: Bool = false) {
        self.clientId = clientId
        host = devMode ? Host.dev : Host.real
        apiService = ApiService(baseUrl: "https://account.\(host)/")
    }
    
    #if TEST
    public init(clientId: String, devMode: Bool = false, protocolClasses: [AnyClass]? = nil) {
        self.clientId = clientId
        host = devMode ? Host.dev : Host.real
        apiService = ApiService(baseUrl: "https://account.\(host)/", protocolClasses: protocolClasses)
    }
    #endif
    
    private func dispatch(
        response: DefaultDataResponse,
        to emitter: ((SingleEvent<TokenPair>) -> Void),
        with filter: () -> Bool
    ) {
        let error = NSError(statusCode: response.response?.statusCode ?? 0, error: response.error)
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
    
    public func requestRidiAuthorization() -> Single<TokenPair> {
        return Single<TokenPair>.create { emitter -> Disposable in
            self.apiService.requestAuthorization(
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
        cookieStorage.cookieAcceptPolicy = .always
        cookieStorage.setCookie(HTTPCookie(url: host, name: CookieName.refreshToken, value: refreshToken))
        return Single<TokenPair>.create { emitter -> Disposable in
            self.apiService.refreshAccessToken { response in
                self.dispatch(response: response, to: emitter, with: { () -> Bool in
                    let statusCode = response.response?.statusCode ?? 0
                    return statusCode == 200
                })
            }
            return Disposables.create()
        }
    }
}
