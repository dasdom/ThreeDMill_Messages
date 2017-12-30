//  Created by dasdom on 06.12.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import Foundation

public struct Position {
    public let column: Int
    public let row: Int
    public let floor: Int
}

public struct Move {
    public let from: Position
    public let to: Position
    public let color: SphereColor
}
