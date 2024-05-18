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

let testCreateGlobalResolverMacroMacros: [String: Macro.Type] = [
    "createGlobalResolver": CreateGlobalResolverMacro.self,
]

#endif


final class CreateGlobalResolverMacroTests: XCTestCase {
    func testResolve() throws {
#if canImport(DependoMacros)
        assertMacroExpansion(
            #"""
            @shared()
            final class SMyDI2: Dependo {}
            
            #createGlobalResolver(SMyDI2.self)
            """#,
            expandedSource:
            #"""
            @shared()
            final class SMyDI2: Dependo {}
            
            let DI = {
                SMyDI2.shared
            }()
            """#,
            diagnostics: [],
            macros: testCreateGlobalResolverMacroMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testResolve_invalid_class() throws {
#if canImport(DependoMacros)
        assertMacroExpansion(
            #"""
            @shared()
            final class SMyDI2: Dependo {}
            
            #createGlobalResolver(SMyDI2)
            """#,
            expandedSource:
            #"""
            @shared()
            final class SMyDI2: Dependo {}
            
            #createGlobalResolver(SMyDI2)
            """#,
            diagnostics: [.init(message: "#resolve(param.Type) should get a Dependo subclass Type as a parameter.", line: 4, column: 1)],
            macros: testCreateGlobalResolverMacroMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
