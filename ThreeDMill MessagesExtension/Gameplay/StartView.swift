//  Created by dasdom on 09.06.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import UIKit

class StartView: GameBaseView {

    let startButton: UIButton
    
    override init(frame: CGRect, options: [String : Any]?) {
        
        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        
        startButton = UIButton(type: .system)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Start Match", for: .normal)
        startButton.tintColor = UIColor.white
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        startButton.layer.borderColor = UIColor.white.cgColor
        startButton.layer.borderWidth = 1
        startButton.layer.cornerRadius = 5
        startButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        super.init(frame: frame, options: options)
        
        addSubview(overlayView)
        overlayView.addSubview(startButton)
        
        bringSubview(toFront: tutorialButton)
        
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            startButton.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
