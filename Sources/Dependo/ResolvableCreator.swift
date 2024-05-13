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
}
