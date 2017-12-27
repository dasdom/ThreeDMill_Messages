//  Created by dasdom on 08.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import Foundation
import Messages

extension Notification.Name {
    static let numberOfRemainingSpheresChanged = Notification.Name("numberOfRemainingSpheresChanged")
}

enum BoardMode {
    case addSpheres
    case removeSphere
    case move(color: SphereColor)
    case surrender
}

final class Board {
    
    static let numberOfColumns = 4
    var mode = BoardMode.addSpheres
    private(set) var poles: [[Pole]]
    private var remainingWhiteSpheres = 32
    private var remainingRedSpheres = 32
    private(set) var lastMoves: [Move] = []
    private var columnsRowsWithRemovableSpheres: [String] = []
    private(set) var lastMill = ""
    var surrendered = false
    
    private var seenMills: [String] = []
    
    var url: URL {
        var queryItems: [URLQueryItem] = []
        
        if case .surrender = mode {
            queryItems.append(URLQueryItem(name: "surrendered", value: "true"))
            
            var components = URLComponents()
            components.queryItems = queryItems
            guard let url = components.url else { fatalError() }
            print("url: \(url)")
            return url
        }
        
        for column in 0..<Board.numberOfColumns {
            for row in 0..<Board.numberOfColumns {
                let pole = poles[column][row]
                var poleArray: [String] = []
                for sphereColor in pole.sphereColors {
                    poleArray.append("\(sphereColor)")
                }
                for move in lastMoves {
                    if move.to.column == column, move.to.row == row {
                        poleArray.removeLast()
                    }
                    if move.from.column == column, move.from.row == row {
                        poleArray.append(move.color.rawValue)
                    }
                }
                if poleArray.count > 0 {
                    queryItems.append(URLQueryItem(name: "\(column),\(row)", value: poleArray.joined(separator: ",")))
                }
            }
        }
        for move in lastMoves {
            queryItems.append(URLQueryItem(name: "\(move.from.column),\(move.from.row),\(move.from.floor),\(move.to.column),\(move.to.row),\(move.to.floor)", value: move.color.rawValue))
        }
        
        if seenMills.count > 0 {
            queryItems.append(URLQueryItem(name: "seenMills", value: seenMills.joined(separator: ",")))
        }
        queryItems.append(URLQueryItem(name: "remainingWhite", value: "\(remainingWhiteSpheres)"))
        queryItems.append(URLQueryItem(name: "remainingRed", value: "\(remainingRedSpheres)"))

        queryItems.append(URLQueryItem(name: "lastMill", value: "\(lastMill)"))
        
        var components = URLComponents()
        components.queryItems = queryItems
        guard let url = components.url else { fatalError() }
        print("url: \(url)")
        return url
    }
    
    init(url: URL? = nil) {
        poles = []
        for _ in 0..<Board.numberOfColumns {
            var column: [Pole] = []
            for _ in 0..<Board.numberOfColumns {
                column.append(Pole())
            }
            poles.append(column)
        }
        
        guard let url = url else {
            print("no url")
            return
        }
        print("url: \(url)")
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("no components")
            return
        }
        
        guard let queryItems = components.queryItems else {
            print("no queryItems")
            return
        }
        
        for queryItem in queryItems {
            let nameComponents = queryItem.name.components(separatedBy: ",")
            guard let value = queryItem.value else {
                print("no value")
                return
            }
            if nameComponents.count == 2 {
                guard let column = Int(nameComponents[0]) else {
                    print("no column")
                    return
                }
                guard let row = Int(nameComponents[1]) else {
                    print("no row")
                    return
                }
                let valueComponents = value.components(separatedBy: ",")
                let pole = poles[column][row]
                for colorName in valueComponents {
                    print("colorName: \(colorName)")
                    
                    guard let sphereColor = SphereColor(rawValue: colorName) else {
                        print("no sphereColor")
                        return
                    }
                    pole.add(color: sphereColor)
                }
                poles[column][row] = pole
            } else if nameComponents.count == 6 {
                guard let fromColumn = Int(nameComponents[0]) else { fatalError("no column") }
                guard let fromRow = Int(nameComponents[1]) else { fatalError("no row") }
                guard let fromFloor = Int(nameComponents[2]) else { fatalError("no floor") }
                guard let toColumn = Int(nameComponents[3]) else { fatalError("no column") }
                guard let toRow = Int(nameComponents[4]) else { fatalError("no row") }
                guard let toFloor = Int(nameComponents[5]) else { fatalError("no floor") }
                let from = Position(column: fromColumn, row: fromRow, floor: fromFloor)
                let to = Position(column: toColumn, row: toRow, floor: toFloor)
                guard let sphereColor = SphereColor(rawValue: value) else { fatalError("no color") }
                let move = Move(from: from, to: to, color: sphereColor)
                lastMoves.append(move)
            } else if nameComponents.count == 1 {
                let name = nameComponents[0]
                if name == "seenMills" {
                    seenMills = value.components(separatedBy: ",")
                    print("seenMills: \(seenMills)")
                } else if name == "remainingWhite" {
                    guard let remainingWhiteInt = Int(value) else { fatalError() }
                    remainingWhiteSpheres = remainingWhiteInt
                } else if name == "remainingRed" {
                    guard let remainingRedInt = Int(value) else { fatalError() }
                    remainingRedSpheres = remainingRedInt
                } else if name == "surrendered" {
                    surrendered = true
                } else if name == "lastMill" {
                    lastMill = value
                }
            }
        }
        print("lastMoves: \(lastMoves)")
        
