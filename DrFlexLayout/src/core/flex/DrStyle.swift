//
//  DrStyle.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/31.
//

import UIKit

/// 视图样式集合
public struct DrStyle: Equatable {
    /// 圆角
    public var round: DrRoundStyle? = nil
    /// 边框
    public var border: DrBorderStyle? = nil
    /// 阴影
    public var shadow: DrShadowStyle? = nil
    /// 渐变背景色
    public var gradient: DrGradientStyle? = nil
    
    public init(){}
    
    public init(cornerRadius: CGFloat) {
        self.round = DrRoundStyle(radius: cornerRadius)
    }
    
    public init(border width: CGFloat, color: UIColor) {
        self.border = DrBorderStyle(width: width, color: color)
    }
    
    public init(shadow: DrShadowStyle) {
        self.shadow = shadow
    }
    
    public init(gradient: DrGradientStyle) {
        self.gradient = gradient
    }
    
}

/// 边框样式
public struct DrBorderStyle: Equatable {
    /// 边框宽度
    public var width: CGFloat
    /// 边框颜色
    public var color: UIColor
    
    public init(width: CGFloat, color: UIColor) {
        self.width = width
        self.color = color
    }
    
}

/// 圆角样式
public struct DrRoundStyle: Equatable {
    /// 半径
    public let radius: CGFloat?
    /// 左上角半径
    public let topLeftRadius: CGFloat?
    /// 右上角半径
    public let topRightRadius: CGFloat?
    /// 左下角半径
    public let bottomLeftRadius: CGFloat?
    /// 右下角半径
    public let bottomRightRadius: CGFloat?
    
    /// 是否各个半径相同
    public var isSameRadius: Bool {
        if let _ = radius {
            return true
        }
        guard let topleft = topLeftRadius,
              let topRight = topRightRadius,
              let bottomLeft = bottomLeftRadius,
              let bottomRight = bottomRightRadius else { return false }
        return topleft == topRight && topRight == bottomLeft && bottomLeft == bottomRight
    }
    
    /// 相同半径的值
    public var sameRadius: CGFloat? {
        if let radius = radius {
            return radius
        }
        guard isSameRadius, let topleft = topLeftRadius else { return nil }
        return topleft
    }
    
    public init(radius: CGFloat){
        self.radius = radius
        self.topLeftRadius = nil
        self.topRightRadius = nil
        self.bottomLeftRadius = nil
        self.bottomRightRadius = nil
    }
    
    public init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat){
        self.radius = nil
        self.topLeftRadius = topLeft
        self.topRightRadius = topRight
        self.bottomLeftRadius = bottomLeft
        self.bottomRightRadius = bottomRight
    }
    
}

/// 阴影样式
public struct DrShadowStyle: Equatable {
    
    /// 阴影颜色
    public var color: UIColor
    /// 对应设计工具中的x和y
    public var offset: CGSize
    /// 阴影的模糊半径（模糊度）
    public var blurRadius: CGFloat
    /// 阴影的透明度
    public var opacity: CGFloat
    /// 阴影的扩散半径
    public var spreadRadius: CGFloat?
    
    public init(offset: CGSize, blurRadius: CGFloat, spreadRadius: CGFloat? = nil, color: UIColor, opacity: CGFloat = 1){
        self.offset = offset
        self.blurRadius = blurRadius
        self.spreadRadius = spreadRadius
        self.color = color
        self.opacity = opacity
    }
}

/// 渐变背景色
public struct DrGradientStyle: Equatable {
    public var colors: [CGColor]? = nil
    public var locations: [NSNumber]? = nil
    public var startPoint: CGPoint? = nil
    public var endPoint: CGPoint? = nil
    public var type: CAGradientLayerType? = nil
    
    public init(){}
    public init(colors: [UIColor], locations: [Float]? = nil) {
        self.colors = colors.map({ $0.cgColor })
        if let locations = locations {
            self.locations = locations.map({ NSNumber(value: $0) })
        }
    }
}
