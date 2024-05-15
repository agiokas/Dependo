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

let testResolveSourceMacros: [String: Macro.Type] = [
    "resolveSource": ResolveSourceMacro.self,
]

#endif


final class ResolveSourceMacroTests: XCTestCase {
    func testResolveSourceMacro() throws {
#if canImport(DependoMacros)
        assertMacroExpansion(
            """
            @resolveSource()
            class ABC: Dependo {
            
            }
            """,
            expandedSource:
            """
            class ABC: Dependo {
            
                static var shared = Dependo()
            
                override init() {
                    super.init()
                    Self.shared = self
                }
            
            }
            """,
            diagnostics: [],
            macros: testResolveSourceMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testInvalidClass() throws {
#if canImport(DependoMacros)
        assertMacroExpansion(
            """
            @resolveSource()
            struct ABC {}
            """,
            expandedSource:
            """
            struct ABC {}
            """,
            diagnostics: [.init(message: "Macro should be used on a Dependo subclass.", line: 1, column: 1)],
            macros: testResolveSourceMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
