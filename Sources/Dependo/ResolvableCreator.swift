//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

class ResolvableCreator {
    private let factory: (Resolver) -> Any

    init<R>(for _: R.Type, _ factory: @escaping (Resolver) -> R) {
        self.factory = factory
    }

    func make(resolver: Resolver) -> Any {
        factory(resolver)
    }

    func makeClosure<T>(resolver: Resolver, type _: T.Type) -> (() -> T) {
        let theFactory = factory
        return {
            guard let result = theFactory(resolver) as? T else {
                fatalError("Resolver failed to resolve")
            }
            return result
        }
    }
}
