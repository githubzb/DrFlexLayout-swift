//
//  DrFlexTableView.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/11/15.
//

import UIKit

fileprivate let kDrFlexCellIdentifier = "DrFlexTableView.flexCell"
fileprivate let kDrFlexHeaderFooterIdentifier = "DrFlexTableView.flexHeaderFooter"

fileprivate typealias DrFlexCellMap = NSMutableDictionary


class _TableView: UITableView {
    
    weak var touchHook: DrScrollViewTouchHook?
    
    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        guard let hook = touchHook else {
            return super.touchesShouldBegin(touches, with: event, in: view)
        }
        return hook.touchesShouldBegin(touches, with: event, in: view)
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        guard let hook = touchHook else {
            return super.touchesShouldCancel(in: view)
        }
        return hook.touchesShouldCancel(in: view)
    }
}

/**
 帮助：当style为grouped或insetGrouped时，列表顶部会多出一部分间隔，此时我们可以设置一个tableHeaderView，
 并将其高度设置为大于0，且小于1的值即可。
 */
open class DrFlexTableView: UIView, DrScrollViewTouchHook {
    
    private let table: _TableView
    /// 内部的UITableView（注意：请不要直接改变其相关的代理方法，否则内部将无法正确工作）
    public var innerTable: UITableView { table }
    
    /// 存储每组cell视图
    private lazy var cellViewMap: [Int: DrFlexCellMap] = [:]
    private lazy var headerViewMap: [Int: UIView] = [:]
    private lazy var footerViewMap: [Int: UIView] = [:]
    
    fileprivate var dataSource: DrFlexTableDataSource?
    fileprivate var delegate: DrFlexTableDelegate?
    
    /// UIScrollView代理
    public let scrollDelegate = DrFlexScrollViewCallback()
    
    /// cell高度是否相同（会优化加载速度），默认：false（不相同）
    public var isSameHeight = false
    public var isSameSectionHeaderHeight = false
    public var isSameSectionFooterHeight = false
    
    public var sectionHeaderHeight: CGFloat = 0
    public var sectionFooterHeight: CGFloat = 0
    
    
    public init(style: UITableView.Style) {
        table = _TableView(frame: .zero, style: style)
        table.backgroundColor = .white
        table.estimatedRowHeight = 0
        table.estimatedSectionHeaderHeight = 0
        table.estimatedSectionFooterHeight = 0
        table.separatorStyle = .none
        table.register(UITableViewCell.self, forCellReuseIdentifier: kDrFlexCellIdentifier)
        table.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: kDrFlexHeaderFooterIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        
        let header = UIView()
        header.frame = CGRect(x: 0, y: 0, width: 0, height: 0.0001)
        table.tableHeaderView = header
        table.tableFooterView = UIView()
        super.init(frame: .zero)
        addSubview(table)
        self.dataSource = DrFlexTableDataSource(flexTable: self)
        self.delegate = DrFlexTableDelegate(flexTable: self)
        table.touchHook = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        table.frame = bounds
        layoutTableHeaderView()
        layoutTableFooterView()
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        table.dataSource = dataSource
        table.delegate = delegate
    }
    
    // MARK: - Tools
    
    /// 重新构建全部cell、headerView、footerView视图
    public func reload() {
        cellViewMap.removeAll()
        headerViewMap.removeAll()
        footerViewMap.removeAll()
        table.reloadData()
    }
    
    /// 重新构建指定分组的cell、headerView、footerView视图
    public func reloadSections(_ sections: IndexSet, with: UITableView.RowAnimation = .none) {
        for section in sections {
            cellViewMap[section] = nil
            headerViewMap[section] = nil
            footerViewMap[section] = nil
        }
        table.reloadSections(sections, with: with)
    }
    
    /// 重新构建指定cell视图
    public func reloadRows(at: [IndexPath], with: UITableView.RowAnimation = .none) {
        for indexPath in at {
            cellViewMap[indexPath.section]?[indexPath.row] = nil
        }
        table.reloadRows(at: at, with: with)
    }
    
    /**
     刷新全部列表视图（不会重新构建cell）
     
     - Parameter needLayout: 是否需要重新计算布局（默认：false）
     */
    public func refresh(needLayout: Bool = false) {
        if needLayout {
            cellViewMap.values.forEach({ $0.allValues.forEach({ ($0 as? UIView)?.dr_needLayout = true }) })
            headerViewMap.values.forEach({ $0.dr_needLayout = true })
            footerViewMap.values.forEach({ $0.dr_needLayout = true })
        }
        table.reloadData()
    }
    
    /**
     刷新指定分组（不会重新构建cell）
     
     - Parameter sections: 分组下标集合
     - Parameter with: 刷新动画（默认：无）
     - Parameter needLayout: 是否需要重新计算布局（默认：false）
     */
    public func refreshSections(_ sections: IndexSet, with: UITableView.RowAnimation = .none, needLayout: Bool = false) {
        if needLayout {
            for section in sections {
                cellViewMap[section]?.allValues.forEach({($0 as? UIView)?.dr_needLayout = true})
            }
        }
        table.reloadSections(sections, with: with)
    }
    
    /**
     刷新指定cell（不会重新构建cell）
     
     - Parameter at: cell所在下标
     - Parameter with: 刷新动画（默认：无）
     - Parameter needLayout: 是否需要重新计算布局（默认：false）
     */
    public func refreshRows(at: [IndexPath], with: UITableView.RowAnimation = .none, needLayout: Bool = false) {
        if needLayout {
            at.forEach({(cellViewMap[$0.section]?[$0.row] as? UIView)?.dr_needLayout = true})
        }
        table.reloadRows(at: at, with: with)
    }
    
    /**
     删除指定cell
     
     - Parameter at: cell所在下标
     - Parameter with: 刷新动画（默认：无）
     */
    public func deleteRows(at indexs: [IndexPath], with animate: UITableView.RowAnimation = .none) {
        indexs.forEach { path in
            cellViewMap[path.section]?[path.row] = nil
        }
        table.deleteRows(at: indexs, with: animate)
    }
    
    /**
     在指定section中指定位置插入cell个数
     
     - Parameter rowsCount: 插入cell的个数
     - Parameter section: section索引
     - Parameter at: 插入位置下标
     - Parameter with: 刷新动画（默认：无）
     */
    public func insertRows(rowsCount: Int,
                           section: Int,
                           at insertIndex: Int,
                           with animate: UITableView.RowAnimation = .none) {
        guard rowsCount > 0 else {
            return
        }
        var indxs: [IndexPath] = []
        for i in 0..<rowsCount {
            indxs.append(IndexPath(row: insertIndex + i, section: section))
        }
        table.insertRows(at: indxs, with: animate)
    }
    
//    /**
//     删除指定section
//
//     - Parameter sections: section所在下标
//     - Parameter with: 刷新动画（默认：无）
//     */
//    public func deleteSections(sections: IndexSet, with animate: UITableView.RowAnimation = .none) {
//        var secs: [IndexSet.Element] = []
//        for section in sections {
//            guard let _ = cellViewMap[section] else {
//                continue
//            }
//            secs.append(section)
//            cellViewMap.removeValue(forKey: section)
//        }
//        if secs.count > 0 {
//            table.deleteSections(IndexSet(secs), with: animate)
//        }
//    }
    
