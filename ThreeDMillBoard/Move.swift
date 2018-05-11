//  Created by dasdom on 06.12.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import Foundation

public struct Position {
    public let column: Int
    public let row: Int
    public let floor: Int
    
    public static func offBoard() -> Position {
        return self.init(column: -1, row: -1, floor: -1)
    }
    
    public func isOffBoard() -> Bool {
        return column == -1 && row == -1 && floor == -1
    }
}

public struct Move {
    public let from: Position
    public let to: Position
    public let color: SphereColor
}
