//  Created by dasdom on 08.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import UIKit

public enum SphereColor: String {
    case w
    case r
    
    public func uiColor() -> UIColor {
        switch self {
        case .w: return UIColor.white
        case .r: return UIColor.red
        }
    }
    
    public func oposit() -> SphereColor {
        switch self {
        case .w: return .r
        case .r: return .w
        }
    }
}