    /// 重新计算tableHeaderView布局
    public func layoutTableHeaderView() {
        if let header = table.tableHeaderView, header.isYogaEnabled {
            header.dr_resetWidth(bounds.width)
            header.dr_flex.layout(mode: .adjustHeight)
            table.tableHeaderView = header
        }
    }
    
    /// 重新计算tableFooterView布局
    public func layoutTableFooterView() {
        if let footer = table.tableFooterView, footer.isYogaEnabled {
            footer.dr_resetWidth(bounds.width)
            footer.dr_flex.layout(mode: .adjustHeight)
            table.tableFooterView = footer
        }
    }
    
    /**
     增加一组列表视图（这是除了绑定数据源的方式加载列表外，另一种加载列表的方式。使用该方式加载列表时，请不要再使用数据绑定的方式，否则列表显示条数可能不正常）
     
     - Parameter section: 组对象
     - Parameter refresh: 是否立即刷新列表，默认：false（需要手动调用refresh()刷新列表）
     */
    public func appendGroup(_ section: DRFlexTableGroup, immediateRefresh refresh: Bool = false) {
        let sectionIndex: Int
        if let maxKey = cellViewMap.keys.max() {
            sectionIndex = maxKey + 1
        }else {
            sectionIndex = 0
        }
        let cellMap = DrFlexCellMap()
        for (i, v) in section.cellList.enumerated() {
            v.dr_needLayout = true
            cellMap[i] = v
        }
        cellViewMap[sectionIndex] = cellMap
        if let header = section.headerView {
            header.dr_needLayout = true
            appendHeaderView(header: header, section: sectionIndex)
        }
        if let footer = section.footerView {
            footer.dr_needLayout = true
            appendFooterView(footer: footer, section: sectionIndex)
        }
        self.groupCount = sectionIndex + 1
        if refresh {
            table.reloadData()
        }
    }
    
    /**
     获取指定indexPath的cell视图
     
     - Parameter indexPath: IndexPath
     
     - Returns: cell视图
     */
    public func cell<T: UIView>(at indexPath: IndexPath) -> T? {
        cell(atRow: indexPath.row, atSection: indexPath.section)
    }
    
    /**
     获取指定组下的指定行的cell视图
     
     - Parameter row: 行下标
     - Parameter section: 组下标
     
     - Returns: cell视图
     */
    public func cell<T: UIView>(atRow row: Int, atSection section: Int) -> T? {
        guard let list = cellViewMap[section] else { return nil }
        guard list.count > row else { return nil }
        guard let cell = list[row] as? T else { return nil }
        return cell
    }
    
    /**
     获取可见区域的cell视图
     */
    public func visibleCells<T: UIView>() -> [T]? {
        guard let list = indexPathsForVisibleRows else {
            return nil
        }
        var arr = [T]()
        for indexPath in list {
            if let cell: T = cell(at: indexPath) {
                arr.append(cell)
            }
        }
        return arr
    }
    
    /**
     获取指定组的HeaderView
     
     - Parameter section: 组下标
     
     - Returns: HeaderView
     */
    public func headerView<T: UIView>(atSection section: Int) -> T? {
        guard let header = headerViewMap[section] as? T else {
            return nil
        }
        return header
    }
    
    /**
     获取指定组的FooterView
     
     - Parameter section: 组下标
     
     - Returns: FooterView
     */
    public func footerView<T: UIView>(atSection section: Int) -> T? {
        guard let footer = footerViewMap[section] as? T else {
            return nil
        }
        return footer
    }
    
    public func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        true
    }
    
    public func touchesShouldCancel(in view: UIView) -> Bool {
        view is UIControl
    }
    
    /// 设置cell编辑状态
    fileprivate func setCellEditing(_ isEditing: Bool, animated: Bool) {
        visibleCells()?.forEach({ cell in
            if let c = cell as? DrCellEditing, c.isEditing != isEditing {
                c.setEditing(isEditing, animated: animated)
            }
        })
        table.visibleCells.forEach { [weak self] cell in
            self?.setCellSelectionStyle(cell: cell)
        }
    }
    
    /// 设置指定cell编辑状态
    fileprivate func setCellEditing(_ isEditing: Bool, animated: Bool, indexPath: IndexPath) {
        guard let cell = cell(at: indexPath) as? DrCellEditing, cell.isEditing != isEditing else {
            return
        }
        cell.setEditing(isEditing, animated: animated)
    }
    
    /// 设置cell选中style
    fileprivate func setCellSelectionStyle(cell: UITableViewCell) {
        if isEditing {
            // cell.selectionStyle = .none // 设置该值会导致多选时，选择按钮点击没有选中状态，因此采用下面方法
            if allowsMultipleSelectionDuringEditing {
                if cell.multipleSelectionBackgroundView == nil {
                    let v = UIView()
                    v.backgroundColor = backgroundColor
                    cell.multipleSelectionBackgroundView = v
                }
                cell.selectionStyle = .default
            }else {
                cell.selectionStyle = .none
            }
        }else {
            cell.selectionStyle = .none
        }
    }
    
    /// 存储cell视图
    fileprivate func appendCell(cell: UIView?, atIndexPath indexPath: IndexPath) {
        if let map = cellViewMap[indexPath.section] {
            map[indexPath.row] = cell
        }else{
            let map = DrFlexCellMap()
            map[indexPath.row] = cell
            cellViewMap[indexPath.section] = map
        }
    }
    /// 存储headerView
    fileprivate func appendHeaderView(header: UIView, section: Int) {
        headerViewMap[section] = header
    }
    /// 存储footerView
    fileprivate func appendFooterView(footer: UIView, section: Int) {
        footerViewMap[section] = footer
    }
    
    /// 组个数
    fileprivate var groupCount: Int?
    /// 获取每组的cell个数
    fileprivate func cellCount(group: Int) -> Int {
        guard let li = cellViewMap[group] else {
            return 0
        }
        return li.count
    }
    
}


// MARK: - TableView Paramters

extension DrFlexTableView {
    
    public var rowHeight: CGFloat {
        set {
            table.rowHeight = newValue
        }
        get {
            table.rowHeight
        }
    }
    
    public var allowsSelection: Bool {
        set {
            table.allowsSelection = newValue
        }
        get {
            table.allowsSelection
        }
    }

