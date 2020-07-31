import Foundation

public struct AuthorizationError: Swift.Error {
    var underlyingError: Swift.Error?
    var statusCode: Int?
    var apiErrorCode: String?
    var apiErrorDescription: String?
}

extension AuthorizationError: CustomNSError {
    public struct ErrorUserInfoKey {
        public static let statusCode = "statusCode"
        public static let apiErrorCode = "errorCode"
        public static let apiErrorDescription = "errorDescription"
    }

    public static var errorDomain: String { "\(String(reflecting: self)).Domain" }
    public var errorCode: Int { 0 }
    public var errorUserInfo: [String: Any] {
        var errorUserInfo = [String: Any]()

        underlyingError.flatMap { errorUserInfo[NSUnderlyingErrorKey] = $0 }
        statusCode.flatMap { errorUserInfo[ErrorUserInfoKey.statusCode] = $0 }
        apiErrorCode.flatMap { errorUserInfo[ErrorUserInfoKey.apiErrorCode] = $0 }
        apiErrorDescription.flatMap { errorUserInfo[ErrorUserInfoKey.apiErrorDescription] = $0 }

        return errorUserInfo
    }
}