        if remainingRedSpheres < 1, remainingWhiteSpheres < 1 {
            guard let lastMove = lastMoves.last else { fatalError("No last move? How is that possible?") }
            if lastMove.to.column < 0 {
                mode = .move(color: lastMove.color)
            } else {
                switch lastMove.color {
                case .red:
                    mode = .move(color: .white)
                default:
                    mode = .move(color: .red)
                }
            }
        } else {
            mode = .addSpheres
        }
    }
    
    func resetLastMoves() {
        lastMoves = []
    }
}

// MARK: - BoardLogic
extension Board {
    func canAddSphereTo(column: Int, row: Int) -> Bool {
        return poles[column][row].spheres < 4
    }
    
    func canRemoveSphereFrom(column: Int, row: Int) -> Bool {
        if case .removeSphere = mode, !columnsRowsWithRemovableSpheres.contains("\(column)\(row)") {
            return false
        }
        return poles[column][row].spheres > 0
    }
    
    func addSphereWith(_ color: SphereColor, toColumn column: Int, andRow row: Int, updateRemainCount: Bool = true) throws {
        guard canAddSphereTo(column: column, row: row) else {
            throw BoardLogicError.poleFull
        }
        
        let floor = poles[column][row].sphereColors.count
        let move: Move
        if let previousMove = lastMoves.first {
            let from = previousMove.from
            move = Move(from: Position(column: from.column, row: from.row, floor: from.floor), to: Position(column: column, row: row, floor: floor), color: color)
            lastMoves = [move]
        } else {
            move = Move(from: Position(column: -1, row: -1, floor: -1), to: Position(column: column, row: row, floor: floor), color: color)
            lastMoves.append(move)
        }
        
        poles[column][row].add(color: color)
        
        if updateRemainCount {
            switch color {
            case .red:
                remainingRedSpheres -= 1
            case .white:
                remainingWhiteSpheres -= 1
            }
        }
        
        NotificationCenter.default.post(name: .numberOfRemainingSpheresChanged, object: nil, userInfo: [SphereColor.white: remainingWhiteSpheres, SphereColor.red: remainingRedSpheres])
    }
    
    func removeSphereFrom(column: Int, andRow row: Int, updateCounts: Bool = true) throws {
        guard canRemoveSphereFrom(column: column, row: row) else {
            throw BoardLogicError.poleEmpty
        }
        
        guard let sphereColor = poles[column][row].sphereColors.last else { fatalError("no sphere color") }
        
        switch (mode, sphereColor) {
        case (.addSpheres, .red):
            if updateCounts {
                remainingRedSpheres += 1
            }
        case (.addSpheres, .white):
            if updateCounts {
                remainingWhiteSpheres += 1
            }
        default:            
            let fromFloor = poles[column][row].sphereColors.count - 1
            let from = Position(column: column, row: row, floor: fromFloor)
            let to = Position(column: -1, row: -1, floor: -1)
            guard let sphereColor = poles[column][row].sphereColors.last else { fatalError("no sphere color") }
            let move = Move(from: from, to: to, color: sphereColor)
            lastMoves.append(move)
        }
        
        poles[column][row].remove()
        
    }
    
    func columnsRowsWithRemovableSpheresFor(sphereColor: SphereColor) -> [(Int, Int)] {
       
        var sphereIdInMills: [String] = []
        for mill in seenMills {
            for millId in mill.components(separatedBy: ".") {
                sphereIdInMills.append(millId)
            }
        }
        
        var columnRows: [(Int, Int)] = []
        for column in 0..<Board.numberOfColumns {
            for row in 0..<Board.numberOfColumns {
                let count = poles[column][row].sphereColors.count
                if count < 1 || sphereIdInMills.contains("\(column)\(row)\(count-1)") {
                    continue
                }
                if let removableSphere = poles[column][row].sphereColors.last, removableSphere == sphereColor {
                    columnRows.append((column, row))
                }
            }
        }
        
        columnsRowsWithRemovableSpheres = columnRows.map { "\($0.0)\($0.1)" }
        return columnRows
    }
    
