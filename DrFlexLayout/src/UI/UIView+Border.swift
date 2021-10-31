//
//  UIView+Border.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/31.
//

import UIKit

private var kDrBorderLayerAssociatedObjectHandle = 80_711_710

extension UIView {
    
    var dr_borderLayer: CAShapeLayer {
        if let borderLayer = objc_getAssociatedObject(self, &kDrBorderLayerAssociatedObjectHandle) as? CAShapeLayer {
            return borderLayer
        }else{
            let borderLayer = CAShapeLayer()
            objc_setAssociatedObject(self,
                                     &kDrBorderLayerAssociatedObjectHandle,
                                     borderLayer,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return borderLayer
        }
    }
    
    func dr_setBorderStyle(_ style: DrBorderStyle){
        
    }
}
