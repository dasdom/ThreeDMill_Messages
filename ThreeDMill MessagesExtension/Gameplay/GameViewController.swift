//  Created by dasdom on 27.05.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import UIKit
import ThreeDMillBoard

class GameViewController: GameBaseViewController {

    override var contentView: GameView { return view as! GameView }
    private var notification: NSObjectProtocol?

    override func loadView() {
        let contentView = GameView(frame: .zero, options: nil)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        contentView.addGestureRecognizer(tapRecognizer)
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = board.lastMill {
            contentView.continueButton.setTitle("Show mill", for: .normal)
            contentView.continueButton.isHidden = false
        }
        
        contentView.surrenderButton.addTarget(self, action: #selector(surrender(sender:)), for: .touchUpInside)
        contentView.reanimateButton.addTarget(self, action: #selector(reanimate(sender:)), for: .touchUpInside)
        contentView.newMatchButton.addTarget(self, action: #selector(newMatch(sender:)), for: .touchUpInside)
        contentView.continueButton.addTarget(self, action: #selector(continueWithGame(sender:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if case .move = board.mode {
            contentView.remainingWhiteInfoStackView.isHidden = true
            contentView.remainingRedInfoStackView.isHidden = true
        } else {
            notification = NotificationCenter.default.addObserver(forName: .numberOfRemainingSpheresChanged, object: nil, queue: OperationQueue.main) { notification in
                
                let userInfo = notification.userInfo
                let remainingWhiteSpheres = userInfo?[SphereColor.w] as! Int
                let remainingRedSpheres = userInfo?[SphereColor.r] as! Int
                
//                self.activateAddButton = remainingWhiteSpheres + remainingRedSpheres > 0
                
                self.contentView.remainingWhiteSpheresLabel.text = "\(remainingWhiteSpheres)"
                self.contentView.remainingRedSpheresLabel.text = "\(remainingRedSpheres)"
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        if board.surrendered {
            let alert = UIAlertController(title: "You won!", message: "The other player surrendered!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let _ = notification {
            NotificationCenter.default.removeObserver(notification as Any)
        }
    }
    
    override func done(sender: UIButton!) {
        
        guard let sphereNode = self.movingSphereNode() else { return }
        
        //        stopTimer()
        
        sphereNode.isMoving = false
        
        if case .showMill = board.mode {
            assert(false)
        }
        
        switch board.mode {
        case .removeSphere:
            print("do nothing")
        case .finish:
            self.stopTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.contentView.hideText()
                self.delegate?.gameViewController(self, didFinishMoveWith: self.board)
            })
        default:
            self.delegate?.gameViewController(self, didFinishMoveWith: self.board)
        }
    }
    
    override func didTapPole() {
        contentView.reanimateButton.isEnabled = false
        contentView.continueButton.isHidden = true
    }
    
    override func didFinishMoveAnimation() {
        
        DispatchQueue.main.async {
            self.contentView.reanimateButton.isEnabled = true
        }
    }
    
    override func mill(on board: Board, sphereNode: GameSphereNode) -> Bool {
        let hadMill = super.mill(on: board, sphereNode: sphereNode)
        if hadMill {
            contentView.continueButton.isHidden = false
        }
        return hadMill
    }
    
    @objc override func continueWithGame(sender: UIButton!) {
        
        super.continueWithGame(sender: sender)
        
        if let _ = lastResult {
            
            if case .showMill = board.mode {
                
                contentView.continueButton.isHidden = true
                
            }
            
        } else if let _ = board.lastMill {
            
            if case .showMill = board.mode {
                
                contentView.continueButton.isHidden = true
                
            } else {
                
                contentView.continueButton.isHidden = false
                
            }
        }
        
        contentView.continueButton.setTitle("Continue", for: .normal)
    }
}

extension GameViewController: GameBaseViewActions {
    
    func add(_ color: SphereColor) {
        contentView.insert(color: color)
    }
    
    // MARK: Actions
    
    @objc func surrender(sender: UIButton!) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "Do you really want to surrender?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Surrender", style: .default) { _ in
            self.board.mode = .surrender
            self.delegate?.gameViewController(self, didFinishMoveWith: self.board)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func reanimate(sender: UIButton!) {
        
        sender.isEnabled = false
        
        if let sphereNode = movingSphereNode() {
            sphereNode.removeFromParentNode()
        }
        
        board = Board(url: board.receivedURL)
        
        animateLastMoves()
    }
    
    @objc func newMatch(sender: UIButton) {
        board = Board()
        animateLastMoves()
    }
}


