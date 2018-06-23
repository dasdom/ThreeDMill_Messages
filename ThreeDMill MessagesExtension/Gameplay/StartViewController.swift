//  Created by dasdom on 09.06.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import UIKit
import ThreeDMillBoard

class StartViewController: GameBaseViewController {
    
    override func loadView() {
        let startView = StartView(frame: .zero, options: nil)
        startView.startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        view = startView
    }

    @objc func start() {
        board = Board(url: URL(string: "start"))
        delegate?.gameViewController(self, didFinishMoveWith: board)
    }
}
