//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//

import Foundation

public protocol Resolver {
    /// Resolves an instance of a given type.
    /// A `fatal error` would be thrown if  the `type` is not registered
    ///
    /// - Parameter type: The type to resolve.
    /// - Returns: An instance of the resolved type.
    func resolve<R>(_ type: R.Type?) -> R
    
    /// Returns an optional instance of a given type.
    ///
    /// - Parameter type: The type to resolve.
    /// - Returns: An optional instance of the resolved type.
    func optionalResolve<R>(_: R.Type?) -> R?
}

public extension Resolver {
    /// Resolves an instance of a given type.
    /// A `fatal error` would be thrown if  the `type` is not registered
    ///
    /// - Parameter type: The type to resolve.
    /// - Returns: An instance of the resolved type.
    func resolve<R>(_ type: R.Type? = nil) -> R {
        resolve(type)
    }
    
    /// Returns an optional instance of a given type.
    ///
    /// - Parameter type: The type to resolve.
    /// - Returns: An optional instance of the resolved type.
    func optionalResolve<R>(_ type: R.Type? = nil) -> R? {
        optionalResolve(type)
    }
}

/// The main class for the Dependency Injection framework.
///
/// This class conforms to the `Resolver` protocol and provides a thread-safe way to resolve instances.
open class Dependo: Resolver {
    /// A serial dispatch queue used for thread-safe operations.
    private static let dispatchQueue = DispatchQueue(label: "Dependo.serial.queue", qos: .userInteractive)
    
    /// A storage dictionary that maps object identifiers to resolvable creators.
    private var storage = [ObjectIdentifier: ResolvableCreator]()
    
    /// Initializes a new instance of `Dependo`.
    public init() {}

    /// Resolves an instance of a given type.
    /// A `fatal error` would be thrown if  the `type` is not registered
    ///
    /// - Parameter type: The type to resolve.
    /// - Returns: An instance of the resolved type.
    public func resolve<R>(_: R.Type?) -> R {
        guard let resolvedEntity: R = optionalResolve() else {
            fatalError("Dependo: Could not resolve requested type \(R.self)")
        }

        return resolvedEntity
    }

    /// Returns an optional instance of a given type.
    ///
    /// - Parameter type: The type to resolve.
    /// - Returns: An optional instance of the resolved type.
    public func optionalResolve<R>(_: R.Type? = nil) -> R? {
        if let optional = R.self as? IOptional.Type {
            guard let creator = getCreator(for: optional.wrappedType()) else {
                return nil
            }

            return Optional.some(creator.make(resolver: self)) as? R
        }

        return getCreator(for: R.self)?.make(resolver: self) as? R
    }
    
    /// Performs a closure in a thread-safe manner. Using the dispatch queue of `Dependo`
    ///
    /// - Parameter closure: The closure to be executed in a thread-safe manner.
    /// - Returns: The result of the closure execution.
    @discardableResult public func threadSafe<T>(_ closure: @escaping () -> T?) -> T? {
        var returnValue: T?
        Self.dispatchQueue.sync { returnValue = closure() }
        return returnValue
    }
    
    /// Returns a collection of all registered entities.
    ///
    /// - Returns: A collection of closures that can be used to resolve instances.
    public func registeredEntities() -> [() -> Any?] {
        storage.map { _, factory in { factory.make(resolver: self) } }
    }

    /// Registers a factory for resolving instances of type `R`.
    /// A `fatal error` would be thrown if  the `type` is already registered
    ///
    /// - Parameter factory: A closure that returns an instance of type `R`.
    /// - Returns: The current instance of `Dependo` for method chaining.
    @discardableResult public func register<R>(_ factory: @escaping (Resolver) -> R) -> Self {
        register(R.self, factory)
    }

    /// Registers an instance of a given type.
    /// A `fatal error` would be thrown if  the `type` is already registered
    ///
    /// - Parameter type: The type to register.
    /// - Parameter instance: An instance of the registered type.
    /// - Returns: The current instance of `Dependo` for method chaining.
    @discardableResult public func register<R>(_ type: R.Type, instance: R) -> Self {
        register(type) { _ in instance }
    }

    /// Registers an instance of a given type.
    /// A `fatal error` would be thrown if  the `type` is already registered
    ///
    /// - Parameter instance: An instance of the registered type.
    /// - Returns: The current instance of `Dependo` for method chaining.
    @discardableResult public func register<R>(instance: R) -> Self {
        register(R.self) { _ in instance }
    }

    /// Registers a factory for a given type.
    /// A `fatal error` would be thrown if  the `type` is already registered
    ///
    /// - Parameter type: The type to register.
    /// - Parameter factory: A closure that returns an instance of type `R`.
    /// - Returns: The current instance of `Dependo` for method chaining.
    @discardableResult public func register<R>(_ type: R.Type, _ factory: @escaping (Resolver) -> R) -> Self {
        guard getCreator(for: type) == nil else {
            fatalError("Dependo: Type \(type) already registered.")
        }
        return replace(type.self, factory)
    }
    
    /// Replaces a registered instance with a new one.
    ///
    /// - Parameter instance: The new instance to replace the existing one.
    /// - Returns: The current instance of `Dependo` for method chaining.
    @discardableResult public func replace<R>(instance: R) -> Self {
        replace(R.self) { _ in instance }
    }

    /// Replaces a registered instance with a new one.
    ///
    /// - Parameter type: The type to replace the existing instance.
    /// - Parameter instance: The new instance to replace the existing one.
    /// - Returns: The current instance of `Dependo` for method chaining.
    @discardableResult public func replace<R>(_ type: R.Type, instance: R) -> Self {
        replace(type) { _ in instance }
    }

    /// Replaces a registered instance with a new one.
    ///
    /// - Parameter type: The type to replace the existing instance.
    /// - Parameter factory: A closure that returns an instance of type `R`.
    /// - Returns: The current instance of `Dependo` for method chaining.
    @discardableResult public func replace<R>(_ type: R.Type, _ factory: @escaping (Resolver) -> R) -> Self {
        threadSafe {
            self.storage[ObjectIdentifier(type)] = ResolvableCreator(for: type, factory)
        }
        return self
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
