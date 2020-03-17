import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RidiOAuth2Tests.allTests),
    ]
}
#endif
