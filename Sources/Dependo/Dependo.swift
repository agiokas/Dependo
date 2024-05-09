//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//

import Foundation

open class Dependo {
    public init() {}
    
    private var resolvableFactories = [ObjectIdentifier: AnyResolvableFactory]()

    public func register<R>(_ type: R.Type, factory: @escaping (R.Initializers) -> R) where R: Resolvable {
        resolvableFactories[ObjectIdentifier(type)] = ResolvableFactory(factory).any()
    }
    
    public func optionalResolve<R>(_ parameters: R.Initializers) -> R? where R: Resolvable {
        let value = getFactory(for: R.self)
        return value?.make(parameters: parameters)
    }
    
    public func resolve<R>(_ parameters: R.Initializers) throws -> R? where R: Resolvable {
        guard let result: R = optionalResolve(parameters) else {
            throw DependoError.notRegistered(type: String(describing: R.self))
        }
        return result
    }
    
    private func getFactory(for type: Any.Type) -> AnyResolvableFactory? {
        resolvableFactories[ObjectIdentifier(type)]
    }
}
