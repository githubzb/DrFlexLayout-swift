//
//  DrTableViewDataSource.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/12/4.
//

import UIKit

public struct DrViewBuilder {
    public let reuseId: String
    public let builder: (_ reuseView: UIView?) -> UIView
    
    public init(_ reuseId: String, builder: @escaping (_ reuseView: UIView?) -> UIView) {
        self.reuseId = reuseId
        self.builder = builder
    }
}

public protocol DrTableViewDataSource {
    
    // MARK: - Source
    var numberOfSections: Int { get }
    func numberOfRowsInSection(section: Int) -> Int
    func cellView(indexPath: IndexPath) -> DrViewBuilder
    func cellHeight(indexPath: IndexPath, in tableView: UITableView) -> CGFloat
    func headerView(section: Int) -> DrViewBuilder?
    func footerView(section: Int) -> DrViewBuilder?
    func headerHeight(section: Int, in tableView: UITableView) -> CGFloat?
    func footerHeight(section: Int, in tableView: UITableView) -> CGFloat?
    func cleanCache()
    
    // MARK: - delegate
    func click(view: UIView, indexPath: IndexPath)
    func willDisplay(view: UIView, indexPath: IndexPath)
    
}

public class DrTableViewGroupSource<Item> {
    
    public typealias CellBuilder = (_ item: Item, _ indexPath: IndexPath) -> DrViewBuilder
    public typealias HeaderFooterBuilder = (_ group: Group<Item>, _ section: Int) -> DrViewBuilder?
    public typealias CellAction = (_ item: Item, _ indexPath: IndexPath, _ view: UIView) -> Void
    
    private var sourceBinder: (() -> [Group<Item>]?)?
    private var source: [Group<Item>]? { sourceBinder?() }
    
    private let cellBuilder: CellBuilder
    private let headerBuilder: HeaderFooterBuilder?
    private let footerBuilder: HeaderFooterBuilder?
    private var clickBinder: CellAction?
    private var willDisplayBinder: CellAction?
    
    private var heightCaches: [String: CGFloat] = [:]
    
    /// 是否可变高度（当为true时，列表首次加载性能会降低，因为它会为每个cell分别计算高度，并缓存）
    public let isMutableHeight: Bool
    
    public init(isMutableHeight: Bool = false,
                cellBuilder: @escaping CellBuilder,
                headerBuilder: HeaderFooterBuilder?,
                footerBuilder: HeaderFooterBuilder?) {
        self.isMutableHeight = isMutableHeight
        self.cellBuilder = cellBuilder
        self.headerBuilder = headerBuilder
        self.footerBuilder = footerBuilder
    }
    
    /// 绑定数据源
    public func bindSource<T: AnyObject>(_ target: T, binding: @escaping (_ target: T) -> [Group<Item>]) {
        weak var weakTarget = target
        sourceBinder = {
            guard let target = weakTarget else {
                return nil
            }
            return binding(target)
        }
    }
    
    /// 点击回调
    public func onClick<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath, _ view: UIView) -> Void) {
        clickBinder = { [weak target] (item, indexPath, view) in
            guard let target = target else {
                return
            }
            return binding(target, item, indexPath, view)
        }
    }
    
    /// cell将要显示回调
    public func onWillDisplay<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath, _ view: UIView) -> Void) {
        willDisplayBinder = { [weak target] (item, indexPath, view) in
            guard let target = target else {
                return
            }
            return binding(target, item, indexPath, view)
        }
    }
}

extension DrTableViewGroupSource {
    
    public struct Group<Item> {
        public var items: [Item]
        public var header: Any?
        public var footer: Any?
        
        public var itemCount: Int { items.count }
        
        public init(_ items: [Item]) {
            self.items = items
            self.header = nil
            self.footer = nil
        }
        public init(items: [Item], header: Any?, footer: Any?) {
            self.items = items
            self.header = header
            self.footer = footer
        }
        
        public subscript(index: Int) -> Item {
            get {
                items[index]
            }
            set {
                items[index] = newValue
            }
        }
    }
}

extension DrTableViewGroupSource: DrTableViewDataSource {
    
    public var numberOfSections: Int {
        source?.count ?? 1
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        source![section].itemCount
    }
    
    public func item(row: Int, section: Int) -> Item {
        source![section][row]
    }
    
