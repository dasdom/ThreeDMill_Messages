//  Created by dasdom on 08.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import UIKit
//import QuartzCore
import SceneKit
import Messages
import ThreeDMillBoard

class GameBaseViewController: UIViewController, GameViewAnimationProtocol {
    
    var board = Board() {
        didSet {
            contentView.update(with: board)
            
            contentView.resetBoardVisually()
        }
    }
    var timer: Timer?
    var timerStartDate: Date?
    weak var delegate: GameViewControllerProtocol?
    private var aSphereIsMoving = false
    var lastResult: [(Int, Int, Int)]?
    private var modeBeforeMillWasShown: BoardMode?
    
    var contentView: GameBaseView { return view as! GameBaseView }
    
    init(board: Board) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.board = board
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let contentView = GameBaseView(frame: .zero, options: nil)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        contentView.addGestureRecognizer(tapRecognizer)
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.update(with: board)
        
        print("lastMill: \(String(describing: board.lastMill))")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            contentView.tutorialButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 10),
            contentView.infoTextView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -10)
            ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateLastMoves()
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
    
    func done(sender: UIButton!) {
        print("needs to be overridden")
    }
    
    @objc func help(sender: UIButton!) {
        
        guard let messagesViewController = delegate as? MSMessagesAppViewController else { return }
        messagesViewController.requestPresentationStyle(.expanded)
        
        let nextViewController = TutorialViewController(board: Board())
        nextViewController.tutorialItems = [
            TutorialItem(text: "Tap a pole to move the sphere to that pole.", afterDoneText: "Nice! Tap anywhere to continue."),
            TutorialItem(text: "Four spheres with the same color in a row are a mill. Try to make a mill.",
                         afterMillText: "Good job! When you have a mill, you can remove a sphere of your opponent (from the marked poles). Then the game continues until one player cannot move any of their spheres anymore. Tap anywhere to continue.",
                         afterDoneText: "Oh no! You missed the mill. Try again!",
                         url: URL(string: "?3,0=w&3,1=w&3,2=w&2,0=r&2,1=r&-1,-1,-1,2,2,0=r"),
                         continueAfterMill: true,
                         continueAfterDone: false),
            TutorialItem(text: "Mills can be in each floor, in columns, rows and diagonals. Try to find the spot where to put the sphere to make a mill.",
                         afterMillText: "Awesome! Good job! Tap anywhere to continue.",
                         afterDoneText: "Oh no! You missed the mill. Try again!",
                         url: URL(string: "?3,0=w&3,1=r,w,r&3,2=r&3,3=w,r,w,w&-1,-1,-1,3,2,1=r&remainingWhite=27&remainingRed=27"),
                         continueAfterMill: true,
                         continueAfterDone: false),
            TutorialItem(text: "Each player has 32 spheres to begin with. When all spheres are played, you can move spheres to make mills. Tap a pole with a sphere you want to move. Than tap the pole where you want to move the sphere to.",
                         afterMillText: "Now you are ready to play! Have fun! Tap anywhere to return to the game.",
                         afterDoneText: "Now you are ready to play! Have fun! Tap anywhere to return to the game.",
                         url: URL(string: "?3,0=w&3,1=r,w,r&3,2=r&3,3=w,w,r,r&2,0=w,r,w&2,1=r,r,w&2,2=r,w&2,3=r,r,w,w&1,0=r,w,w&1,1=r,w,w&1,2=w,r&1,3=r,r,w,w&0,0=r,r&0,1=w,r,w&0,2=r,w&0,3=r,r,w,w&-1,-1,-1,3,2,1=r&remainingWhite=0&remainingRed=0"),
                         continueAfterMill: true,
                         continueAfterDone: true),
        ]
        present(nextViewController, animated: true, completion: nil)
    }
    
    func mill(on board: Board, sphereNode: GameSphereNode) -> Bool {
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
            
            contentView.fadeAllBut(result: result, toOpacity: 0.3)
            
//            contentView.continueButton.isHidden = false
            
            contentView.showText()
            
            return true
        }
        return false
    }
    
    func didFinishMoveAnimation() {
        // meant to be overridden in subclasses
    }
    
    func stopTimer() {
        contentView.doneButton.isHidden = true
        timerStartDate = nil
        timer?.invalidate()
    }
    
    func didTapPole() {
        // meant to be overridden in subclasses
    }
}

