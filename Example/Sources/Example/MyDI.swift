//
//  Created by Apostolos Giokas.
//  Copyright © 2024 Apostolos Giokas. All rights reserved.
//  

import Foundation
import DependoMacro
import Dependo

@shared
@declare(parameters: (deviceId: String?, clientId: String?).self, result: IExampleViewModel.self)
final class MyDI: Dependo {}

#createGlobalResolver(MyDI.self)
