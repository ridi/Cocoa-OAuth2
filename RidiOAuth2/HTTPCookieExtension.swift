import Foundation

extension HTTPCookie {
    convenience init(url: String, name: String, value: String, secure: Bool = true) {
        var properties = [HTTPCookiePropertyKey: Any]()
        properties[.name] = name
        properties[.value] = value
        properties[.domain] = url
        properties[.originURL] = url
        properties[.path] = "/"
        properties[.secure] = secure
        self.init(properties: properties)!
    }
}
