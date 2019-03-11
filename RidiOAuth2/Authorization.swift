import Alamofire
import RxSwift

public final class Authorization {
    private struct Host {
        static let dev = "dev.ridi.io"
        static let real = "ridibooks.com"
    }
    
    private let clientId: String
    private let clientSecret: String
    private let host: String
    private let apiService: ApiService
    
    public init(clientId: String, clientSecret: String, devMode: Bool = false) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        host = devMode ? Host.dev : Host.real
        apiService = ApiService(baseUrl: "https://account.\(host)/")
    }
    
    #if TEST
    public init(clientId: String, clientSecret: String, devMode: Bool = false, protocolClasses: [AnyClass]? = nil) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        host = devMode ? Host.dev : Host.real
        apiService = ApiService(baseUrl: "https://account.\(host)/", protocolClasses: protocolClasses)
    }
    #endif
    
    public func requestPasswordGrantAuthorization(username: String, password: String) -> Single<TokenResponse> {
        return Single<TokenResponse>.create { emitter -> Disposable in
            self.apiService.requestToken(
                grantType: .password,
                clientId: self.clientId,
                clientSecret: self.clientSecret,
                username: username,
                password: password,
                refreshToken: nil,
                success: { tokenResponse in
                    emitter(.success(tokenResponse))
                },
                failure: { error in
                    emitter(.error(error))
                }
            )
            return Disposables.create()
        }
    }
    
    public func refreshAccessToken(refreshToken: String) -> Single<TokenResponse> {
        return Single<TokenResponse>.create { emitter -> Disposable in
            self.apiService.requestToken(
                grantType: .refresh,
                clientId: self.clientId,
                clientSecret: self.clientSecret,
                username: nil,
                password: nil,
                refreshToken: refreshToken,
                success: { tokenResponse in
                    emitter(.success(tokenResponse))
                },
                failure: { error in
                    emitter(.error(error))
                }
            )
            return Disposables.create()
        }
    }
}
