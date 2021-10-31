//
//  DrStyle.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/31.
//

import UIKit

/// 视图样式集合
public struct DrStyle {
    /// 圆角半径
    public var round: DrRoundStyle? = nil
    /// 边框
    public var border: DrBorderStyle? = nil
    /// 阴影
    public var shadow: DrShadowStyle? = nil
    /// 背景色
    public var background: UIColor? = nil
    /// 渐变背景色
    public var gradient: DrGradientStyle? = nil
    
    public init(){}
    
    public init(cornerRadius: CGFloat) {
        self.round = DrRoundStyle(radius: cornerRadius)
    }
    
    public init(border: CGFloat, color: UIColor) {
        self.border = DrBorderStyle(width: border, color: color)
    }
    
    public init(shadow: DrShadowStyle) {
        self.shadow = shadow
    }
    
    public init(gradient: DrGradientStyle) {
        self.gradient = gradient
    }
}

/// 边框样式
public struct DrBorderStyle {
    /// 边框宽度
    public var width: CGFloat? = nil
    /// 左边框宽度
    public var leftWidth: CGFloat? = nil
    /// 上边框宽度
    public var topWidth: CGFloat? = nil
    /// 右边框宽度
    public var rightWidth: CGFloat? = nil
    /// 下边框宽度
    public var bottomWidth: CGFloat? = nil
    /// 边框颜色
    public var color: UIColor
    
    public init(width: CGFloat, color: UIColor) {
        self.width = width
        self.color = color
    }
    
    public init(edge: UIEdgeInsets, color: UIColor) {
        leftWidth = edge.left
        topWidth = edge.top
        rightWidth = edge.right
        bottomWidth = edge.bottom
        self.color = color
    }
    
    public init(horizontal: CGFloat? = nil, vertical: CGFloat? = nil, color: UIColor){
        leftWidth = horizontal
        rightWidth = horizontal
        topWidth = vertical
        bottomWidth = vertical
        self.color = color
    }
}

/// 圆角样式
public struct DrRoundStyle {
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
        guard let topleft = topLeftRadius else { return nil }
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
public struct DrShadowStyle {
    
    /// 阴影颜色
    public var color: UIColor
    /// 对应设计工具中的x和y
    public var offset: CGSize
    /// 阴影的模糊半径（模糊度）
    public var blurRadius: CGFloat
    /// 阴影的透明度
    public var opacity: CGFloat
    /// 阴影的扩散半径
    public var spreadRadius: CGFloat
    
    public init(offset: CGSize, blurRadius: CGFloat, spreadRadius: CGFloat = 0, color: UIColor, opacity: CGFloat = 1){
        self.offset = offset
        self.blurRadius = blurRadius
        self.spreadRadius = spreadRadius
        self.color = color
        self.opacity = opacity
    }
}

/// 渐变背景色
public struct DrGradientStyle {
    public var colors: [CGColor]? = nil
    public var locations: [NSNumber]? = nil
    public var startPoint: CGPoint? = nil
    public var endPoint: CGPoint? = nil
    public var type: CAGradientLayerType? = nil
    
    public init(){}
}
