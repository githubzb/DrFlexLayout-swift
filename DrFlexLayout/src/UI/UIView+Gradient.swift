//
//  UIView+Gradient.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/18.
//

import UIKit

private var kDrGradientLayerAssociatedObjectHandle = 80_601_718

extension UIView {
    
    var dr_gradientLayer: CAGradientLayer {
        if let gradientLayer = objc_getAssociatedObject(self, &kDrGradientLayerAssociatedObjectHandle) as? CAGradientLayer {
            return gradientLayer
        }else{
            let gradientLayer = CAGradientLayer()
            objc_setAssociatedObject(self,
                                     &kDrGradientLayerAssociatedObjectHandle,
                                     gradientLayer,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return gradientLayer
        }
    }
    
    var dr_useGradient: Bool {
        if let _ = objc_getAssociatedObject(self, &kDrGradientLayerAssociatedObjectHandle) as? CAGradientLayer {
            return true
        }
        return false
    }
    
    func dr_setGradientStyle(_ style: DrGradientStyle) {
        let gradientLayer = dr_gradientLayer
        gradientLayer.removeFromSuperlayer()
        gradientLayer.frame = bounds
        gradientLayer.dr_setStyle(style)
        self.layer.addSublayer(gradientLayer)
    }
    
}

extension CAGradientLayer{
    
    func dr_setStyle(_ style: DrGradientStyle) {
        if let colors = style.colors {
            self.colors = colors
        }
        if let locations = style.locations {
            self.locations = locations
        }
        if let startPoint = style.startPoint {
            self.startPoint = startPoint
        }
        if let endPoint = style.endPoint {
            self.endPoint = endPoint
        }
        if let type = style.type {
            self.type = type
        }
    }
}
