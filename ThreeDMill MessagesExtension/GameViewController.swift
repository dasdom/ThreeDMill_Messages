//  Created by dasdom on 08.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import UIKit
//import QuartzCore
import SceneKit
import ThreeDMillBoard

final class GameViewController: UIViewController {
    
    lazy var board = Board()
    private var notification: NSObjectProtocol?
    private var activateAddButton = true
    private var timer: Timer?
    private var timerStartDate: Date?
    weak var delegate: GameViewControllerProtocol?
    private var aSphereIsMoving = false
    private var lastResult: [(Int, Int, Int)]?
    private var modeBeforeMillWasShown: BoardMode?
    
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
        
        print("lastMill: \(board.lastMill)")
        
        if let _ = board.lastMill {
            contentView.continueButton.setTitle("Show mill", for: .normal)
            contentView.continueButton.isHidden = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            contentView.surrenderButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 10)
            ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notification = NotificationCenter.default.addObserver(forName: .numberOfRemainingSpheresChanged, object: nil, queue: OperationQueue.main) { notification in
            
            let userInfo = notification.userInfo
            guard let remainingWhiteSpheres = userInfo?[SphereColor.w] as? Int else {
                fatalError()
            }
            guard let remainingRedSpheres = userInfo?[SphereColor.r] as? Int else {
                fatalError()
            }
            
            self.activateAddButton = remainingWhiteSpheres + remainingRedSpheres > 0
            
            self.contentView.remainingWhiteSpheresLabel.text = "\(remainingWhiteSpheres)"
            self.contentView.remainingRedSpheresLabel.text = "\(remainingRedSpheres)"
        }
        
        if case .move = board.mode {
            contentView.whiteButtonStackView.isHidden = true
            contentView.redButtonStackView.isHidden = true
        }
        
//        contentView.fixCameraPosition()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateLastMoves()
        
