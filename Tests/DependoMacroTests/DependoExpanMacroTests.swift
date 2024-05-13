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

let testExpanMacros: [String: Macro.Type] = [
    "register": DependoExpanMacro.self,
]

#endif

final class DependoExpanMacroTests: XCTestCase {
    func testMacroRegisterOneParameter() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            protocol IVM {}
            class SomeVM: IVM {}
            
            @register(parameters: Int.self, result: OtherClass.self)
            class ABC {
            
            }
            """,
            expandedSource:
            """
            protocol IVM {}
            class SomeVM: IVM {}
            class ABC {
            
                private var paramInt_OtherClass: ((_ param: Int, _ resolver: Resolver) -> OtherClass)?

                func tryResolve(param: Int) -> OtherClass? {
                    paramInt_OtherClass?(param, self)
                }

                func resolve(param: Int) -> OtherClass {
                    guard let result: OtherClass = tryResolve(param: param) else {
                        fatalError("Could not resolve OtherClass")
                    }
                    return result
                }

                @discardableResult func replace(factory: @escaping (_ param: Int, _ resolver: Resolver) -> OtherClass) -> Self {
                    threadSafe {
                        self.paramInt_OtherClass = factory
                    }
                    return self
                }
            
                @discardableResult func register(factory: @escaping (_ param: Int, _ resolver: Resolver) -> OtherClass) -> Self {
                    guard paramInt_OtherClass == nil else {
                        fatalError("Type OtherClass with parameters (param: Int) already registered.")
                    }
                    return replace(factory: factory)
                }
            
            }
            """,
            macros: testExpanMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroRegisterTuple() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            protocol IVM {}
            class SomeVM: IVM {}
            
            @register(parameters: (p1: Int, p2: String).self, result: OtherClass.self)
            class ABC {
            
            }
            """,
            expandedSource:
            """
            protocol IVM {}
            class SomeVM: IVM {}
            class ABC {
            
                private var p1Int_p2String_OtherClass: ((_ p1: Int, _ p2: String, _ resolver: Resolver) -> OtherClass)?

                func tryResolve(p1: Int, p2: String) -> OtherClass? {
                    p1Int_p2String_OtherClass?(p1, p2, self)
                }

                func resolve(p1: Int, p2: String) -> OtherClass {
                    guard let result: OtherClass = tryResolve(p1: p1, p2: p2) else {
                        fatalError("Could not resolve OtherClass")
                    }
                    return result
                }

                @discardableResult func replace(factory: @escaping (_ p1: Int, _ p2: String, _ resolver: Resolver) -> OtherClass) -> Self {
                    threadSafe {
                        self.p1Int_p2String_OtherClass = factory
                    }
                    return self
                }
            
                @discardableResult func register(factory: @escaping (_ p1: Int, _ p2: String, _ resolver: Resolver) -> OtherClass) -> Self {
                    guard p1Int_p2String_OtherClass == nil else {
                        fatalError("Type OtherClass with parameters (p1: Int, p2: String) already registered.")
                    }
                    return replace(factory: factory)
                }
            
            }
            """,
            macros: testExpanMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
