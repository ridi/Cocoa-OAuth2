import Alamofire

enum ResponseType: String {
    case code
    case password
}

final class Api {
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
        
        self.sessionManager = SessionManager(configuration: configuration)
        self.baseUrl = baseUrl
    }
    
    private func createUrl(path: String) -> URL {
        return URL(string: baseUrl)!.appendingPathComponent(path)
    }
    
    func requestAuthorization(
        clientId: String,
        responseType: ResponseType,
        redirectUri: String,
        completion: @escaping (DefaultDataResponse) -> Void
    ) {
        let url = createUrl(path: "ridi/authorize")
        let parameters: Parameters = ["client_id": clientId, "response_type": responseType, "redirect_uri": redirectUri]
        sessionManager.request(url, method: .get, parameters: parameters).response(completionHandler: completion)
    }
    
    func refreshAccessToken(completion: @escaping (DefaultDataResponse) -> Void) {
        let url = createUrl(path: "ridi/token")
        sessionManager.request(url, method: .post).response(completionHandler: completion)
    }
}
