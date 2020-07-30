import Foundation
import HTTPURLKit

enum GrantType: String, Encodable {
    case password
    case refresh  = "refresh_token"
}

struct TokenRequest: Encodable, Requestable {
    typealias ResponseBody = _TokenResponse
    typealias Parameters = Self

    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case username
        case password
        case refreshToken = "refresh_token"
    }

    var grantType: GrantType
    var clientID: String
    var clientSecret: String
    var username: String?
    var password: String?
    var refreshToken: String?
    var extraData: Encodable?

    var baseURL: URL

    var url: URL { URL(string: "oauth2/token", relativeTo: baseURL)! }
    var httpMethod: URLRequest.HTTPMethod { .post }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(grantType, forKey: .grantType)
        try container.encode(clientID, forKey: .clientID)
        try container.encode(clientSecret, forKey: .clientSecret)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(refreshToken, forKey: .refreshToken)

        try extraData?.encode(to: encoder)
    }
}
