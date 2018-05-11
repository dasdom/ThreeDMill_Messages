//  Created by dasdom on 13.12.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import Foundation

struct BoardChecker {
    
    static func sphereColor(on poles: [[Pole]], atColumn column: Int, row: Int, floor: Int) -> SphereColor? {
        
        let pole = poles[column][row]
        guard pole.spheres > floor else { return nil }
        return poles[column][row].sphereColors[floor]
    }
}

// MARK: - Checker
extension BoardChecker {
    
    private static func sphereColor(on poles: [[Pole]], sameAs inputColor: SphereColor?, columnRowFloor: (Int, Int, Int)) -> SphereColor? {
        let (column, row, floor) = columnRowFloor
        
        let color = sphereColor(on: poles, atColumn: column, row: row, floor: floor)
        
        if inputColor == nil || color == inputColor {
            return color
        }
        
        return nil
    }
    
    static func checkForMatch(poles: [[Pole]], seenMills: [String]) -> CheckResult {
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
        var lastMill: String? = nil
        for check in functions {
            tempResults = check(poles)
            for tempResult in tempResults {
                let resultStringArray = tempResult.map {
                    return "\($0.0)\($0.1)\($0.2)"
                }
                
                let resultString = resultStringArray.joined(separator: ".")
                print("resultString: \(resultString)")
                
                if seenMills.contains(resultString) {
                    tempSeenMills.append(resultString)
                } else if result == nil {
                    tempSeenMills.append(resultString)
                    result = tempResult
                    lastMill = resultString
                } else {
                    tempSeenMills.append(resultString)
                }
                
            }
        }
        
        return CheckResult(result: result, seenMills: tempSeenMills, lastMill: lastMill)
    }
    
    static func checkForColumn(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        floorLoop: for floor in 0..<Board.numberOfColumns {
            columnLoop: for column in 0..<Board.numberOfColumns {
                result = []
                firstColor = nil
                rowLoop: for row in 0..<Board.numberOfColumns {
                    
                    let columnRowFloor = (column, row, floor)
                    firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForRow(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        floorLoop: for floor in 0..<Board.numberOfColumns {
            rowLoop: for row in 0..<Board.numberOfColumns {
                result = []
                firstColor = nil
                columnLoop: for column in 0..<Board.numberOfColumns {
                    
                    let columnRowFloor = (column, row, floor)
                    firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForFloorDiagonal1(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        floorLoop: for floor in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            rowLoop: for row in 0..<Board.numberOfColumns {
                
                let columnRowFloor = (row, row, floor)
                firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForFloorDiagonal2(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        floorLoop: for floor in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            rowLoop: for column in 0..<Board.numberOfColumns {
                
                let row = Board.numberOfColumns - 1 - column
                
                let columnRowFloor = (column, row, floor)
                firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForColumnDiagonal1(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        columnLoop: for column in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            rowLoop: for row in 0..<Board.numberOfColumns {
                
                let columnRowFloor = (column, row, row)
                firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForColumnDiagonal2(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        columnLoop: for column in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            floorLoop: for floor in 0..<Board.numberOfColumns {
                
                let row = Board.numberOfColumns - 1 - floor
                
                let columnRowFloor = (column, row, floor)
                firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForRowDiagonal1(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        rowLoop: for row in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            columnLoop: for column in 0..<Board.numberOfColumns {
                
                let columnRowFloor = (column, row, column)
                firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForRowDiagonal2(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        columnLoop: for row in 0..<Board.numberOfColumns {
            result = []
            firstColor = nil
            floorLoop: for floor in 0..<Board.numberOfColumns {
                
                let column = Board.numberOfColumns - 1 - floor
                
                let columnRowFloor = (column, row, floor)
                firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForPole(poles: [[Pole]]) -> [[(Int, Int, Int)]] {
        var allResults: [[(Int,Int,Int)]] = []
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        rowLoop: for row in 0..<Board.numberOfColumns {
            columnLoop: for column in 0..<Board.numberOfColumns {
                result = []
                firstColor = nil
                floorLoop: for floor in 0..<Board.numberOfColumns {
                    
                    let columnRowFloor = (column, row, floor)
                    firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForRoomDiagonal1(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        columnLoop: for column in 0..<Board.numberOfColumns {
            
            let columnRowFloor = (column, column, column)
            firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForRoomDiagonal2(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        columnLoop: for column in 0..<Board.numberOfColumns {

            let row = Board.numberOfColumns - 1 - column

            let columnRowFloor = (column, row, column)
            firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForRoomDiagonal3(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        rowLoop: for row in 0..<Board.numberOfColumns {
            
            let column = Board.numberOfColumns - 1 - row
            
            let columnRowFloor = (column, row, row)
            firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
    
    static func checkForRoomDiagonal4(poles: [[Pole]]) -> [[(Int,Int,Int)]] {
        var result: [(Int,Int,Int)]? = []
        var firstColor: SphereColor?
        floorLoop: for floor in 0..<Board.numberOfColumns {
            
            let column = Board.numberOfColumns - 1 - floor
            
            let columnRowFloor = (column, column, floor)
            firstColor = sphereColor(on: poles, sameAs: firstColor, columnRowFloor: columnRowFloor)
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
}
