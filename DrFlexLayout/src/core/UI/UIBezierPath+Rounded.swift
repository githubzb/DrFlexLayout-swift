//
//  UIBezierPath+Rounded.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/31.
//

import UIKit

fileprivate let kDrCircleControlPoint = 0.447715

extension UIBezierPath {
    
    public static func dr_bezierPath(rect: CGRect,
                                     inset: CGPoint = .zero,
                                     topLeft topLeftRadius: CGFloat,
                                     topRight topRightRadius: CGFloat,
                                     bottomLeft bottomLeftRadius: CGFloat,
                                     bottomRight bottomRightRadius: CGFloat) -> UIBezierPath {
        if topLeftRadius.isNaN || topRightRadius.isNaN || bottomLeftRadius.isNaN || bottomRightRadius.isNaN {
            return UIBezierPath(rect: rect)
        }
        let x = rect.origin.x - inset.x
        let y = rect.origin.y - inset.y
        let maxX = rect.maxX + inset.x
        let maxY = rect.maxY + inset.y
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x - inset.x + topLeftRadius, y: y))
        
        // +------------------+
        //  \\      top     //
        //   \\+----------+//
        path.addLine(to: CGPoint(x: maxX - topRightRadius, y: y))
        if topRightRadius > 0 {
            path.addCurve(to: CGPoint(x: maxX, y: y + topRightRadius),
                          controlPoint1: CGPoint(x: maxX + inset.x - topRightRadius * kDrCircleControlPoint, y: y),
                          controlPoint2: CGPoint(x: maxX, y: y - inset.y + topRightRadius * kDrCircleControlPoint))
        }
        // +------------------+
        //  \\     top      //|
        //   \\+----------+// |
        //                |   |
        //                |rig|
        //                |ht |
        //                |   |
        //                 \\ |
        //                  \\|
        
        path.addLine(to: CGPoint(x: maxX, y: maxY - bottomRightRadius))
        if bottomRightRadius > 0 {
            path.addCurve(to: CGPoint(x: maxX - bottomRightRadius, y: maxY),
                          controlPoint1: CGPoint(x: maxX, y: maxY + inset.y - bottomRightRadius * kDrCircleControlPoint),
                          controlPoint2: CGPoint(x: maxX + inset.x - bottomRightRadius * kDrCircleControlPoint, y: maxY))
        }
        
        // +------------------+
        //  \\     top      //|
        //   \\+----------+// |
        //                |   |
        //                |rig|
        //                |ht |
        //                |   |
        //   //+----------+\\ |
        //  //    bottom    \\|
        // +------------------+
        
        path.addLine(to: CGPoint(x: x + bottomLeftRadius, y: maxY))
        if bottomLeftRadius > 0 {
            path.addCurve(to: CGPoint(x: x, y: maxY - bottomLeftRadius),
                          controlPoint1: CGPoint(x: x - inset.x + bottomLeftRadius * kDrCircleControlPoint, y: maxY),
                          controlPoint2: CGPoint(x: x, y: maxY + inset.y - bottomLeftRadius * kDrCircleControlPoint))
        }
        
        // +------------------+
        // |\\     top      //|
        // | \\+----------+// |
        // |   |          |   |
        // |lef|          |rig|
        // |t  |          |ht |
        // |   |          |   |
        // | //+----------+\\ |
        // |//    bottom    \\|
        // +------------------+
        path.addLine(to: CGPoint(x: x, y: y + inset.y + topLeftRadius))
        if topLeftRadius > 0 {
            path.addCurve(to: CGPoint(x: x + topLeftRadius, y: y),
                          controlPoint1: CGPoint(x: x, y: y - inset.y + topLeftRadius * kDrCircleControlPoint),
                          controlPoint2: CGPoint(x: x - inset.x + topLeftRadius * kDrCircleControlPoint, y: y))
        }
        return path
    }
    
}
