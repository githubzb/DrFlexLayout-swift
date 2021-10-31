//
//  UIBezierPath+Rounded.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/31.
//

import UIKit

fileprivate let kDrCircleControlPoint = 0.447715

extension UIBezierPath {
    
    static func dr_bezierPath(rect: CGRect, style: DrRoundStyle) -> UIBezierPath{
        if style.radius == nil && (style.topLeftRadius == nil || style.topRightRadius == nil || style.bottomLeftRadius == nil || style.bottomRightRadius == nil) {
            return UIBezierPath()
        }
        if style.isSameRadius {
            return UIBezierPath(roundedRect: rect, cornerRadius: style.sameRadius!)
        }
        let path = UIBezierPath()
        let topLeftVal = getValueOrZero(value: style.topLeftRadius, def: style.radius)
        path.move(to: CGPoint(x: rect.origin.x + topLeftVal, y: rect.origin.y))
        
        // +------------------+
        //  \\      top     //
        //   \\+----------+//
        let topRightVal = getValueOrZero(value: style.topRightRadius, def: style.radius)
        path.addLine(to: CGPoint(x: rect.maxX - topRightVal, y: rect.origin.y))
        if topRightVal > 0 {
            path.addCurve(to: CGPoint(x: rect.maxX, y: rect.origin.y + topRightVal),
                          controlPoint1: CGPoint(x: rect.maxX - topRightVal * kDrCircleControlPoint, y: rect.origin.y),
                          controlPoint2: CGPoint(x: rect.maxX, y: rect.origin.y + topRightVal * kDrCircleControlPoint))
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
        let bottomRightVal = getValueOrZero(value: style.bottomRightRadius, def: style.radius)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRightVal))
        if bottomRightVal > 0 {
            path.addCurve(to: CGPoint(x: rect.maxX - bottomRightVal, y: rect.maxY),
                          controlPoint1: CGPoint(x: rect.maxX, y: rect.maxY - bottomRightVal * kDrCircleControlPoint),
                          controlPoint2: CGPoint(x: rect.maxX - bottomRightVal * kDrCircleControlPoint, y: rect.maxY))
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
        let bottomLeftVal = getValueOrZero(value: style.bottomLeftRadius, def: style.radius)
        path.addLine(to: CGPoint(x: rect.origin.x + bottomLeftVal, y: rect.maxY))
        if bottomLeftVal > 0 {
            path.addCurve(to: CGPoint(x: rect.origin.x, y: rect.maxY - bottomLeftVal),
                          controlPoint1: CGPoint(x: rect.origin.x + bottomLeftVal * kDrCircleControlPoint, y: rect.maxY),
                          controlPoint2: CGPoint(x: rect.origin.x, y: rect.maxY - bottomLeftVal * kDrCircleControlPoint))
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
        path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + topLeftVal))
        if topLeftVal > 0 {
            path.addCurve(to: CGPoint(x: rect.origin.x + topLeftVal, y: rect.origin.y),
                          controlPoint1: CGPoint(x: rect.origin.x, y: rect.origin.y + topLeftVal * kDrCircleControlPoint),
                          controlPoint2: CGPoint(x: rect.origin.x + topLeftVal * kDrCircleControlPoint, y: rect.origin.y))
        }
        return path
    }
    
    private static func getValueOrZero(value: CGFloat?, def: CGFloat?) -> CGFloat {
        guard let value = value else {
            guard let `default` = def else { return 0 }
            return `default`
        }
        return value
    }
}