    public var allowsSelectionDuringEditing: Bool {
        set {
            table.allowsSelectionDuringEditing = newValue
        }
        get {
            table.allowsSelectionDuringEditing
        }
    }

    public var allowsMultipleSelection: Bool {
        set {
            table.allowsMultipleSelection = newValue
        }
        get {
            table.allowsMultipleSelection
        }
    }
    
    public var allowsMultipleSelectionDuringEditing: Bool {
        set {
            table.allowsMultipleSelectionDuringEditing = newValue
        }
        get {
            table.allowsMultipleSelectionDuringEditing
        }
    }
    
    @available(iOS 11.0, *)
    public var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
        set {
            table.contentInsetAdjustmentBehavior = newValue
        }
        get {
            table.contentInsetAdjustmentBehavior
        }
    }
    
    public override var backgroundColor: UIColor?{
        set {
            self.table.backgroundColor = newValue
        }
        get {
            self.table.backgroundColor
        }
    }
    
    public var sectionHeaderTopPadding: CGFloat {
        set {
            if #available(iOS 15.0, *) {
                table.sectionHeaderTopPadding = newValue
            }
        }
        get {
            if #available(iOS 15.0, *) {
                return table.sectionHeaderTopPadding
            }else{
                return 0
            }
        }
    }
    
    public var contentInset: UIEdgeInsets {
        set {
            table.contentInset = newValue
        }
        get {
            table.contentInset
        }
    }
    
    public var contentOffset: CGPoint {
        set {
            table.contentOffset = newValue
        }
        get {
            table.contentOffset
        }
    }
    
    public var bouncesZoom: Bool {
        set {
            table.bouncesZoom = newValue
        }
        get {
            table.bouncesZoom
        }
    }
    
    public var bounces: Bool {
        set {
            table.bounces = newValue
        }
        get {
            table.bounces
        }
    }
    
    public var showsVerticalScrollIndicator: Bool {
        set {
            table.showsVerticalScrollIndicator = newValue
        }
        get {
            table.showsVerticalScrollIndicator
        }
    }
    
    public var showsHorizontalScrollIndicator: Bool {
        set {
            table.showsHorizontalScrollIndicator = newValue
        }
        get {
            table.showsHorizontalScrollIndicator
        }
    }
    
    /// show special section index list on right when row count reaches this value. default is 0
    public var sectionIndexMinimumDisplayRowCount: Int {
        set {
            table.sectionIndexMinimumDisplayRowCount = newValue
        }
        get {
            table.sectionIndexMinimumDisplayRowCount
        }
    }
    
    /// color used for text of the section index
    public var sectionIndexColor: UIColor? {
        set {
            table.sectionIndexColor = newValue
        }
        get {
            table.sectionIndexColor
        }
    }
    
    /// the background color of the section index while not being touched
    public var sectionIndexBackgroundColor: UIColor? {
        set {
            table.sectionIndexBackgroundColor = newValue
        }
        get {
            table.sectionIndexBackgroundColor
        }
    }
    
    /// the background color of the section index while it is being touched
    public var sectionIndexTrackingBackgroundColor: UIColor? {
        set {
            table.sectionIndexTrackingBackgroundColor = newValue
        }
        get {
            table.sectionIndexTrackingBackgroundColor
        }
    }
    
    public var separatorStyle: UITableViewCell.SeparatorStyle{
        set {
            table.separatorStyle = newValue
        }
        get {
            table.separatorStyle
        }
    }
    
    public var separatorColor: UIColor? {
        set {
            table.separatorColor = newValue
        }
        get {
            table.separatorColor
        }
    }
    
    public var separatorInset: UIEdgeInsets {
        set {
            table.separatorInset = newValue
        }
        get {
            table.separatorInset
        }
    }
    
    public var separatorEffect: UIVisualEffect? {
        set {
            table.separatorEffect = newValue
        }
        get {
            table.separatorEffect
        }
    }
    
    /// default value is YES
    public var insetsContentViewsToSafeArea: Bool {
        set {
            if #available(iOS 11.0, *) {
                table.insetsContentViewsToSafeArea = newValue
            }
        }
        get {
            if #available(iOS 11.0, *) {
                return table.insetsContentViewsToSafeArea
            }
            return true
        }
    }
    
    @available(iOS 11.0, *)
    public var separatorInsetReference: UITableView.SeparatorInsetReference {
        set {
            table.separatorInsetReference = newValue
        }
        get {
            table.separatorInsetReference
        }
    }
    
    public var tableHeaderView: UIView? {
        set {
            if let view = newValue, view.isYogaEnabled, bounds.size != .zero {
                view.dr_resetWidth(bounds.width)
                view.dr_flex.layout(mode: .adjustHeight)
                table.tableHeaderView = view
            }else {
                table.tableHeaderView = newValue
            }
        }
        get {
            table.tableHeaderView
        }
    }
    
    public var tableFooterView: UIView? {
        set {
            if let view = newValue, view.isYogaEnabled, bounds.size != .zero {
                view.dr_resetWidth(bounds.width)
                view.dr_flex.layout(mode: .adjustHeight)
                table.tableFooterView = view
            }else {
                table.tableFooterView = newValue
            }
        }
        get {
            table.tableFooterView
        }
    }
    
    public var style: UITableView.Style { table.style }
    
    public var isPrefetchingEnabled: Bool {
        set {
            if #available(iOS 15.0, *) {
                table.isPrefetchingEnabled = newValue
            }
        }
        get {
            if #available(iOS 15.0, *) {
                return table.isPrefetchingEnabled
            }
            return false
        }
    }
    
    public var backgroundView: UIView? {
        set {
            table.backgroundView = newValue
        }
        get {
            table.backgroundView
        }
    }
    
    @available(iOS 13.0, *)
    public var contextMenuInteraction: UIContextMenuInteraction? {
        if #available(iOS 14.0, *) {
            return table.contextMenuInteraction
        }
        return nil
    }
    
    public var numberOfSections: Int { table.numberOfSections }
    
}

// MARK: - TableView Methods

extension DrFlexTableView {
    
    public func numberOfRows(inSection section: Int) -> Int { table.numberOfRows(inSection: section) }
    /// includes header, footer and all rows
    func rect(forSection section: Int) -> CGRect { table.rect(forSection: section) }
    public func rectForHeader(inSection section: Int) -> CGRect { table.rectForHeader(inSection: section) }
    public func rectForFooter(inSection section: Int) -> CGRect { table.rectForFooter(inSection: section) }
    public func rectForRow(at indexPath: IndexPath) -> CGRect { table.rectForRow(at: indexPath) }
    /// returns nil if point is outside of any row in the table
    public func indexPathForRow(at point: CGPoint) -> IndexPath? { table.indexPathForRow(at: point) }
    /// returns nil if rect not valid
    public func indexPathsForRows(in rect: CGRect) -> [IndexPath]? { table.indexPathsForRows(in: rect) }
    public var indexPathsForVisibleRows: [IndexPath]? { table.indexPathsForVisibleRows }
    
