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
    "declare": DependoExpanMacro.self,
]

#endif

final class DependoExpanMacroTests: XCTestCase {
    func testMacroDeclare_wrong_parameter_syntax() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            protocol IVM {}
            class SomeVM: IVM {}
            
            @declare(p: Int.sef, result: OtherClass.self)
            class ABC: Dependo {
            
            }
            """,
            expandedSource:
            """
            protocol IVM {}
            class SomeVM: IVM {}
            class ABC: Dependo {
            
            }
            """,
            diagnostics: [.init(message: "Invalid Syntax. Currect syntax is `@declare<P, T>(parameters: P1.Type, result: T.Type)`. P can be a normal type or a tuple.", line: 4, column: 1)],
            macros: testExpanMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroDeclare_wrong_result_syntax() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            protocol IVM {}
            class SomeVM: IVM {}
            
            @declare(parameter: Int.sef, r: OtherClass.self)
            class ABC: Dependo {
            
            }
            """,
            expandedSource:
            """
            protocol IVM {}
            class SomeVM: IVM {}
            class ABC: Dependo {
            
            }
            """,
            diagnostics: [.init(message: "Invalid Syntax. Currect syntax is `@declare<P, T>(parameters: P1.Type, result: T.Type)`. P can be a normal type or a tuple.", line: 4, column: 1)],
            macros: testExpanMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    
    func testMacroDeclareOneParameter() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            protocol IVM {}
            class SomeVM: IVM {}
            
            @declare(parameters: Int.self, result: OtherClass.self)
            class ABC: Dependo {
            
            }
            """,
            expandedSource:
            """
            protocol IVM {}
            class SomeVM: IVM {}
            class ABC: Dependo {
            
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
    
    func testMacroDeclareTuple() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            protocol IVM {}
            class SomeVM: IVM {}
            
            @declare(parameters: (p1: Int, p2: String).self, result: OtherClass.self)
            class ABC: Dependo {
            
            }
            """,
            expandedSource:
            """
            protocol IVM {}
            class SomeVM: IVM {}
            class ABC: Dependo {
            
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
    
    func testMacroDeclareTuple_withOptional() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            protocol IVM {}
            class SomeVM: IVM {}
            
            @declare(parameters: (p1: Int?, p2: String).self, result: OtherClass.self)
            class ABC: Dependo {
            
            }
            """,
            expandedSource:
            """
            protocol IVM {}
            class SomeVM: IVM {}
            class ABC: Dependo {
            
                private var p1IntOptional_p2String_OtherClass: ((_ p1: Int?, _ p2: String, _ resolver: Resolver) -> OtherClass)?

                func tryResolve(p1: Int?, p2: String) -> OtherClass? {
                    p1IntOptional_p2String_OtherClass?(p1, p2, self)
                }

                func resolve(p1: Int?, p2: String) -> OtherClass {
                    guard let result: OtherClass = tryResolve(p1: p1, p2: p2) else {
                        fatalError("Could not resolve OtherClass")
                    }
                    return result
                }

                @discardableResult func replace(factory: @escaping (_ p1: Int?, _ p2: String, _ resolver: Resolver) -> OtherClass) -> Self {
                    threadSafe {
                        self.p1IntOptional_p2String_OtherClass = factory
                    }
                    return self
                }
            
                @discardableResult func register(factory: @escaping (_ p1: Int?, _ p2: String, _ resolver: Resolver) -> OtherClass) -> Self {
                    guard p1IntOptional_p2String_OtherClass == nil else {
                        fatalError("Type OtherClass with parameters (p1: Int?, p2: String) already registered.")
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
    
    func testMacroDeclare_on_non_Dependo_class() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            @declare(parameters: (p1: Int, p2: String).self, result: OtherClass.self)
            class ABC {
            
            }
            """,
            expandedSource:
            """
            class ABC {
            
            }
            """,
            diagnostics: [.init(message: "Macro should be used on a Dependo subclass.", line: 1, column: 1)],
            macros: testExpanMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroDeclare_invalid_tuple_arguments() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            @declare(parameters: (p1: () -> Int, p2: String).self, result: OtherClass.self)
            class ABC: Dependo {
            
            }
            """,
            expandedSource:
            """
            class ABC: Dependo {
            
            }
            """,
            diagnostics: [.init(message: "Invalid tuple parameters. Tuple parameters should not be Closures or other Tuples.", line: 1, column: 1)],
            macros: testExpanMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroDeclare_unnamed_tuple_arguments() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            @declare(parameters: (Int, String).self, result: OtherClass.self)
            class ABC: Dependo {
            
            }
            """,
            expandedSource:
            """
            class ABC: Dependo {
            
            }
            """,
            diagnostics: [.init(message: "Tuple parameters should be named. i.e. (Int, String) to (age: Int, name: String)", line: 1, column: 1)],
            macros: testExpanMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroDeclare_invalid_result_type_closure() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            @declare(parameters: Int.sef, result: ((Int)->Double).self)
            class ABC: Dependo {
            
            }
            """,
            expandedSource:
            """
            class ABC: Dependo {
            
            }
            """,
            diagnostics: [.init(message: "Invalid result type. Result type should not be Closures or other Tuples.", line: 1, column: 1)],
            macros: testExpanMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroDeclare_no_dependo_subclass() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            @declare(parameters: Int.sef, result: ((Int)->Double).self)
            class ABC: Dependo2 {
            
            }
            """,
            expandedSource:
            """
            class ABC: Dependo2 {
            
            }
            """,
            diagnostics: [.init(message: "Macro should be used on a Dependo subclass.", line: 1, column: 1)],
            macros: testExpanMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroDeclare_invalid_result_type() throws {
        #if canImport(DependoMacros)
        assertMacroExpansion(
            """
            @declare(parameters: Int.sef, result2: Double.self)
            class ABC: Dependo {
            
            }
            """,
            expandedSource:
            """
            class ABC: Dependo {
            
            }
            """,
            diagnostics: [.init(message: "Invalid Syntax. Currect syntax is `@declare<P, T>(parameters: P1.Type, result: T.Type)`. P can be a normal type or a tuple.", line: 1, column: 1)],
            macros: testExpanMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