    func spheresAt(column: Int, row: Int) -> Int {
        return poles[column][row].spheres
    }
    
    func sphereColorAt(column: Int, row: Int, floor: Int) -> SphereColor? {
        let pole = poles[column][row]
        guard pole.spheres > floor else { return nil }
        return poles[column][row].sphereColors[floor]
    }
    
    func checkForMatch() -> [(Int, Int, Int)]? {
        //        var result: [(Int,Int,Int)]? = checkForColumn()
        let functions = [checkForColumn,
                         checkForRow,
                         checkForFloorDiagonal1,
                         checkForFloorDiagonal2,
                         checkForColumnDiagonal1,
                         checkForColumnDiagonal2,
                         checkForRowDiagonal1,
                         checkForRowDiagonal2,
                         checkForPole,
                         checkForRoomDiagonal1,
                         checkForRoomDiagonal2,
                         checkForRoomDiagonal3,
                         checkForRoomDiagonal4
        ]
        
        var result: [(Int,Int,Int)]? = nil
        var tempSeenMills: [String] = []
        var tempResults: [[(Int,Int,Int)]] = []
        for check in functions {
            tempResults = check()
            for tempResult in tempResults {
                let resultStringArray = tempResult.map {
                    return "\($0.0)\($0.1)\($0.2)"
                }
//                let resultString = tempResult.reduce("", {
//                    return $0 + ".\($1.0)\($1.1)\($1.2)"
//                })
                let resultString = resultStringArray.joined(separator: ".")
                print("resultString: \(resultString)")
                
                if seenMills.contains(resultString) {
                    tempSeenMills.append(resultString)
                } else if result == nil {
                    tempSeenMills.append(resultString)
                    result = tempResult
                    lastMill = resultString
                } else {
                    assert(false, "Unexpected! Fix!")
                }
                
            }
        }
        seenMills = tempSeenMills
        
        return result
    }
    
    func sphereColor(inputColor: SphereColor?, columnRowFloor: (Int, Int, Int)) -> SphereColor? {
        let (column, row, floor) = columnRowFloor
        
        let color = sphereColorAt(column: column, row: row, floor: floor)
        
        if inputColor == nil || color == inputColor {
            return color
        }
        
        return nil
    }

