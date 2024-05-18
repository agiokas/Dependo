//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

import Foundation

protocol IExampleViewModel {
    func status() -> Bool
    func getInfo() throws -> Info
}

final class ExampleViewModel: IExampleViewModel {
    let deviceId: String?
    let clientId: String?
    let getClientInformationUseCase: IGetClientInformationUseCase = DI.resolve()
    
    init(deviceId: String? = nil, clientId: String? = nil) {
        self.deviceId = deviceId
        self.clientId = clientId
    }
    
    func status() -> Bool {
        deviceId != nil && clientId != nil
    }
    
    func getInfo() throws -> Info {
        try getClientInformationUseCase.getInfo()
    }
}
