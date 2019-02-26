#if os(iOS)
@testable import RidiOAuth2_iOS
#else
@testable import RidiOAuth2_macOS
#endif
import RxSwift
import XCTest

class RidiOAuth2Tests: XCTestCase {
    private let disposeBag = DisposeBag()
    
    private var authorization: Authorization!
    
    struct Dummy {
        static let clientId = "test"
        static let accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJpT1NBaG4iLCJ1X2lkeCI6MTIzNDU2Ny" +
            "wiZXhwIjoxNTM3NDM4MzgxLCJjbGllbnRfaWQiOiJlUGdiS0tSeVB2ZEFGelR2RmcyRHZyUzdHZW5mc3RIZGtRMnV2Rk5kIiwic2" +
            "NvcGUiOiJhbGwifQ.D7orb7vzfdgDqi_ZWV-t3bsFODC4mjNfOH4MXJuMn80"
        static let refreshToken = "XbFdJiND7ZltASEPy4oHiCd9QRjOcR"
    }
    
    override func setUp() {
        authorization = Authorization(clientId: Dummy.clientId, protocolClasses: [HTTPStubURLProtocol.self])
    }
    
    override func tearDown() {
        super.tearDown()
        Hippolyte.shared.stop()
    }
    
    private var urlMatcher: RegexMatcher {
        let regex = try! NSRegularExpression(pattern: "https://account.ridibooks.com")
        return RegexMatcher(regex: regex)
    }
    
    private func setUpRequestRidiAuthorizationStub(loginRequired: Bool) {
        let redirectUrl =
            loginRequired ? "https://account.ridibooks.com/login?return_url=login_required" : "app://authorized"
        let response = StubResponse.Builder()
            .stubResponse(withStatusCode: loginRequired ? 200 : 302)
            .addHeader(withKey: "Location", value: redirectUrl)
        let request = StubRequest.Builder()
            .stubRequest(withMethod: .GET, urlMatcher: urlMatcher)
            .addResponse(response.build())
        Hippolyte.shared.add(stubbedRequest: request.build())
        Hippolyte.shared.start()
        
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.setCookie(HTTPCookie(url: ".ridibooks.com", name: "ridi-at", value: Dummy.accessToken))
        cookieStorage.setCookie(HTTPCookie(url: ".ridibooks.com", name: "ridi-rt", value: Dummy.refreshToken))
    }
    
    private func setUpRefreshAccessTokenStub() {
        let response = StubResponse.Builder()
            .stubResponse(withStatusCode: 200)
        let request = StubRequest.Builder()
            .stubRequest(withMethod: .POST, urlMatcher: urlMatcher)
            .addResponse(response.build())
        Hippolyte.shared.add(stubbedRequest: request.build())
        Hippolyte.shared.start()
    }
    
    func testRidiAuthorization() {
        setUpRequestRidiAuthorizationStub(loginRequired: false)
        
        let expt = expectation(description: "testRidiAuthorization")
        authorization.requestRidiAuthorization().subscribe { event in
            if case let .success(tokenPair) = event {
                XCTAssertEqual(tokenPair.accessToken, Dummy.accessToken)
                XCTAssertEqual(tokenPair.refreshToken, Dummy.refreshToken)
                expt.fulfill()
            } else {
                XCTFail()
            }
        }.addDisposableTo(disposeBag)
        wait(for: [expt], timeout: 5)
    }
    
    func testTokenRefresh() {
        setUpRefreshAccessTokenStub()
        
        let expt = expectation(description: "testTokenRefresh")
        authorization.refreshAccessToken(refreshToken: Dummy.refreshToken).subscribe { event in
            if case let .success(tokenPair) = event {
                XCTAssertEqual(tokenPair.accessToken, Dummy.accessToken)
                XCTAssertEqual(tokenPair.refreshToken, Dummy.refreshToken)
                expt.fulfill()
            } else {
                XCTFail()
            }
        }.addDisposableTo(disposeBag)
        wait(for: [expt], timeout: 5)
    }
    
    func testRedirectingToLoginPage() {
        setUpRequestRidiAuthorizationStub(loginRequired: true)
        
        let expt = expectation(description: "testRedirectingToLoginPage")
        authorization.requestRidiAuthorization().subscribe { event in
            if case let .error(error) = event {
                XCTAssertEqual((error as NSError).domain, AuthorizationErrorDomain)
                expt.fulfill()
            } else {
                XCTFail()
            }
        }.addDisposableTo(disposeBag)
        wait(for: [expt], timeout: 5)
    }
}
