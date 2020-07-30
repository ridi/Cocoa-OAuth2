import Foundation

public struct AuthorizationError: Swift.Error {
    var underlyingError: Swift.Error?
    var statusCode: Int?
    var authorizationErrorCode: String?
    var authorizationErrorDescription: String?
}

extension AuthorizationError: CustomNSError {
    public struct ErrorUserInfoKey {
        public static let statusCode = "statusCode"
        public static let authorizationErrorCode = "errorCode"
        public static let authorizationErrorDescription = "errorDescription"
    }

    public static var errorDomain: String { "\(String(reflecting: self)).Domain" }
    public var errorCode: Int { 0 }
    public var errorUserInfo: [String: Any] {
        var errorUserInfo = [String: Any]()

        underlyingError.flatMap { errorUserInfo[NSUnderlyingErrorKey] = $0 }
        statusCode.flatMap { errorUserInfo[ErrorUserInfoKey.statusCode] = $0 }
        authorizationErrorCode.flatMap { errorUserInfo[ErrorUserInfoKey.authorizationErrorCode] = $0 }
        authorizationErrorDescription.flatMap { errorUserInfo[ErrorUserInfoKey.authorizationErrorDescription] = $0 }

        return errorUserInfo
    }
}
