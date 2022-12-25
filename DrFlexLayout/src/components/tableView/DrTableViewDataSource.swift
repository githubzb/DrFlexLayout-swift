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

public typealias DrTableViewProtocol = DrTableViewDataSource & DrTableViewDelegate

public protocol DrTableViewDataSource {
    
    var sectionIndexTitles: [String]? { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(section: Int) -> Int
    func cellView(indexPath: IndexPath) -> DrViewBuilder
    func cellHeight(indexPath: IndexPath, in tableView: UITableView) -> CGFloat
    func headerView(section: Int) -> DrViewBuilder?
    func footerView(section: Int) -> DrViewBuilder?
    func headerHeight(section: Int, in tableView: UITableView) -> CGFloat?
    func footerHeight(section: Int, in tableView: UITableView) -> CGFloat?
    func cleanCache(indexPaths: [IndexPath]?)
    
    func sectionIndexTitlesMap(title: String, at index: Int) -> Int
}

public protocol DrTableViewDelegate {
    
    func click(view: UIView, indexPath: IndexPath)
    func deselect(view: UIView, indexPath: IndexPath)
    func willDisplay(view: UIView, indexPath: IndexPath)
    func willDisplayHeader(view: UIView, section: Int)
    func willDisplayFooter(view: UIView, section: Int)
    func willClick(view: UIView, indexPath: IndexPath) -> IndexPath?
    func willDeselect(view: UIView, indexPath: IndexPath) -> IndexPath?
    
    func canEdit(indexPath: IndexPath) -> Bool
    func editingStyle(indexPath: IndexPath) -> UITableViewCell.EditingStyle
    func titleForDelete(indexPath: IndexPath) -> String?
    func commitEdit(view: UIView, editingStyle: UITableViewCell.EditingStyle, indexPath: IndexPath)
    
    func willBeginEditing(indexPath: IndexPath)
    func didEndEditing(indexPath: IndexPath)
    
    func shouldIndentWhileEditing(indexPath: IndexPath) -> Bool
    
    func leadingSwipeActions(indexPath: IndexPath) -> DrSwipeActionsConfiguration?
    func trailingSwipeActions(indexPath: IndexPath) -> DrSwipeActionsConfiguration?
    
    func canMove(indexPath: IndexPath) -> Bool
    func shouldMove(from sourceIndexPath: IndexPath, to proposedDestinationIndexPath: IndexPath) -> IndexPath
    func didMove(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

public class DrTableViewSourceBase<Item>: DrTableViewDelegate {
    
    
    typealias CellAction = (_ item: Item, _ indexPath: IndexPath, _ view: UIView) -> Void
    typealias IndexPathAction = (_ item: Item, _ indexPath: IndexPath) -> Void
    typealias CellRetIndexPathAction = (_ item: Item, _ indexPath: IndexPath, _ view: UIView) -> IndexPath?
    typealias CanEditBinder = (_ item: Item, _ indexPath: IndexPath) -> Bool
    typealias CommitEditBinder = (_ item: Item, _ indexPath: IndexPath, _ editStyle: UITableViewCell.EditingStyle, _ view: UIView) -> Void
    typealias EditingStyleBinder = (_ item: Item, _ indexPath: IndexPath) -> UITableViewCell.EditingStyle
    typealias TitleForDeleteBinder = (_ item: Item, _ indexPath: IndexPath) -> String?
    typealias ShouldIdentWhileEditingBinder = (_ item: Item, _ indexPath: IndexPath) -> Bool
    typealias SwipeAction = (_ item: Item, _ indexPath: IndexPath) -> DrSwipeActionsConfiguration?
    typealias CanMoveBinder = (_ item: Item, _ indexPath: IndexPath) -> Bool
    typealias ShouldMoveBinder = (_ fromItem: Item, _ toItem: Item, _ from: IndexPath, _ to: IndexPath) -> IndexPath
    typealias DidMoveBinder = (_ fromItem: Item, _ toItem: Item, _ from: IndexPath, _ to: IndexPath) -> Void
    
    private var clickBinder: CellAction?
    private var deselectBinder: CellAction?
    private var willDisplayBinder: CellAction?
    private var willClickBinder: CellRetIndexPathAction?
    private var willDeselectBinder: CellRetIndexPathAction?
    private var willBeginEditingBinder: IndexPathAction?
    private var didEndEditingBinder: IndexPathAction?
    
    private var canEditBinder: CanEditBinder?
    private var editingStyleBinder: EditingStyleBinder?
    private var titleForDeleteBinder: TitleForDeleteBinder?
    private var commitEditBinder: CommitEditBinder?
    
    private var shouldIndentWhileEditingBinder: ShouldIdentWhileEditingBinder?
    
    private var leadingSwipeActionsBinder: SwipeAction?
    private var trailingSwipeActionsBinder: SwipeAction?
    
    private var canMoveBinder: CanMoveBinder?
    private var shouldMoveBinder: ShouldMoveBinder?
    private var didMoveBinder: DidMoveBinder?
    
    func item(indexPath: IndexPath) -> Item {
        fatalError("需子类重写该方法")
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
    
    /// 取消选中回调
    public func onDeselect<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath, _ view: UIView) -> Void) {
        deselectBinder = { [weak target] (item, indexPath, view) in
            guard let target = target else {
                return
            }
            return binding(target, item, indexPath, view)
        }
    }
    
    /// 将要执行点击回调，返回nil，将不执行点击回调
    public func onWillClick<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath, _ view: UIView) -> IndexPath?) {
        willClickBinder = { [weak target] (item, indexPath, view) in
            guard let target = target else {
                return nil
            }
            return binding(target, item, indexPath, view)
        }
    }
    
