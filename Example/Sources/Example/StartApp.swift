// The Swift Programming Language
// https://docs.swift.org/swift-book

final class StartApp {
    func initialize() throws {
        MyDI()
            .register(IGetClientInformationUseCase.self) { _ in GetClientInformationUseCase() }
            .register { deviceId, clientId, resolver in ExampleViewModel(deviceId: deviceId, clientId: clientId) }
        
        let _: IExampleViewModel = MyDI.shared.resolve(deviceId: "D1", clientId: "c1")
        let vm: IExampleViewModel = DI.resolve(deviceId: "D1", clientId: "C1")
        
        let _ = vm.status()
        let _ = try vm.getInfo()
    }
}