    public func scrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        table.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }

    public func scrollToNearestSelectedRow(at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        table.scrollToNearestSelectedRow(at: scrollPosition, animated: animated)
    }
    
    // Allows multiple insert/delete/reload/move calls to be animated simultaneously. Nestable.
    @available(iOS 11.0, *)
    public func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        table.performBatchUpdates(updates, completion: completion)
    }
    
    public func moveSection(_ section: Int, toSection newSection: Int) { table.moveSection(section, toSection: newSection) }
    public func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) { table.moveRow(at: indexPath, to: newIndexPath) }
    
    public var hasUncommittedUpdates: Bool {
        if #available(iOS 11.0, *) {
            return table.hasUncommittedUpdates
        }
        return false
    }
    
    public func reloadSectionIndexTitles() { table.reloadSectionIndexTitles() }
    
    /// default is NO. setting is not animated.
    public var isEditing: Bool {
        set {
            table.isEditing = newValue
            setCellEditing(newValue, animated: false)
        }
        get {
            table.isEditing
        }
    }
    
    public func setEditing(_ editing: Bool, animated: Bool) {
        table.setEditing(editing, animated: animated)
        setCellEditing(editing, animated: animated)
    }
    
    // Selection
    
    /// returns nil or index path representing section and row of selection.
    public var indexPathForSelectedRow: IndexPath? { table.indexPathForSelectedRow }

    /// returns nil or a set of index paths representing the sections and rows of the selection.
    public var indexPathsForSelectedRows: [IndexPath]? { table.indexPathsForSelectedRows }
    
    /// Selects and deselects rows. These methods will not call the delegate methods (-tableView:willSelectRowAtIndexPath: or tableView:didSelectRowAtIndexPath:), nor will it send out a notification.
    public func selectRow(at indexPath: IndexPath?, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
        table.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }

    public func deselectRow(at indexPath: IndexPath, animated: Bool) {
        table.deselectRow(at: indexPath, animated: animated)
    }
}


// MARK: - 绑定TableView相关回调
extension DrFlexTableView {
    
    /// 绑定分组个数回调
    public func numberOfSections<T: AnyObject>(_ target: T, binding: @escaping (_ target: T)->Int) {
        weak var weakTarget = target
        self.dataSource?.numberOfSections = {
            if let target = weakTarget {
                return binding(target)
            }
            return 0
        }
    }
    
