//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

import Foundation
import XCTest
@testable import Dependo

public extension XCTestCase {
    /// Tests that the running the given `closure` returns in a `fatalError()` call.
    func expectFatalError(file: StaticString = #file,
                          line: UInt = #line,
                          closure: @escaping () -> Void) {
        let exp = expectation(description: "expectFatalError")

        FatalErrorOverride.replaceFatalError { _, _, _ in
            exp.fulfill()

            repeat {
                RunLoop.current.run()
            } while true
        }

        // act, perform on separate thead because a call to fatalError pauses forever
        let uuid = UUID().uuidString
        DispatchQueue(label: uuid).async(execute: closure)

        let result = XCTWaiter.wait(for: [exp], timeout: XCTWaiter.timeout, enforceOrder: false)
        switch result {
        case .timedOut:
            FatalErrorOverride.restoreFatalError()
            XCTFail("Expect Fatal Error", file: file, line: line)
        default:
            FatalErrorOverride.restoreFatalError()
        }
    }
}

private extension XCTWaiter {
    static var timeout: TimeInterval { 1 }
}
