//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct ResolveSourceMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try checkDependo(declaration: declaration)
        
        let sharedInstance = """
            static var shared = Dependo()
        """
        
        let initializer = """
        override init() {
            super.init()
            Self.shared = self
        }
        """
        
        return [
            DeclSyntax(stringLiteral: sharedInstance),
            DeclSyntax(stringLiteral: initializer),
        ]
    }
}
