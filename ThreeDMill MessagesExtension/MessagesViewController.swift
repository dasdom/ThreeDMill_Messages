//  Created by dasdom on 03.12.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import UIKit
import Messages
import ThreeDMillBoard

class MessagesViewController: MSMessagesAppViewController {
    
    var mainController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
        
//        if let gameController = mainController as? GameViewController,
//            let board = Board(message: message) {
//            
//            gameController.board = board
//            
//            gameController.animateLastMoves()
//        }
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        removeAllChildViewControllers()
        
        let controller: UIViewController
        if let senderId = conversation.selectedMessage?.senderParticipantIdentifier,
            !conversation.remoteParticipantIdentifiers.contains(senderId) {
            
            controller = NotYourTurnViewController()
        } else {
            let board = Board(message: conversation.selectedMessage)
            if let unwrappedBoard = board {
                let gameBoard = unwrappedBoard.url.absoluteString.contains("start") ? Board() : unwrappedBoard
                let gameController = GameViewController(board: gameBoard)
                gameController.delegate = self
                controller = gameController
            } else {
                let startController = StartViewController(board: Board())
                startController.delegate = self
                controller = startController
            }
        }
        
        mainController = controller
        
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        
        controller.didMove(toParentViewController: self)
    }
    
    private func removeAllChildViewControllers() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
    
    fileprivate func composeMessage(with board: Board, caption: String, image: UIImage?, session: MSSession? = nil) -> MSMessage {
        
        let layout = MSMessageTemplateLayout()
        layout.image = image
//        layout.caption = caption
        
        let message = MSMessage(session: session ?? MSSession())
//        let message = MSMessage()
        message.url = board.url
        message.layout = layout
        
        return message
    }
}

extension MessagesViewController: GameViewControllerProtocol {
   func gameViewController(_ controller: Screenshotable, didFinishMoveWith board: Board) {
        
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }

        let image = controller.screenshot()
        
        let message = composeMessage(with: board, caption: "Your turn!", image: image, session: conversation.selectedMessage?.session)
    
    if #available(iOSApplicationExtension 11.0, *) {
        conversation.send(message) { error in
            if let error = error {
                print(error)
            }
        }
    } else {
        conversation.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    
        dismiss()
    }
}
