//
//  DrTableDataSource.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/3/30.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

public class DrTableDataSource<Item> {
    
    public typealias Element = DrFlexLayout.Source<Item>
    
    public typealias CellBuilder = (_ item: Item, _ indexPath: IndexPath) -> UIView
    public typealias HeaderFooterBuilder = (_ item: SourceSection<Item>, _ section: Int) -> UIView
    
    private var source: Element?
    private var sourceId: UInt64 = 0
    
    private var cellBuilder: CellBuilder?
    private var headerBuilder: HeaderFooterBuilder?
    private var footerBuilder: HeaderFooterBuilder?
    private var _cellClick = PublishRelay<(item: Item, indexPath: IndexPath)>()
    
    /// cell点击事件
    public var cellClick: ControlEvent<(item: Item, indexPath: IndexPath)> {
        ControlEvent(events: _cellClick)
    }
    
    public init(cellBuilder: @escaping CellBuilder,
                headerBuilder: HeaderFooterBuilder? = nil,
                footerBuilder: HeaderFooterBuilder? = nil) {
        self.cellBuilder = cellBuilder
        self.headerBuilder = headerBuilder
        self.footerBuilder = footerBuilder
    }
    
    // 处理数据的刷新
    private func handlerTable(_ table: DrFlexTableView, element: Element) {
        guard self.source == nil || sourceId != element.id else {
            return
        }
        source = element
        sourceId = element.id
        
        switch element.operate {
        case .`init`:
            table.reload()
            
        case let .refreshSection(section):
            table.refreshSections(IndexSet(integer: section), needLayout: true)
            
        case let .refreshSections(sections):
            table.refreshSections(IndexSet(sections), needLayout: true)
            
        case let .refreshRow(section, row):
            table.refreshRows(at: [IndexPath(row: row, section: section)], needLayout: true)
            
        case let .refreshRows(section, rows):
            table.refreshRows(at: rows.map({IndexPath(row: $0, section: section)}), needLayout: true)
            
        case let .reloadSection(section):
            table.reloadSections(IndexSet(integer: section))
            
        case let .reloadSections(sections):
            table.reloadSections(IndexSet(sections))
            
        case let .reloadRow(section, row):
            table.reloadRows(at: [IndexPath(row: row, section: section)])
            
        case let .reloadRows(section, rows):
            table.reloadRows(at: rows.map({IndexPath(row: $0, section: section)}))
            
        case let .deleteRow(section, row):
            table.deleteRows(at: [IndexPath(row: row, section: section)])
            
        case let .deleteRows(section, rows):
            table.deleteRows(at: rows.map({IndexPath(row: $0, section: section)}))
            
        case let .loadMoreInSection(section):
            table.refreshSections(IndexSet(integer: section), needLayout: false)
            
        case .loadMore:
            table.refresh()
            
        case let .insertRows(section, insertIndex, rowCount, refreshAfter):
            table.insertRows(rowsCount: rowCount, section: section, at: insertIndex, afterNeedLayout: refreshAfter)
        }
    }
    
}

extension DrTableDataSource {
    
    func dataBind(table: DrFlexTableView, observedEvent: Event<Element>) {
        Binder<Element>(self){ (ds, el) in
            ds.handlerTable(table, element: el)
        }.on(observedEvent)
    }
    
    func bindTable(_ table: DrFlexTableView) {
        table.numberOfSections(self) {$0.source?.sections.count ?? 0}
        table.numberOfRowsInSection(self) {$0.source?.items(section: $1)?.count ?? 0}
        table.cellInit(self) { target, indexPath -> UIView? in
            guard let cellBuilder = target.cellBuilder,
                  let item = target.source?.item(row: indexPath.row, section: indexPath.section) else {
                return nil
            }
            return cellBuilder(item, indexPath)
        }
        table.cellUpdate(self) { target, cell, indexPath in
            if let v = cell as? DrTableCellUpdateable,
               let item = target.source?.item(row: indexPath.row, section: indexPath.section) {
                return v.updateItem(item: item, indexPath: indexPath)
            }
            return false
        }
        table.headerInit(self) { target, section -> UIView? in
            guard let headerBuilder = target.headerBuilder,
                  let item = target.source?.sections[section] else {
                return nil
            }
            return headerBuilder(item, section)
        }
        table.footerInit(self) { target, section in
            guard let footerBuilder = target.footerBuilder,
                  let item = target.source?.sections[section] else {
                return nil
            }
            return footerBuilder(item, section)
        }
        table.cellClick(self) { target, indexPath in
            guard let item = target.source?.item(row: indexPath.row, section: indexPath.section) else {
                return
            }
            target._cellClick.accept((item, indexPath))
        }
    }
}


public protocol DrTableCellUpdateable {
    
    func updateItem(item: Any, indexPath: IndexPath) -> Bool
}

public func convertItemType<T>(_ item: Any, type: T.Type) -> T {
    guard let item = item as? T else {
        fatalError("\(item) convert to \(type) fail.")
    }
    return item
}
