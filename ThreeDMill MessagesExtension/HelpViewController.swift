//  Created by dasdom on 02.01.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import UIKit
import ThreeDMillBoard

class HelpViewController: UIViewController {

    let board: Board
//    weak var gameViewController: GameViewController? = nil
    
    var contentView: HelpView {
        return view as! HelpView
    }
    
    init(board: Board) {
        
        self.board = board
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let contentView = HelpView()
        contentView.update(with: board.receivedURL?.absoluteString)
        
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
    }
    
    @objc func close() {
//        if let text = contentView.text, text.count > 0, let url = URL(string: text) {
//            let board = Board(url: url)
//            gameViewController?.board = board
//            gameViewController?.contentView.update(with: board)
//        }
        dismiss(animated: true, completion: nil)
    }
}
