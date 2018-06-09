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
        
        contentView.surrenderButton.addTarget(self, action: #selector(surrender(sender:)), for: .touchUpInside)
        contentView.reanimateButton.addTarget(self, action: #selector(reanimate(sender:)), for: .touchUpInside)
        
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
        
        contentView.hideText()
        
        switch board.mode {
        case .removeSphere:
            print("do nothing")
        default:
            delegate?.gameViewController(self, didFinishMoveWith: board)
        }
    }
    
    override func tap(sender: UITapGestureRecognizer) {
        super.tap(sender: sender)
        
        contentView.reanimateButton.isEnabled = false
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
    }
}

extension GameViewController: GameBaseViewActions {
    
    func add(_ color: SphereColor) {
        contentView.insert(color: color)
    }
    
    // MARK: Actions
    
    @objc func surrender(sender: UIButton!) {
        board.mode = .surrender
        delegate?.gameViewController(self, didFinishMoveWith: board)
    }
    
    func help(sender: UIButton!) {
        let nextViewController = TutorialViewController(board: Board())
        nextViewController.tutorialItems = [
            TutorialItem(text: "Tap a pole to move the sphere to that pole.", afterDoneText: "Nice! Tap anywhere to continue."),
            TutorialItem(text: "Four spheres with the same color in a row are a mill. Try to make a mill.",
                         afterMillText: "Good job! When you have a mill, you can remove a sphere of your opponent (from the marked poles). Tap anywhere to continue.",
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
    
    @objc func reanimate(sender: UIButton!) {
        
        sender.isEnabled = false
        
        if let sphereNode = movingSphereNode() {
            sphereNode.removeFromParentNode()
        }
        
        board = Board(url: board.receivedURL)
        contentView.update(with: board)
        
        animateLastMoves()
    }
}

extension GameViewController: Screenshotable {
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


