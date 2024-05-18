import XCTest
@testable import Example

final class ExampleTests: XCTestCase {
    func testExample() throws {
        let startApp = StartApp()
        XCTAssertThrowsError(try startApp.initialize())
    }
}
