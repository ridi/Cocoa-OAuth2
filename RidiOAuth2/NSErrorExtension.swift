import Foundation

extension NSError {
    convenience init(statusCode: Int = 0, error: Error? = nil) {
        let userInfo: [String: Any] = [AuthorizationErrorKey: error ?? "nil"]
        self.init(domain: AuthorizationErrorDomain, code: statusCode, userInfo: userInfo)
    }
}
