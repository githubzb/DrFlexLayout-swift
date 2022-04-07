//
//  DrPercent.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/18.
//

import UIKit

public struct DrPercent {
    let value: CGFloat
}

postfix operator %
public postfix func % (v: CGFloat) -> DrPercent {
    return DrPercent(value: v)
}

public postfix func % (v: Int) -> DrPercent {
    return DrPercent(value: CGFloat(v))
}

prefix operator -
public prefix func - (p: DrPercent) -> DrPercent {
    return DrPercent(value: -p.value)
}
