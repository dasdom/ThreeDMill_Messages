//  Created by dasdom on 21.05.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import UIKit

struct GameViewFactory {
    static func colorIndicatorView(_ color: UIColor) -> UIView {
        let sphereIndicatorHeight = CGFloat(20)
        
        let colorView = UIView()
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = sphereIndicatorHeight/2.0
        colorView.widthAnchor.constraint(equalToConstant: sphereIndicatorHeight).isActive = true
        colorView.heightAnchor.constraint(equalTo: colorView.widthAnchor).isActive = true
        return colorView
    }
    
    static func remainingSpheresLable() -> UILabel {
        let label = UILabel()
        label.text = "32"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }
    
    static func remainingInfoStackView(views: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
        return stackView
    }
    
    static func button(title: String, fontSize: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.tintColor = .white
        let buttonFont = UIFont.systemFont(ofSize: fontSize)
        button.titleLabel?.font = buttonFont
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 5
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return button
    }
}
