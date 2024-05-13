//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//

import Foundation

public protocol Resolver {
    func resolve<R>(_ type: R.Type?) -> R
    
    func optionalResolve<R>(_: R.Type?) -> R?
}

public extension Resolver {
    func resolve<R>(_ type: R.Type? = nil) -> R {
        resolve(type)
    }
    
    func optionalResolve<R>(_ type: R.Type? = nil) -> R? {
        optionalResolve(type)
    }
}

open class Dependo: Resolver {
    private static let dispatchQueue = DispatchQueue(label: "Dependo.serial.queue", qos: .userInteractive)
    private var storage = [ObjectIdentifier: ResolvableCreator]()

    public init() {}

    public func resolve<R>(_ type: R.Type?) -> R {
        guard let resolvedEntity: R = optionalResolve() else {
            fatalError("Dependo: Could not resolve requested type \(R.self)")
        }

        return resolvedEntity
    }
    
    public func optionalResolve<R>(_: R.Type? = nil) -> R? {
        if let optional = R.self as? IOptional.Type {
            guard let creator = getCreator(for: optional.wrappedType()) else {
                return nil
            }

            return Optional.some(creator.make(resolver: self)) as? R
        }

        return getCreator(for: R.self)?.make(resolver: self) as? R
    }
    
    @discardableResult public func threadSafe<T>(_ closure: @escaping () -> T?) -> T? {
        var returnValue: T?
        Self.dispatchQueue.sync {
            returnValue = closure()
        }
        return returnValue
    }
    
    public func registeredEntities() -> [() -> Any?] {
        storage.map { _, factory in { factory.make(resolver: self) } }
    }
    
    @discardableResult public func register<R>(_ factory: @escaping (Resolver) -> R) -> Self {
        register(R.self, factory)
    }
    
    @discardableResult public func register<R>(_ type: R.Type, instance: R) -> Self {
        register(type) { _ in instance }
    }
    
    @discardableResult public func register<R>(instance: R) -> Self {
        register(R.self) { _ in instance }
    }
    
    @discardableResult public func replace<R>(instance: R) -> Self {
        replace(R.self) { _ in instance }
    }

    @discardableResult public func replace<R>(_ type: R.Type, instance: R) -> Self {
        replace(type) { _ in instance }
    }

    @discardableResult public func replace<R>(_ type: R.Type,
                                              _ factory: @escaping (Resolver) -> R) -> Self {
        threadSafe {
            self.storage[ObjectIdentifier(type)] = ResolvableCreator(for: type, factory)
        }
        return self
    }
    
    @discardableResult public func register<R>(_ type: R.Type, _ factory: @escaping (Resolver) -> R) -> Self {
        guard getCreator(for: type) == nil else {
            fatalError("Dependo: Type \(type) already registered.")
        }        
        return replace(type.self, factory)
    }
    
    private func getCreator(for type: Any.Type) -> ResolvableCreator? {
        let value: ResolvableCreator? = threadSafe {
            self.storage[ObjectIdentifier(type)]
        }
        return value
    }
}

protocol IOptional {
    static func wrappedType() -> Any.Type
}

extension Optional: IOptional {
    static func wrappedType() -> Any.Type {
        Wrapped.self
    }
}
