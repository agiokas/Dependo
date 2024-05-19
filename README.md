# Dependo

[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fagiokas%2FDependo%2Fbadge%3Fref%3Dmain%26token%3D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&style=flat)](https://actions-badge.atrox.dev/agiokas/Dependo/goto?ref=main&token=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)
[![codecov](https://codecov.io/gh/agiokas/Dependo/graph/badge.svg?token=CQXQTVUZRD)](https://codecov.io/gh/agiokas/Dependo)

**Dependo** is a lightweight, thread safe Dependency Injection library written in swift.

Dependo's key features: 
- It is Thread safe
- It is Type safe
- It has Type safe argument Injection

## Installation

Use the Swift Package Manager to install Dependo

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/agiokas/Dependo", exact: "0.2")
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: ["Dependo"])
    ]
)
```

## Usage

While there are multiple ways to use Dependo. In order to take advantage of the full feature-set we advice you to.

1. Declare a subclass of `Dependo`
2. Mark it as shared
3. Create a global Resolver

```swift
import Dependo


@shared
final class MyDI: Dependo {}

#createGlobalResolver(MyDI.self)
```

Any possible argumented registration should be declared here too.

```swift

@shared
@declare(parameters: (deviceId: String?, clientId: String?).self, result: IExampleViewModel.self)
final class MyDI: Dependo {}

```

After your application launches the DI should be created and all Dependencies be registered.

```swift
func application(_: UIApplication,
didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    initializeDI()
}

func initializeDI() {         
    // Create an instance of MyDI
    MyDI()
    // Register Database.self with its implementation
        .register(Database.self) { _ in DatabaseImplementation() }
        // Register IGetClientInformationUseCase.self with its implementation
        .register(IGetClientInformationUseCase.self) { _ in GetClientInformationUseCase() }
        // Register a ExampleViewModel with deviceId and clientId parameters
        .register { deviceId, clientId, resolver in ExampleViewModel(deviceId: deviceId, clientId: clientId) }
        // Register a ExampleViewModel just with a deviceId parameter
        .register { deviceId, clientId, resolver in ExampleViewModel(deviceId: deviceId) }
}
```

In order to have the Dependency Injector create this Entities (Resolve) the DI keyword, which is created by the `#createGlobalResolver` macro can be used.

```swift
/// Resolve something inline
let vm: IExampleViewModel = DI.resolve(deviceId: "D1", clientId: "C1")

/// Resolve something as a property of a class
class ExampleViewModel{
    ...
    let getClientInformationUseCase: IGetClientInformationUseCase = DI.resolve()
}

```

> **Warning**: Any `.resolve()` and every registration of a Type which is already registered will fail with a fatal error. This is intentional, as it is considered a programming error that should be fixed rather than handled at runtime.
>
To avoid this error, ensure that you only register each type once.

Registering the same type multiple times will result in a fatal error.: 
```swift
di.register(MyType.self) { _ in MyTypeImplementation() }
di.register(MyType.self) { _ in MyTypeImplementation() }
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

Dependo is licensed under the [MIT License](https://github.com/agiokas/Dependo/blob/main/LICENSE). This means you are free to use, modify, and distribute Dependo as per the terms of the license.