extension GameBaseViewController {
    @objc func tap(sender: UITapGestureRecognizer) {
        
        guard !aSphereIsMoving else {
            return
        }
        
        if case .finish = board.mode {
            return
        }
        
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
                
                didTapPole()
                
                print("column: \(column), row: \(row)")
                
                switch board.mode {
                case .removeSphere:
                    removeSphereFrom(node: node, column: column, row: row)
                case .move:
                    moveSphereUpOn(column: column, row: row)
//                case .showMill(color: _):
//                    continueWithGame(sender: nil)
                default:
                    addSphereTo(pole: node, column: column, row: row)
                }
            }
        }
    }
    
    private func actionToMove(to poleNode: SCNNode, duration: TimeInterval = 0.3) -> SCNAction {
        var position = poleNode.position
        position.y = GameBaseView.startY
        return SCNAction.move(to: position, duration: duration)
    }
    
    private func actionToMoveUp(sphere: GameSphereNode, duration: TimeInterval = 0.3) -> SCNAction {
        var spherePosition = sphere.position
        spherePosition.y = GameBaseView.startY
        return SCNAction.move(to: spherePosition, duration: duration)
    }
    
    private func actionToMoveDown(to poleNode: SCNNode, column: Int, row: Int, duration: TimeInterval = 0.3) -> SCNAction {
        
        var position = poleNode.position
        position.y = 2.0 + 3.5 * Float(board.spheresAt(column: column, row: row))
        return SCNAction.move(to: position, duration: duration)
    }
    
    func movingSphereNode() -> GameSphereNode? {
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
    
    private func addShereToBoard(sphere: GameSphereNode, column: Int, row: Int, updateCounts: Bool = true) {
        try? board.addSphereWith(sphere.color, toColumn: column, andRow: row, updateRemainCount: updateCounts)
        contentView.add(sphere, toColumn: column, andRow: row)
    }
    
    private func addSphereTo(pole: SCNNode, column: Int, row: Int) {
        guard board.canAddSphereTo(column: column, row: row) else {
            let alertController = UIAlertController(title: "Pole full", message: "A pole cannot hold more than four spheres.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let sphereNode = movingSphereNode() else { fatalError("No moving sphere node") }
    
        let move: SCNAction
        
        let moveToPole = actionToMove(to: pole)
        let moveDown = actionToMoveDown(to: pole, column: column, row: row)

        if sphereNode.position.y < 20 {
            let (columnToRemove, rowToRemove) = contentView.columnAndRow(for: sphereNode)
            removeSphere(column: columnToRemove, row: rowToRemove)
            
            let moveUp = actionToMoveUp(sphere: sphereNode)
            move = SCNAction.sequence([moveUp, moveToPole, moveDown])
//            move = SCNAction.sequence([moveToPole, moveDown])

            addShereToBoard(sphere: sphereNode, column: column, row: row)
        } else {
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateButton), userInfo: nil, repeats: true)
            timerStartDate = Date()
            
            move = SCNAction.sequence([moveToPole, moveDown])
            
            addShereToBoard(sphere: sphereNode, column: column, row: row)
        }
//        move.timingMode = .easeOut
        aSphereIsMoving = true
        sphereNode.runAction(move) {
            
            DispatchQueue.main.async {
                _ = self.mill(on: self.board, sphereNode: sphereNode)
                
                switch self.board.mode {
                case .showMill(color: _):
                    print("do nothing")
                default:
                    if !self.board.canMove(for: sphereNode.color.oposit()) {
                        self.board.mode = .finish
                        self.contentView.showConfetti()
                    }
                }
                
//                if !isMill {
//                    self.done(sender: nil)
//                }
                
                self.aSphereIsMoving = false
            }
        }
    }
    
    func moveSphereUpOn(column: Int, row: Int) {
        
        guard let sphereNode = contentView.topSphereAt(column: column, row: row) else {
//            fatalError("no sphere to move up")
            return
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
        
        addShereToBoard(sphere: sphereNode, column: column, row: row, updateCounts: false)
        
        aSphereIsMoving = true
        move.timingMode = .easeOut
        sphereNode.runAction(move) {
            
            if case .showMill = self.board.mode {
                assert(false)
            }

            if completionHandler == nil {

                self.insertSphereIfNeeded(sphereColor: sphereNode.color, mode:self.board.mode)

                self.presentMoveAlertIfNeeded()

                self.didFinishMoveAnimation()
            }
            
            completionHandler?()
            self.aSphereIsMoving = false
        }
        
        sphereNode.isMoving = false
    }
    
    fileprivate func insertSphereIfNeeded(sphereColor: SphereColor?, mode: BoardMode) {
        if let unwrappedSphereColor = sphereColor {
            switch (mode, unwrappedSphereColor) {
            case (.move(color: _), _):
                print("do nothing")
            case (_, .w):
                self.contentView.insert(color: .r)
            case (_, .r):
                self.contentView.insert(color: .w)
            }
        }
    }
    
    func removeSphere(fromColumn column: Int, row: Int) {
        
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
            
            self.insertSphereIfNeeded(sphereColor: sphereNode?.color.oposit(), mode: self.board.mode)
            self.presentMoveAlertIfNeeded()
            self.aSphereIsMoving = false
            
            self.didFinishMoveAnimation()
            
            if !self.board.canMove(for: sphereNode!.color) {
                self.contentView.showLostText()
            }
        }
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
        
        addShereToBoard(sphere: sphereNode, column: toColumn, row: toRow, updateCounts: false)
        
        move.timingMode = .easeOut
        aSphereIsMoving = true
        sphereNode.runAction(move) {
            
            if let completionHandler = completionHandler {
                completionHandler()
            }
            
            self.aSphereIsMoving = false
            
            self.didFinishMoveAnimation()
            
            if !self.board.canMove(for: sphereNode.color.oposit()) {
                self.contentView.showLostText()
            }
            
        }
        
        sphereNode.isMoving = false
    }
    
    @objc func updateButton() {
        guard let interval = timerStartDate?.timeIntervalSinceNow else { return }
        let remaining = 3+Int(interval)
        if remaining < 0 {
            contentView.doneButton.isHidden = true
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
                if !self.board.canMove(for: sphereNode!.color) {
                    self.board.mode = .finish
                    self.contentView.showConfetti()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        self.contentView.hideText()
                        self.delegate?.gameViewController(self, didFinishMoveWith: self.board)
                    })
                } else {
                    self.delegate?.gameViewController(self, didFinishMoveWith: self.board)
                }
            }
        }
        
    }
    
    @objc func continueWithGame(sender: UIButton!) {
        
        if let result = lastResult {
            
            if case .showMill(color: let sphereColorToRemove) = board.mode {
                
                contentView.fadeAllBut(result: result, toOpacity: 1.0)
                
                let columnAndRows = self.board.columnsRowsWithRemovableSpheresFor(sphereColor: sphereColorToRemove)
                print("columnAndRows: \(columnAndRows)")
                self.contentView.color(polesColumnAndRows: columnAndRows)
                
                contentView.hideText()
                
                board.mode = .removeSphere
                
                if columnAndRows.count < 1 {
                    let alertController = UIAlertController(title: "Pitty", message: "All reachable spheres of your opponent are in mills. So you cannot remove any sphere. More luck next time.", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.delegate?.gameViewController(self, didFinishMoveWith: self.board)
                    })
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
                }
            }
            
        } else if let lastMill = board.lastMill {
            
            if case .showMill(color: _) = board.mode {
                contentView.fadeAllBut(result: lastMill, toOpacity: 1.0)

                board.mode = modeBeforeMillWasShown!
            } else {
                contentView.fadeAllBut(result: lastMill, toOpacity: 0.3)
                                
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
    
    func animateLastMoves() {
        
        if board.lastAnimationMoves.count < 1 {
            contentView.insert(color: .w)
            return
        }
        
        var completion: (() -> Void)? = nil
        for move in board.lastAnimationMoves.reversed() {
            
            let previousCompletion = completion
            if move.from.column < 0 {
                let sphereNode = contentView.insert(color: move.color)
                
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

extension GameBaseViewController: Screenshotable {
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
}


protocol GameViewControllerProtocol: class {
    func gameViewController(_ controller: Screenshotable, didFinishMoveWith: Board)
}

protocol GameViewAnimationProtocol {
    func didFinishMoveAnimation()
}
