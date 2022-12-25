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
import UIKit

public class DrTableDataSource<Item> {
    
    public typealias Element = DrSource<Item>
    
    public typealias CellBuilder = (_ item: Item, _ indexPath: IndexPath) -> UIView?
    public typealias HeaderFooterBuilder = (_ item: SourceSection<Item>, _ section: Int) -> UIView?
    public typealias CellCanEditer = (_ item: Item, _ indexPath: IndexPath) -> Bool
    public typealias CellEditingStyle = (_ item: Item, _ indexPath: IndexPath) -> UITableViewCell.EditingStyle
    public typealias CellEditCommiter = (_ item: Item, _ indexPath: IndexPath, _ type: UITableViewCell.EditingStyle) -> Void
    public typealias CellSwipeMenuHandler = (_ item: Item, _ indexPath: IndexPath, _ menuItemIndex: Int) -> Void
    public typealias CellCanMove = (_ item: Item, _ indexPath: IndexPath) -> Bool
    // 调整最终移动的位置（返回最终移动的位置）
    public typealias CellMoveTarget = (_ fromItem: Item, _ fromIndexPath: IndexPath, _ toItem: Item, _ toIndexPath: IndexPath) -> IndexPath
    // 最终从哪里移动到哪里
    public typealias CellDidMove = (_ fromItem: Item, _ fromIndexPath: IndexPath, _ toItem: Item, _ toIndexPath: IndexPath) -> Void
    
    private var source: Element?
    private var sourceId: UInt64 = 0
    private var swipeMenuItems: [DrSwipeMenuItem]?
    
    private var cellBuilder: CellBuilder?
    private var headerBuilder: HeaderFooterBuilder?
    private var footerBuilder: HeaderFooterBuilder?
    private var _cellClick = PublishRelay<(item: Item, indexPath: IndexPath)>()
    private var _cellCanEditer: CellCanEditer?
    private var _cellEditingStyle: CellEditingStyle?
    private var _cellEditCommiter: CellEditCommiter?
    private var _cellSwipeMenuHandler: CellSwipeMenuHandler?
    private var _cellCanMove: CellCanMove?
    private var _cellMoveTarget: CellMoveTarget?
    private var _cellDidMove: CellDidMove?
    
    /// cell点击事件
    public var cellClick: ControlEvent<(item: Item, indexPath: IndexPath)> {
        ControlEvent(events: _cellClick)
    }
    
    /// 是否允许编辑
    public func cellCanEdit(_ canEdit: @escaping CellCanEditer) {
        _cellCanEditer = canEdit
    }
    /// 编辑样式
    public func cellEditingStyle(_ style: @escaping CellEditingStyle) {
        _cellEditingStyle = style
    }
    /// 编辑提交操作
    public func cellEditCommit(_ commit: @escaping CellEditCommiter) {
        _cellEditCommiter = commit
    }
    
    /// 添加cell的左滑菜单（与cellEditCommit不能同时使用，iOS 11开始可用）
    public func addCellSwipeMenu(items: [DrSwipeMenuItem], _ handler: @escaping CellSwipeMenuHandler) {
        self.swipeMenuItems = items
        self._cellSwipeMenuHandler = handler
    }
    
    /// 是否允许移动
    public func cellCanMove(_ canMove: @escaping CellCanMove) {
        self._cellCanMove = canMove
    }
    /// 调整移动目标地址
    public func cellMoveTarget(_ moveTarget: @escaping CellMoveTarget) {
        self._cellMoveTarget = moveTarget
    }
    /// 最终移动位置
    public func cellDidMove(_ didMove: @escaping CellDidMove) {
        self._cellDidMove = didMove
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
            
        case let .insertRows(section, insertIndex, rowCount):
            table.insertRows(rowsCount: rowCount, section: section, at: insertIndex)
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
        table.canEditRow(self) { target, indexPath in
            guard let canEditer = target._cellCanEditer,
                  let item = target.source?.item(row: indexPath.row, section: indexPath.section) else {
                return false
            }
            return canEditer(item, indexPath)
        }
        table.editingStyle(self) { target, indexPath in
            guard let editerStyle = target._cellEditingStyle,
                  let item = target.source?.item(row: indexPath.row, section: indexPath.section) else {
                return .none
            }
            return editerStyle(item, indexPath)
        }
        table.titleForDeleteConfirmationButton(self) { target, indexPath in
            return "删除"
        }
        table.commitEditing(self) { target, style, indexPath in
            guard let commit = target._cellEditCommiter,
                  let item = target.source?.item(row: indexPath.row, section: indexPath.section) else {
                return
            }
            commit(item, indexPath, style)
        }
        if #available(iOS 11.0, *) {
            table.trailingSwipeActionsForRowAt(self) { target, indexPath in
                guard let menuItems = target.swipeMenuItems, menuItems.count > 0,
                      let item = target.source?.item(row: indexPath.row, section: indexPath.section) else {
                    return nil
                }
                let handler = target._cellSwipeMenuHandler!
                let actions = menuItems.enumerated().map { (idx ,menuItem) -> UIContextualAction in
                    let action = UIContextualAction(style: .normal, title: menuItem.title) { _, _, commit in
                        handler(item, indexPath, idx)
                        commit(true)
                    }
                    action.backgroundColor = menuItem.backgroundColor
                    action.image = menuItem.image
                    return action
                }
                return UISwipeActionsConfiguration(actions: actions)
            }
        }
        table.canMoveRow(self) { target, indexPath in
            guard let canMove = target._cellCanMove,
                  let item = target.source?.item(row: indexPath.row, section: indexPath.section) else {
                return false
            }
            return canMove(item, indexPath)
        }
        table.targetIndexPathForMove(self) { target, from, to in
            guard let moveTarget = target._cellMoveTarget,
                  let fromItem = target.source?.item(row: from.row, section: from.section),
                  let toItem = target.source?.item(row: to.row, section: to.section) else {
                      return to
                  }
            return moveTarget(fromItem, from, toItem, to)
        }
        table.moveRow(self) { target, from, to in
            guard let didMove = target._cellDidMove,
                  let fromItem = target.source?.item(row: from.row, section: from.section),
                  let toItem = target.source?.item(row: to.row, section: to.section) else {
                      return
                  }
            didMove(fromItem, from, toItem, to)
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


/// cell侧滑菜单
public struct DrSwipeMenuItem {
    public let title: String?
    public let backgroundColor: UIColor
    public let image: UIImage?
    
    public init(title: String, backgroundColor: UIColor = .lightGray) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.image = nil
    }
    public init(image: UIImage?, backgroundColor: UIColor = .white) {
        self.title = nil
        self.backgroundColor = backgroundColor
        self.image = image
    }
}
