//  Created by dasdom on 08.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import UIKit

enum SphereColor: String {
    case white
    case red
    
    func uiColor() -> UIColor {
        switch self {
        case .white: return UIColor.white
        case .red: return UIColor.red
        }
    }
}
