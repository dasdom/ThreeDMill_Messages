//  Created by dasdom on 02.01.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import UIKit

class HelpView: UIView {
    
    private let debugTextView: UITextView
    
    var text: String? {
        return debugTextView.text
    }
    
    override init(frame: CGRect) {
        
        debugTextView = UITextView()
        debugTextView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: frame)
        
        addSubview(debugTextView)
        
        NSLayoutConstraint.activate([
            debugTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            debugTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            debugTextView.topAnchor.constraint(equalTo: topAnchor),
            debugTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with text: String?) {
        debugTextView.text = text
    }
}
