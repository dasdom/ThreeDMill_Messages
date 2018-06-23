//  Created by dasdom on 02.06.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import UIKit
import ThreeDMillBoard

class TutorialViewController: GameBaseViewController {

    var tutorialItems: [TutorialItem] = []
    var currentTutorialItem = 0
    var shouldContinue = false
    private var millChecked = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNextTutorialItem()
        
        contentView.tutorialButton.setTitle("Dismiss", for: .normal)
        contentView.tutorialButton.addTarget(self, action: #selector(dismiss(sender:)), for: .touchUpInside)
    }
    
    func showNextTutorialItem() {
        millChecked = false
        if tutorialItems.count <= currentTutorialItem {
            dismiss(animated: true, completion: nil)
            return
        }
        
        contentView.emptyPoles()
        contentView.resetPoleColor()
        
        let item = tutorialItems[currentTutorialItem]
        
        board = Board(url: item.url)
        
        contentView.infoTextView.text = item.text
        contentView.infoTextView.isHidden = false
        
        if currentTutorialItem > 0 {
            animateLastMoves()
        }
    }
    
    override func updateButton() {
        guard let interval = timerStartDate?.timeIntervalSinceNow else { return }
        let remaining = 0.8+interval
        if remaining < 0, millChecked {
            timer?.invalidate()
            contentView.doneButton.isHidden = true
            done(sender: nil)
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
        
        let isMill = super.mill(on: board, sphereNode: sphereNode)
        
        let item = tutorialItems[currentTutorialItem]
        
        if let _ = item.afterMillText, isMill {
            contentView.infoTextView.text = item.afterMillText
            contentView.infoTextView.isHidden = false
        }
        if item.continueAfterMill {
            shouldContinue = true
        }
        
        millChecked = true
        return isMill
    }
    
    @objc func dismiss(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
}
