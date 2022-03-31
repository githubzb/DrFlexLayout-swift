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
    // 刷新某行
    case refreshRow(section: Int, row: Int)
    // 重载某个section
    case reloadSection(Int)
    // 重载某行
    case reloadRow(section: Int, row: Int)
    // section中加载更多item
    case loadMoreInSection(Int)
    // 加载更多section
    case loadMore
}

public class Source {
    
    public private(set) var id: UInt64 = UInt64.min
    public private(set) var operate: Operate = .`init`
    
    public private(set) var sections: [SourceSection]
    
    public init() {
        self.sections = []
    }
    
    public init(sections: [SourceSection]) {
        self.sections = sections
    }
    
    public convenience init(items: [SourceItem]?) {
        guard let items = items else {
            self.init(sections: [])
            return
        }
        self.init(sections: [SourceSection(items: items)])
    }
    
    public convenience init(sectionList: [[SourceItem]]) {
        self.init(sections: sectionList.map({SourceSection(items: $0)}))
    }
    
    public func append(sections: [SourceSection]) {
        self.sections += sections
        self.operate = .loadMore
        updateId()
    }
    
    @discardableResult
    public func append(models: [Any], section: Int) -> Bool {
        guard section < sections.count else {
            return false
        }
        var sec = sections[section]
        var i = sec.items.count
        var li: [SourceItem] = []
        for model in models {
            li.append(SourceItem(section: section, row: i, model: model))
            i += 1
        }
        sec.items += li
        self.sections[section] = sec
        self.operate = .loadMoreInSection(section)
        updateId()
        return true
    }
    
    @discardableResult
    public func append(model: Any, section: Int) -> Bool {
        guard section < sections.count else {
            return false
        }
        var sec = sections[section]
        sec.items.append(SourceItem(section: section, row: sec.items.count, model: model))
        self.sections[section] = sec
        self.operate = .loadMoreInSection(section)
        updateId()
        return true
    }
    
    @discardableResult
    public func replace(models: [Any], section: Int) -> Bool {
        guard section < sections.count else {
            return false
        }
        var list: [SourceItem] = []
        for (i, model) in models.enumerated() {
            list.append(SourceItem(section: section, row: i, model: model))
        }
        var sec = sections[section]
        sec.items = list
        self.sections[section] = sec
        self.operate = .reloadSection(section)
        updateId()
        return true
    }
    
    @discardableResult
    public func replace(model: Any, row: Int, section: Int) -> Bool {
        guard section < sections.count else {
            return false
        }
        var sec = sections[section]
        guard row < sec.items.count else {
            return false
        }
        var item = sec.items[row]
        let oldModel = item.model
        item.model = model
        sec.items[row] = item
        self.sections[section] = sec
        if type(of: oldModel) == type(of: model) {
            // 两个model类型相同
            self.operate = .refreshRow(section: section, row: row)
        }else{
            self.operate = .reloadRow(section: section, row: row)
        }
        updateId()
        return true
    }
    
    /// 清空某一section
    @discardableResult
    public func clear(section: Int) -> Bool {
        guard section < sections.count else {
            return false
        }
        self.sections[section] = SourceSection(items: [])
        self.operate = .reloadSection(section)
        updateId()
        return true
    }
    
    public func items(section: Int) ->[SourceItem]? {
        guard section < sections.count else {
            return nil
        }
        return sections[section].items
    }
    
    public func item(row: Int, section: Int) -> SourceItem? {
        guard section < sections.count else {
            return nil
        }
        let sec = sections[section]
        guard row < sec.items.count else {
            return nil
        }
        return sec.items[row]
    }
    
    private func updateId() {
        if id == UInt64.max {
            id = UInt64.min
        }else{
            id += 1
        }
    }
}

extension Source: Equatable {
    
    public static func == (lhs: Source, rhs: Source) -> Bool {
        lhs.id == rhs.id
    }
}

extension Source: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct SourceSection {
    private var _headerModel: Any?
    private var _footerModel: Any?
    public var items: [SourceItem]
    
    public init(items: [SourceItem], headerModel: Any? = nil, footerModel: Any? = nil) {
        self.items = items
        self._headerModel = headerModel
        self._footerModel = footerModel
    }
    
    public func headerModel<T>() -> T? {
        guard let m = _headerModel as? T else {
            return nil
        }
        return m
    }
    
    public func headerModel<T>(type: T.Type) -> T? {
        guard let m = _headerModel as? T else {
            return nil
        }
        return m
    }
    
    public func footerModel<T>() -> T? {
        guard let m = _footerModel as? T else {
            return nil
        }
        return m
    }
    
    public func footerModel<T>(type: T.Type) -> T? {
        guard let m = _footerModel as? T else {
            return nil
        }
        return m
    }
}

public struct SourceItem {
    public let section: Int
    public let row: Int
    public var model: Any
    
    public init(section: Int, row: Int, model: Any) {
        self.section = section
        self.row = row
        self.model = model
    }
    
    public func getModel<T>() -> T {
        convertType(model)
    }
    
    public func getModel<T>(type: T.Type) -> T {
        convertType(model)
    }
}


/// 将Any类型，转成指定类型（转换失败会crash）
func convertType<T>(_ model: Any) -> T {
    guard let m = model as? T else {
        fatalError("\(type(of: model)) convert to \(T.self) fail.")
    }
    return m
}
