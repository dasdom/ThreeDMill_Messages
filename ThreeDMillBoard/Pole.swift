//  Created by dasdom on 08.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import Foundation

public final class Pole {
    public var sphereColors: [SphereColor] = []
    var spheres: Int {
        return sphereColors.count
    }
    
    func add(color: SphereColor) {
        sphereColors.append(color)
    }
    
    func remove() {
        sphereColors.removeLast()
    }
}
