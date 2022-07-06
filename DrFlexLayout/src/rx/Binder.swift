//
//  Binder.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/7/6.
//

import Foundation
import RxSwift

extension DrFlex: ReactiveCompatible {}
extension Reactive where Base: DrFlex {
    
    public var display: Binder<Bool> {
        Binder(base) { (flex, display) in
            flex.display(display)
        }
    }
    
    public var isHidden: Binder<Bool> {
        Binder(base) { (flex, isHidden) in
            flex.isHidden = isHidden
        }
    }
}
