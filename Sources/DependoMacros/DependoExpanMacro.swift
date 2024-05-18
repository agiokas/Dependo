//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

@main
struct DIMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DependoExpanMacro.self,
        SharedMacro.self,
        CreateGlobalResolverMacro.self
    ]
}

public struct DependoExpanMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try checkDependo(declaration: declaration)
        let parameters = try getParameters(node)
        let resultType = try getResultType(node)

        let parameterList = parameters.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
        let unnamedParameterList = parameters.map { "_ \($0.name): \($0.type)" }.joined(separator: ", ")
        let parameterName = (parameters
            .map { "\($0.name)\($0.type)" }
            .joined(separator: "_") + "_\(resultType)")
            .replacingOccurrences(of: "?", with: "Optional")
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

func checkDependo(declaration: some SwiftSyntax.DeclGroupSyntax) throws {
    guard let inheritanceClause = declaration.inheritanceClause else {
        throw DIError.notDependoSubclass
    }
    guard inheritanceClause.inheritedTypes.contains(where: { inheritance in
        inheritance.type.as(IdentifierTypeSyntax.self)?.name.text == "Dependo"
    }) else {
        throw DIError.notDependoSubclass
    }
}

private func getParameters(_ node: SwiftSyntax.AttributeSyntax) throws -> [(name: String, type: String)] {
    guard let list = node.arguments else {
        throw DIError.invalidSyntax
    }
    switch list {
    case let .argumentList(listSyntax):
        guard let firstElement = listSyntax.first, firstElement.label?.text == "parameters" else {
            throw DIError.invalidSyntax
        }
        guard let parameters = firstElement.expression.as(MemberAccessExprSyntax.self) else {
            throw DIError.invalidSyntax
        }
        return try analyse(parameters)
    default:
        throw DIError.invalidSyntax
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
            
            // Expression is a non-optional type
            if let type = element.expression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                return (name, type)
            }
            
            // Expression is a optional type
            if let optionalExpr = element.expression.as(OptionalChainingExprSyntax.self) {
                if let type = optionalExpr.expression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                    return (name, "\(type)?")
                }
            }
            
            throw DIError.invalidTupleParameterType
        }
    }
    throw DIError.invalidSyntax
}

private func getResultType(_ node: SwiftSyntax.AttributeSyntax) throws -> String {
    guard let list = node.arguments else {
        throw DIError.invalidResultType
    }
    switch list {
    case let .argumentList(listSyntax):
        guard let lastElement = listSyntax.last, lastElement.label?.text == "result" else {
            throw DIError.invalidSyntax
        }
        guard let declReference = lastElement.expression.as(MemberAccessExprSyntax.self)?.base?.as(DeclReferenceExprSyntax.self) else {
            throw DIError.invalidResultType
        }
        return declReference.baseName.text
    default:
        throw DIError.invalidResultType
    }
}

enum DIError: Error, CustomStringConvertible {
    case notDependoSubclass
    case invalidSyntax
    case invalidResultType
    case unnamedTupleParameter
    case invalidTupleParameterType
    case invalidClass
    case invalidInjectDependo
    case sharedMacroInvalidClass

    var description: String {
        switch self {
        case .notDependoSubclass: "Macro should be used on a Dependo subclass."
        case .invalidSyntax: "Invalid Syntax. Currect syntax is `@declare<P, T>(parameters: P1.Type, result: T.Type)`. P can be a normal type or a tuple."
        case .invalidResultType: "Invalid result type. Result type should not be Closures or other Tuples."
        case .invalidTupleParameterType: "Invalid tuple parameters. Tuple parameters should not be Closures or other Tuples."
        case .unnamedTupleParameter: "Tuple parameters should be named. i.e. (Int, String) to (age: Int, name: String)"
        case .invalidClass: "Macro should be used on a subclass of Dependo."
        case .invalidInjectDependo: "#resolve(param.Type) should get a Dependo subclass Type as a parameter."
        case .sharedMacroInvalidClass: "@shared should be used on a Dependo subclass."
        }
    }
}
