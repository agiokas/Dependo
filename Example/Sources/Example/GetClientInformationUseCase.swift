//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

import Foundation

struct Info {
    let firstName: String
    let lastName: String
}

protocol IGetClientInformationUseCase {
    func getInfo() throws -> Info
}

struct GetClientInformationUseCase: IGetClientInformationUseCase {
    func getInfo() throws -> Info {
        throw GetClientInformationUseCaseError.fetchFailed
    }
}

enum GetClientInformationUseCaseError: Error {
    case fetchFailed
}
