//
//  DrFlexTableView+rx.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/3/31.
//

import UIKit
import RxSwift
import ObjectiveC.runtime
import RxCocoa

extension Reactive where Base: DrFlexTableView {
    
    private var identifier: UnsafeRawPointer {
        let delegateIdentifier = ObjectIdentifier(base)
        let integerIdentifier = Int(bitPattern: delegateIdentifier)
        return UnsafeRawPointer(bitPattern: integerIdentifier)!
    }
    
    /// 绑定数据源
    public func items<DataObservable: ObservableType,
                      Item>
    (_ dataSource: DrTableDataSource<Item>) ->
    (_ source: DataObservable) -> Disposable
    where DataObservable.Element == DrTableDataSource<Item>.Element {
        dataSource.bindTable(base)
        objc_setAssociatedObject(base, identifier, dataSource, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return { source in
            return source.asObservable()
                .observe(on: MainScheduler())
                .catch { err in
                    return .empty()
                }
                .subscribe { [weak table = self.base] (event) in
                    guard let table = table else {
                        return
                    }
                    dataSource.dataBind(table: table, observedEvent: event)
                }
        }
    }
    
    
    public var contentOffset: ControlProperty<CGPoint> {
        let behavior = _contentOffsetBehavior
        base.scrollDelegate.didScroll(behavior) { target, scrollView in
            target.accept(scrollView.contentOffset)
        }
        let binder = Binder<CGPoint>(base) { (table, offset) in
            table.contentOffset = offset
        }
        return ControlProperty(values: behavior, valueSink: binder)
    }
    
    private var _contentOffsetBehavior: BehaviorRelay<CGPoint> {
        if let behavior = objc_getAssociatedObject(base, DrKeys.contentOffsetKey) as? BehaviorRelay<CGPoint> {
            return behavior
        }
        let behavior = BehaviorRelay<CGPoint>(value: base.contentOffset)
        objc_setAssociatedObject(base, DrKeys.contentOffsetKey, behavior, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return behavior
    }
}


