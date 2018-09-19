import Foundation

struct Global {
    struct ClientID {
        static let dev = "Nkt2Xdc0zMuWmye6MSkYgqCh9q6JjeMCsUiH1kgL"
        static let real = "ePgbKKRyPvdAFzTvFg2DvrS7GenfstHdkQ2uvFNd"
    }
    
    struct Host {
        static let dev = "dev.ridi.io"
        static let real = "ridibooks.com"
    }
    
    static func removeAllCookies() {
        let cookieStorage = HTTPCookieStorage.shared
        for cookie in cookieStorage.cookies ?? [] {
            cookieStorage.deleteCookie(cookie)
        }
    }
}
