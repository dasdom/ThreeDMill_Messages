//  Created by dasdom on 09.06.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import UIKit

class GameView: GameBaseView {

    let surrenderButton: UIButton
    let reanimateButton: UIButton
    let continueButton: UIButton
    let remainingWhiteSpheresLabel: UILabel
    let remainingWhiteInfoStackView: UIStackView
    let remainingRedSpheresLabel: UILabel
    let remainingRedInfoStackView: UIStackView
    
    override init(frame: CGRect, options: [String : Any]?) {
        
        surrenderButton = GameViewFactory.button(title: "Surrender", fontSize: 15)
        surrenderButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        
        reanimateButton = GameViewFactory.button(title: "Reanimate", fontSize: 15)
        reanimateButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        reanimateButton.isEnabled = false
        
        let whiteView = GameViewFactory.colorIndicatorView(UIColor.white)
        remainingWhiteSpheresLabel = GameViewFactory.remainingSpheresLable()
        remainingWhiteInfoStackView = GameViewFactory.remainingInfoStackView(views: [whiteView, remainingWhiteSpheresLabel])
        remainingWhiteInfoStackView.translatesAutoresizingMaskIntoConstraints = false

        let redView = GameViewFactory.colorIndicatorView(UIColor.red)
        remainingRedSpheresLabel = GameViewFactory.remainingSpheresLable()
        remainingRedInfoStackView = GameViewFactory.remainingInfoStackView(views: [redView, remainingRedSpheresLabel])
        remainingRedInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        continueButton = GameViewFactory.button(title: "Continue", fontSize: 15)
        continueButton.isHidden = true
        
        super.init(frame: frame, options: options)
        
        addSubview(surrenderButton)
        addSubview(reanimateButton)
        addSubview(continueButton)
        addSubview(remainingRedInfoStackView)
        addSubview(remainingWhiteInfoStackView)
        
        if #available(iOSApplicationExtension 11.0, *) {
            NSLayoutConstraint.activate([
                remainingRedInfoStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
                remainingRedInfoStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                remainingWhiteInfoStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
                remainingWhiteInfoStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                continueButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                ])
        } else {
            NSLayoutConstraint.activate([
                remainingRedInfoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                remainingRedInfoStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                remainingWhiteInfoStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                remainingWhiteInfoStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                ])
        }
        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            surrenderButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            surrenderButton.topAnchor.constraint(equalTo: tutorialButton.topAnchor),
            reanimateButton.leadingAnchor.constraint(equalTo: surrenderButton.trailingAnchor, constant: 10),
            reanimateButton.topAnchor.constraint(equalTo: surrenderButton.topAnchor),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

