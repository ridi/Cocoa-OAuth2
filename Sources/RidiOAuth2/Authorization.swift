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
    private let session: Session
    
    public init(clientId: String, clientSecret: String, devMode: Bool = false) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        host = devMode ? Host.dev : Host.real
        session = Session(baseURL: URL(string: "https://account.\(host)/"))
    }

    public func requestPasswordGrantAuthorization(
        username: String,
        password: String,
        extraData: [String: String] = [:]
    ) -> Single<TokenResponse> {
        request(
            TokenRequest(
                grantType: .password,
                clientID: clientId,
                clientSecret: clientSecret,
                username: username,
                password: password,
                refreshToken: nil,
                extraData: extraData
            )
        )
    }
    
    public func refreshAccessToken(
        refreshToken: String,
        extraData: [String: String] = [:]
    ) -> Single<TokenResponse> {
        request(
            TokenRequest(
                grantType: .refresh,
                clientID: clientId,
                clientSecret: clientSecret,
                username: nil,
                password: nil,
                refreshToken: refreshToken,
                extraData: extraData
            )
        )
    }

    private func request(_ request: TokenRequest) -> Single<TokenResponse> {
        .create { single -> Disposable in
            let request = self.session.request(request) { response in
                switch response.result {
                case .success(let _token):
                    guard let token = _token.token else {
                        single(.error(
                            AuthorizationError(
                                underlyingError: nil,
                                statusCode: response.response?.statusCode,
                                apiErrorCode: try? response.result.get().errorCode,
                                apiErrorDescription: try? response.result.get().errorDescription
                            )
                        ))
                        return
                    }

                    single(.success(token))
                case .failure(let error):
                    single(.error(
                        AuthorizationError(
                            underlyingError: error,
                            statusCode: response.response?.statusCode,
                            apiErrorCode: try? response.result.get().errorCode,
                            apiErrorDescription: try? response.result.get().errorDescription
                        )
                    ))
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
