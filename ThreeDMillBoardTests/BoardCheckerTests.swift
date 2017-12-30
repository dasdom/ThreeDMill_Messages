//  Created by dasdom on 27.12.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import XCTest
@testable import ThreeDMillBoard

class BoardCheckerTests: XCTestCase {
    
    var poles: [[Pole]] = []

    override func setUp() {
        super.setUp()

        poles = []
        for _ in 0..<Board.numberOfColumns {
            var column: [Pole] = []
            for _ in 0..<Board.numberOfColumns {
                column.append(Pole())
            }
            poles.append(column)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Column and row
    func test_checkForColumn_1() {
        poles[0][0].add(color: .red)
        poles[0][1].add(color: .red)
        poles[0][2].add(color: .red)
        poles[0][3].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "000.010.020.030")
    }
    
    func test_checkForColumn_2() {
        poles[2][0].add(color: .white)
        poles[2][0].add(color: .red)
        poles[2][1].add(color: .white)
        poles[2][1].add(color: .red)
        poles[2][2].add(color: .white)
        poles[2][2].add(color: .red)
        poles[2][3].add(color: .white)
        poles[2][3].add(color: .red)

        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: ["200.210.220.230"])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "201.211.221.231")
    }
    
    func test_checkForRow_1() {
        poles[0][0].add(color: .red)
        poles[1][0].add(color: .red)
        poles[2][0].add(color: .red)
        poles[3][0].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "000.100.200.300")
    }
    
    func test_checkForRow_2() {
        poles[0][2].add(color: .white)
        poles[0][2].add(color: .red)
        poles[1][2].add(color: .white)
        poles[1][2].add(color: .red)
        poles[2][2].add(color: .white)
        poles[2][2].add(color: .red)
        poles[3][2].add(color: .white)
        poles[3][2].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: ["020.120.220.320"])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "021.121.221.321")
    }
    
    // MARK: - Floor diagonal
    func test_checkForFloorDiagonal1_1() {
        poles[0][0].add(color: .red)
        poles[1][1].add(color: .red)
        poles[2][2].add(color: .red)
        poles[3][3].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "000.110.220.330")
    }
    
    func test_checkForFloorDiagonal1_2() {
        poles[0][0].add(color: .white)
        poles[0][0].add(color: .red)
        poles[1][1].add(color: .white)
        poles[1][1].add(color: .red)
        poles[2][2].add(color: .white)
        poles[2][2].add(color: .red)
        poles[3][3].add(color: .white)
        poles[3][3].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: ["000.110.220.330"])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "001.111.221.331")
    }
    
    func test_checkForFloorDiagonal2_1() {
        poles[0][3].add(color: .red)
        poles[1][2].add(color: .red)
        poles[2][1].add(color: .red)
        poles[3][0].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "030.120.210.300")
    }
    
    func test_checkForFloorDiagonal2_2() {
        poles[0][3].add(color: .white)
        poles[0][3].add(color: .red)
        poles[1][2].add(color: .white)
        poles[1][2].add(color: .red)
        poles[2][1].add(color: .white)
        poles[2][1].add(color: .red)
        poles[3][0].add(color: .white)
        poles[3][0].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: ["030.120.210.300"])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "031.121.211.301")
    }
    
    func test_checkForColumnDiagonal1_1() {
        poles[0][0].add(color: .red)
        
        poles[0][1].add(color: .white)
        poles[0][1].add(color: .red)
        
        poles[0][2].add(color: .white)
        poles[0][2].add(color: .white)
        poles[0][2].add(color: .red)
        
        poles[0][3].add(color: .white)
        poles[0][3].add(color: .white)
        poles[0][3].add(color: .white)
        poles[0][3].add(color: .red)

        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "000.011.022.033")
    }
    
    func test_checkForColumnDiagonal2_1() {
        poles[0][3].add(color: .red)

        poles[0][2].add(color: .white)
        poles[0][2].add(color: .red)

        poles[0][1].add(color: .white)
        poles[0][1].add(color: .white)
        poles[0][1].add(color: .red)

        poles[0][0].add(color: .white)
        poles[0][0].add(color: .white)
        poles[0][0].add(color: .white)
        poles[0][0].add(color: .red)

        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "030.021.012.003")
    }
    
    func test_checkForRowDiagonal1_1() {
        poles[0][0].add(color: .red)
        
        poles[1][0].add(color: .white)
        poles[1][0].add(color: .red)
        
        poles[2][0].add(color: .white)
        poles[2][0].add(color: .white)
        poles[2][0].add(color: .red)
        
        poles[3][0].add(color: .white)
        poles[3][0].add(color: .white)
        poles[3][0].add(color: .white)
        poles[3][0].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "000.101.202.303")
    }
    
    func test_checkForRowDiagonal2_1() {
        poles[3][0].add(color: .red)

        poles[2][0].add(color: .white)
        poles[2][0].add(color: .red)

        poles[1][0].add(color: .white)
        poles[1][0].add(color: .white)
        poles[1][0].add(color: .red)
        
        poles[0][0].add(color: .white)
        poles[0][0].add(color: .white)
        poles[0][0].add(color: .white)
        poles[0][0].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "300.201.102.003")
    }
    
    func test_checkForPole_1() {
        poles[0][0].add(color: .red)
        poles[0][0].add(color: .red)
        poles[0][0].add(color: .red)
        poles[0][0].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "000.001.002.003")
    }
    
    func test_checkForPole_2() {
        poles[1][2].add(color: .red)
        poles[1][2].add(color: .red)
        poles[1][2].add(color: .red)
        poles[1][2].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "120.121.122.123")
    }
    
    func test_checkForRoomDiagonal1() {
        poles[0][0].add(color: .red)
        
        poles[1][1].add(color: .white)
        poles[1][1].add(color: .red)
        
        poles[2][2].add(color: .white)
        poles[2][2].add(color: .white)
        poles[2][2].add(color: .red)
        
        poles[3][3].add(color: .white)
        poles[3][3].add(color: .white)
        poles[3][3].add(color: .white)
        poles[3][3].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "000.111.222.333")
    }
    
    func test_checkForRoomDiagonal2() {
        poles[0][3].add(color: .red)
        
        poles[1][2].add(color: .white)
        poles[1][2].add(color: .red)
        
        poles[2][1].add(color: .white)
        poles[2][1].add(color: .white)
        poles[2][1].add(color: .red)
        
        poles[3][0].add(color: .white)
        poles[3][0].add(color: .white)
        poles[3][0].add(color: .white)
        poles[3][0].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "030.121.212.303")
    }
    
    func test_checkForRoomDiagonal3() {
        poles[3][0].add(color: .red)
        
        poles[2][1].add(color: .white)
        poles[2][1].add(color: .red)
        
        poles[1][2].add(color: .white)
        poles[1][2].add(color: .white)
        poles[1][2].add(color: .red)
        
        poles[0][3].add(color: .white)
        poles[0][3].add(color: .white)
        poles[0][3].add(color: .white)
        poles[0][3].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "300.211.122.033")
    }
    
    func test_checkForRoomDiagonal4() {
        poles[3][3].add(color: .red)
        
        poles[2][2].add(color: .white)
        poles[2][2].add(color: .red)
        
        poles[1][1].add(color: .white)
        poles[1][1].add(color: .white)
        poles[1][1].add(color: .red)
        
        poles[0][0].add(color: .white)
        poles[0][0].add(color: .white)
        poles[0][0].add(color: .white)
        poles[0][0].add(color: .red)
        
        let checkResult = BoardChecker.checkForMatch(poles: poles, seenMills: [])
        
        let resultStringArray = checkResult.result?.map {
            return "\($0.0)\($0.1)\($0.2)"
        }
        let resultString = resultStringArray?.joined(separator: ".")
        XCTAssertEqual(resultString, "330.221.112.003")
    }
}