    /// 绑定每组下的cell个数回调
    public func numberOfRowsInSection<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ section: Int)->Int) {
        weak var weakTarget = target
        self.dataSource?.numberOfRowsInSection = { (section) in
            if let target = weakTarget {
                return binding(target, section)
            }
            return 0
        }
    }
    
    
    /// 初始化cell
    public func cellInit<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->UIView?) {
        weak var weakTarget = target
        self.delegate?.cellInit = { (indexPath) in
            if let target = weakTarget {
                return binding(target, indexPath)
            }
            return nil
        }
    }
    
    /// 初始化每组的headerView
    public func headerInit<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ section: Int) -> UIView?) {
        weak var weakTarget = target
        self.delegate?.headerInit = { (section) in
            if let target = weakTarget {
                return binding(target, section)
            }
            return nil
        }
    }
    
    /// 初始化每组的footerView
    public func footerInit<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ section: Int) -> UIView?) {
        weak var weakTarget = target
        self.delegate?.footerInit = { (section) in
            if let target = weakTarget {
                return binding(target, section)
            }
            return nil
        }
    }
    
    /// 更新cell视图
    public func cellUpdate<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ cell: UIView, _ indexPath: IndexPath) -> Bool) {
        weak var weakTarget = target
        self.delegate?.updateCellData = { (cell, indexPath) in
            if let target = weakTarget {
                return binding(target, cell, indexPath)
            }
            return false
        }
    }
    
    /// 绑定cell点击回调
    public func cellClick<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Void) {
        weak var weakTarget = target
        self.delegate?.cellClick = { (indexPath) in
            if let target = weakTarget {
                binding(target, indexPath)
            }
        }
    }
    
    public func canEditRow<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Bool) {
        weak var weakTarget = target
        self.dataSource?.canEditRow = { (indexPath) in
            if let target = weakTarget {
                return binding(target, indexPath)
            }
            return false
        }
    }
    
    public func canMoveRow<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Bool) {
        weak var weakTarget = target
        self.dataSource?.canMoveRow = { (indexPath) in
            if let target = weakTarget {
                return binding(target, indexPath)
            }
            return false
        }
    }
    
    /// 列表右侧索引列表数据绑定
    public func sectionIndexTitles<T: AnyObject>(_ target: T, binding: @escaping (_ target: T)->[String]?) {
        weak var weakTarget = target
        self.dataSource?.sectionIndexTitles = {
            if let target = weakTarget {
                return binding(target)
            }
            return nil
        }
    }
    
    /// 列表右侧索引列表index映射到tableview section下标绑定
    public func sectionForSectionIndex<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ title: String, _ index: Int)->Int) {
        weak var weakTarget = target
        self.dataSource?.sectionForSectionIndex = { (title, index) in
            if let target = weakTarget {
                return binding(target, title, index)
            }
            return 0
        }
    }
    
    public func commitEditing<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ style: UITableViewCell.EditingStyle, _ indexPath: IndexPath)->Void) {
        weak var weakTarget = target
        self.dataSource?.commitEditing = { (style, indexPath) in
            if let target = weakTarget {
                binding(target, style, indexPath)
            }
        }
    }
    
    public func moveRow<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ from: IndexPath, _ to: IndexPath)->Void) {
        weak var weakTarget = target
        self.dataSource?.moveRow = { (from, to) in
            if let target = weakTarget {
                binding(target, from, to)
            }
        }
    }
    
    public func cellWillDisplay<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ cell: UIView, _ indexPath: IndexPath)->Void) {
        weak var weakTarget = target
        self.delegate?.cellWillDisplay = { (cell, indexPath) in
            if let target = weakTarget {
                binding(target, cell, indexPath)
            }
        }
    }
    
    public func headerWillDisplay<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ header: UIView, _ section: Int)->Void) {
        weak var weakTarget = target
        self.delegate?.headerWillDisplay = { (header, section) in
            if let target = weakTarget {
                binding(target, header, section)
            }
        }
    }
    
    public func footerWillDisplay<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ footer: UIView, _ section: Int)->Void) {
        weak var weakTarget = target
        self.delegate?.footerWillDisplay = { (footer, section) in
            if let target = weakTarget {
                binding(target, footer, section)
            }
        }
    }
    
    public func cellDidEndDisplaying<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ cell: UIView, _ indexPath: IndexPath)->Void) {
        weak var weakTarget = target
        self.delegate?.cellDidEndDisplaying = { (cell, indexPath) in
            if let target = weakTarget {
                binding(target, cell, indexPath)
            }
        }
    }
    
    public func headerDidEndDisplaying<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ header: UIView, _ section: Int)->Void) {
        weak var weakTarget = target
        self.delegate?.headerDidEndDisplaying = { (header, section) in
            if let target = weakTarget {
                binding(target, header, section)
            }
        }
    }
    
    public func footerDidEndDisplaying<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ footer: UIView, _ section: Int)->Void) {
        weak var weakTarget = target
        self.delegate?.footerDidEndDisplaying = { (footer, section) in
            if let target = weakTarget {
                binding(target, footer, section)
            }
        }
    }
    
    public func accessoryButtonTapped<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Void) {
        weak var weakTarget = target
        self.delegate?.accessoryButtonTapped = { (indexPath) in
            if let target = weakTarget {
                binding(target, indexPath)
            }
        }
    }
    
    public func shouldHighlightRow<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Bool) {
        weak var weakTarget = target
        self.delegate?.shouldHighlightRow = { (indexPath) in
            if let target = weakTarget {
                return binding(target, indexPath)
            }
            return false
        }
    }
    
    public func didHighlightRow<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Void) {
        weak var weakTarget = target
        self.delegate?.didHighlightRow = { (indexPath) in
            if let target = weakTarget {
                binding(target, indexPath)
            }
        }
    }
    
    public func didUnhighlightRow<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Void) {
        weak var weakTarget = target
        self.delegate?.didUnhighlightRow = { (indexPath) in
            if let target = weakTarget {
                binding(target, indexPath)
            }
        }
    }
    
    public func willSelectRow<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->IndexPath?) {
        weak var weakTarget = target
        self.delegate?.willSelectRow = { (indexPath) in
            if let target = weakTarget {
                return binding(target, indexPath)
            }
            return indexPath
        }
    }
    
    public func willDeselectRow<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->IndexPath?) {
        weak var weakTarget = target
        self.delegate?.willDeselectRow = { (indexPath) in
            if let target = weakTarget {
                return binding(target, indexPath)
            }
            return indexPath
        }
    }
    
    public func didDeselectRow<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Void) {
        weak var weakTarget = target
        self.delegate?.didDeselectRow = { (indexPath) in
            if let target = weakTarget {
                binding(target, indexPath)
            }
        }
    }
    
    public func editingStyle<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->UITableViewCell.EditingStyle) {
        weak var weakTarget = target
        self.delegate?.editingStyle = { (indexPath) in
            if let target = weakTarget {
                return binding(target, indexPath)
            }
            return .none
        }
    }
    
    public func titleForDeleteConfirmationButton<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->String?) {
        weak var weakTarget = target
        self.delegate?.titleForDeleteConfirmationButton = { (indexPath) in
            if let target = weakTarget{
                return binding(target, indexPath)
            }
            return nil
        }
    }
    
    @available(iOS 11.0, *)
    public func trailingSwipeActionsForRowAt<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->UISwipeActionsConfiguration?) {
        weak var weakTarget = target
        self.delegate?.trailingSwipeActions = { (indexPath) in
            if let target = weakTarget {
                return binding(target, indexPath)
            }
            return nil
        }
    }
    
    public func shouldIndentWhileEditing<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Bool) {
        weak var weakTarget = target
        self.delegate?.shouldIndentWhileEditing = { (indexPath) in
            if let target = weakTarget{
                return binding(target, indexPath)
            }
            return false
        }
    }
    
    public func willBeginEditing<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Void) {
        weak var weakTarget = target
        self.delegate?.willBeginEditing = { (indexPath) in
            if let target = weakTarget {
                binding(target, indexPath)
            }
        }
    }
    
    public func didEndEditing<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath?)->Void) {
        weak var weakTarget = target
        self.delegate?.didEndEditing = { (indexPath) in
            if let target = weakTarget {
                binding(target, indexPath)
            }
        }
    }
    
    public func targetIndexPathForMove<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ from: IndexPath, _ to: IndexPath)->IndexPath) {
        weak var weakTarget = target
        self.delegate?.targetIndexPathForMove = { (from, to) in
            if let target = weakTarget {
                return binding(target, from, to)
            }
            return to
        }
    }
    
    public func indentationLevel<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Int) {
        weak var weakTarget = target
        self.delegate?.indentationLevel = { (indexPath) in
            if let target = weakTarget {
                return binding(target, indexPath)
            }
            return 0
        }
    }
    
    public func canFocus<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Bool) {
        weak var weakTarget = target
        self.delegate?.canFocus = { (indexPath) in
            if let target = weakTarget {
                return binding(target, indexPath)
            }
            return false
        }
    }
    
    public func shouldUpdateFocus<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ context: UITableViewFocusUpdateContext)->Bool) {
        weak var weakTarget = target
        self.delegate?.shouldUpdateFocus = { (context) in
            if let target = weakTarget {
                return binding(target, context)
            }
            return false
        }
    }
    
    public func didUpdateFocus<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ context: UITableViewFocusUpdateContext, _ coordinator: UIFocusAnimationCoordinator)->Void) {
        weak var weakTarget = target
        self.delegate?.didUpdateFocus = { (context, coordinator) in
            if let target = weakTarget {
                binding(target, context, coordinator)
            }
        }
    }
    
    public func indexPathForPreferredFocusedView<T: AnyObject>(_ target: T, binding: @escaping (_ target: T)->IndexPath?) {
        weak var weakTarget = target
        self.delegate?.indexPathForPreferredFocusedView = {
            if let target = weakTarget {
                return binding(target)
            }
            return nil
        }
    }
    
    @available(iOS 13.0, *)
    public func contextMenuConfiguration<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath, _ point: CGPoint)->UIContextMenuConfiguration?) {
        weak var weakTarget = target
        self.delegate?.contextMenuConfiguration = { (indexPath, point) in
            if let target = weakTarget{
                return binding(target, indexPath, point)
            }
            return nil
        }
    }
    
    @available(iOS 13.0, *)
    public func previewForHighlightingContextMenu<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ config: UIContextMenuConfiguration)->UITargetedPreview?) {
        weak var weakTarget = target
        self.delegate?.previewForHighlightingContextMenu = { (config) in
            if let target = weakTarget {
                return binding(target, config as! UIContextMenuConfiguration) as Any
            }
            return nil
        }
    }
    
    @available(iOS 13.0, *)
    public func previewForDismissingContextMenu<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ config: UIContextMenuConfiguration)->UITargetedPreview?) {
        weak var weakTarget = target
        self.delegate?.previewForDismissingContextMenu = { (config) in
            if let target = weakTarget {
                return binding(target, config as! UIContextMenuConfiguration) as Any
            }
            return nil
        }
    }
    
    @available(iOS 13.0, *)
    public func willPerformPreviewAction<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ config: UIContextMenuConfiguration, _ animator: UIContextMenuInteractionCommitAnimating)->Void) {
        weak var weakTarget = target
        self.delegate?.willPerformPreviewAction = { (config, animator) in
            if let target = weakTarget {
                binding(target, config as! UIContextMenuConfiguration, animator as! UIContextMenuInteractionCommitAnimating)
            }
        }
    }
    
    @available(iOS 13.0, *)
    public func willDisplayContextMenu<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ config: UIContextMenuConfiguration, _ animator: UIContextMenuInteractionAnimating?)->Void) {
        weak var weakTarget = target
        self.delegate?.willDisplayContextMenu = { (config, animator) in
            if let target = weakTarget {
                binding(target, config as! UIContextMenuConfiguration, animator as? UIContextMenuInteractionAnimating)
            }
        }
    }
    
    @available(iOS 13.0, *)
    public func willEndContextMenuInteraction<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ config: UIContextMenuConfiguration, _ animator: UIContextMenuInteractionAnimating?)->Void) {
        weak var weakTarget = target
        self.delegate?.willEndContextMenuInteraction = { (config, animator) in
            if let target = weakTarget {
                binding(target, config as! UIContextMenuConfiguration, animator as? UIContextMenuInteractionAnimating)
            }
        }
    }
    
}


