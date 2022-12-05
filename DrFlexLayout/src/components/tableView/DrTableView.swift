//
//  DrTableView.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/12/4.
//

import UIKit

public class DrTableView: UIView, DrScrollViewTouchHook {
    
    let viewTag = 2016
    
    private let table: _TableView
    private var _tableViewDataSource: _DataSource!
    private var _tableViewDelegate: _Delegate!
    
    private var _dataSource: Any?
    /// 内部的UITableView（注意：请不要直接改变其相关的代理方法，否则内部将无法正确工作）
    public var innerTable: UITableView { table }
    /// 数据源
    public var dataSource: DrTableViewDataSource?
    
    /// cell高度，默认：0（对于相同高度的cell，设置该属性有利于提升计算高度的性能；<=0：自动计算高度）
    public var rowHeight: CGFloat = 0
    
    public init(style: UITableView.Style) {
        table = _TableView(frame: .zero, style: style)
        table.backgroundColor = .white
        table.estimatedRowHeight = 0
        table.estimatedSectionHeaderHeight = 0
        table.estimatedSectionFooterHeight = 0
        table.separatorStyle = .none
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        
        let header = UIView()
        header.frame = CGRect(x: 0, y: 0, width: 0, height: 0.0001)
        table.tableHeaderView = header
        table.tableFooterView = UIView()
        super.init(frame: .zero)
        addSubview(table)
        table.touchHook = self
        _tableViewDataSource = _DataSource(table: self)
        _tableViewDelegate = _Delegate(table: self)
    }
    
    required init?(coder: NSCoder) {
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
        if window != nil {
            table.dataSource = _tableViewDataSource
            table.delegate = _tableViewDelegate
        }
    }
    
    public func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        true
    }
    
    public func touchesShouldCancel(in view: UIView) -> Bool {
        view is UIControl
    }
    
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
}

// MARK: - tool
extension DrTableView {
    
    public func reload(needCleanCache: Bool = true) {
        if needCleanCache {
            dataSource?.cleanCache()
        }
        table.reloadData()
    }
    
    
    
    /// 设置cell选中style，目的是去掉cell点击后的选中背景
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
}


// MARK: - TableView Paramters
extension DrTableView {
    
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

// MARK: - TableView Method
extension DrTableView {
    
    /// default is NO. setting is not animated.
    public var isEditing: Bool {
        set {
            table.isEditing = newValue
//            setCellEditing(newValue, animated: false)
        }
        get {
            table.isEditing
        }
    }
    
    public func setEditing(_ editing: Bool, animated: Bool) {
        table.setEditing(editing, animated: animated)
//        setCellEditing(editing, animated: animated)
    }
}


// MARK: - DataSource
fileprivate class _DataSource: NSObject, UITableViewDataSource {
    
    weak var table: DrTableView?
    
    init(table: DrTableView) {
        self.table = table
        super.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        table?.dataSource?.numberOfSections ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        table?.dataSource?.numberOfRowsInSection(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewBuilder = table!.dataSource!.cellView(indexPath: indexPath)
        let cell: UITableViewCell
        if let _cell = tableView.dequeueReusableCell(withIdentifier: viewBuilder.reuseId) {
            cell = _cell
        }else {
            cell = UITableViewCell(style: .default, reuseIdentifier: viewBuilder.reuseId)
        }
        cell.contentView.backgroundColor = tableView.backgroundColor
        let cellView: UIView
        if let view = cell.contentView.viewWithTag(table!.viewTag) {
            let v = viewBuilder.builder(view)
            if v != view {
                // 未复用视图
                v.tag = table!.viewTag
                let height = table!.dataSource!.cellHeight(indexPath: indexPath, in: tableView)
                v.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: height)
                view.removeFromSuperview()
                cell.contentView.addSubview(v)
                cellView = v
            }else {
                cellView = view
            }
        }else {
            let view = viewBuilder.builder(nil)
            view.tag = table!.viewTag
            let height = table!.dataSource!.cellHeight(indexPath: indexPath, in: tableView)
            view.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: height)
            cell.contentView.addSubview(view)
            cellView = view
        }
        if cellView.isYogaEnabled {
            cellView.dr_flex.layoutByAsync()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        nil
    }
}

fileprivate class _Delegate: NSObject, UITableViewDelegate {
    
    weak var table: DrTableView?
    
    init(table: DrTableView) {
        self.table = table
        super.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath),
              let v = cell.contentView.viewWithTag(table!.viewTag) else {
            return
        }
        table?.dataSource?.click(view: v, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = table?.rowHeight, height > 0 else {
            return table?.dataSource?.cellHeight(indexPath: indexPath, in: tableView) ?? 0
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        table?.setCellSelectionStyle(cell: cell)
        guard let v = cell.contentView.viewWithTag(table!.viewTag) else {
            return
        }
        table?.dataSource?.willDisplay(view: v, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewBuilder = table?.dataSource?.headerView(section: section) else {
            return nil
        }
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: viewBuilder.reuseId)
        if header == nil {
            header = UITableViewHeaderFooterView(reuseIdentifier: viewBuilder.reuseId)
        }
        header?.contentView.backgroundColor = tableView.backgroundColor
        let headerView: UIView
        if let v = header?.contentView.viewWithTag(table!.viewTag) {
            let newView = viewBuilder.builder(v)
            if newView != v {
                // 未复用视图
                newView.tag = table!.viewTag
                let height = table!.dataSource!.headerHeight(section: section, in: tableView) ?? 0
                newView.frame = CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: height))
                v.removeFromSuperview()
                header?.contentView.addSubview(newView)
                headerView = newView
            }else {
                headerView = v
            }
        }else {
            headerView = viewBuilder.builder(nil)
            headerView.tag = table!.viewTag
            let height = table!.dataSource!.headerHeight(section: section, in: tableView) ?? 0
            headerView.frame = CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: height))
            header?.contentView.addSubview(headerView)
        }
        if headerView.isYogaEnabled {
            headerView.dr_flex.layoutByAsync()
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = table?.dataSource?.headerHeight(section: section, in: tableView), height > 0 {
            return height
        }
        switch tableView.style {
        case .grouped, .insetGrouped:
            return CGFloat.leastNonzeroMagnitude
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let viewBuilder = table?.dataSource?.footerView(section: section) else {
            return nil
        }
        var footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: viewBuilder.reuseId)
        if footer == nil {
            footer = UITableViewHeaderFooterView(reuseIdentifier: viewBuilder.reuseId)
        }
        footer?.contentView.backgroundColor = tableView.backgroundColor
        let footerView: UIView
        if let v = footer?.contentView.viewWithTag(table!.viewTag) {
            let newView = viewBuilder.builder(v)
            if newView != v {
                // 未复用视图
                newView.tag = table!.viewTag
                let height = table!.dataSource!.footerHeight(section: section, in: tableView) ?? 0
                newView.frame = CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: height))
                v.removeFromSuperview()
                footer?.contentView.addSubview(newView)
                footerView = newView
            }else {
                footerView = v
            }
        }else {
            footerView = viewBuilder.builder(nil)
            footerView.tag = table!.viewTag
            let height = table!.dataSource!.footerHeight(section: section, in: tableView) ?? 0
            footerView.frame = CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: height))
            footer?.contentView.addSubview(footerView)
        }
        if footerView.isYogaEnabled {
            footerView.dr_flex.layoutByAsync()
        }
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = table?.dataSource?.footerHeight(section: section, in: tableView), height > 0 {
            return height
        }
        switch tableView.style {
        case .grouped, .insetGrouped:
            return CGFloat.leastNonzeroMagnitude
        default:
            return 0
        }
    }
}
