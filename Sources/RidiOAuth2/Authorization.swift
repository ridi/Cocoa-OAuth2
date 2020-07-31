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
        session.rx.request(
                request: TokenRequest(
                    grantType: .password,
                    clientID: clientId,
                    clientSecret: clientSecret,
                    username: username,
                    password: password,
                    refreshToken: nil,
                    extraData: extraData
                )
            )
            .map {
                try self._processResponse($0)
            }
    }
    
    public func refreshAccessToken(
        refreshToken: String,
        extraData: [String: String] = [:]
    ) -> Single<TokenResponse> {
        session.rx.request(
                request: TokenRequest(
                    grantType: .refresh,
                    clientID: clientId,
                    clientSecret: clientSecret,
                    username: nil,
                    password: nil,
                    refreshToken: refreshToken,
                    extraData: extraData
                )
            )
            .map {
                try self._processResponse($0)
            }
    }

    private func _processResponse(_ response: Response<_TokenResponse, Swift.Error>) throws -> TokenResponse {
        switch response.result {
        case .success(let _token):
            guard let token = _token.token else {
                throw AuthorizationError(
                    underlyingError: nil,
                    statusCode: response.response?.statusCode,
                    apiErrorCode: try? response.result.get().errorCode,
                    apiErrorDescription: try? response.result.get().errorDescription
                )
            }

            return token
        case .failure(let error):
            throw AuthorizationError(
                underlyingError: error,
                statusCode: response.response?.statusCode,
                apiErrorCode: try? response.result.get().errorCode,
                apiErrorDescription: try? response.result.get().errorDescription
            )
        }
    }
}
