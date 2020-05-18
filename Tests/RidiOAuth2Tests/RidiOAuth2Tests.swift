import Foundation
import XCTest
import RxSwift
import Hippolyte
@testable import RidiOAuth2

final class RidiOAuth2Tests: XCTestCase {
    private let disposeBag = DisposeBag()
    
    private var authorization: Authorization!
    
    struct Dummy {
        static let clientId = "dummyClientId"
        static let clientSecret = "dummyClientSecret"
        static let username = "dummyUsername"
        static let password = "dummyPassword"
        
        static let accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJpT1NBaG4iLCJ1X2lkeCI6MTIzNDU2Ny" +
            "wiZXhwIjoxNTM3NDM4MzgxLCJjbGllbnRfaWQiOiJlUGdiS0tSeVB2ZEFGelR2RmcyRHZyUzdHZW5mc3RIZGtRMnV2Rk5kIiwic2" +
            "NvcGUiOiJhbGwifQ.D7orb7vzfdgDqi_ZWV-t3bsFODC4mjNfOH4MXJuMn80"
        static let refreshToken = "XbFdJiND7ZltASEPy4oHiCd9QRjOcR"
        
        static let errorCode = "invalid_request"
        static let errorDescription = "Request is missing username parameter."
    }
    
    override func setUp() {
        authorization = Authorization(
            clientId: Dummy.clientId,
            clientSecret: Dummy.clientSecret
        )
    }
    
    override func tearDown() {
        super.tearDown()
        Hippolyte.shared.stop()
    }
    
    private var urlMatcher: RegexMatcher {
        let regex = try! NSRegularExpression(pattern: "https://account.ridibooks.com")
        return RegexMatcher(regex: regex)
    }
    
    private func setUpRequestPasswordGrantAuthorizationStub() {
        let response = StubResponse.Builder()
            .stubResponse(withStatusCode: 200)
            .addBody("""
                {"access_token":"\(Dummy.accessToken)","expires_in":3500,
                "token_type":"Bearer","scope":"all",
                "refresh_token":"\(Dummy.refreshToken)","refresh_token_expires_in":3500}
                """.data(using: .utf8)!)
        let request = StubRequest.Builder()
            .stubRequest(withMethod: .POST, urlMatcher: urlMatcher)
            .addResponse(response.build())
        Hippolyte.shared.add(stubbedRequest: request.build())
        Hippolyte.shared.start()
    }
    
    func testRequestPasswordGrantAuthorization() {
        setUpRequestPasswordGrantAuthorizationStub()
        
        let expt = expectation(description: "testRequestPasswordGrantAuthorization")
        authorization.requestPasswordGrantAuthorization(username: Dummy.username, password: Dummy.password)
            .subscribe { event in
                if case let .success(tokenResponse) = event {
                    XCTAssertEqual(tokenResponse.accessToken, Dummy.accessToken)
                    XCTAssertEqual(tokenResponse.refreshToken, Dummy.refreshToken)
                    expt.fulfill()
                } else {
                    XCTFail()
                }
            }
            .disposed(by: disposeBag)
        wait(for: [expt], timeout: 5)
    }
    
    private func setUpRequestPasswordGrantAuthorizationErrorStub() {
        let response = StubResponse.Builder()
            .stubResponse(withStatusCode: 400)
            .addBody("""
                {"error":"\(Dummy.errorCode)","description":"\(Dummy.errorDescription)"}
                """.data(using: .utf8)!)
        let request = StubRequest.Builder()
            .stubRequest(withMethod: .POST, urlMatcher: urlMatcher)
            .addResponse(response.build())
        Hippolyte.shared.add(stubbedRequest: request.build())
        Hippolyte.shared.start()
    }
    
    func testRequestPasswordGrantAuthorizationError() {
        setUpRequestPasswordGrantAuthorizationErrorStub()
        
        let expt = expectation(description: "testRequestPasswordGrantAuthorizationError")
        authorization.requestPasswordGrantAuthorization(username: Dummy.username, password: Dummy.password)
            .subscribe { event in
                if case let .error(error) = event {
                    let userInfo = (error as NSError).userInfo
                    XCTAssertEqual(userInfo[AuthorizationErrorKey.statusCode] as? Int, 400)
                    XCTAssertEqual(userInfo[AuthorizationErrorKey.errorCode] as? String, Dummy.errorCode)
                    XCTAssertEqual(userInfo[AuthorizationErrorKey.errorDescription] as? String, Dummy.errorDescription)
                    expt.fulfill()
                } else {
                    XCTFail()
                }
            }
            .disposed(by: disposeBag)
        wait(for: [expt], timeout: 5)
    }

    static var allTests = [
        ("testRequestPasswordGrantAuthorization", testRequestPasswordGrantAuthorization),
        ("testRequestPasswordGrantAuthorizationError", testRequestPasswordGrantAuthorizationError),
    ]
}
