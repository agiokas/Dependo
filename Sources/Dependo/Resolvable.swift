//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//

public protocol Resolvable {
    associatedtype Initializers
    associatedtype ReturnType

    init(parameters: Initializers)
}