// MARK: - TableView DataSource

fileprivate let kDrCellTag = 30303

fileprivate class DrFlexTableDataSource: NSObject, UITableViewDataSource {
    
    weak var flexTable: DrFlexTableView?
    
    /// 返回分组个数
    var numberOfSections: (()->Int)?
    /// 返回每组下的cell个数
    var numberOfRowsInSection: ((Int)->Int)?
    var canEditRow: ((IndexPath)->Bool)?
    var canMoveRow: ((IndexPath)->Bool)?
    var sectionIndexTitles: (()->[String]?)?
    var sectionForSectionIndex: ((String, Int)->Int)?
    var commitEditing: ((UITableViewCell.EditingStyle, IndexPath)->Void)?
    var moveRow: ((IndexPath, IndexPath)->Void)?
    
    init(flexTable: DrFlexTableView) {
        self.flexTable = flexTable
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let action = numberOfSections {
            return action()
        }
        if let count = flexTable?.groupCount {
            return count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let action = numberOfRowsInSection {
            return action(section)
        }
        return flexTable?.cellCount(group: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kDrFlexCellIdentifier, for: indexPath)
        cell.contentView.backgroundColor = tableView.backgroundColor
        cell.contentView.viewWithTag(kDrCellTag)?.removeFromSuperview()
        if let view = flexTable?.cell(at: indexPath) {
            view.removeFromSuperview()
            view.tag = kDrCellTag
            cell.contentView.addSubview(view)
        }else {
            if tableView.rowHeight > 0 {
                if let cellView = flexTable?.delegate?.cellInit?(indexPath) {
                    if let c = cellView as? DrCellEditing {
                        c.setEditing(tableView.isEditing, animated: false)
                    }
                    if cellView.isYogaEnabled {
                        cellView.dr_resetSize(CGSize(width: tableView.frame.width, height: tableView.rowHeight))
                        cellView.dr_flex.layout()
                    }
                    flexTable?.appendCell(cell: cellView, atIndexPath: indexPath)
                    cellView.tag = kDrCellTag
                    cell.contentView.addSubview(cellView)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        canEditRow?(indexPath) ?? false
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        canMoveRow?(indexPath) ?? false
    }

    
    // Index
    
    /// return list of section titles to display in section index view (e.g. "ABCD...Z#")
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        sectionIndexTitles?()
    }

    /// tell table which section corresponds to section title/index (e.g. "B",1))
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        sectionForSectionIndex?(title, index) ?? 0
    }

    
    // Data manipulation - insert and delete support
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        commitEditing?(editingStyle, indexPath)
    }

    
    // Data manipulation - reorder / moving support
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveRow?(sourceIndexPath, destinationIndexPath)
    }
    
}

// MARK: - TableView Delegate

fileprivate let kDrHeaderFooterTag = 40404

