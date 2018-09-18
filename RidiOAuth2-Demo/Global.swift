import Foundation

struct Global {
    static let devClientId = "Nkt2Xdc0zMuWmye6MSkYgqCh9q6JjeMCsUiH1kgL"
    static let realClientId = "ePgbKKRyPvdAFzTvFg2DvrS7GenfstHdkQ2uvFNd"
    
    static func removeAllCookies() {
        let cookieStorage = HTTPCookieStorage.shared
        for cookie in cookieStorage.cookies ?? [] {
            cookieStorage.deleteCookie(cookie)
        }
    }
}