    /// 将要执行取消选中回调，返回nil，将不执行取消选中回调
    public func onWillDeselect<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath, _ view: UIView) -> IndexPath?) {
        willDeselectBinder = { [weak target] (item, indexPath, view) in
            guard let target = target else {
                return nil
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
    
    public func onWillBeginEditing<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath) -> Void) {
        willBeginEditingBinder = { [weak target] (item, indexPath) in
            guard let target = target else {
                return
            }
            binding(target, item, indexPath)
        }
    }
    
    public func onDidEndEditing<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath) -> Void) {
        didEndEditingBinder = { [weak target] (item, indexPath) in
            guard let target = target else {
                return
            }
            binding(target, item, indexPath)
        }
    }
    
    public func onCanEdit<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath) -> Bool) {
        canEditBinder = { [weak target] (item, indexPath) in
            guard let target = target else {
                return false
            }
            return binding(target, item, indexPath)
        }
    }
    
    public func onEditingStyle<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath) -> UITableViewCell.EditingStyle) {
        editingStyleBinder = { [weak target] (item, indexPath) in
            guard let target = target else {
                return .none
            }
            return binding(target, item, indexPath)
        }
    }
    
    public func onTitleForDelete<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath) -> String?) {
        titleForDeleteBinder = { [weak target] (item, indexPath) in
            guard let target = target else {
                return nil
            }
            return binding(target, item, indexPath)
        }
    }
    
    public func onCommitEdit<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath, _ editStyle: UITableViewCell.EditingStyle, _ view: UIView) -> Void) {
        commitEditBinder = { [weak target] (item, indexPath, editStyle, view) in
            guard let target = target else {
                return
            }
            binding(target, item, indexPath, editStyle, view)
        }
    }
    
    public func onShouldIndentWhileEditing<T: AnyObject>(target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath) -> Bool) {
        shouldIndentWhileEditingBinder = { [weak target] (item, indexPath) -> Bool in
            guard let target = target else {
                return true
            }
            return binding(target, item, indexPath)
        }
    }
    
    public func onLeadingSwipeAction<T: AnyObject>(target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath) -> DrSwipeActionsConfiguration?) {
        leadingSwipeActionsBinder = { [weak target] (item, indexPath) in
            guard let target = target else {
                return nil
            }
            return binding(target, item, indexPath)
        }
    }
    
    public func onTrailingSwipeAction<T: AnyObject>(target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath) -> DrSwipeActionsConfiguration?) {
        trailingSwipeActionsBinder = { [weak target] (item, indexPath) in
            guard let target = target else {
                return nil
            }
            return binding(target, item, indexPath)
        }
    }
    
    public func onCanMove<T: AnyObject>(target: T, binding: @escaping (_ target: T, _ item: Item, _ indexPath: IndexPath)->Bool) {
        canMoveBinder = { [weak target] (item, indexPath) in
            guard let target = target else {
                return false
            }
            return binding(target, item, indexPath)
        }
    }
    
    public func onShouldMove<T: AnyObject>(target: T, binding: @escaping (_ target: T, _ fromItem: Item, _ toItem: Item, _ from: IndexPath, _ to: IndexPath) -> IndexPath) {
        shouldMoveBinder = { [weak target] (fromItem, toItem, from, to) in
            guard let target = target else {
                return to
            }
            return binding(target, fromItem, toItem, from, to)
        }
    }
    
    public func onDidMove<T: AnyObject>(target: T, binding: @escaping (_ target: T, _ fromItem: Item, _ toItem: Item, _ from: IndexPath, _ to: IndexPath)->Void) {
        didMoveBinder = { [weak target] (fromItem, toItem, from, to) in
            guard let target = target else {
                return
            }
            binding(target, fromItem, toItem, from, to)
        }
    }
    
    
    public func click(view: UIView, indexPath: IndexPath) {
        guard let clickBinder = clickBinder else {
            return
        }
        let item = item(indexPath: indexPath)
        clickBinder(item, indexPath, view)
    }
    
    public func deselect(view: UIView, indexPath: IndexPath) {
        guard let deselectBinder = deselectBinder else {
            return
        }
        let item = item(indexPath: indexPath)
        deselectBinder(item, indexPath, view)
    }
    
    public func willDisplay(view: UIView, indexPath: IndexPath) {
        guard let willDisplayBinder = willDisplayBinder else {
            return
        }
        let item = item(indexPath: indexPath)
        willDisplayBinder(item, indexPath, view)
    }
    
    public func willDisplayHeader(view: UIView, section: Int) {}
    
    public func willDisplayFooter(view: UIView, section: Int) {}
    
    public func willClick(view: UIView, indexPath: IndexPath) -> IndexPath? {
        guard let willClickBinder = willClickBinder else {
            return indexPath
        }
        let item = item(indexPath: indexPath)
        return willClickBinder(item, indexPath, view)
    }
    
    public func willDeselect(view: UIView, indexPath: IndexPath) -> IndexPath? {
        guard let willDeselectBinder = willDeselectBinder else {
            return indexPath
        }
        let item = item(indexPath: indexPath)
        return willDeselectBinder(item, indexPath, view)
    }
    
    public func canEdit(indexPath: IndexPath) -> Bool {
        guard let canEditBinder = canEditBinder else {
            return true
        }
        let item = item(indexPath: indexPath)
        return canEditBinder(item, indexPath)
    }
    
    public func editingStyle(indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard let editingStyleBinder = editingStyleBinder else {
            return .delete
        }
        let item = item(indexPath: indexPath)
        return editingStyleBinder(item, indexPath)
    }
    
    public func titleForDelete(indexPath: IndexPath) -> String? {
        guard let titleForDeleteBinder = titleForDeleteBinder else {
            return nil
        }
        let item = item(indexPath: indexPath)
        return titleForDeleteBinder(item, indexPath)
    }
    
    public func commitEdit(view: UIView, editingStyle: UITableViewCell.EditingStyle, indexPath: IndexPath) {
        guard let commitEditBinder = commitEditBinder else {
            return
        }
        let item = item(indexPath: indexPath)
        commitEditBinder(item, indexPath, editingStyle, view)
    }
    
    public func willBeginEditing(indexPath: IndexPath) {
        guard let willBeginEditingBinder = willBeginEditingBinder else {
            return
        }
        let item = item(indexPath: indexPath)
        willBeginEditingBinder(item, indexPath)
    }
    
    public func didEndEditing(indexPath: IndexPath) {
        guard let didEndEditingBinder = didEndEditingBinder else {
            return
        }
        let item = item(indexPath: indexPath)
        didEndEditingBinder(item, indexPath)
    }
    
    public func shouldIndentWhileEditing(indexPath: IndexPath) -> Bool {
        guard let shouldIndentWhileEditingBinder = shouldIndentWhileEditingBinder else {
            return true
        }
        let item = item(indexPath: indexPath)
        return shouldIndentWhileEditingBinder(item, indexPath)
    }
    
    public func leadingSwipeActions(indexPath: IndexPath) -> DrSwipeActionsConfiguration? {
        guard let leadingSwipeActionsBinder = leadingSwipeActionsBinder else {
            return nil
        }
        let item = item(indexPath: indexPath)
        return leadingSwipeActionsBinder(item, indexPath)
    }
    
    public func trailingSwipeActions(indexPath: IndexPath) -> DrSwipeActionsConfiguration? {
        guard let trailingSwipeActionsBinder = trailingSwipeActionsBinder else {
            return nil
        }
        let item = item(indexPath: indexPath)
        return trailingSwipeActionsBinder(item, indexPath)
    }
    
    public func canMove(indexPath: IndexPath) -> Bool {
        guard let canMoveBinder = canMoveBinder else {
            return false
        }
        let item = item(indexPath: indexPath)
        return canMoveBinder(item, indexPath)
    }
    
    public func shouldMove(from sourceIndexPath: IndexPath, to proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard let shouldMoveBinder = shouldMoveBinder else {
            return proposedDestinationIndexPath
        }
        let fromItem = item(indexPath: sourceIndexPath)
        let toItem = item(indexPath: proposedDestinationIndexPath)
        return shouldMoveBinder(fromItem, toItem, sourceIndexPath, proposedDestinationIndexPath)
    }
    
    public func didMove(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let didMoveBinder = didMoveBinder else {
            return
        }
        let fromItem = item(indexPath: sourceIndexPath)
        let toItem = item(indexPath: destinationIndexPath)
        didMoveBinder(fromItem, toItem, sourceIndexPath, destinationIndexPath)
    }
}


