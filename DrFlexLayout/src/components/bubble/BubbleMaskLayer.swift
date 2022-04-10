//
//  BubbleMaskLayer.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/4/10.
//

import UIKit

/// 箭头方向
public enum ArrowDirection: Int {
    case right = 0
    case bottom = 1
    case left = 2
    case top = 3
}

/// 气泡蒙层
public class BubbleMaskLayer: CAShapeLayer {
    
    /// 箭头的圆角半径
    public let arrowRadius: CGFloat
    /// 箭头的尺寸
    public let arrowSize: CGSize
    /// 箭头方向
    public let arrowDirection: ArrowDirection
    /// 箭头的相对位置（0.5：表示居中）
    public let arrowPosition: CGFloat
    
    /**
     初始化气泡蒙层
     
     - Parameter arrowSize: 箭头大小（默认：30x12）
     - Parameter arrowDirection: 箭头方向（默认：.bottom）
     - Parameter arrowPosition: 箭头相对位置（范围：[0, 1]，默认：0.5，即：居中）
     - Parameter arrowRadius: 箭头圆角半径（默认：0）
     */
    public init(arrowSize: CGSize = CGSize(width: 30, height: 12),
         arrowDirection: ArrowDirection = .bottom,
         arrowPosition: CGFloat = 0.5,
         arrowRadius: CGFloat = 0) {
        self.arrowSize = arrowSize
        self.arrowDirection = arrowDirection
        self.arrowPosition = arrowPosition
        self.arrowRadius = arrowRadius
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var frame: CGRect {
        didSet {
            path = _bubblePath
        }
    }
    
    // 绘制气泡的路径
    private var _bubblePath: CGPath {
        let path = CGMutablePath()
        let points = _bubblePoints
        path.move(to: points[6])
        var pointA = CGPoint.zero
        var pointB = CGPoint.zero
        var radius: CGFloat = 0
        var count: Int = 0
        
        while count < 7 {
            // 整个过程需要画七个圆角(矩形框的四个角和箭头处的三个角)，所以分为七个步骤
            
            // 箭头处的三个圆角和矩形框的四个圆角不一样
            radius = count < 3 ? arrowRadius : cornerRadius
            
            pointA = points[count]
            pointB = points[(count + 1) % 7]
            // 画矩形框最后一个角的时候，pointB就是points[0]
            path.addArc(tangent1End: pointA, tangent2End: pointB, radius: radius)
            count = count + 1
        }
        path.closeSubpath()
        return path
    }
    
    // 绘制气泡的点
    private var _bubblePoints: [CGPoint] {
        // 先确定箭头的三个点
        var beginPoint = CGPoint.zero // 箭头的起始位置点
        var topPoint = CGPoint.zero // 箭头的顶点
        var endPoint = CGPoint.zero // 箭头结束位置点
        
        // 箭头顶点横纵坐标的取值范围
        let tpXRange = bounds.width - 2 * cornerRadius - arrowSize.width
        let tpYRange = bounds.height - 2 * cornerRadius -  arrowSize.width
        
        // 用于表示矩形框的位置和大小
        var rX: CGFloat = 0
        var rY: CGFloat = 0
        var rWidth = bounds.width
        var rHeight = bounds.height
        
        // 计算箭头的位置，以及调整矩形框的位置和大小
        switch arrowDirection {
            
        case .right: //箭头在右时
            topPoint = CGPoint(x: bounds.width, y: bounds.height / 2 + tpYRange * (arrowPosition - 0.5))
            beginPoint = CGPoint(x: topPoint.x - arrowSize.height, y:topPoint.y - arrowSize.width / 2 )
            endPoint = CGPoint(x: beginPoint.x, y: beginPoint.y + arrowSize.width)
            
            rWidth -= arrowSize.height
            
        case .bottom: //箭头在下时
            topPoint = CGPoint(x: bounds.width / 2 + tpXRange * (arrowPosition - 0.5), y: bounds.height)
            beginPoint = CGPoint(x: topPoint.x + arrowSize.width / 2, y:topPoint.y - arrowSize.height)
            endPoint = CGPoint(x: beginPoint.x - arrowSize.width, y: beginPoint.y)
            
            rHeight -= arrowSize.height
            
        case .left: //箭头在左时
            topPoint = CGPoint(x: 0, y: bounds.height / 2 + tpYRange * (arrowPosition - 0.5))
            beginPoint = CGPoint(x: topPoint.x + arrowSize.height, y: topPoint.y + arrowSize.width / 2)
            endPoint = CGPoint(x: beginPoint.x, y: beginPoint.y - arrowSize.width)
            
            rX = arrowSize.height
            rWidth -= arrowSize.height
            
        case .top: //箭头在上时
            topPoint = CGPoint(x: bounds.width / 2 + tpXRange * (arrowPosition - 0.5), y: 0)
            beginPoint = CGPoint(x: topPoint.x - arrowSize.width / 2, y: topPoint.y + arrowSize.height)
            endPoint = CGPoint(x: beginPoint.x + arrowSize.width, y: beginPoint.y)
            
            rY = arrowSize.height
            rHeight -= arrowSize.height
        }

        // 先把箭头的三个点放进关键点数组中
        var points = [beginPoint, topPoint, endPoint]
        
        //确定圆角矩形的四个点
        let bottomRight = CGPoint(x: rX + rWidth, y: rY + rHeight); //右下角的点
        let bottomLeft = CGPoint(x: rX, y: rY + rHeight);
        let topLeft = CGPoint(x: rX, y: rY);
        let topRight = CGPoint(x: rX + rWidth, y: rY);
        
        //先放在一个临时数组, 放置顺序跟下面紧接着的操作有关
        let rectPoints = [bottomRight, bottomLeft, topLeft, topRight]
        
        // 绘制气泡形状的时候，从箭头开始,顺时针地进行
        // 箭头向右时，画完箭头之后会先画到矩形框的右下角
        // 所以此时先把矩形框右下角的点放进关键点数组,其他三个点按顺时针方向添加
        // 箭头在其他方向时，以此类推
        
        var rectPointIndex: Int = arrowDirection.rawValue
        for _ in 0...3 {
            points.append(rectPoints[rectPointIndex])
            rectPointIndex = (rectPointIndex + 1) % 4
        }
        
        return points
    }
}
