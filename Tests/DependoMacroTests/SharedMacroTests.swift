//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(DependoMacros)
import DependoMacros

let testSharedMacro: [String: Macro.Type] = [
    "shared": SharedMacro.self,
]

#endif


final class SharedMacroTests: XCTestCase {
    func testResolveSourceMacro() throws {
#if canImport(DependoMacros)
        assertMacroExpansion(
            """
            @shared()
            class ABC: Dependo {
            
            }
            """,
            expandedSource:
            """
            class ABC: Dependo {
            
                private static var _shared: ABC?
            
                static var shared: ABC {
                    _shared ?? ABC()
                }

                @discardableResult override init() {
                    super.init()
                    Self._shared = self
                }
            
            }
            """,
            diagnostics: [],
            macros: testSharedMacro
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testInvalidClass() throws {
#if canImport(DependoMacros)
        assertMacroExpansion(
            """
            @shared()
            struct ABC {}
            """,
            expandedSource:
            """
            struct ABC {}
            """,
            diagnostics: [.init(message: "Macro should be used on a Dependo subclass.", line: 1, column: 1)],
            macros: testSharedMacro
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