        if board.surrendered {
            let alert = UIAlertController(title: "You won!", message: "The other player surrendered!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
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
}

extension GameViewController: ButtonActions {
    
    func add(_ color: SphereColor) {
        contentView.add(color: color)
    }
    
    // MARK: Actions
    func done(sender: UIButton!) {
//        let sphereNodes = contentView.scene?.rootNode.childNodes(passingTest: { node, stop -> Bool in
//            guard let gameSphereNode = node as? GameSphereNode else { return false }
//            return gameSphereNode.isMoving
//        })
//        guard let sphereNode = sphereNodes?.first as? GameSphereNode else { return }
        
        guard let sphereNode = self.movingSphereNode() else { return }
        
        stopTimer()
        
        sphereNode.isMoving = false
        
        if case .showMill = board.mode {
            assert(false)
        }
        
        switch board.mode {
        case .removeSphere:
            print("do nothing")
        default:
            delegate?.gameViewController(self, didFinishMoveWith: board)
        }
    }
    
    func stopTimer() {
        contentView.doneButton.isHidden = true
        timerStartDate = nil
        timer?.invalidate()
    }
    
    func surrender(sender: UIButton!) {
        board.mode = .surrender
        delegate?.gameViewController(self, didFinishMoveWith: board)
    }
    
    func help(sender: UIButton!) {
        let helpViewController = HelpViewController(board: board)
        //        helpViewController.gameViewController = self
        let navigationController = UINavigationController(rootViewController: helpViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func reanimate(sender: UIButton!) {
        
        sender.isEnabled = false
        
        if let sphereNode = movingSphereNode() {
            sphereNode.removeFromParentNode()
        }
        
        board = Board(url: board.receivedURL)
        contentView.update(with: board)
        
        animateLastMoves()
    }
}

extension GameViewController {
    @objc func tap(sender: UITapGestureRecognizer) {
        
        guard !aSphereIsMoving else {
            return
        }
        
        self.contentView.reanimateButton.isEnabled = false

        let location = sender.location(in: contentView)
        
        let hitResult = contentView.hitTest(location, options: nil)
        if hitResult.count > 0 {
            let result = hitResult[0]
            let node = result.node
            
            if case .showMill = board.mode {
                continueWithGame(sender: nil)
                return
            }
            
            if let (column, row) = contentView.pole(for: node) {
                print("column: \(column), row: \(row)")
                
                switch board.mode {
                case .removeSphere:
                    removeSphereFrom(node: node, column: column, row: row)
                case .move:
                    moveSphereUpOn(column: column, row: row)
//                case .showMill(color: _):
//                    continueWithGame(sender: nil)
                default:
                    addSphereTo(node: node, column: column, row: row)
                }
            }
        }
    }
    
    private func actionToMove(to poleNode: SCNNode, duration: TimeInterval = 0.3) -> SCNAction {
        var position = poleNode.position
        position.y = GameView.startY
        return SCNAction.move(to: position, duration: duration)
    }
    
    private func actionToMoveUp(sphere: GameSphereNode, duration: TimeInterval = 0.3) -> SCNAction {
        var spherePosition = sphere.position
        spherePosition.y = GameView.startY
        return SCNAction.move(to: spherePosition, duration: duration)
    }
    
    private func actionToMoveDown(to poleNode: SCNNode, column: Int, row: Int, duration: TimeInterval = 0.3) -> SCNAction {
        
        var position = poleNode.position
        position.y = 2.0 + 3.5 * Float(board.spheresAt(column: column, row: row))
        return SCNAction.move(to: position, duration: duration)
    }
    
    private func movingSphereNode() -> GameSphereNode? {
        let sphereNodes = contentView.scene?.rootNode.childNodes(passingTest: { node, stop -> Bool in
            guard let gameSphereNode = node as? GameSphereNode else { return false }
            return gameSphereNode.isMoving
        })
        
        return sphereNodes?.first as? GameSphereNode
    }
    
    private func removeSphere(column: Int, row: Int) {
        try? board.removeSphereFrom(column: column, andRow: row)
        _ = contentView.removeTopSphereAt(column: column, row: row)
    }
    
    private func add(sphere: GameSphereNode, column: Int, row: Int, updateCounts: Bool = true) {
        try? board.addSphereWith(sphere.color, toColumn: column, andRow: row, updateRemainCount: updateCounts)
        contentView.add(sphere, toColumn: column, andRow: row)
    }
    
    private func addSphereTo(node: SCNNode, column: Int, row: Int) {
        guard board.canAddSphereTo(column: column, row: row) else {
            let alertController = UIAlertController(title: "Pole full", message: "A pole cannot hold more than four spheres.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let sphereNode = movingSphereNode() else { fatalError("No moving sphere node") }
        
        let move: SCNAction
        
        let moveToPole = actionToMove(to: node)
        let moveDown = actionToMoveDown(to: node, column: column, row: row)

        if sphereNode.position.y < 20 {
            let (columnToRemove, rowToRemove) = contentView.columnAndRow(for: sphereNode)
            removeSphere(column: columnToRemove, row: rowToRemove)
            
            let moveUp = actionToMoveUp(sphere: sphereNode)
            move = SCNAction.sequence([moveUp, moveToPole, moveDown])
            
            add(sphere: sphereNode, column: column, row: row)
        } else {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateButton), userInfo: nil, repeats: true)
            timerStartDate = Date()
        
            move = SCNAction.sequence([moveToPole, moveDown])

            add(sphere: sphereNode, column: column, row: row)
            
            _ = mill(on: board, sphereNode: sphereNode)
            
            switch board.mode {
            case .addSpheres, .showMill(color: _):
                print("do nothing")
            default:
                if !board.canMove(for: sphereNode.color.oposit()) {
                    timer?.invalidate()
                    let alert = UIAlertController(title: "Congratulations", message: "You won!", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    present(alert, animated: true, completion: nil)
                }
            }
        }
        move.timingMode = .easeOut
        aSphereIsMoving = true
        sphereNode.runAction(move) {
            self.aSphereIsMoving = false
        }
    }
    
    func moveSphereUpOn(column: Int, row: Int) {
        
        guard let sphereNode = contentView.topSphereAt(column: column, row: row) else {
            fatalError("no sphere to move up")
        }
        
        if case .move(color: let color) = board.mode, sphereNode.color != color {
            let alert = UIAlertController(title: "Wat?", message: "Use your own stones!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        sphereNode.isMoving = true
        
        removeSphere(column: column, row: row)
        
        let moveUp = actionToMoveUp(sphere: sphereNode)
        
        aSphereIsMoving = true
        sphereNode.runAction(moveUp) {
            self.board.mode = .addSpheres
            self.aSphereIsMoving = false
        }
    }
    
    func moveSphere(_ sphereNode: GameSphereNode, toColumn column: Int, andRow row: Int, completionHandler: (() -> Void)?) {
     
        let poleNode = contentView.poleNode(column: column, row: row)

        var position = sphereNode.position
        position.x = poleNode.position.x
        position.z = poleNode.position.z
        
        let wait = SCNAction.wait(duration: 2)
        let moveToPole = actionToMove(to: poleNode, duration: 0.5)
        
        let moveDown = actionToMoveDown(to: poleNode, column: column, row: row, duration: 0.5)
        
        let move = SCNAction.sequence([wait, moveToPole, moveDown])
        
        add(sphere: sphereNode, column: column, row: row, updateCounts: false)
        
        aSphereIsMoving = true
        move.timingMode = .easeOut
        sphereNode.runAction(move) {
            
            if case .showMill = self.board.mode {
                assert(false)
            }
            
            if completionHandler == nil {
            
                switch (self.board.mode, sphereNode.color) {
                case (.move(color: _), _):
                    print("do nothing")
                case (_, .r):
                    self.add(.w)
                case (_, .w):
                    self.add(.r)
                }
                
                self.presentMoveAlertIfNeeded()
                
                DispatchQueue.main.async {
                    self.contentView.reanimateButton.isEnabled = true
                }
            }
            
            completionHandler?()
            self.aSphereIsMoving = false
        }
        
        sphereNode.isMoving = false
    }
    
    func removeSphere(fromColumn column: Int, row: Int) {
        
//        let fadeDuration: Double = 1.0
//
//        self.contentView.fadeAllBut(result: self.board.lastMill)
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: NSEC_PER_SEC * UInt64(fadeDuration))) {

            let poleNode = self.contentView.poleNode(column: column, row: row)
            var position = poleNode.position
            position.y = 20
            let wait1 = SCNAction.wait(duration: 0.5)
            let moveUp = SCNAction.move(to: position, duration: 0.3)
            let wait2 = SCNAction.wait(duration: 0.1)
            let fade = SCNAction.fadeOpacity(to: 0.1, duration: 0.1)
            let remove = SCNAction.removeFromParentNode()
            remove.timingMode = .easeOut
            let cleanUp = SCNAction.run { _ in
                try? self.board.removeSphereFrom(column: column, andRow: row, updateCounts: false)
                //            self.board.mode = .addSpheres
            }
            let moveAndRemove = SCNAction.sequence([wait1, moveUp, wait2, fade, remove, cleanUp])
            
            let sphereNode = self.contentView.removeTopSphereAt(column: column, row: row)
            self.aSphereIsMoving = true
            sphereNode?.runAction(moveAndRemove) {
                
                if case .showMill = self.board.mode {
                    assert(false)
                }
                
                if let sphereColor = sphereNode?.color {
                    switch (self.board.mode, sphereColor) {
                    case (.move(color: _), _):
                        print("do nothing")
                    case (_, .r):
                        self.add(.r)
                    case (_, .w):
                        self.add(.w)
                    }
                }
                self.presentMoveAlertIfNeeded()
                self.aSphereIsMoving = false
                
                DispatchQueue.main.async {
                    self.contentView.reanimateButton.isEnabled = true
                }
        }
//        }
    }
    
    func moveSphere(fromColumn: Int, fromRow: Int, toColumn: Int, toRow: Int, completionHandler: (() -> Void)?) {
        
        guard let sphereNode = contentView.topSphereAt(column: fromColumn, row: fromRow) else {
            fatalError("no sphere to move up")
        }
        
        sphereNode.isMoving = true
        
        removeSphere(column: fromColumn, row: fromRow)
        
        let wait = SCNAction.wait(duration: 1)
        let moveUp = actionToMoveUp(sphere: sphereNode, duration: 0.5)

        let poleNode = contentView.poleNode(column: toColumn, row: toRow)
        
        var position = sphereNode.position
        position.x = poleNode.position.x
        position.z = poleNode.position.z
        
        let moveToPole = actionToMove(to: poleNode, duration: 0.5)
        position.y = 2.0 + 3.5 * Float(board.spheresAt(column: toColumn, row: toRow))
        let moveDown = SCNAction.move(to: position, duration: 0.5)
        let move = SCNAction.sequence([wait, moveUp, moveToPole, moveDown])
        
        add(sphere: sphereNode, column: toColumn, row: toRow, updateCounts: false)
        
        move.timingMode = .easeOut
        aSphereIsMoving = true
        sphereNode.runAction(move) {
            completionHandler?()
            
            self.aSphereIsMoving = false
            
            DispatchQueue.main.async {
                self.contentView.reanimateButton.isEnabled = true
            }
        }
        
        sphereNode.isMoving = false
    }
    
    @objc func updateButton() {
        guard let interval = timerStartDate?.timeIntervalSinceNow else { return }
        let remaining = 3+Int(interval)
        if remaining < 0 {
            done(sender: nil)
        } else {
            contentView.doneButton.isHidden = false
        }
        contentView.doneButton.setTitle("\(remaining)", for: .normal)
    }
    
    private func removeSphereFrom(node: SCNNode, column: Int, row: Int) {
        
        if !board.canRemoveSphereFrom(column: column, row: row) {
            return
        }
        
        var position = node.position
        position.y = 20
        let moveUp = SCNAction.move(to: position, duration: 0.3)
        let wait = SCNAction.wait(duration: 0.05)
        let fade = SCNAction.fadeOpacity(to: 0.1, duration: 0.1)
        let remove = SCNAction.removeFromParentNode()
        remove.timingMode = .easeOut
        
        let moveAndRemove = SCNAction.sequence([moveUp, wait, fade, remove])

        let sphereNode = contentView.removeTopSphereAt(column: column, row: row)
        aSphereIsMoving = true
        sphereNode?.runAction(moveAndRemove) {
            try? self.board.removeSphereFrom(column: column, andRow: row)
            self.aSphereIsMoving = false
            DispatchQueue.main.async {
                self.delegate?.gameViewController(self, didFinishMoveWith: self.board)
            }
        }
        
    }
    
    private func mill(on board: Board, sphereNode: GameSphereNode) -> Bool {
        lastResult = board.checkForMatch()
        if let result = lastResult {
            
            stopTimer()
            
            sphereNode.isMoving = false
            
            let sphereColorToRemove: SphereColor
            switch sphereNode.color {
            case .r:
                sphereColorToRemove = .w
            case .w:
                sphereColorToRemove = .r
            }
            
            self.board.mode = .showMill(color: sphereColorToRemove)
            
//            let alertController = UIAlertController(title: "Mill", message: "Mill: \(result)\nYou can now remove a \(colorToRemove) sphere from the board.", preferredStyle: .alert)
//
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
//
//                let columnAndRows = self.board.columnsRowsWithRemovableSpheresFor(sphereColor: sphereColorToRemove)
//                print("columnAndRows: \(columnAndRows)")
//                self.contentView.color(polesColumnAndRows: columnAndRows)
//
//            })
          
//            alertController.addAction(okAction)
//            present(alertController, animated: true, completion: nil)
            
            contentView.fadeAllBut(result: result, toOpacity: 0.3)
            
            contentView.continueButton.isHidden = false
            
            contentView.showText()
            
            return true
        }
        return false
    }
    
    func continueWithGame(sender: UIButton!) {
        
        if let result = lastResult {
            
            if case .showMill(color: let sphereColorToRemove) = board.mode {
                
                contentView.fadeAllBut(result: result, toOpacity: 1.0)
                
                let columnAndRows = self.board.columnsRowsWithRemovableSpheresFor(sphereColor: sphereColorToRemove)
                print("columnAndRows: \(columnAndRows)")
                self.contentView.color(polesColumnAndRows: columnAndRows)
                
                contentView.continueButton.isHidden = true
                
                contentView.hideText()
                
                board.mode = .removeSphere
            }
            
        } else if let lastMill = board.lastMill {
            
            if case .showMill(color: _) = board.mode {
                contentView.fadeAllBut(result: lastMill, toOpacity: 1.0)

                contentView.continueButton.isHidden = true

                board.mode = modeBeforeMillWasShown!
            } else {
                contentView.fadeAllBut(result: lastMill, toOpacity: 0.3)
                
                contentView.continueButton.isHidden = false
                
                modeBeforeMillWasShown = board.mode
                board.mode = .showMill(color: .w)
            }
        }
    }
    
    func presentMoveAlertIfNeeded() {
        if case .move = board.mode {
            let alertController = UIAlertController(title: "Move", message: "All spheres are played. So now you can move your spheres to create mills.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func screenshot() -> UIImage? {
        let snapshot = contentView.snapshot()
        return imageWithImage(image: snapshot, croppedTo: CGRect(x: 0, y: view.frame.size.height*0.1, width: snapshot.size.width, height: snapshot.size.width+view.frame.size.height*0.2))
    }
    
    func imageWithImage(image: UIImage, croppedTo rect: CGRect) -> UIImage {
        if image.size.width > image.size.height {
            return image
        }
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        let drawRect = CGRect(x: -rect.origin.x, y: -rect.origin.y, width: image.size.width, height: image.size.height)
        
        context?.clip(to: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        
        image.draw(in: drawRect)
        
        let subImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()

        return subImage!
    }
    
    func animateLastMoves() {
        
        if board.lastAnimationMoves.count < 1 {
            add(.w)
            return
        }
        
        var completion: (() -> Void)? = nil
        for move in board.lastAnimationMoves.reversed() {
            
            let previousCompletion = completion
            if move.from.column < 0 {
                let sphereNode = contentView.add(color: move.color)
                
                let column = move.to.column
                let row = move.to.row
                completion = {
                    DispatchQueue.main.async {
                        self.moveSphere(sphereNode, toColumn: column, andRow: row, completionHandler:previousCompletion)
                        self.board.resetLastMoves()
                    }
                }
            } else if move.to.column < 0 {
                completion = {
                    DispatchQueue.main.async {
                        self.removeSphere(fromColumn: move.from.column, row: move.from.row)
                        self.board.resetLastMoves()
                    }
                }
            } else {
                completion = {
                    DispatchQueue.main.async {
                        self.moveSphere(fromColumn: move.from.column, fromRow: move.from.row, toColumn: move.to.column, toRow: move.to.row, completionHandler:previousCompletion)
                        self.board.resetLastMoves()
                    }
                }
            }
        }
        completion?()
    }
}


protocol GameViewControllerProtocol: class {
    func gameViewController(_ controller: GameViewController, didFinishMoveWith: Board)
}
