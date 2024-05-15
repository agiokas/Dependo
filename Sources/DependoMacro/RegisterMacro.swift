//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

/// Declare a new paramerized type the DI should handle.
/// # Example #
/// ```
/// @declare(parameters: (age: Int, name: String).self, result: ResultType.self)
/// ```
@attached(member, names: arbitrary)
public macro declare<P, T>(parameters: P.Type, result: T.Type) = #externalMacro(module: "DependoMacros", type: "DependoExpanMacro")

@attached(member, names: arbitrary)
public macro resolveSource() = #externalMacro(module: "DependoMacros", type: "ResolveSourceMacro")
