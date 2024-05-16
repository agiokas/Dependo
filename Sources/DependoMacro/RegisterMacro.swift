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
/// @sharedDependo()
/// final class MyDI: Dependo {}
/// ```
@attached(member, names: arbitrary)
public macro sharedDependo() = #externalMacro(module: "DependoMacros", type: "SharedMacro")

/// `#resolve` uses the specified subclass of `Dependo` to inject entities. This `Dependo` subclass first needs to be marked as `@sharedDependo()`
/// # Example #
/// ```
/// @sharedDependo()
/// final class MyDI: Dependo {}
///
/// MyDI()
///     .register(MyUseCase.self) { _ in MyUseCaseImplementation() }
///
/// let myUseCase: MyUseCase = #resolve(MyDI.self)
///
/// ```
@freestanding(expression)
public macro resolve<T, R>(_ type: T.Type) -> R = #externalMacro(module: "DependoMacros", type: "ResolveMacro")
