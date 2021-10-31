//
//  UIView+Round.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/31.
//

import UIKit

extension UIView {
    
    var dr_shapeLayer: CAShapeLayer {
        if let shapeLayer = self.layer.mask as? CAShapeLayer {
            return shapeLayer
        }else{
            return CAShapeLayer()
        }
    }
    
    func dr_setRoundStyle(_ style: DrRoundStyle, masksToBounds: Bool = false) {
        if style.isSameRadius {
            self.layer.mask = nil
            self.layer.cornerRadius = style.sameRadius!
            self.layer.masksToBounds = masksToBounds
        }else{
            self.layer.cornerRadius = 0
            self.layer.masksToBounds = false
            let shapeLayer = dr_shapeLayer
            shapeLayer.path = UIBezierPath.dr_bezierPath(rect: bounds, style: style).cgPath
            self.layer.mask = shapeLayer
        }
    }
}