    func checkForColumn() -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        floorLoop: for floor in 0..<Board.numberOfColumns {
            columnLoop: for column in 0..<Board.numberOfColumns {
                result = []
                firstColor = nil
                rowLoop: for row in 0..<Board.numberOfColumns {
                   
                    let columnRowFloor = (column, row, floor)
                    firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
                    result?.append(columnRowFloor)
                    if firstColor == nil {
                        result = nil
                        break rowLoop
                    }
                    
                }
                if let unwrappedResult = result {
                    allResults.append(unwrappedResult)
                }
            }
        }
        return allResults
    }
    
    func checkForRow() -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        floorLoop: for floor in 0..<Board.numberOfColumns {
            rowLoop: for row in 0..<Board.numberOfColumns {
                result = []
                firstColor = nil
                columnLoop: for column in 0..<Board.numberOfColumns {
                    
                    let columnRowFloor = (column, row, floor)
                    firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
                    result?.append(columnRowFloor)
                    if firstColor == nil {
                        result = nil
                        break columnLoop
                    }
                    
                }
                if let unwrappedResult = result {
                    allResults.append(unwrappedResult)
                }
            }
        }
        return allResults
    }
    
    func checkForFloorDiagonal1() -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        floorLoop: for floor in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            rowLoop: for row in 0..<Board.numberOfColumns {
                
                let columnRowFloor = (row, row, floor)
                firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
                result?.append(columnRowFloor)
                if firstColor == nil {
                    result = nil
                    break rowLoop
                }
                
            }
            if let unwrappedResult = result {
                allResults.append(unwrappedResult)
            }
        }
        return allResults
    }
    
    func checkForFloorDiagonal2() -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        floorLoop: for floor in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            rowLoop: for column in 0..<Board.numberOfColumns {
                
                let row = Board.numberOfColumns - 1 - column
                
                let columnRowFloor = (column, row, floor)
                firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
                result?.append(columnRowFloor)
                if firstColor == nil {
                    result = nil
                    break rowLoop
                }
                
            }
            if let unwrappedResult = result {
                allResults.append(unwrappedResult)
            }
        }
        return allResults
    }
    
    func checkForColumnDiagonal1() -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        columnLoop: for column in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            rowLoop: for row in 0..<Board.numberOfColumns {
                
                let columnRowFloor = (column, row, row)
                firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
                result?.append(columnRowFloor)
                if firstColor == nil {
                    result = nil
                    break rowLoop
                }
                
            }
            if let unwrappedResult = result {
                allResults.append(unwrappedResult)
            }
        }
        return allResults
    }
    
    func checkForColumnDiagonal2() -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        columnLoop: for column in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            floorLoop: for floor in 0..<Board.numberOfColumns {
                
                let row = Board.numberOfColumns - 1 - floor
                
                let columnRowFloor = (column, row, floor)
                firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
                result?.append(columnRowFloor)
                if firstColor == nil {
                    result = nil
                    break floorLoop
                }
                
            }
            if let unwrappedResult = result {
                allResults.append(unwrappedResult)
            }
        }
        return allResults
    }

    func checkForRowDiagonal1() -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        rowLoop: for row in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            columnLoop: for column in 0..<Board.numberOfColumns {
                
                let columnRowFloor = (column, row, column)
                firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
                result?.append(columnRowFloor)
                if firstColor == nil {
                    result = nil
                    break columnLoop
                }
                
            }
            if let unwrappedResult = result {
                allResults.append(unwrappedResult)
            }
        }
        return allResults
    }

    func checkForRowDiagonal2() -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        columnLoop: for row in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            floorLoop: for floor in 0..<Board.numberOfColumns {
                
                let column = Board.numberOfColumns - 1 - floor
                
                let columnRowFloor = (column, row, floor)
                firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
                result?.append(columnRowFloor)
                if firstColor == nil {
                    result = nil
                    break floorLoop
                }
                
            }
            if let unwrappedResult = result {
                allResults.append(unwrappedResult)
            }
        }
        return allResults
    }

    func checkForPole() -> [[(Int, Int, Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        rowLoop: for row in 0..<Board.numberOfColumns {
            columnLoop: for column in 0..<Board.numberOfColumns {
                result = []
                firstColor = nil
                floorLoop: for floor in 0..<Board.numberOfColumns {
                    
                    let columnRowFloor = (column, row, floor)
                    firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
                    result?.append(columnRowFloor)
                    if firstColor == nil {
                        result = nil
                        break floorLoop
                    }
                    
                }
                if let unwrappedResult = result {
                    allResults.append(unwrappedResult)
                }
            }
        }
        return allResults
    }

    func checkForRoomDiagonal1() -> [[(Int,Int,Int)]] {
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        columnLoop: for column in 0..<Board.numberOfColumns {
            
            let columnRowFloor = (column, column, column)
            firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
            result?.append(columnRowFloor)
            if firstColor == nil {
                result = nil
                break columnLoop
            }
            
        }
        if let unwrappedResult = result {
            return [unwrappedResult]
        }
        return []
    }

    func checkForRoomDiagonal2() -> [[(Int,Int,Int)]] {
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        columnLoop: for column in 0..<Board.numberOfColumns {
            
            let row = Board.numberOfColumns - 1 - column
            
            let columnRowFloor = (column, row, column)
            firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
            result?.append(columnRowFloor)
            if firstColor == nil {
                result = nil
                break columnLoop
            }
            
        }
        if let unwrappedResult = result {
            return [unwrappedResult]
        }
        return []
    }

    func checkForRoomDiagonal3() -> [[(Int,Int,Int)]] {
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        rowLoop: for row in 0..<Board.numberOfColumns {
            
            let column = Board.numberOfColumns - 1 - row
            
            let columnRowFloor = (column, row, row)
            firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
            result?.append(columnRowFloor)
            if firstColor == nil {
                result = nil
                break rowLoop
            }
            
        }
        if let unwrappedResult = result {
            return [unwrappedResult]
        }
        return []
    }

    func checkForRoomDiagonal4() -> [[(Int,Int,Int)]] {
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        floorLoop: for floor in 0..<Board.numberOfColumns {
            
            let column = Board.numberOfColumns - 1 - floor
            
            let columnRowFloor = (column, column, floor)
            firstColor = sphereColor(inputColor: firstColor, columnRowFloor: columnRowFloor)
            result?.append(columnRowFloor)
            if firstColor == nil {
                result = nil
                break floorLoop
            }
            
        }
        if let unwrappedResult = result {
            return [unwrappedResult]
        }
        return []
    }
    
    enum BoardLogicError: Error {
        case poleFull
        case poleEmpty
    }
}

extension Board {
    convenience init?(message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
//        guard let messageURL = message?.url ??
//            URL(string: "?3,1=white&0,0=white,red&0,1=white,red&0,2=white&1,0=white,red&1,1=white,red&1,2=white,red&1,3=white,red&-1,-1,-1,0,2,1=red&remainingRed=1&remainingWhite=1&seenMills=100.110.120.130,101.111.121.131") else { return nil }

        self.init(url: messageURL)
    }
}
