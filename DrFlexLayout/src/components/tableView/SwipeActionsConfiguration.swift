//
//  SwipeActionsConfiguration.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/12/25.
//

import UIKit

public struct DrSwipeActionsConfiguration {
    
    public let performsFirstActionWithFullSwipe: Bool
    public let actions: [Action]
    
    public init(actions: [Action], performsFirstActionWithFullSwipe: Bool = true) {
        self.performsFirstActionWithFullSwipe = performsFirstActionWithFullSwipe
        self.actions = actions
    }
}

extension DrSwipeActionsConfiguration {
    
    public struct Action {
        public let title: String
        public let backgroundColor: UIColor
        public let image: UIImage?
        public let handler: (_ completionHandler: (Bool) -> Void) -> Void
        
        public init(title: String, bgColor: UIColor = .white, image: UIImage? = nil, handler: @escaping (_ completionHandler: (Bool)->Void)-> Void) {
            self.title = title
            self.backgroundColor = bgColor
            self.image = image
            self.handler = handler
        }
    }
}
