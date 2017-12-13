//  Created by dasdom on 14.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import UIKit
import SceneKit

class GameSphereNode: SCNNode {
    let color: SphereColor
    var isMoving = true
    
    init(geometry: SCNGeometry, color: SphereColor) {
        
        self.color = color
        
        super.init()

        self.geometry = geometry
        self.name = "Sphere"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
