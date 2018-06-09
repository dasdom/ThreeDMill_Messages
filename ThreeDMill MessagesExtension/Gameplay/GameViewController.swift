//  Created by dasdom on 27.05.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import UIKit
import ThreeDMillBoard

class GameViewController: GameBaseViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        if board.surrendered {
            let alert = UIAlertController(title: "You won!", message: "The other player surrendered!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
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
    
    override func didFinishMoveAnimation() {
        
        DispatchQueue.main.async {
            self.contentView.reanimateButton.isEnabled = true
        }
    }
}

extension GameViewController: ButtonActions {
    
    func add(_ color: SphereColor) {
        contentView.insert(color: color)
    }
    
    // MARK: Actions
    
    func surrender(sender: UIButton!) {
        board.mode = .surrender
        delegate?.gameViewController(self, didFinishMoveWith: board)
    }
    
    func help(sender: UIButton!) {
//        let helpViewController = HelpViewController(board: board)
        //        helpViewController.gameViewController = self
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
//        let navigationController = UINavigationController(rootViewController: nextViewController)
        present(nextViewController, animated: true, completion: nil)
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


