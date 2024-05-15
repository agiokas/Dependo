//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

import Dependo
import DependoMacro

protocol MainScreenViewModelProtocol {}

final class MainScreenViewModel: MainScreenViewModelProtocol {
    internal init(deviceId: String) {
        self.deviceId = deviceId
    }
    
    let deviceId: String
}

final class MainScreenViewModel2: MainScreenViewModelProtocol {
    internal init(deviceId: String, userName: String) {
        self.deviceId = deviceId
        self.userName = userName
    }
    
    let deviceId: String
    let userName: String
}

protocol ICalculateComplexStuffUseCase {}

final class CalculateComplexStuffUseCase: ICalculateComplexStuffUseCase {}

@declare(parameters: String.self, result: MainScreenViewModelProtocol.self)
@declare(parameters: (deviceId: String, userName: String).self, result: MainScreenViewModelProtocol.self)
final class DI: Dependo { }

let di = DI()
    .register { param, _ in MainScreenViewModel(deviceId: param) }
    .register(ICalculateComplexStuffUseCase.self) { _ in CalculateComplexStuffUseCase() }
    .register { deviceId, userName, _ in MainScreenViewModel2(deviceId: deviceId, userName: userName) }

let vm1: MainScreenViewModelProtocol = di.resolve(param: "d2")
let vm2: MainScreenViewModelProtocol = di.resolve(deviceId: "d1", userName: "Apo")
let calcUseCase: ICalculateComplexStuffUseCase = di.resolve()

print("ViewModel 1:\(type(of: vm1))")
print("ViewModel 2:\(type(of: vm2))")
print("Use case   :\(type(of: calcUseCase))")
