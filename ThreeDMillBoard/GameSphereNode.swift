//  Created by dasdom on 14.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import UIKit
import SceneKit

public final class GameSphereNode: SCNNode {
    public let color: SphereColor
    public var isMoving = true
    
    public init(geometry: SCNGeometry, color: SphereColor) {
        
        self.color = color
        
        super.init()

        self.geometry = geometry
        self.name = "Sphere"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
