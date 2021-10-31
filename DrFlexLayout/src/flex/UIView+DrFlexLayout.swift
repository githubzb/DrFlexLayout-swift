//
//  UIView+DrFlexLayout.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/18.
//

import UIKit

private var kDrFlexLayoutAssociatedObjectHandle = 70_301_718

extension UIView {
    
    public var dr_flex: DrFlex {
        if let flex = objc_getAssociatedObject(self, &kDrFlexLayoutAssociatedObjectHandle) as? DrFlex {
            return flex
        } else {
            let flex = DrFlex(view: self)
            objc_setAssociatedObject(self,
                                     &kDrFlexLayoutAssociatedObjectHandle,
                                     flex,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return flex
        }
    }
}