fileprivate class DrFlexTableDelegate: NSObject, UITableViewDelegate {
    
    weak var flexTable: DrFlexTableView?
    
    /// 初始化cell视图
    var cellInit: ((IndexPath)->UIView?)?
    /// 初始化headerView视图
    var headerInit: ((Int)->UIView?)?
    /// 初始化footerView视图
    var footerInit: ((Int)->UIView?)?
    /// 更新cell视图数据源
    var updateCellData: ((UIView, IndexPath)->Bool)?
    /// cell点击
    var cellClick: ((IndexPath)->Void)?
    var cellWillDisplay: ((UIView, IndexPath)->Void)?
    var headerWillDisplay: ((UIView, Int)->Void)?
    var footerWillDisplay: ((UIView, Int)->Void)?
    
    var cellDidEndDisplaying: ((UIView, IndexPath)->Void)?
    var headerDidEndDisplaying: ((UIView, Int)->Void)?
    var footerDidEndDisplaying: ((UIView, Int)->Void)?
    
    var accessoryButtonTapped: ((IndexPath)->Void)?
    var shouldHighlightRow: ((IndexPath)->Bool)?
    var didHighlightRow: ((IndexPath)->Void)?
    var didUnhighlightRow: ((IndexPath)->Void)?
    
    var willSelectRow: ((IndexPath)->IndexPath?)?
    var willDeselectRow: ((IndexPath)->IndexPath?)?
    var didDeselectRow: ((IndexPath)->Void)?
    
    var editingStyle: ((IndexPath)->UITableViewCell.EditingStyle)?
    
    var titleForDeleteConfirmationButton: ((IndexPath)->String?)?
    
    var trailingSwipeActions: ((IndexPath)->Any?)?
    
    var shouldIndentWhileEditing: ((IndexPath)->Bool)?
    var willBeginEditing: ((IndexPath)->Void)?
    var didEndEditing: ((IndexPath?)->Void)?
    
    var targetIndexPathForMove: ((IndexPath, IndexPath)->IndexPath)?
    var indentationLevel: ((IndexPath)->Int)?
    var canFocus: ((IndexPath)->Bool)?
    var shouldUpdateFocus: ((UITableViewFocusUpdateContext)->Bool)?
    var didUpdateFocus: ((UITableViewFocusUpdateContext, UIFocusAnimationCoordinator)->Void)?
    var indexPathForPreferredFocusedView: (()->IndexPath?)?
    
    var contextMenuConfiguration: ((IndexPath, CGPoint)->Any?)?
    var previewForHighlightingContextMenu: ((Any)->Any?)?
    var previewForDismissingContextMenu: ((Any)->Any?)?
    var willPerformPreviewAction: ((Any, Any)->Void)?
    var willDisplayContextMenu: ((Any, Any?)->Void)?
    var willEndContextMenuInteraction: ((Any, Any?)->Void)?
    
    
    init(flexTable: DrFlexTableView) {
        self.flexTable = flexTable
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellClick?(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard tableView.rowHeight <= 0 else {
            return tableView.rowHeight
        }
        if let cell = flexTable?.cell(at: indexPath) {
            if cell.dr_needLayout, cell.isYogaEnabled {
                if (updateCellData?(cell, indexPath) ?? false) {
                    cell.dr_needLayout = false
                    if tableView.rowHeight > 0 {
                        cell.dr_resetSize(CGSize(width: tableView.frame.width, height: tableView.rowHeight))
                        cell.dr_flex.layout()
                    }else {
                        cell.dr_resetWidth(tableView.frame.width)
                        cell.dr_flex.layout(mode: .adjustHeight)
                    }
                }
            }
            return cell.frame.height
        }
        guard let cell = cellInit?(indexPath) else {
            return 0
        }
        if let c = cell as? DrCellEditing {
            c.setEditing(tableView.isEditing, animated: false)
        }
        if cell.isYogaEnabled {
            cell.dr_resetWidth(tableView.frame.width)
            cell.dr_flex.layout(mode: .adjustHeight)
        }
        flexTable?.appendCell(cell: cell, atIndexPath: indexPath)
        if (flexTable?.isSameHeight ?? false) {
            flexTable?.rowHeight = cell.frame.height
        }
        return cell.frame.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = flexTable?.sectionHeaderHeight, height > 0 {
            return height
        }
        if let header = flexTable?.headerView(atSection: section) {
            if header.dr_needLayout, header.isYogaEnabled {
                header.dr_needLayout = false
                if let height = flexTable?.sectionHeaderHeight, height > 0 {
                    header.dr_resetSize(CGSize(width: tableView.frame.width, height: height))
                    header.dr_flex.layout()
                }else {
                    header.dr_resetWidth(tableView.frame.width)
                    header.dr_flex.layout(mode: .adjustHeight)
                }
            }
            return header.frame.height
        }
        guard let header = headerInit?(section) else {
            switch tableView.style {
            case .grouped, .insetGrouped:
                return CGFloat.leastNonzeroMagnitude
            default:
                return 0
            }
        }
        if header.isYogaEnabled {
            header.dr_resetWidth(tableView.frame.width)
            header.dr_flex.layout(mode: .adjustHeight)
        }
        flexTable?.appendHeaderView(header: header, section: section)
        if let isSame = flexTable?.isSameSectionHeaderHeight, isSame {
            flexTable?.sectionHeaderHeight = header.frame.height
        }
        return header.frame.height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = flexTable?.sectionFooterHeight, height > 0 {
            return height
        }
        if let footer = flexTable?.footerView(atSection: section) {
            if footer.dr_needLayout, footer.isYogaEnabled {
                footer.dr_needLayout = false
                if let height = flexTable?.sectionFooterHeight, height > 0 {
                    footer.dr_resetSize(CGSize(width: tableView.frame.width, height: height))
                    footer.dr_flex.layout()
                }else {
                    footer.dr_resetWidth(tableView.frame.width)
                    footer.dr_flex.layout(mode: .adjustHeight)
                }
            }
            return footer.frame.height
        }
        guard let footer = footerInit?(section) else {
            switch tableView.style {
            case .grouped, .insetGrouped:
                return CGFloat.leastNonzeroMagnitude
            default:
                return 0
            }
        }
        if footer.isYogaEnabled {
            footer.dr_resetWidth(tableView.frame.width)
            footer.dr_flex.layout(mode: .adjustHeight)
        }
        flexTable?.appendFooterView(footer: footer, section: section)
        if let isSame = flexTable?.isSameSectionFooterHeight, isSame {
            flexTable?.sectionFooterHeight = footer.frame.height
        }
        return footer.frame.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: kDrFlexHeaderFooterIdentifier)
        header?.contentView.viewWithTag(kDrHeaderFooterTag)?.removeFromSuperview()
        if let view = flexTable?.headerView(atSection: section) {
            view.removeFromSuperview()
            view.tag = kDrHeaderFooterTag
            header?.contentView.addSubview(view)
        }else {
            if let height = flexTable?.sectionHeaderHeight, height > 0 {
                if let headerView = headerInit?(section) {
                    if headerView.isYogaEnabled {
                        headerView.dr_resetSize(CGSize(width: tableView.frame.width, height: height))
                        headerView.dr_flex.layout()
                    }
                    flexTable?.appendHeaderView(header: headerView, section: section)
                    header?.contentView.addSubview(headerView)
                }
            }
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: kDrFlexHeaderFooterIdentifier)
        footer?.contentView.viewWithTag(kDrHeaderFooterTag)?.removeFromSuperview()
        if let view = flexTable?.footerView(atSection: section) {
            view.removeFromSuperview()
            view.tag = kDrHeaderFooterTag
            footer?.contentView.addSubview(view)
        }else {
            if let height = flexTable?.sectionFooterHeight, height > 0 {
                if let footerView = footerInit?(section) {
                    if footerView.isYogaEnabled {
                        footerView.dr_resetSize(CGSize(width: tableView.frame.width, height: height))
                        footerView.dr_flex.layout()
                    }
                    flexTable?.appendFooterView(footer: footerView, section: section)
                    footer?.contentView.addSubview(footerView)
                }
            }
        }
        return footer
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        flexTable?.setCellSelectionStyle(cell: cell)
        flexTable?.setCellEditing(tableView.isEditing, animated: false, indexPath: indexPath)
        if tableView.rowHeight > 0,
           let cellView = flexTable?.cell(at: indexPath), cellView.isYogaEnabled, cellView.dr_needLayout {
            cellView.dr_needLayout = false
            if (updateCellData?(cell, indexPath) ?? false) {
                cellView.dr_resetSize(CGSize(width: tableView.frame.width, height: tableView.rowHeight))
                cellView.dr_flex.layout()
            }
        }
        if let action = cellWillDisplay, let cellView = flexTable?.cell(at: indexPath) {
            action(cellView, indexPath)
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let height = flexTable?.sectionHeaderHeight, height > 0,
           let header = flexTable?.headerView(atSection: section), header.isYogaEnabled, header.dr_needLayout {
            header.dr_needLayout = false
            header.dr_resetSize(CGSize(width: tableView.frame.width, height: height))
            header.dr_flex.layout()
        }
        if let action = headerWillDisplay, let header = flexTable?.headerView(atSection: section) {
            action(header, section)
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let height = flexTable?.sectionFooterHeight, height > 0,
           let footer = flexTable?.footerView(atSection: section), footer.isYogaEnabled, footer.dr_needLayout {
            footer.dr_needLayout = false
            footer.dr_resetSize(CGSize(width: tableView.frame.width, height: height))
            footer.dr_flex.layout()
        }
        if let action = footerWillDisplay, let footer = flexTable?.footerView(atSection: section) {
            action(footer, section)
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let action = cellDidEndDisplaying else { return }
        if let cell = flexTable?.cell(at: indexPath) {
            action(cell, indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard let action = headerDidEndDisplaying else { return }
        if let header = flexTable?.headerView(atSection: section) {
            action(header, section)
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        guard let action = footerDidEndDisplaying else { return }
        if let footer = flexTable?.footerView(atSection: section) {
            action(footer, section)
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        accessoryButtonTapped?(indexPath)
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return shouldHighlightRow?(indexPath) ?? true // 注意：返回false时，selected回调将不执行
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        didHighlightRow?(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        didUnhighlightRow?(indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        willSelectRow?(indexPath) ?? indexPath
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        willDeselectRow?(indexPath) ?? indexPath
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        didDeselectRow?(indexPath)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        editingStyle?(indexPath) ?? .none
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        titleForDeleteConfirmationButton?(indexPath)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        trailingSwipeActions?(indexPath) as? UISwipeActionsConfiguration
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        shouldIndentWhileEditing?(indexPath) ?? false
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        willBeginEditing?(indexPath)
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        didEndEditing?(indexPath)
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        targetIndexPathForMove?(sourceIndexPath, proposedDestinationIndexPath) ?? proposedDestinationIndexPath
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        indentationLevel?(indexPath) ?? 0
    }

    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        canFocus?(indexPath) ?? false
    }

    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        shouldUpdateFocus?(context) ?? false
    }

    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        didUpdateFocus?(context, coordinator)
    }

    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        indexPathForPreferredFocusedView?()
    }

    /**
     * @abstract Called when the interaction begins.
     *
     * @param tableView  This UITableView.
     * @param indexPath  IndexPath of the row for which a configuration is being requested.
     * @param point      Location of the interaction in the table view's coordinate space
     *
     * @return A UIContextMenuConfiguration describing the menu to be presented. Return nil to prevent the interaction from beginning.
     *         Returning an empty configuration causes the interaction to begin then fail with a cancellation effect. You might use this
     *         to indicate to users that it's possible for a menu to be presented from this element, but that there are no actions to
     *         present at this particular time.
     */
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        contextMenuConfiguration?(indexPath, point) as? UIContextMenuConfiguration
    }

    /**
     * @abstract Called when the interaction begins. Return a UITargetedPreview to override the default preview created by the table view.
     *
     * @param tableView      This UITableView.
     * @param configuration  The configuration of the menu about to be displayed by this interaction.
     */
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        previewForHighlightingContextMenu?(configuration) as? UITargetedPreview
    }

    /**
     * @abstract Called when the interaction is about to dismiss. Return a UITargetedPreview describing the desired dismissal target.
     * The interaction will animate the presented menu to the target. Use this to customize the dismissal animation.
     *
     * @param tableView      This UITableView.
     * @param configuration  The configuration of the menu displayed by this interaction.
     */
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        previewForDismissingContextMenu?(configuration) as? UITargetedPreview
    }

    /**
     * @abstract Called when the interaction is about to "commit" in response to the user tapping the preview.
     *
     * @param tableView      This UITableView.
     * @param configuration  Configuration of the currently displayed menu.
     * @param animator       Commit animator. Add animations to this object to run them alongside the commit transition.
     */
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        willPerformPreviewAction?(configuration, animator)
    }

    /**
     * @abstract Called when the table view is about to display a menu.
     *
     * @param tableView       This UITableView.
     * @param configuration   The configuration of the menu about to be displayed.
     * @param animator        Appearance animator. Add animations to run them alongside the appearance transition.
     */
    @available(iOS 14.0, *)
    func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        willDisplayContextMenu?(configuration, animator)
    }

    /**
     * @abstract Called when the table view's context menu interaction is about to end.
     *
     * @param tableView       This UITableView.
     * @param configuration   Ending configuration.
     * @param animator        Disappearance animator. Add animations to run them alongside the disappearance transition.
     */
    @available(iOS 14.0, *)
    func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        willEndContextMenuInteraction?(configuration, animator)
    }
    
    
    
    // MARK: - ScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        flexTable?.scrollDelegate.didScroll?(scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        flexTable?.scrollDelegate.scrollViewDidZoom?(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        flexTable?.scrollDelegate.scrollViewWillBeginDragging?(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        flexTable?.scrollDelegate.scrollViewWillEndDragging?(scrollView, velocity, targetContentOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        flexTable?.scrollDelegate.scrollViewDidEndDragging?(scrollView, decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        flexTable?.scrollDelegate.scrollViewWillBeginDecelerating?(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        flexTable?.scrollDelegate.scrollViewDidEndDecelerating?(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        flexTable?.scrollDelegate.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        flexTable?.scrollDelegate.viewForZooming?(scrollView)
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        flexTable?.scrollDelegate.scrollViewWillBeginZooming?(scrollView, view)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        flexTable?.scrollDelegate.scrollViewDidEndZooming?(scrollView, view, scale)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        flexTable?.scrollDelegate.scrollViewShouldScrollToTop?(scrollView) ?? true
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        flexTable?.scrollDelegate.scrollViewDidScrollToTop?(scrollView)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        flexTable?.scrollDelegate.didChangeAdjustedContentInset?(scrollView)
    }
}