public class DrTableViewGroupSource<Item>: DrTableViewSourceBase<Item> {
    
    public typealias CellBuilder = (_ item: Item, _ indexPath: IndexPath) -> DrViewBuilder
    public typealias HeaderFooterBuilder = (_ group: Group<Item>, _ section: Int) -> DrViewBuilder?
    typealias HeaderFooterDisplayBinder = (_ group: Group<Item>, _ section: Int, _ view: UIView) -> Void
    typealias SectionIndexTitlesBuilder = () -> [String]?
    typealias SectionIndexTitlesMapBinder = (_ title: String, _ index: Int) -> Int
    
    private var sourceBinder: (() -> [Group<Item>]?)?
    private var source: [Group<Item>]? { sourceBinder?() }
    
    private let cellBuilder: CellBuilder
    private let headerBuilder: HeaderFooterBuilder?
    private let footerBuilder: HeaderFooterBuilder?
    private var sectionIndexTitlesBuilder: SectionIndexTitlesBuilder?
    private var sectionIndexTitlesMapBinder: SectionIndexTitlesMapBinder?
    
    private var willDisplayHeaderBinder: HeaderFooterDisplayBinder?
    private var willDisplayFooterBinder: HeaderFooterDisplayBinder?
    
    private var heightCaches: [String: CGFloat] = [:]
    
