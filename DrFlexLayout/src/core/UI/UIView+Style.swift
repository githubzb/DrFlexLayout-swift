//
//  UIView+Style.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/11/7.
//

import UIKit

extension UIView {
    
    private struct AssociatedKeys {
        static var style = "dr_style"
        static var oldStyle = "dr_oldStyle"
        static var oldFrame = "dr_old_frame"
        static var gradientLayer = "dr_gradientLayer"
        static var roundLayer = "dr_roundLayer"
        static var borderLayer = "dr_borderLayer"
        static var backgroundLayer = "dr_backgroundLayer"
    }
    
    var dr_style: DrStyle? {
        set {
            if let style = dr_style, style == newValue { return }
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.style,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.style) as? DrStyle
        }
    }
    
    var dr_oldStyle: DrStyle? {
        set {
            if let style = dr_oldStyle, style == newValue { return }
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.oldStyle,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.oldStyle) as? DrStyle
        }
    }
    
    var dr_oldFrame: CGRect? {
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.oldFrame,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.oldFrame) as? CGRect
        }
    }
    
    var dr_gradientLayer: CAGradientLayer? {
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.gradientLayer,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.gradientLayer) as? CAGradientLayer
        }
    }
    
    var dr_roundLayer: CAShapeLayer? {
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.roundLayer,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.roundLayer) as? CAShapeLayer
        }
    }
    
    var dr_borderLayer: CAShapeLayer? {
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.borderLayer,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.borderLayer) as? CAShapeLayer
        }
    }
    
    var dr_backgroundLayer: CALayer? {
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.backgroundLayer,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.backgroundLayer) as? CALayer
        }
    }
    
}


extension UIView {
    
    /// 根据style，构建UI
    public func dr_buildStyle(style: DrStyle) {
        dr_style = style
        dr_buildStyle()
    }
    
    func dr_buildStyle() {
        if dr_oldStyle == nil && dr_style == nil { return }
        if let oldStyle = dr_oldStyle,
            let newStyle = dr_style, oldStyle == newStyle,
            let oldFrame = dr_oldFrame, oldFrame == bounds {
            return
        }
        dr_oldStyle = dr_style
        dr_oldFrame = bounds
        if let round = dr_oldStyle?.round, !round.isSameRadius {
            resetStyleByOther(round: round)
        }else {
            resetStyleBySystem()
        }
    }
    
    // 采用特殊方法实现
    private func resetStyleByOther(round: DrRoundStyle) {
        let style = dr_oldStyle
        // 渐变
        if let gradient = style?.gradient {
            if self.dr_gradientLayer == nil {
                self.dr_gradientLayer = CAGradientLayer()
                self.layer.addSublayer(self.dr_gradientLayer!)
            }
            self.dr_gradientLayer?.frame = bounds
            self.dr_gradientLayer?.locations = gradient.locations
            self.dr_gradientLayer?.colors = gradient.colors
            if let start = gradient.startPoint {
                self.dr_gradientLayer?.startPoint = start
            }
            if let end = gradient.endPoint {
                self.dr_gradientLayer?.endPoint = end
            }
            if let type = gradient.type {
                self.dr_gradientLayer?.type = type
            }
        }else{
            self.dr_gradientLayer?.removeFromSuperlayer()
            self.dr_gradientLayer = nil
        }
        // 边框
        self.layer.borderColor = nil
        self.layer.borderWidth = 0
        if let border = style?.border {
            if self.dr_borderLayer == nil {
                self.dr_borderLayer = CAShapeLayer()
            }
            self.dr_borderLayer?.removeFromSuperlayer()
            if self.dr_gradientLayer == nil {
                // 不存在渐变
                self.layer.addSublayer(self.dr_borderLayer!)
            }else {
                // 存在渐变
                self.dr_gradientLayer?.addSublayer(self.dr_borderLayer!)
            }
            let rect = bounds.insetBy(dx: border.width, dy: border.width)
            let tl = round.topLeftRadius ?? 0
            let tr = round.topRightRadius ?? 0
            let bl = round.bottomLeftRadius ?? 0
            let br = round.bottomRightRadius ?? 0
            let borderPath = UIBezierPath.dr_bezierPath(rect: CGRect(origin: .zero, size: rect.size),
                                                        inset: CGPoint(x: border.width * 0.5, y: border.width * 0.5),
                                                        topLeft: tl,
                                                        topRight: tr,
                                                        bottomLeft: bl,
                                                        bottomRight: br)
            self.dr_borderLayer?.lineWidth = border.width
            self.dr_borderLayer?.fillColor = UIColor.clear.cgColor
            self.dr_borderLayer?.strokeColor = border.color.cgColor
            self.dr_borderLayer?.frame = rect
            self.dr_borderLayer?.path = borderPath.cgPath
            
        }else{
            self.dr_borderLayer?.removeFromSuperlayer()
            self.dr_borderLayer = nil
        }
        
        // 圆角
        self.layer.cornerRadius = 0
        self.layer.masksToBounds = false
        if self.dr_roundLayer == nil {
            self.dr_roundLayer = CAShapeLayer()
        }
        self.dr_roundLayer?.frame = bounds
        let tl = round.topLeftRadius ?? 0
        let tr = round.topRightRadius ?? 0
        let bl = round.bottomLeftRadius ?? 0
        let br = round.bottomRightRadius ?? 0
        let roundPath = UIBezierPath.dr_bezierPath(rect: bounds,
                                                   topLeft: tl,
                                                   topRight: tr,
                                                   bottomLeft: bl,
                                                   bottomRight: br)
        self.dr_roundLayer?.path = roundPath.cgPath
        if self.dr_gradientLayer == nil {
            if self.dr_backgroundLayer == nil {
                self.dr_backgroundLayer = CALayer()
            }
            if let bgColor = backgroundColor {
                self.dr_backgroundLayer?.backgroundColor = bgColor.cgColor
                self.backgroundColor = nil
            }
            self.dr_backgroundLayer?.removeFromSuperlayer()
            self.layer.insertSublayer(self.dr_backgroundLayer!, at: 0)
            self.dr_backgroundLayer?.frame = bounds
            self.dr_backgroundLayer?.mask = self.dr_roundLayer
        }else{
            // 此时不需要backgroundLayer了
            if let bgColor = self.dr_backgroundLayer?.backgroundColor {
                self.backgroundColor = UIColor(cgColor: bgColor)
            }
            self.dr_backgroundLayer?.removeFromSuperlayer()
            self.dr_backgroundLayer = nil
            self.layer.mask = nil
            self.dr_gradientLayer?.mask = self.dr_roundLayer
        }
        
        // 阴影
        self.layer.shadowColor = style?.shadow?.color.cgColor
        self.layer.shadowRadius = style?.shadow?.blurRadius ?? 0
        self.layer.shadowOffset = style?.shadow?.offset ?? .zero
        self.layer.shadowOpacity = Float(style?.shadow?.opacity ?? 0)
        if let spread = style?.shadow?.spreadRadius {
            // 扩展半径
            let rect = bounds.insetBy(dx: -spread, dy: -spread)
            self.layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }else{
            self.layer.shadowPath = nil
        }
    }
    
