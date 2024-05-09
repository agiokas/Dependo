//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

class AnyResolvableFactory {
    private let _make: (Any) -> Any?

    init<R>(_ factory: ResolvableFactory<R>) where R: Resolvable {
        _make = { parameters in
            factory.make(parameters: parameters as! R.Initializers)
        }
    }

    func make<R>(parameters: Any) -> R? where R: Resolvable {
        guard let correctParameters = parameters as? R.Initializers else {
            return nil
        }
        return _make(correctParameters) as? R
    }
}
