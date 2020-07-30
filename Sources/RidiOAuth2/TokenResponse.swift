import Foundation

public struct TokenResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case scope = "scope"
        case refreshToken = "refresh_token"
        case refreshTokenExpiresIn = "refresh_token_expires_in"
    }

    public let accessToken: String
    public let expiresIn: Int
    public let tokenType: String
    public let scope: String
    public let refreshToken: String
    public let refreshTokenExpiresIn: Int
}

struct _TokenResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case errorCode = "error"
        case errorDescription = "description"
    }

    public let errorCode: String?
    public let errorDescription: String?
    public let token: TokenResponse?

    init(from decoder: Decoder) throws {
        guard let token = try? TokenResponse(from: decoder) else {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            errorCode = try container.decodeIfPresent(String.self, forKey: .errorCode)
            errorDescription = try container.decodeIfPresent(String.self, forKey: .errorDescription)
            self.token = nil

            return
        }

        self.errorCode = nil
        self.errorDescription = nil
        self.token = token
    }
}
