//
//  UIView+Shadow.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/31.
//

import UIKit

extension UIView {
    
    func dr_setShadowStyle(_ style: DrShadowStyle) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = style.color.cgColor
        self.layer.shadowOffset = style.offset
        self.layer.shadowOpacity = Float(style.opacity)
        if style.spreadRadius > 0 {
            let rect = bounds.insetBy(dx: -style.spreadRadius, dy: -style.spreadRadius)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: style.blurRadius)
            self.layer.shadowPath = path.cgPath
        }else{
            self.layer.shadowRadius = style.blurRadius
            self.layer.shadowPath = nil
        }
    }
}
