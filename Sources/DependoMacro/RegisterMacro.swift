//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

/// Declare a new paramerized type the DI should be able to register and to resolve.
/// # Example #
/// ```
/// @declare(parameters: (age: Int, name: String).self, result: ResultType.self)
/// ```
@attached(member, names: arbitrary)
public macro declare<P, T>(parameters: P.Type, result: T.Type) = #externalMacro(module: "DependoMacros", type: "DependoExpanMacro")

/// Declare a `Dependo` subclass as shared. This would allow this subclass to inject entities using the #resolve macro.
/// # Example #
/// ```
/// @shared()
/// final class MyDI: Dependo {}
/// ```
@attached(member, names: arbitrary)
public macro shared() = #externalMacro(module: "DependoMacros", type: "SharedMacro")

/// `#createGlobalResolver` would a property named  `DI`  for the specified Dependo subclass`
/// # Example #
/// ```
/// @shared()
/// final class MyDI: Dependo {}
///
/// MyDI()
///     .register(MyUseCase.self) { _ in MyUseCaseImplementation() }
///
/// #createProperty(MyDI.self)
///
/// let myUC: MyUseCase = DI.resolve()
///
/// ```
@freestanding(declaration, names: named(DI))
public macro createGlobalResolver<T>(_ type: T.Type) = #externalMacro(module: "DependoMacros", type: "CreateGlobalResolverMacro")
