//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

@attached(member, names: arbitrary)
public macro register<P1, T>(parameters: P1.Type, result: T.Type) = #externalMacro(module: "DependoMacros", type: "DependoExpanMacro")
