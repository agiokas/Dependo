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

let testInjectMacros: [String: Macro.Type] = [
    "resolve": ResolveMacro.self,
]

#endif


final class InjectMacroTests: XCTestCase {
    func testInject() throws {
#if canImport(DependoMacros)
        assertMacroExpansion(
            #"""
            @resolveSource()
            final class SMyDI2: Dependo {}
            
            let k: ABC = #resolve(SMyDI2.self)
            """#,
            expandedSource:
            #"""
            @resolveSource()
            final class SMyDI2: Dependo {}
            
            let k: ABC = SMyDI2.shared.resolve()
            """#,
            diagnostics: [],
            macros: testInjectMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testInject_invalid_class() throws {
#if canImport(DependoMacros)
        assertMacroExpansion(
            #"""
            @resolveSource()
            final class SMyDI2: Dependo {}
            
            let k: ABC = #resolve(SMyDI2)
            """#,
            expandedSource:
            #"""
            @resolveSource()
            final class SMyDI2: Dependo {}
            
            let k: ABC = #resolve(SMyDI2)
            """#,
            diagnostics: [.init(message: "#resolve(param.Type) should get a Dependo subclass Type as a parameter.", line: 4, column: 14)],
            macros: testInjectMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
