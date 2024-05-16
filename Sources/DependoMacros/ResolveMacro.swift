//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct ResolveMacro: ExpressionMacro {
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, 
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        let di = try getDependoSubclass(node: node)
        return ExprSyntax(stringLiteral: "\(di).shared.resolve()")
    }
    
    private static func getDependoSubclass(node: some SwiftSyntax.FreestandingMacroExpansionSyntax) throws -> String {
        guard let basename = node.arguments
            .first?
            .expression
            .as(MemberAccessExprSyntax.self)?
            .base?
            .as(DeclReferenceExprSyntax.self)?
            .baseName else {
            throw DIError.invalidInjectDependo
        }
        
        return basename.text
    }
}
