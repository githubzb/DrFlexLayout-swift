//
//  DrFlexTableView+rx.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/3/31.
//

import UIKit
import RxSwift
import ObjectiveC.runtime

extension Reactive where Base: DrFlexTableView {
    
    private var identifier: UnsafeRawPointer {
        let delegateIdentifier = ObjectIdentifier(base)
        let integerIdentifier = Int(bitPattern: delegateIdentifier)
        return UnsafeRawPointer(bitPattern: integerIdentifier)!
    }
    
    public var dataSource: DrTableDataSource {
        if let ds = objc_getAssociatedObject(base, identifier) as? DrTableDataSource {
            return ds
        }
        let ds = DrTableDataSource()
        objc_setAssociatedObject(base, identifier, ds, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return ds
    }
    
    public func items(dataSource: DrTableDataSource) {
        
    }
}
