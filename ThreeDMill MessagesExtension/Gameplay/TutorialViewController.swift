//  Created by dasdom on 02.06.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import UIKit
import ThreeDMillBoard

class TutorialViewController: GameBaseViewController {

    var tutorialItems: [TutorialItem] = []
    var currentTutorialItem = 0
    var shouldContinue = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNextTutorialItem()
        
        contentView.tutorialButton.setTitle("Dismiss", for: .normal)
        contentView.tutorialButton.addTarget(self, action: #selector(dismiss(sender:)), for: .touchUpInside)
    }
    
    func showNextTutorialItem() {
        if tutorialItems.count <= currentTutorialItem {
            dismiss(animated: true, completion: nil)
            return
        }
        
        contentView.emptyPoles()
        contentView.resetPoleColor()
        
        let item = tutorialItems[currentTutorialItem]
        
        board = Board(url: item.url)
        contentView.update(with: board)
        
        contentView.infoTextView.text = item.text
        contentView.infoTextView.isHidden = false
        
        if currentTutorialItem > 0 {
            animateLastMoves()
        }
    }
    
    override func done(sender: UIButton!) {
        let item = tutorialItems[currentTutorialItem]
        
        if let _ = item.afterDoneText {
            contentView.infoTextView.text = item.afterDoneText
            contentView.infoTextView.isHidden = false
        }
        if item.continueAfterDone {
            shouldContinue = true
        } else {
            currentTutorialItem -= 1
            shouldContinue = true
        }
    }
    
    override func tap(sender: UITapGestureRecognizer) {
        
        if shouldContinue {
            if case .showMill = board.mode {
                continueWithGame(sender: nil)
//                return
            }
            
            currentTutorialItem += 1
            showNextTutorialItem()
            shouldContinue = false
        } else {
            super.tap(sender: sender)
        }
    }
    
    override func mill(on board: Board, sphereNode: GameSphereNode) -> Bool {
        
        let item = tutorialItems[currentTutorialItem]
        
        if let _ = item.afterMillText {
            contentView.infoTextView.text = item.afterMillText
            contentView.infoTextView.isHidden = false
        }
        if item.continueAfterMill {
            shouldContinue = true
        }
        
        return super.mill(on: board, sphereNode: sphereNode)
    }
    
    @objc func dismiss(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
}
