//
//  DrScrollViewTouchHook.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/12/4.
//

import UIKit

public protocol DrScrollViewTouchHook: AnyObject {
    func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool
    func touchesShouldCancel(in view: UIView) -> Bool
}