private var kDrFlexNeedLayoutAssociatedObjectHandle = 50_505_718
fileprivate extension UIView {
     
    /// 标记视图是否需要重新计算布局
    var dr_needLayout: Bool {
        set {
            objc_setAssociatedObject(self, &kDrFlexNeedLayoutAssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            objc_getAssociatedObject(self, &kDrFlexNeedLayoutAssociatedObjectHandle) as? Bool ?? false
        }
    }
    
}

extension UIView {
    
    func dr_resetWidth(_ width: CGFloat) {
        var frame = frame
        frame.origin = .zero
        frame.size.width = width
        self.frame = frame
    }
    
    func dr_resetSize(_ size: CGSize) {
        var frame = frame
        frame.origin = .zero
        frame.size = size
        self.frame = frame
    }
}


public struct DRFlexTableGroup {
    public let headerView: UIView?
    public let footerView: UIView?
    public let cellList: [UIView]
    
    public init(header: @autoclosure ()->UIView?, footer: @autoclosure ()->UIView?, cellList: @autoclosure ()->[UIView]){
        headerView = header()
        footerView = footer()
        self.cellList = cellList()
    }
}


public protocol DrCellEditing {
    var isEditing: Bool { get }
    func setEditing(_ isEditing: Bool, animated: Bool)
}
