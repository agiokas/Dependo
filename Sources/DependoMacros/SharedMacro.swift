//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct SharedMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try checkDependo(declaration: declaration)
        let name = try getType(declaration)
        
        let sharedInstance = """
            private static var _shared: \(name)?
        static var shared: \(name) { _shared ?? \(name)() }
        """
        
        let initializer = """
        override init() {
            super.init()
            Self._shared = self
        }
        """
        
        return [
            DeclSyntax(stringLiteral: sharedInstance),
            DeclSyntax(stringLiteral: initializer),
        ]
    }
    
    static func getType(_ declaration: some DeclGroupSyntax) throws -> String {
        guard let name = declaration.as(ClassDeclSyntax.self)?.name.text else {
            throw DIError.sharedMacroInvalidClass
        }
        return name
    }
}

