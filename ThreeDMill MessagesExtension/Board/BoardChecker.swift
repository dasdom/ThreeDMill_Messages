//  Created by dasdom on 13.12.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import Foundation

struct BoardChecker {
    
    func sphereColor(on poles: [[Pole]], atColumn column: Int, row: Int, floor: Int) -> SphereColor? {
        
        let pole = poles[column][row]
        guard pole.spheres > floor else { return nil }
        return poles[column][row].sphereColors[floor]
    }
}
