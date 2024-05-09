//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

import Foundation

enum DependoError: Error, LocalizedError {
    case notRegistered(type: String)
    
    var errorDescription: String {
        switch self {
        case let .notRegistered(type): "Type \(type) is not registed in Dependo"
        }
    }
}
