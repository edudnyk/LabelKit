import XCTest
@testable import LabelKit

final class LabelKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LabelKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
