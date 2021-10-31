//
//  DrFlexLayout+Private.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/18.
//

import UIKit

extension DrFlex {
    
    func valueOrUndefined(_ value: CGFloat?) -> YGValue {
        if let value = value {
            return YGValue(value)
        } else {
            return YGValueUndefined
        }
    }
    
    func valueOrAuto(_ value: CGFloat?) -> YGValue {
        if let value = value {
            return YGValue(value)
        } else {
            return YGValueAuto
        }
    }
}
