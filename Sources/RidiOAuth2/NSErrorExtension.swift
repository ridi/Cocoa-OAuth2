import Foundation

public let AuthorizationErrorDomain = "Authorization.Error.Domain"
public struct AuthorizationErrorKey {
    public static let error = "error"
    public static let statusCode = "statusCode"
    public static let errorCode = "errorCode"
    public static let errorDescription = "errorDescription"
}

extension NSError {
    convenience init(error: NSError?, statusCode: Int?, errorCode: String?, errorDescription: String?) {
        var userInfo: [String: Any] = [
            AuthorizationErrorKey.error: error ?? "nil",
            AuthorizationErrorKey.statusCode: statusCode ?? "nil",
            AuthorizationErrorKey.errorCode: errorCode ?? "nil",
            AuthorizationErrorKey.errorDescription: errorDescription ?? "nil"
        ]
        userInfo[NSLocalizedDescriptionKey] = "\(AuthorizationErrorDomain) error: \(userInfo)"
        self.init(domain: AuthorizationErrorDomain, code: 0, userInfo: userInfo)
    }
}
