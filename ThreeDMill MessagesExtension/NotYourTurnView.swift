//  Created by dasdom on 31.12.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import UIKit

class NotYourTurnView: UIView {

    override init(frame: CGRect) {

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "It's not your turn."
        label.textColor = UIColor.yellow
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.brown
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
