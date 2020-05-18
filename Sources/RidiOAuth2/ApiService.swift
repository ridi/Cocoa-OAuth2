import Alamofire
import Foundation

enum GrantType: String {
    case password
    case refresh  = "refresh_token"
}

private extension Dictionary where Key == String {
    subscript(safe key: Key) -> Value? {
        get {
            return self[key]
        }
        set {
            if let newValue = newValue {
                self[key] = newValue
            }
        }
    }
}

final class ApiService {
    private let timeout: TimeInterval = 10
    
    private let sessionManager: SessionManager
    private let baseUrl: String
    
    init(baseUrl: String, protocolClasses: [AnyClass]? = nil) {
        var headers = SessionManager.defaultHTTPHeaders
        headers["Accept"] = "application/json"
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.httpAdditionalHeaders = headers
        configuration.httpShouldSetCookies = true
        configuration.protocolClasses = protocolClasses
        
        sessionManager = SessionManager(configuration: configuration)
        self.baseUrl = baseUrl
    }
    
    private func createUrl(path: String) -> URL {
        return URL(string: baseUrl)!.appendingPathComponent(path)
    }
    
    func requestToken(
        grantType: GrantType,
        clientId: String,
        clientSecret: String,
        username: String? = nil,
        password: String? = nil,
        refreshToken: String? = nil,
        extraData: [String: String] = [:],
        completion: @escaping (Swift.Result<TokenResponse, Error>) -> Void
    ) {
        let url = createUrl(path: "oauth2/token")
        var parameters: Parameters = ["grant_type": grantType.rawValue]
        parameters[safe: "client_id"] = clientId
        parameters[safe: "client_secret"] = clientSecret
        parameters[safe: "username"] = username
        parameters[safe: "password"] = password
        parameters[safe: "refresh_token"] = refreshToken
        extraData.forEach { parameters[safe: $0.key] = $0.value }
        sessionManager.request(url, method: .post, parameters: parameters).responseJSON(completionHandler: { response in
            let error = response.result.error as NSError?
            let statusCode = response.response?.statusCode
            if let value = response.result.value as? [String: Any] {
                if let tokenResponse = TokenResponse(dictionary: value) {
                    completion(.success(tokenResponse))
                } else {
                    completion(.failure(NSError(
                        error: error,
                        statusCode: statusCode,
                        errorCode: value["error"] as? String,
                        errorDescription: value["error_description"] as? String
                    )))
                }
            } else {
                completion(.failure(NSError(
                    error: error,
                    statusCode: statusCode,
                    errorCode: nil,
                    errorDescription: nil
                )))
            }
        })
    }
}