    public func cellView(indexPath: IndexPath) -> DrViewBuilder {
        let item = item(row: indexPath.row, section: indexPath.section)
        return cellBuilder(item, indexPath)
    }
    
    public func cellHeight(indexPath: IndexPath, in tableView: UITableView) -> CGFloat {
        let viewBuilder = cellView(indexPath: indexPath)
        if isMutableHeight {
            let tag = "\(indexPath.section)-\(indexPath.row)"
            guard let height = heightCaches[tag] else {
                let view = viewBuilder.builder(nil)
                view.dr_resetWidth(tableView.frame.width)
                if view.isYogaEnabled {
                    view.dr_flex.layout(mode: .adjustHeight)
                }
                heightCaches[tag] = view.frame.height
                return view.frame.height
            }
            return height
        }
        guard let height = heightCaches[viewBuilder.reuseId] else {
            let view = viewBuilder.builder(nil)
            view.dr_resetWidth(tableView.frame.width)
            if view.isYogaEnabled {
                view.dr_flex.layout(mode: .adjustHeight)
            }
            heightCaches[viewBuilder.reuseId] = view.frame.height
            return view.frame.height
        }
        return height
    }
    
    public func headerView(section: Int) -> DrViewBuilder? {
        guard let builder = headerBuilder else {
            return nil
        }
        let group = source![section]
        return builder(group, section)
    }
    
    public func footerView(section: Int) -> DrViewBuilder? {
        guard let builder = footerBuilder else {
            return nil
        }
        let group = source![section]
        return builder(group, section)
    }
    
    public func headerHeight(section: Int, in tableView: UITableView) -> CGFloat? {
        guard let viewBuilder = headerView(section: section) else {
            return nil
        }
        guard let height = heightCaches[viewBuilder.reuseId] else {
            let view = viewBuilder.builder(nil)
            view.dr_resetWidth(tableView.frame.width)
            if view.isYogaEnabled {
                view.dr_flex.layout(mode: .adjustHeight)
            }
            heightCaches[viewBuilder.reuseId] = view.frame.height
            return view.frame.height
        }
        return height
    }
    
    public func footerHeight(section: Int, in tableView: UITableView) -> CGFloat? {
        guard let viewBuilder = footerView(section: section) else {
            return nil
        }
        guard let height = heightCaches[viewBuilder.reuseId] else {
            let view = viewBuilder.builder(nil)
            view.dr_resetWidth(tableView.frame.width)
            if view.isYogaEnabled {
                view.dr_flex.layout(mode: .adjustHeight)
            }
            heightCaches[viewBuilder.reuseId] = view.frame.height
            return view.frame.height
        }
        return height
    }
    
    public func cleanCache() {
        heightCaches.removeAll()
    }
    
    public func click(view: UIView, indexPath: IndexPath) {
        guard let clickBinder = clickBinder else {
            return
        }
        let item = item(row: indexPath.row, section: indexPath.section)
        clickBinder(item, indexPath, view)
    }
    
    public func willDisplay(view: UIView, indexPath: IndexPath) {
        guard let willDisplayBinder = willDisplayBinder else {
            return
        }
        let item = item(row: indexPath.row, section: indexPath.section)
        willDisplayBinder(item, indexPath, view)
    }
}


public class DrTableViewItemSource<Item> {
    
    public typealias CellBuilder = (_ item: Item, _ indexPath: IndexPath) -> DrViewBuilder
    public typealias HeaderFooterBuilder = () -> DrViewBuilder
    public typealias CellAction = (_ item: Item, _ indexPath: IndexPath, _ view: UIView) -> Void
    
    private var sourceBinder: (() -> [Item]?)?
    private var source: [Item]? { sourceBinder?() }
    
    private let cellBuilder: CellBuilder
    private let headerBuilder: HeaderFooterBuilder?
    private let footerBuilder: HeaderFooterBuilder?
    private var clickBinder: CellAction?
    private var willDisplayBinder: CellAction?
    
    private var heightCaches: [String: CGFloat] = [:]
    
    /// 是否可变高度（当为true时，列表首次加载性能会降低，因为它会为每个cell分别计算高度，并缓存）
    public let isMutableHeight: Bool
    
    public init(isMutableHeight: Bool = false,
                cellBuilder: @escaping CellBuilder,
                headerBuilder: HeaderFooterBuilder? = nil,
                footerBuilder: HeaderFooterBuilder? = nil) {
        self.isMutableHeight = isMutableHeight
        self.cellBuilder = cellBuilder
        self.headerBuilder = headerBuilder
        self.footerBuilder = footerBuilder
    }
    
