//
//  TestLayer.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2021/10/18.
//

import UIKit

class TestLayer: CAGradientLayer {
    
    var boxShadowRadius: CGFloat = 0
    var boxShadowColor: UIColor = .white
    var boxShadowOffset: CGSize = CGSize(width: 0, height: 0)
    var boxShadowOpacity: CGFloat = 0
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "boxShadowRadius" ||
            key == "boxShadowOffset" ||
            key == "boxShadowColor" ||
            key == "boxShadowOpacity" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func draw(in ctx: CGContext) {
        print("-----开始绘制")
        var radius = self.cornerRadius
        
        var rect = self.bounds
        if (self.borderWidth != 0) {
            rect = rect.insetBy(dx: self.borderWidth, dy: self.borderWidth)
            radius -= self.borderWidth
            radius = max(radius, 0)
        }
        
        ctx.setAllowsAntialiasing(true)
        ctx.setShouldAntialias(true)
        ctx.interpolationQuality = .high
        let colorspace = CGColorSpaceCreateDeviceRGB()
        
        let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        ctx.addPath(bezierPath.cgPath)
        ctx.clip()
        let outer = CGMutablePath()
        outer.addRect(rect.insetBy(dx: -1*rect.width, dy: -1*rect.height))
        outer.addPath(bezierPath.cgPath)
        outer.closeSubpath()
        var newComponents: [CGFloat] = []
        if let oldComponents = self.boxShadowColor.cgColor.components {
            let numberOfComponents = self.boxShadowColor.cgColor.numberOfComponents
            switch numberOfComponents {
            case 2:
                newComponents.append(oldComponents[0])
                newComponents.append(oldComponents[0])
                newComponents.append(oldComponents[0])
                newComponents.append(oldComponents[1] * self.boxShadowOpacity)
            case 4:
                newComponents.append(oldComponents[0])
                newComponents.append(oldComponents[1])
                newComponents.append(oldComponents[2])
                newComponents.append(oldComponents[3] * self.boxShadowOpacity)
            default :
                break
            }
        }
        
        var shadowColor: CGColor? = nil
        if let components = newComponents.withUnsafeBufferPointer({$0.baseAddress}),
           let shadowColorWithMultipliedAlpha = CGColor(colorSpace: colorspace, components: components){
            ctx.setFillColor(shadowColorWithMultipliedAlpha)
            shadowColor = shadowColorWithMultipliedAlpha
        }
        ctx.setShadow(offset: self.boxShadowOffset, blur: self.boxShadowRadius, color: shadowColor)
        ctx.addPath(outer)
        ctx.fillPath(using: .evenOdd)
    }
    
}
