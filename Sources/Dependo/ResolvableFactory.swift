//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

import Foundation

class ResolvableFactory<R> where R: Resolvable  {
    let factory: (R.Initializers) -> R

    init(_ factory: @escaping (R.Initializers) -> R) {
        self.factory = factory
    }

    func make(parameters: R.Initializers) -> R {
        factory(parameters)
    }
}

extension ResolvableFactory {
    func any() -> AnyResolvableFactory {
        AnyResolvableFactory(self)
    }
}
