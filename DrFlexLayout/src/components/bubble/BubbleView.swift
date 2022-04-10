//
//  BubbleView.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/4/10.
//

import UIKit

open class BubbleView: UIView {

    /// 箭头的圆角半径
    open var arrowRadius: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    /// 箭头的尺寸
    open var arrowSize: CGSize = CGSize(width: 26, height: 12) {
        didSet {
            self.setNeedsLayout()
        }
    }
    /// 箭头方向
    open var arrowDirection: ArrowDirection = .bottom {
        didSet {
            self.setNeedsLayout()
        }
    }
    /// 箭头的相对位置（取值范围：[0, 1]，0.5：表示居中）
    open var arrowPosition: CGFloat = 0.5 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let mask = BubbleMaskLayer(arrowSize: arrowSize,
                                   arrowDirection: arrowDirection,
                                   arrowPosition: arrowPosition,
                                   arrowRadius: arrowRadius)
        mask.cornerRadius = layer.cornerRadius
        mask.frame = bounds
        layer.mask = mask
    }
}