    /// 是否可变高度（当为true时，列表首次加载性能会降低，因为它会为每个cell分别计算高度，并缓存）
    public let isMutableHeight: Bool
    public var sectionIndexTitles: [String]? { sectionIndexTitlesBuilder?() }
    
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
    
    // 绑定section index title数据源
    public func bindSectionIndexTitles<T: AnyObject>(_ target: T, binding: @escaping (_ target: T) -> [String]?) {
        sectionIndexTitlesBuilder = { [weak target] in
            guard let target = target else {
                return nil
            }
            return binding(target)
        }
    }
    
    public func onSectionIndexTitlesMap<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ title: String, _ index: Int) -> Int) {
        sectionIndexTitlesMapBinder = { [weak target] (title, index) in
            guard let target = target else {
                return 0
            }
            return binding(target, title, index)
        }
    }
    
    /// 组头视图将要显示
    public func onWillDisplayHeader<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ group: Group<Item>, _ section: Int, _ view: UIView) -> Void) {
        willDisplayHeaderBinder = { [weak target] (group, section, view) in
            guard let target = target else {
                return
            }
            binding(target, group, section, view)
        }
    }
    
    /// 组尾视图将要显示
    public func onWillDisplayFooter<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ group: Group<Item>, _ section: Int, _ view: UIView) -> Void) {
        willDisplayFooterBinder = { [weak target] (group, section, view) in
            guard let target = target else {
                return
            }
            binding(target, group, section, view)
        }
    }
    
    override func item(indexPath: IndexPath) -> Item {
        source![indexPath.section][indexPath.row]
    }
    
    public override func willDisplayHeader(view: UIView, section: Int) {
        guard let willDisplayHeaderBinder = willDisplayHeaderBinder else {
            return
        }
        let group = source![section]
        willDisplayHeaderBinder(group, section, view)
    }
    
    public override func willDisplayFooter(view: UIView, section: Int) {
        guard let willDisplayFooterBinder = willDisplayFooterBinder else {
            return
        }
        let group = source![section]
        willDisplayFooterBinder(group, section, view)
    }
    
    public func sectionIndexTitlesMap(title: String, at index: Int) -> Int {
        sectionIndexTitlesMapBinder?(title, index) ?? 0
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
    
    private func cacheKey(indexPath: IndexPath) -> String {
        "\(indexPath.section)-\(indexPath.row)"
    }
    
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
            let tag = cacheKey(indexPath: indexPath)
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
    
    public func cleanCache(indexPaths: [IndexPath]?) {
        if isMutableHeight {
            // 清除指定缓存
            if let indexPaths = indexPaths {
                for indexPath in indexPaths {
                    heightCaches[cacheKey(indexPath: indexPath)] = nil
                }
            }
        }else {
            heightCaches.removeAll()
        }
    }
    
}


