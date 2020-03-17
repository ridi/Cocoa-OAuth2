public struct TokenResponse {
    public let accessToken: String
    public let expiresIn: Int
    public let tokenType: String
    public let scope: String
    public let refreshToken: String
    public let refreshTokenExpiresIn: Int
    
    init?(dictionary: [String: Any]) {
        guard let accessToken = dictionary["access_token"] as? String,
            let expiresIn = dictionary["expires_in"] as? Int,
            let tokenType = dictionary["token_type"] as? String,
            let scope = dictionary["scope"] as? String,
            let refreshToken = dictionary["refresh_token"] as? String,
            let refreshTokenExpiresIn = dictionary["refresh_token_expires_in"] as? Int else {
                return nil
        }
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
        self.scope = scope
        self.refreshToken = refreshToken
        self.refreshTokenExpiresIn = refreshTokenExpiresIn
    }
}
