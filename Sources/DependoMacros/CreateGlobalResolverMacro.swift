//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CreateGlobalResolverMacro: DeclarationMacro {
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        let di = try getDependoSubclass(node: node)
        return [DeclSyntax(stringLiteral: wrapper(name: di))]
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
    
    private static func wrapper(name: String) -> String {
    """
    let DI = { \(name).shared }()
    """
    }
}