    // 使用系统方法实现
    private func resetStyleBySystem() {
        let style = dr_oldStyle
        self.dr_backgroundLayer?.removeFromSuperlayer()
        self.dr_backgroundLayer = nil
        self.dr_roundLayer?.removeFromSuperlayer()
        self.dr_roundLayer = nil
        self.dr_borderLayer?.removeFromSuperlayer()
        self.dr_borderLayer = nil
        self.layer.masksToBounds = false
        // 画渐变
        if let gradient = style?.gradient {
            if self.dr_gradientLayer == nil {
                self.dr_gradientLayer = CAGradientLayer()
                self.layer.addSublayer(self.dr_gradientLayer!)
            }
            self.dr_gradientLayer?.frame = bounds
            self.dr_gradientLayer?.locations = gradient.locations
            self.dr_gradientLayer?.colors = gradient.colors
            if let start = gradient.startPoint {
                self.dr_gradientLayer?.startPoint = start
            }
            if let end = gradient.endPoint {
                self.dr_gradientLayer?.endPoint = end
            }
            if let type = gradient.type {
                self.dr_gradientLayer?.type = type
            }
        }else{
            self.dr_gradientLayer?.removeFromSuperlayer()
            self.dr_gradientLayer = nil
        }
        // 画圆角
        if let round = style?.round {
            self.layer.cornerRadius = round.sameRadius ?? 0
            if let gradientLayer = self.dr_gradientLayer {
                gradientLayer.cornerRadius = round.sameRadius ?? 0
            }
        }else{
            self.layer.cornerRadius = 0
            if let gradientLayer = self.dr_gradientLayer {
                gradientLayer.cornerRadius = 0
            }
        }
        // 画边框
        self.layer.borderWidth = style?.border?.width ?? 0
        self.layer.borderColor = style?.border?.color.cgColor
        // 画阴影
        self.layer.shadowColor = style?.shadow?.color.cgColor
        self.layer.shadowRadius = style?.shadow?.blurRadius ?? 0
        self.layer.shadowOffset = style?.shadow?.offset ?? .zero
        self.layer.shadowOpacity = Float(style?.shadow?.opacity ?? 0)
        if let spread = style?.shadow?.spreadRadius {
            // 扩展半径
            let rect = bounds.insetBy(dx: -spread, dy: -spread)
            self.layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }else{
            self.layer.shadowPath = nil
        }
    }
}
