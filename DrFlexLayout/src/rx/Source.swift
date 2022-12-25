//
//  Source.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/3/28.
//

import Foundation

public enum Operate {
    
    // 初始化
    case `init`
    // 刷新某个section
    case refreshSection(Int)
    // 刷新某组section
    case refreshSections([Int])
    // 刷新某行
    case refreshRow(section: Int, row: Int)
    // 刷新指定section下的多个行
    case refreshRows(section: Int, rows: [Int])
    // 重载某个section
    case reloadSection(Int)
    // 重载某组section
    case reloadSections([Int])
    // 重载某行
    case reloadRow(section: Int, row: Int)
    // 重载指定section下的多行
    case reloadRows(section: Int, rows: [Int])
    // 删除某行
    case deleteRow(section: Int, row: Int)
    // 删除某组行
    case deleteRows(section: Int, rows: [Int])
    // section中加载更多item
    case loadMoreInSection(Int)
    // 加载更多section
    case loadMore
    // 在section中指定位置插入指定行数
    case insertRows(section: Int, insertIndex: Int, rowCount: Int)
}



/// 数据源，对数据源的每个修改操作，都对应一个操作符。如果想批量处理，必须在performBatchUpdates的闭包中完成
public class DrSource<Item> {
    
    public typealias Section = SourceSection<Item>
    
    public private(set) var id: UInt64 = UInt64.min
    public private(set) var operate: Operate = .`init`
    
    public private(set) var sections: [Section]
    
    public init() {
        self.sections = []
    }
    
    public init(_ source: DrSource) {
        self.sections = source.sections
        source.updateId()
        self.id = source.id
    }
    
    public init(sections: [Section]) {
        self.sections = sections
        updateId()
    }
    
    public convenience init(items: [Item]?) {
        guard let items = items else {
            self.init(sections: [])
            return
        }
        self.init(sections: [SourceSection(items: items)])
    }
    
    public convenience init(sectionList: [[Item]]) {
        self.init(sections: sectionList.map({SourceSection(items: $0)}))
    }
    
    public func append(sections: [Section]) {
        self.sections += sections
        self.operate = .loadMore
        updateId()
    }
    
    @discardableResult
    public func append(models: [Item], section: Int) -> Bool {
        guard section < sections.count || section == 0 else {
            return false
        }
        guard sections.count > 0 else {
            self.sections = [Section(items: models)]
            self.operate = .`init`
            updateId()
            return true
        }
        var sec = sections[section]
        sec.items += models
        self.sections[section] = sec
        self.operate = .loadMoreInSection(section)
        updateId()
        return true
    }
    
    @discardableResult
    public func append(model: Item, section: Int) -> Bool {
        guard section < sections.count || section == 0 else {
            return false
        }
        guard sections.count > 0 else {
            self.sections = [Section(items: [model])]
            self.operate = .`init`
            updateId()
            return true
        }
        var sec = sections[section]
        sec.items.append(model)
        self.sections[section] = sec
        self.operate = .loadMoreInSection(section)
        updateId()
        return true
    }
    
    @discardableResult
    public func insert(models: [Item], section: Int, insertIndex: Int) -> Bool {
        guard section < sections.count, models.count > 0 else {
            return false
        }
        var sec = sections[section]
        guard insertIndex <= sec.items.count, insertIndex >= 0 else {
            return false
        }
        sec.items.insert(contentsOf: models, at: insertIndex)
        self.sections[section] = sec
        self.operate = .insertRows(section: section,
                                   insertIndex: insertIndex,
                                   rowCount: models.count)
        updateId()
        return true
    }
    
    @discardableResult
    public func insert(model: Item, section: Int, insertIndex: Int) -> Bool {
        guard section < sections.count else {
            return false
        }
        var sec = sections[section]
        guard insertIndex <= sec.items.count, insertIndex >= 0 else {
            return false
        }
        sec.items.insert(model, at: insertIndex)
        self.sections[section] = sec
        self.operate = .insertRows(section: section,
                                   insertIndex: insertIndex,
                                   rowCount: 1)
        updateId()
        return true
    }
    
    @discardableResult
    public func refresh(model: Item, row: Int, section: Int = 0) -> Bool {
        let res = replace(model: model, row: row, section: section)
        if res {
            self.operate = .refreshRow(section: section, row: row)
        }
        return res
    }
    
    public func replace(sections: [Section]) {
        self.sections = sections
        self.operate = .`init`
        updateId()
    }
    
    @discardableResult
    public func replace(models: [Item], section: Int = 0) -> Bool {
        guard section < sections.count || section == 0 else {
            return false
        }
        guard sections.count > 0 else {
            self.sections = [Section(items: models)]
            self.operate = .`init`
            updateId()
            return true
        }
        var sec = sections[section]
        sec.items = models
        self.sections[section] = sec
        self.operate = .reloadSection(section)
        updateId()
        return true
    }
    
    @discardableResult
    public func replace(model: Item, row: Int, section: Int = 0) -> Bool {
        guard section < sections.count || section == 0 else {
            return false
        }
        guard sections.count > 0 else {
            self.sections = [Section(items: [model])]
            self.operate = .`init`
            updateId()
            return true
        }
        var sec = sections[section]
        guard row < sec.items.count else {
            return false
        }
        sec.items[row] = model
        self.sections[section] = sec
        self.operate = .reloadRow(section: section, row: row)
        updateId()
        return true
    }
    
