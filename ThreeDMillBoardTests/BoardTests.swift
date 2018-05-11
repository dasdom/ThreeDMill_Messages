//  Created by dasdom on 26.02.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import XCTest
@testable import ThreeDMillBoard

class BoardTests: XCTestCase {
    
    var sut: Board!
    
    override func setUp() {
        super.setUp()

        sut = Board()
    }
    
    override func tearDown() {

        sut = nil
        
        super.tearDown()
    }
    
    func test_addShpereWith_1() {
        try? sut.addSphereWith(.red, toColumn: 1, andRow: 2)
        
        sut.url.assertContains(URLQueryItem(name: "-1,-1,-1,1,2,0", value: "red"))
    }
    
    func test_addShpereWith_2() {
        try? sut.addSphereWith(.red, toColumn: 1, andRow: 2)
        sut.resetLastMoves()
        try? sut.addSphereWith(.white, toColumn: 1, andRow: 2)

        sut.url.assertContains(URLQueryItem(name: "1,2", value: "red"))
        sut.url.assertContains(URLQueryItem(name: "-1,-1,-1,1,2,1", value: "white"))
    }
    
    func test_checkResult_addsSeenMills() {
        try? sut.addSphereWith(.red, toColumn: 0, andRow: 0)
        try? sut.addSphereWith(.red, toColumn: 0, andRow: 1)
        try? sut.addSphereWith(.red, toColumn: 0, andRow: 2)
        try? sut.addSphereWith(.red, toColumn: 0, andRow: 3)
        
        _ = sut.checkForMatch()
        
        sut.url.assertContains(URLQueryItem(name: "seenMills", value: "000.010.020.030"))
    }
    
    func test_move_resultsInCorrectURL() {
        try? sut.addSphereWith(.red, toColumn: 0, andRow: 0)
        sut.mode = .move(color: .red)
        try? sut.removeSphereFrom(column: 0, andRow: 0)
        try? sut.addSphereWith(.red, toColumn: 0, andRow: 2)
        
        sut.url.assertContains(URLQueryItem(name: "0,0,0,0,2,0", value: "red"))
    }
}

extension URL {
    func assertContains(_ queryItem: URLQueryItem, file: StaticString = #file, line: UInt = #line) {
        
        let queryItems = self.queryItems!
        XCTAssertTrue(queryItems.contains(queryItem), "\(queryItem) not in \(queryItems)", file: file, line: line)
    }
    
    var queryItems: [URLQueryItem]? {
        return URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems
    }
}
