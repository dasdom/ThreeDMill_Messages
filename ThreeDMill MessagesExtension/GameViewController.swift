//  Created by dasdom on 08.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import UIKit
//import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    lazy var board = Board()
    private var notification: NSObjectProtocol?
    private var activateAddButton = true
    private var timer: Timer?
    private var timerStartDate: Date?
    weak var delegate: GameViewControllerProtocol?
    
    var contentView: GameView { return view as! GameView }
    
    init(board: Board) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.board = board
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let contentView = GameView(frame: .zero, options: nil)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        contentView.addGestureRecognizer(tapRecognizer)
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.update(with: board)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notification = NotificationCenter.default.addObserver(forName: .numberOfRemainingSpheresChanged, object: nil, queue: OperationQueue.main) { notification in
            
            let userInfo = notification.userInfo
            guard let remainingWhiteSpheres = userInfo?[SphereColor.white] as? Int else {
                fatalError()
            }
            guard let remainingRedSpheres = userInfo?[SphereColor.red] as? Int else {
                fatalError()
            }
            
            self.activateAddButton = remainingWhiteSpheres + remainingRedSpheres > 0
            
            self.contentView.remainingWhiteSpheresLabel.text = "\(remainingWhiteSpheres)"
            self.contentView.remainingRedSpheresLabel.text = "\(remainingRedSpheres)"
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let lastMoves = board.lastMoves
        guard let firstMove = lastMoves.first else {
            add(.white)
            return
        }
        
        if firstMove.from.column < 0 {
            let sphereNode = contentView.add(color: firstMove.color)
            
            let column = firstMove.to.column
            let row = firstMove.to.row
            moveSphere(sphereNode, toColumn: column, andRow: row, completionHandler: lastMoves.count < 2 ? nil : {
                if lastMoves.count > 1 {
                    let secondMove = lastMoves[1]
                    if secondMove.to.column < 0 {
                        DispatchQueue.main.async {
                            self.removeSphere(fromColumn: secondMove.from.column, row: secondMove.from.row)
                        }
                    }
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(notification as Any)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}

extension GameViewController: ButtonActions {
//    func add(sender: UIButton!) {
////        done(sender: nil)
//
//        let sphereColor: SphereColor = sender.tag == 0 ? .red : .white
//        contentView.add(color: sphereColor)
//    }
    
    func add(_ color: SphereColor) {
        contentView.add(color: color)
    }
}

extension GameViewController {
    @objc func tap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: contentView)
        
        let hitResult = contentView.hitTest(location, options: nil)
        if hitResult.count > 0 {
            let result = hitResult[0]
            let node = result.node
            
            if let (column, row) = contentView.pole(for: node) {
                print("column: \(column), row: \(row)")
                
                switch board.mode {
                case .removeSphere:
                    removeSphereFrom(node: node, column: column, row: row)
                default:
                    addSphereTo(node: node, column: column, row: row)
                }
            }
        }
    }
    
    private func addSphereTo(node: SCNNode, column: Int, row: Int) {
        guard board.canAddSphereTo(column: column, row: row) else {
            let alertController = UIAlertController(title: "Pole full", message: "A pole cannot hold more than four spheres.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        
        let sphereNodes = contentView.scene?.rootNode.childNodes(passingTest: { node, stop -> Bool in
            guard let gameSphereNode = node as? GameSphereNode else { return false }
            return gameSphereNode.isMoving
        })
        
        guard let sphereNode = sphereNodes?.first as? GameSphereNode else { return }
        
        var position = sphereNode.position
        position.x = node.position.x
        position.z = node.position.z
        let move: SCNAction
        if position.y < 20 {
            let (columnToRemove, rowToRemove) = contentView.columnAndRow(for: sphereNode)
            try? board.removeSphereFrom(column: columnToRemove, andRow: rowToRemove)
            _ = contentView.removeSphereFrom(column: columnToRemove, row: rowToRemove)
            
            var spherePosition = sphereNode.position
            spherePosition.y = 25
            let moveUp = SCNAction.move(to: spherePosition, duration: 0.3)
            position.y = 25
            let moveToPole = SCNAction.move(to: position, duration: 0.3)
            position.y = 2.0 + 3.5 * Float(board.spheresAt(column: column, row: row))
            let moveDown = SCNAction.move(to: position, duration: 0.3)
            move = SCNAction.sequence([moveUp, moveToPole, moveDown])
            
            try? board.addSphereWith(sphereNode.color, toColumn: column, andRow: row)
            contentView.add(sphereNode, toColumn: column, andRow: row)
        } else {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateButton), userInfo: nil, repeats: true)
            timerStartDate = Date()
            
            let moveToPole = SCNAction.move(to: position, duration: 0.3)
            position.y = 2.0 + 3.5 * Float(board.spheresAt(column: column, row: row))
            let moveDown = SCNAction.move(to: position, duration: 0.3)
            move = SCNAction.sequence([moveToPole, moveDown])
            
            try? board.addSphereWith(sphereNode.color, toColumn: column, andRow: row)
            contentView.add(sphereNode, toColumn: column, andRow: row)
            
            _ = mill(on: board, sphereNode: sphereNode)
//            if !mill(on: board, sphereNode: sphereNode) && activateAddButton {
//                
//                switch sphereNode.color {
//                case .red:
//                    contentView.whiteButtonStackView.isHidden = false
//                case .white:
//                    contentView.redButtonStackView.isHidden = false
//                }
//                
//            }
        }
        move.timingMode = .easeOut
        sphereNode.runAction(move)
    }
    
    func moveSphere(_ sphereNode: GameSphereNode, toColumn column: Int, andRow row: Int, completionHandler: (() -> Void)?) {
     
        let poleNode = contentView.poleNode(column: column, row: row)

        var position = sphereNode.position
        position.x = poleNode.position.x
        position.z = poleNode.position.z
        
        let wait = SCNAction.wait(duration: 2)
        let moveToPole = SCNAction.move(to: position, duration: 0.5)
        position.y = 2.0 + 3.5 * Float(board.spheresAt(column: column, row: row))
        let moveDown = SCNAction.move(to: position, duration: 0.5)
        let move = SCNAction.sequence([wait, moveToPole, moveDown])
        
        try? board.addSphereWith(sphereNode.color, toColumn: column, andRow: row, updateRemainCount: false)
        contentView.add(sphereNode, toColumn: column, andRow: row)
        
        move.timingMode = .easeOut
        sphereNode.runAction(move) {
            
            if completionHandler == nil {
                switch sphereNode.color {
                case .red:
                    self.add(.white)
                case .white:
                    self.add(.red)
                }
            }
            
            completionHandler?()
        }
        
        sphereNode.isMoving = false
    }
    
    func removeSphere(fromColumn column: Int, row: Int) {
        
        let poleNode = contentView.poleNode(column: column, row: row)
        var position = poleNode.position
        position.y = 20
        let moveUp = SCNAction.move(to: position, duration: 0.3)
        let wait = SCNAction.wait(duration: 0.05)
        let fade = SCNAction.fadeOpacity(to: 0.1, duration: 0.1)
        let remove = SCNAction.removeFromParentNode()
        remove.timingMode = .easeOut
        let cleanUp = SCNAction.run { _ in
            try? self.board.removeSphereFrom(column: column, andRow: row)
            self.board.mode = .addSpheres
        }
        let moveAndRemove = SCNAction.sequence([moveUp, wait, fade, remove, cleanUp])
        
        let sphereNode = contentView.removeSphereFrom(column: column, row: row)
        sphereNode.runAction(moveAndRemove) {
            switch sphereNode.color {
            case .red:
                self.add(.white)
            case .white:
                self.add(.red)
            }
        }
    }
    
    @objc func updateButton() {
        guard let interval = timerStartDate?.timeIntervalSinceNow else { return }
        let remaining = 1+Int(interval)
        if remaining < 0 {
            done(sender: nil)
        } else {
            contentView.doneButton.isHidden = false
        }
        contentView.doneButton.setTitle("\(remaining)", for: .normal)
    }
    
    func done(sender: UIButton!) {
        let sphereNodes = contentView.scene?.rootNode.childNodes(passingTest: { node, stop -> Bool in
            guard let gameSphereNode = node as? GameSphereNode else { return false }
            return gameSphereNode.isMoving
        })
        guard let sphereNode = sphereNodes?.first as? GameSphereNode else { return }
        
        contentView.doneButton.isHidden = true
        timerStartDate = nil
        timer?.invalidate()
        
        sphereNode.isMoving = false
        
        if board.mode != .removeSphere {
            delegate?.gameViewController(self, didFinishMoveWith: board)
        }
    }
    
    private func removeSphereFrom(node: SCNNode, column: Int, row: Int) {
        
        var position = node.position
        position.y = 20
        let moveUp = SCNAction.move(to: position, duration: 0.3)
        let wait = SCNAction.wait(duration: 0.05)
        let fade = SCNAction.fadeOpacity(to: 0.1, duration: 0.1)
        let remove = SCNAction.removeFromParentNode()
        remove.timingMode = .easeOut
        let cleanUp = SCNAction.run { _ in
            try? self.board.removeSphereFrom(column: column, andRow: row)
            self.board.mode = .addSpheres
            self.delegate?.gameViewController(self, didFinishMoveWith: self.board)
        }
        let moveAndRemove = SCNAction.sequence([moveUp, wait, fade, remove, cleanUp])

        let sphereNode = contentView.removeSphereFrom(column: column, row: row)
        sphereNode.runAction(moveAndRemove)
        
//        switch sphereNode.color {
//        case .red:
//            contentView.redButtonStackView.isHidden = false
//        case .white:
//            contentView.whiteButtonStackView.isHidden = false
//        }
        
    }
    
    private func mill(on board: Board, sphereNode: GameSphereNode) -> Bool {
        if let result = board.checkForMatch() {
            
            let colorToRemove: String
            switch sphereNode.color {
            case .red:
                colorToRemove = "white"
            case .white:
                colorToRemove = "red"
            }
            
            let alertController = UIAlertController(title: "Mill", message: "Mill: \(result)\nYou can now remove a \(colorToRemove) sphere from the board.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                
                self.board.mode = .removeSphere
            })
            
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            return true
        }
        return false
    }
}

protocol GameViewControllerProtocol: class {
    func gameViewController(_ controller: GameViewController, didFinishMoveWith: Board)
}
