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
public macro declare<P1, T>(parameters: P1.Type, result: T.Type) = #externalMacro(module: "DependoMacros", type: "DependoExpanMacro")
