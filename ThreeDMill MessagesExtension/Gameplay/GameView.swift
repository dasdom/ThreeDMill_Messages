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
    let newMatchButton: UIButton
    
    override init(frame: CGRect, options: [String : Any]?) {
        
        surrenderButton = GameViewFactory.button(title: "Surrender", fontSize: 15)
        surrenderButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        
        reanimateButton = GameViewFactory.button(title: "Replay", fontSize: 15)
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
        
        newMatchButton = GameViewFactory.button(title: "New Match", fontSize: 40)
        newMatchButton.isHidden = true
        
        super.init(frame: frame, options: options)
        
        addSubview(surrenderButton)
        addSubview(reanimateButton)
        addSubview(continueButton)
        addSubview(remainingRedInfoStackView)
        addSubview(remainingWhiteInfoStackView)
        addSubview(newMatchButton)
        
        if #available(iOSApplicationExtension 11.0, *) {
            NSLayoutConstraint.activate([
                remainingRedInfoStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
                remainingRedInfoStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                remainingWhiteInfoStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
                remainingWhiteInfoStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                continueButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                newMatchButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                ])
        } else {
            NSLayoutConstraint.activate([
                remainingRedInfoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                remainingRedInfoStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                remainingWhiteInfoStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                remainingWhiteInfoStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                newMatchButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                ])
        }
        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            surrenderButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            surrenderButton.topAnchor.constraint(equalTo: tutorialButton.topAnchor),
            reanimateButton.leadingAnchor.constraint(equalTo: surrenderButton.trailingAnchor, constant: 10),
            reanimateButton.topAnchor.constraint(equalTo: surrenderButton.topAnchor),
            newMatchButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func showLostText() {
        super.showLostText()
        
        DispatchQueue.main.async {
            self.surrenderButton.isHidden = true
            self.tutorialButton.isHidden = true
            self.continueButton.isHidden = true
            
            self.newMatchButton.isHidden = false
        }
    }
    
    override func resetBoardVisually() {
        
        super.resetBoardVisually()
        
        DispatchQueue.main.async {
            
            self.surrenderButton.isHidden = false
            self.tutorialButton.isHidden = false
            
            self.newMatchButton.isHidden = true
        }
    }
}

