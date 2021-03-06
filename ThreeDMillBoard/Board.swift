//  Created by dasdom on 08.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import Foundation
import Messages

public extension Notification.Name {
    static let numberOfRemainingSpheresChanged = Notification.Name("numberOfRemainingSpheresChanged")
}

public enum BoardMode {
    case addSpheres
    case showMill(color: SphereColor)
    case removeSphere
    case move(color: SphereColor)
    case surrender
    case finish
}

public final class Board {
    
    public static let numberOfColumns = 4
    public var mode = BoardMode.addSpheres
    public private(set) var poles: [[Pole]]
    private var remainingWhiteSpheres = 32
    private var remainingRedSpheres = 32
    public private(set) var lastMoves: [Move] = []
    public private(set) var lastAnimationMoves: [Move] = []
    private var columnsRowsWithRemovableSpheres: [String] = []
    private(set) var _lastMill: String? = nil
    public var surrendered = false
    public var receivedURL: URL? = nil
    
    private var seenMills: [String] = []
    
    public var lastMill: [(Int, Int, Int)]? {
//        guard let lastMill = _lastMill else { return nil }
//        let compoments = lastMill.components(separatedBy: ".")
//        return compoments.map { sphereString in
//            let characterStrings = sphereString.map({ character in
//                return String(character)
//            })
//            return (Int(characterStrings[0])!, Int(characterStrings[1])!, Int(characterStrings[2])!)
//        }
        
        return _lastMill?.components(separatedBy: ".")
            .map { str -> (Int, Int, Int) in
                let ints = str.map(String.init).flatMap(Int.init)
                return (ints[0], ints[1], ints[2])
        }
    }
    
    public var url: URL {
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
                for move in lastMoves.reversed() {
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

        if let lastMill = _lastMill {
            queryItems.append(URLQueryItem(name: "lastMill", value: "\(lastMill)"))
        }
        
        var components = URLComponents()
        components.queryItems = queryItems
        guard let url = components.url else { fatalError() }
        print("url: \(url)")
        return url
    }
    
    public init(url: URL? = nil) {
        
        receivedURL = url
        
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
                lastAnimationMoves.append(move)
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
                    print("value: \(value)")
                    _lastMill = value
                }
            }
        }
        print("lastAnimationMoves: \(lastAnimationMoves)")
        
        if remainingRedSpheres < 1, remainingWhiteSpheres < 1 {
            guard let lastMove = lastAnimationMoves.last else { fatalError("No last move? How is that possible?") }
            if lastMove.to.column < 0 {
                mode = .move(color: lastMove.color)
            } else {
                switch lastMove.color {
                case .r:
                    mode = .move(color: .w)
                default:
                    mode = .move(color: .r)
                }
            }
        } else {
            mode = .addSpheres
        }
    }
    
    public func resetLastMoves() {
        lastMoves = []
    }
}

// MARK: - BoardLogic
extension Board {
    public func canAddSphereTo(column: Int, row: Int) -> Bool {
        return poles[column][row].spheres < 4
    }
    
    public func canRemoveSphereFrom(column: Int, row: Int) -> Bool {
        if case .removeSphere = mode, !columnsRowsWithRemovableSpheres.contains("\(column)\(row)") {
            return false
        }
        return poles[column][row].spheres > 0
    }
    
    public func addSphereWith(_ color: SphereColor, toColumn column: Int, andRow row: Int, updateRemainCount: Bool = true) throws {
        guard canAddSphereTo(column: column, row: row) else {
            throw BoardLogicError.poleFull
        }
        
        let floor = poles[column][row].sphereColors.count
        let move: Move
        if let previousMove = lastMoves.last {
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
            case .r:
                remainingRedSpheres -= 1
            case .w:
                remainingWhiteSpheres -= 1
            }
        }
        
        NotificationCenter.default.post(name: .numberOfRemainingSpheresChanged, object: nil, userInfo: [SphereColor.w: remainingWhiteSpheres, SphereColor.r: remainingRedSpheres])
    }
    
    public func removeSphereFrom(column: Int, andRow row: Int, updateCounts: Bool = true) throws {
        guard canRemoveSphereFrom(column: column, row: row) else {
            throw BoardLogicError.poleEmpty
        }
        
        guard let sphereColor = poles[column][row].sphereColors.last else { fatalError("no sphere color") }
        
        if case .showMill = mode {
            assert(false)
        }
        
        switch (mode, sphereColor) {
        case (.addSpheres, .r):
            if updateCounts {
                remainingRedSpheres += 1
            }
        case (.addSpheres, .w):
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
    
    public func columnsRowsWithRemovableSpheresFor(sphereColor: SphereColor) -> [(Int, Int)] {
       
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
    
    public func canMove(for sphereColor: SphereColor) -> Bool {
        for column in 0..<Board.numberOfColumns {
            for row in 0..<Board.numberOfColumns {
                if let removableSphere = poles[column][row].sphereColors.last, removableSphere == sphereColor {
                    return true
                } else if remainingRedSpheres + remainingWhiteSpheres > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    public func spheresAt(column: Int, row: Int) -> Int {
        return poles[column][row].spheres
    }
    
    public func checkForMatch() -> [(Int, Int, Int)]? {
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: seenMills)
        
        seenMills = checkResult.seenMills
        _lastMill = checkResult.lastMill
        
        return checkResult.result
    }

    enum BoardLogicError: Error {
        case poleFull
        case poleEmpty
    }
}

extension Board {
    public convenience init?(message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
      
//        guard let messageURL = message?.url ??
//            URL(string: "?3,0=w&3,1=w&3,2=w&2,0=r&2,1=r&2,2=r&-1,-1,-1,2,3,0=r&remainingRed=1&remainingWhite=1&seenMills=200.210.220.230") else { return nil }
        
//        guard let messageURL = message?.url ??
//            URL(string: "?3,0=w&3,1=w&3,2=w&2,0=r,w&2,1=r,w&2,2=r,w&-1,-1,-1,1,3,0=r&remainingRed=0&remainingWhite=1&seenMills=200.210.220.230") else { return nil }
        
//        guard let messageURL = message?.url ??
//            URL(string: "?3,1=w&0,0=w,r&0,1=w,r&0,2=w&1,0=w,r&1,1=w,r&1,2=w,r&1,3=w,r&-1,-1,-1,0,2,1=r&remainingRed=1&remainingWhite=1&seenMills=100.110.120.130,101.111.121.131") else { return nil }
        
//        guard let messageURL = message?.url ??
//            URL(string: "?3,1=w&3,2=r&0,0=w,r&0,1=w,r&0,2=w,r&1,0=w,r&1,1=w,r&1,2=w,r&1,3=w,r&-1,-1,-1,3,1,1=w&remainingRed=0&remainingWhite=0&seenMills=100.110.120.130,101.111.121.131") else { return nil }

//        guard let messageURL = message?.url ??
//                        URL(string: "?3,0=w&3,1=r,w,r&3,2=r&3,3=w,w,r,r&2,0=w,r,w&2,1=r,r,w&2,2=r,w&2,3=r,r,w,w&1,0=r,w,w&1,1=r,w,w&1,2=w,r&1,3=r,r,w,w&0,0=r,r&0,1=w,r,w&0,2=r,w&0,3=r,r,w,w&-1,-1,-1,3,2,1=r&remainingWhite=0&remainingRed=0") else { return nil }
        
        self.init(url: messageURL)
    }
}