    /// 清空某一section
    @discardableResult
    public func clear(section: Int) -> Bool {
        guard section < sections.count else {
            return false
        }
        var sec = self.sections[section]
        sec.items = []
        self.sections[section] = sec
        self.operate = .reloadSection(section)
        updateId()
        return true
    }
    
    /// 清空第一个section
    @discardableResult
    public func clearFirstSection() -> Bool {
        guard sections.count > 0 else {
            return false
        }
        var sec = self.sections[0]
        sec.items = []
        self.sections[0] = sec
        self.operate = .reloadSection(0)
        updateId()
        return true
    }
    
    /// 清空最后一个section
    @discardableResult
    public func clearLastSection() -> Bool {
        guard sections.count > 0 else {
            return false
        }
        let count = self.sections.count
        var sec = self.sections.last!
        sec.items = []
        self.sections[count-1] = sec
        self.operate = .reloadSection(count-1)
        updateId()
        return true
    }
    
    /// 删除某个section下的第一个item
    @discardableResult
    public func removeFirstItem(section: Int) -> Bool {
        guard section < sections.count else {
            return false
        }
        var sec = self.sections[section]
        guard sec.items.count > 0 else {
            return false
        }
        sec.items.removeFirst()
        self.sections[section] = sec
        self.operate = .deleteRow(section: section, row: 0)
        updateId()
        return true
    }
    
    /// 删除某个section下的最后一个item
    @discardableResult
    public func removeLastItem(section: Int) -> Bool {
        guard section < sections.count else {
            return false
        }
        var sec = self.sections[section]
        guard sec.items.count > 0 else {
            return false
        }
        sec.items.removeLast()
        self.sections[section] = sec
        self.operate = .deleteRow(section: section, row: sec.items.count)
        updateId()
        return true
    }
    
    /// 删除某个section下的指定行
    @discardableResult
    public func removeItem(row: Int, section: Int) -> Bool {
        guard section < sections.count else {
            return false
        }
        var sec = self.sections[section]
        guard row < sec.items.count else {
            return false
        }
        sec.items.remove(at: row)
        self.sections[section] = sec
        self.operate = .deleteRow(section: section, row: row)
        updateId()
        return true
    }
    
    /// 删除某个section下的指定一组行
    public func removeItems(rows: [Int], section: Int) {
        guard section < sections.count, rows.count > 0 else {
            return
        }
        var sec = self.sections[section]
        var _rows: [Int] = []
        for i in rows.sorted(by: >) {
            if i < sec.items.count {
                _rows.append(i)
            }
        }
        for i in _rows {
            sec.items.remove(at: i)
        }
        self.sections[section] = sec
        self.operate = .deleteRows(section: section, rows: _rows)
        updateId()
    }
    
    public func items(section: Int) ->[Item]? {
        guard section < sections.count else {
            return nil
        }
        return sections[section].items
    }
    
    public func itemCount(section: Int) -> Int {
        guard section < sections.count else {
            return 0
        }
        return sections[section].items.count
    }
    
    public func item(row: Int, section: Int) -> Item? {
        guard section < sections.count else {
            return nil
        }
        let sec = sections[section]
        guard row < sec.items.count else {
            return nil
        }
        return sec.items[row]
    }
    
    /// 批量操作（当需要对数据源进行批量操作时，操作过程必须放在该闭包中完成）
    public func performBatchUpdates(_ updates: (_ source: DrSource) -> Operate) {
        self.operate = updates(self)
        updateId()
    }
    
    private func updateId() {
        if id == UInt64.max {
            id = UInt64.min
        }else{
            id += 1
        }
    }
}

extension DrSource: Equatable {
    
    public static func == (lhs: DrSource, rhs: DrSource) -> Bool {
        lhs.id == rhs.id
    }
}

extension DrSource: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct SourceSection<Item> {
    
    private let _header: Any?
    private let _footer: Any?
    public var items: [Item]
    
    public init(items: [Item], header: Any? = nil, footer: Any? = nil) {
        self.items = items
        self._header = header
        self._footer = footer
    }
    
    public func header<T>() -> T? {
        guard let _header = _header as? T else {
            return nil
        }
        return _header
    }
    
    public func header<T>(_ type: T.Type) -> T? {
        guard let _header = _header as? T else {
            return nil
        }
        return _header
    }
    
    public func footer<T>() -> T? {
        guard let _footer = _footer as? T else {
            return nil
        }
        return _footer
    }
    
    public func footer<T>(_ type: T.Type) -> T? {
        guard let _footer = _footer as? T else {
            return nil
        }
        return _footer
    }
    
    public mutating func append(_ item: Item) {
        self.items.append(item)
    }
    
    public mutating func append(items: [Item]) {
        self.items.append(contentsOf: items)
    }
    
    public mutating func insert(_ item: Item, at index: Int) {
        self.items.insert(item, at: index)
    }
    
    public mutating func insert(items: [Item], at index: Int) {
        self.items.insert(contentsOf: items, at: index)
    }
    
    public mutating func removeItem(at index: Int) {
        self.items.remove(at: index)
    }
    
    public mutating func removeAllItem() {
        self.items.removeAll()
        self.items.removeLast()
    }
    
    @discardableResult
    public mutating func removeFirstItem() -> Item? {
        guard self.items.count > 0 else {
            return nil
        }
        return self.items.removeFirst()
    }
    
    @discardableResult
    public mutating func removeLastItem() -> Item? {
        guard self.items.count > 0 else {
            return nil
        }
        return self.items.removeLast()
    }
}