    /// 绑定数据源
    public func bindSource<T: AnyObject>(_ target: T, binding: @escaping (_ target: T) -> [Item]) {
        weak var weakTarget = target
        sourceBinder = {
            guard let target = weakTarget else {
                return nil
            }
            return binding(target)
        }
    }
    
    /// 点击回调
    public func onClick<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath, _ view: UIView) -> Void) {
        clickBinder = { [weak target] (item, indexPath, view) in
            guard let target = target else {
                return
            }
            return binding(target, item, indexPath, view)
        }
    }
    
    /// cell将要显示回调
    public func onWillDisplay<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath, _ view: UIView) -> Void) {
        willDisplayBinder = { [weak target] (item, indexPath, view) in
            guard let target = target else {
                return
            }
            return binding(target, item, indexPath, view)
        }
    }
}

extension DrTableViewItemSource: DrTableViewDataSource {
    
    public var numberOfSections: Int {
        1
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        source?.count ?? 0
    }
    
    public func item(row: Int, section: Int) -> Item {
        source![row]
    }
    
    public func cellView(indexPath: IndexPath) -> DrViewBuilder {
        let item = item(row: indexPath.row, section: indexPath.section)
        return cellBuilder(item, indexPath)
    }
    
    public func cellHeight(indexPath: IndexPath, in tableView: UITableView) -> CGFloat {
        let viewBuilder = cellView(indexPath: indexPath)
        if isMutableHeight {
            let tag = "\(indexPath.section)-\(indexPath.row)"
            guard let height = heightCaches[tag] else {
                let view = viewBuilder.builder(nil)
                view.dr_resetWidth(tableView.frame.width)
                if view.isYogaEnabled {
                    view.dr_flex.layout(mode: .adjustHeight)
                }
                heightCaches[tag] = view.frame.height
                return view.frame.height
            }
            return height
        }
        guard let height = heightCaches[viewBuilder.reuseId] else {
            let view = viewBuilder.builder(nil)
            view.dr_resetWidth(tableView.frame.width)
            if view.isYogaEnabled {
                view.dr_flex.layout(mode: .adjustHeight)
            }
            heightCaches[viewBuilder.reuseId] = view.frame.height
            return view.frame.height
        }
        return height
    }
    
    public func headerView(section: Int) -> DrViewBuilder? {
        headerBuilder?()
    }
    
    public func footerView(section: Int) -> DrViewBuilder? {
        footerBuilder?()
    }
    
    public func headerHeight(section: Int, in tableView: UITableView) -> CGFloat? {
        guard let viewBuilder = headerView(section: section) else {
            return nil
        }
        guard let height = heightCaches[viewBuilder.reuseId] else {
            let view = viewBuilder.builder(nil)
            view.dr_resetWidth(tableView.frame.width)
            if view.isYogaEnabled {
                view.dr_flex.layout(mode: .adjustHeight)
            }
            heightCaches[viewBuilder.reuseId] = view.frame.height
            return view.frame.height
        }
        return height
    }
    
    public func footerHeight(section: Int, in tableView: UITableView) -> CGFloat? {
        guard let viewBuilder = footerView(section: section) else {
            return nil
        }
        guard let height = heightCaches[viewBuilder.reuseId] else {
            let view = viewBuilder.builder(nil)
            view.dr_resetWidth(tableView.frame.width)
            if view.isYogaEnabled {
                view.dr_flex.layout(mode: .adjustHeight)
            }
            heightCaches[viewBuilder.reuseId] = view.frame.height
            return view.frame.height
        }
        return height
    }
    
    public func cleanCache() {
        heightCaches.removeAll()
    }
    
    public func click(view: UIView, indexPath: IndexPath) {
        guard let clickBinder = clickBinder else {
            return
        }
        let item = item(row: indexPath.row, section: indexPath.section)
        clickBinder(item, indexPath, view)
    }
    
    public func willDisplay(view: UIView, indexPath: IndexPath) {
        guard let willDisplayBinder = willDisplayBinder else {
            return
        }
        let item = item(row: indexPath.row, section: indexPath.section)
        willDisplayBinder(item, indexPath, view)
    }
}
