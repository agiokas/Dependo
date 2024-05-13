//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct DIMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DependoExpanMacro.self
    ]
}

public struct DependoExpanMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        let parameters = try getParameters(node)
        let resultType = try getResultType(node)

        let parameterList = parameters.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
        let unnamedParameterList = parameters.map { "_ \($0.name): \($0.type)" }.joined(separator: ", ")
        let parameterName = parameters.map { "\($0.name)\($0.type)" }.joined(separator: "_") + "_\(resultType)"
        let parameterPassing = parameters.map { "\($0.name): \($0.name)" }.joined(separator: ", ")
        let unnamedParameterPassing = parameters.map { "\($0.name)" }.joined(separator: ", ")
        
        let property = """
        private var \(parameterName): ((\(unnamedParameterList), _ resolver: Resolver) -> \(resultType))?
        """
        
        let resolve = """
        func resolve(\(parameterList)) -> \(resultType) {
            guard let result: \(resultType) = tryResolve(\(parameterPassing)) else {
                fatalError("Could not resolve \(resultType)")
            }
            return result
        }
        """
        
        let tryResolve = """
        func tryResolve(\(parameterList)) -> \(resultType)? { \(parameterName)?(\(unnamedParameterPassing), self) }
        """
        
        
        let replace = """
        @discardableResult func replace(factory: @escaping (\(unnamedParameterList), _ resolver: Resolver) -> \(resultType)) -> Self {
            threadSafe {
                self.\(parameterName) = factory
            }
            return self
        }
        """
        let register = """
        @discardableResult func register(factory: @escaping (\(unnamedParameterList), _ resolver: Resolver) -> \(resultType)) -> Self {
            guard \(parameterName) == nil else {
                fatalError("Type \(resultType) with parameters (\(parameterList)) already registered.")
            }
            return replace(factory: factory)
        }
        """
                
        return [
            DeclSyntax(stringLiteral: property),
            DeclSyntax(stringLiteral: tryResolve),
            DeclSyntax(stringLiteral: resolve),
            DeclSyntax(stringLiteral: replace),
            DeclSyntax(stringLiteral: register)
        ]
    }
}

private func getParameters(_ node: SwiftSyntax.AttributeSyntax) throws -> [(name: String, type: String)] {
    guard let list = node.arguments else {
        throw DIError.invalidParameters
    }
    switch list {
    case let .argumentList(listSyntax):
        guard let firstElement = listSyntax.first, firstElement.label?.text == "parameters" else {
            throw DIError.invalidParameters
        }
        guard let parameters = firstElement.expression.as(MemberAccessExprSyntax.self) else {
            throw DIError.invalidParameters
        }
        return try analyse(parameters)
    default:
        throw DIError.invalidParameters
    }
}

private func analyse(_ members: MemberAccessExprSyntax) throws -> [(name: String, type: String)] {
    if let declaration = members.base?.as(DeclReferenceExprSyntax.self) {
        return [("param", declaration.baseName.text)]
    }
    if let tuple = members.base?.as(TupleExprSyntax.self) {
        return try tuple.elements.map { element in
            guard let name = element.label?.text else {
                throw DIError.unnamedTupleParameter
            }
            guard let type = element.expression.as(DeclReferenceExprSyntax.self)?.baseName.text else {
                throw DIError.invalidTupleParameterType
            }
            return (name, type)
        }
    }
    throw DIError.invalidParameters
}

private func getResultType(_ node: SwiftSyntax.AttributeSyntax) throws -> String {
    guard let list = node.arguments else {
        throw DIError.invalidReturnType
    }
    switch list {
    case let .argumentList(listSyntax):
        guard let lastElement = listSyntax.last, lastElement.label?.text == "result" else {
            throw DIError.invalidReturnType
        }
        guard let declReference = lastElement.expression.as(MemberAccessExprSyntax.self)?.base?.as(DeclReferenceExprSyntax.self) else {
            throw DIError.invalidReturnType
        }
        return declReference.baseName.text
    default:
        throw DIError.invalidReturnType
    }
}

enum DIError: Error {
    case invalidParameters
    case invalidReturnType
    case unnamedTupleParameter
    case invalidTupleParameterType
}
 
extension DependoExpanMacro: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
                                 providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
                                 conformingTo protocols: [SwiftSyntax.TypeSyntax],
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        []
    }
}