public class DrTableViewItemSource<Item>: DrTableViewSourceBase<Item> {
    
    public typealias CellBuilder = (_ item: Item, _ indexPath: IndexPath) -> DrViewBuilder
    public typealias HeaderFooterBuilder = () -> DrViewBuilder
    typealias HeaderFooterDisplayBinder = (_ section: Int, _ view: UIView) -> Void
    
    private var sourceBinder: (() -> [Item]?)?
    private var source: [Item]? { sourceBinder?() }
    
    private let cellBuilder: CellBuilder
    private let headerBuilder: HeaderFooterBuilder?
    private let footerBuilder: HeaderFooterBuilder?
    
    private var willDisplayHeaderBinder: HeaderFooterDisplayBinder?
    private var willDisplayFooterBinder: HeaderFooterDisplayBinder?
    
    private var heightCaches: [String: CGFloat] = [:]
    
    /// 是否可变高度（当为true时，列表首次加载性能会降低，因为它会为每个cell分别计算高度，并缓存）
    public let isMutableHeight: Bool
    public var sectionIndexTitles: [String]? { nil }
    
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
    
    /// 组头视图将要显示
    public func onWillDisplayHeader<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ section: Int, _ view: UIView) -> Void) {
        willDisplayHeaderBinder = { [weak target] (section, view) in
            guard let target = target else {
                return
            }
            binding(target, section, view)
        }
    }
    
    /// 组尾视图将要显示
    public func onWillDisplayFooter<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ section: Int, _ view: UIView) -> Void) {
        willDisplayFooterBinder = { [weak target] (section, view) in
            guard let target = target else {
                return
            }
            binding(target, section, view)
        }
    }
    
    override func item(indexPath: IndexPath) -> Item {
        source![indexPath.row]
    }
    
    public func sectionIndexTitlesMap(title: String, at index: Int) -> Int {
        0
    }
}

extension DrTableViewItemSource: DrTableViewDataSource {
    
    private func cacheKey(indexPath: IndexPath) -> String {
        "\(indexPath.section)-\(indexPath.row)"
    }
    
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
            let tag = cacheKey(indexPath: indexPath)
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
    
    public func cleanCache(indexPaths: [IndexPath]?) {
        if isMutableHeight {
            // 清除指定缓存
            if let indexPaths = indexPaths {
                for indexPath in indexPaths {
                    heightCaches[cacheKey(indexPath: indexPath)] = nil
                }
            }
        }else {
            heightCaches.removeAll()
        }
    }
    
}
