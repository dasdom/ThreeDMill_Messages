//  Created by dasdom on 02.06.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import Foundation

struct TutorialItem {
    let text: String
    let afterMillText: String?
    let afterDoneText: String?
    let url: URL?
    let continueAfterMill: Bool
    let continueAfterDone: Bool
    
    init(text: String, afterMillText: String? = nil, afterDoneText: String? = nil, url: URL? = nil, continueAfterMill: Bool = false, continueAfterDone: Bool = true) {
        
        self.text = text
        self.afterMillText = afterMillText
        self.afterDoneText = afterDoneText
        self.url = url
        self.continueAfterMill = continueAfterMill
        self.continueAfterDone = continueAfterDone
    }
}
