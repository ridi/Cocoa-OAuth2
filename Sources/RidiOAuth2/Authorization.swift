import Foundation
import RxSwift
import HTTPURLKit
import RxHTTPURLKit

public final class Authorization {
    private struct Host {
        static let dev = "dev.ridi.io"
        static let real = "ridibooks.com"
    }
    
    private let clientId: String
    private let clientSecret: String
    private let host: String
    private let baseURL: URL
    private let session: Session
    
    public init(clientId: String, clientSecret: String, devMode: Bool = false) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        host = devMode ? Host.dev : Host.real
        baseURL = URL(string: "https://account.\(host)/")!
        session = Session()
    }
    
    #if TEST
        public init(clientId: String, clientSecret: String, devMode: Bool = false, protocolClasses: [AnyClass]? = nil) {
            self.clientId = clientId
            self.clientSecret = clientSecret
            host = devMode ? Host.dev : Host.real
            baseURL = URL(string: "https://account.\(host)/")!
            session = Session()
        }
    #endif

    public func requestPasswordGrantAuthorization(
        username: String,
        password: String,
        extraData: [String: String] = [:]
    ) -> Single<TokenResponse> {
        session.rx.request(request: TokenRequest(grantType: .password, clientID: self.clientId, clientSecret: self.clientSecret, username: username, password: password, refreshToken: nil, extraData: extraData, baseURL: baseURL))
            .map {
                switch $0.result {
                case .success(let _token):
                    guard let token = _token.token else {
                        throw AuthorizationError(
                            underlyingError: nil,
                            statusCode: $0.response?.statusCode,
                            authorizationErrorCode: try? $0.result.get().errorCode,
                            authorizationErrorDescription: try? $0.result.get().errorDescription
                        )
                    }

                    return token
                case .failure(let error):
                    throw AuthorizationError(
                        underlyingError: error,
                        statusCode: $0.response?.statusCode,
                        authorizationErrorCode: try? $0.result.get().errorCode,
                        authorizationErrorDescription: try? $0.result.get().errorDescription
                    )
                }
            }
    }
    
    public func refreshAccessToken(
        refreshToken: String,
        extraData: [String: String] = [:]
    ) -> Single<TokenResponse> {
        session.rx.request(request: TokenRequest(grantType: .refresh, clientID: self.clientId, clientSecret: self.clientSecret, username: nil, password: nil, refreshToken: refreshToken, extraData: extraData, baseURL: baseURL))
            .map {
                switch $0.result {
                case .success(let _token):
                    guard let token = _token.token else {
                        throw AuthorizationError(
                            underlyingError: nil,
                            statusCode: $0.response?.statusCode,
                            authorizationErrorCode: try? $0.result.get().errorCode,
                            authorizationErrorDescription: try? $0.result.get().errorDescription
                        )
                    }

                    return token
                case .failure(let error):
                    throw AuthorizationError(
                        underlyingError: error,
                        statusCode: $0.response?.statusCode,
                        authorizationErrorCode: try? $0.result.get().errorCode,
                        authorizationErrorDescription: try? $0.result.get().errorDescription
                    )
                }
            }
    }
}
