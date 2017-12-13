//  Created by dasdom on 06.12.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import Foundation

struct Position {
    let column: Int
    let row: Int
    let floor: Int
}

struct Move {
    let from: Position
    let to: Position
    let color: SphereColor
}
